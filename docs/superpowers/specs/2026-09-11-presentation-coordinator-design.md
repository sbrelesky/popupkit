# Presentation Coordinator — Design Spec

Date: 2026-09-11
Status: Approved for planning

## Purpose

Right now, every `.popupKit(isPresented:content:)` call site is a fully
independent `PopupKitModifier` instance with its own binding and its own
overlay. A real app typically attaches several of these to one view (one
for `.error`, one for `.success`, one for `.loading`, etc. — exactly like
`PopupKitExample`'s `ContentView` does). Nothing prevents two of them from
being `isPresented == true` at the same time — e.g. a loading popup is up
when a network call fails and the error popup also becomes presented before
the loading flag gets cleared. When that happens, SwiftUI simply renders
both `PopupContainerView` overlays stacked, each with its own dimming
scrim and its own `.accessibilityAddTraits(.isModal)`, completely
uncoordinated.

This was flagged by an outside developer (Dan Fruhman) who read the source
directly and asked what PopupKit does in this case. The honest answer at
time of writing is: none of queue, replace, or drop — it's simply
unhandled. This spec adds a presentation coordinator that enforces a
replace policy across independent `.popupKit` call sites, closing that gap.

## Non-goals

- **Queueing.** A second popup replaces the first; it never waits to show
  after the first is dismissed. Queueing means a user can end up seeing a
  stale error about something they've already navigated past.
- **A configurable policy.** Replace is the only behavior. No API to
  choose queue vs. replace vs. drop — that's speculative flexibility no
  one has asked for.
- **A public API change.** `.popupKit(isPresented:content:position:)`
  keeps its exact current signature. The coordinator is an internal
  implementation detail, not a public type — no one calling PopupKit
  today needs to change anything.
- **A way to inspect coordinator state from outside the library.** No
  public "is something else currently showing" query API.

## Architecture

One new internal type, `PopupPresentationCoordinator`, an `ObservableObject`
(not the `@Observable` macro — that would require bumping the minimum
platform to iOS 17/macOS 14, and there's no other reason to move the floor
off iOS 16 for this):

```swift
final class PopupPresentationCoordinator: ObservableObject {
    private var activeToken: UUID?
    private var activeDismiss: (() -> Void)?

    func present(token: UUID, dismiss: @escaping () -> Void) {
        if let activeToken, activeToken != token {
            activeDismiss?()
        }
        activeToken = token
        activeDismiss = dismiss
    }

    func clear(token: UUID) {
        if activeToken == token {
            activeToken = nil
            activeDismiss = nil
        }
    }
}
```

It's injected via a new internal `EnvironmentValues` key (same pattern as
the existing, public `popupTheme` key, but this one is not exposed
publicly):

```swift
private struct PopupPresentationCoordinatorKey: EnvironmentKey {
    static let defaultValue = PopupPresentationCoordinator()
}

extension EnvironmentValues {
    var popupPresentationCoordinator: PopupPresentationCoordinator {
        get { self[PopupPresentationCoordinatorKey.self] }
        set { self[PopupPresentationCoordinatorKey.self] = newValue }
    }
}
```

Because `defaultValue` is a single shared instance, every `.popupKit` call
site in an app coordinates through the same coordinator by default, with
zero setup required — which is exactly what's needed to fix the loading +
error scenario out of the box. (Since the key isn't public, there's no
supported way to inject a different coordinator instance for a
deliberately-separate popup domain in v1 — not needed for this fix, and
easy to add later without breaking anything if it ever comes up.)

## Changes to `PopupKitModifier`

Add a stable per-instance identity and hook into presentation changes:

```swift
private struct PopupKitModifier: ViewModifier {
    @Binding var isPresented: Bool
    let content: PopupContent
    let position: PopupPosition?
    @Environment(\.popupTheme) private var theme
    @Environment(\.popupPresentationCoordinator) private var coordinator
    @State private var token = UUID()

    func body(content base: Content) -> some View {
        base.overlay {
            if isPresented {
                PopupContainerView(
                    content: content,
                    theme: theme,
                    position: position ?? content.defaultPosition
                ) {
                    isPresented = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
        .onChange(of: isPresented) { newValue in
            if newValue {
                coordinator.present(token: token) { isPresented = false }
            } else {
                coordinator.clear(token: token)
            }
        }
    }
}
```

Use the single-closure `.onChange(of:perform:)` form, not the two-value
form added in iOS 17 — the single-closure form is deprecated under newer
SDKs but still compiles and works, and the project's iOS 16 floor rules
out the newer form. The deprecation warning is expected and fine to leave.

`clear`'s token check means a popup dismissing normally never clears a
*different* popup that has since become active — only a token clearing
itself is honored.

## Data flow / walkthrough of the fix

1. Loading popup presents: its modifier's `isPresented` flips `true` →
   `onChange` fires → `coordinator.present(token: loadingToken, dismiss: { loadingIsPresented = false })`.
   No other popup is active, so nothing gets dismissed. Coordinator now
   tracks `loadingToken` as active.
2. Network call fails; error popup presents: its `isPresented` flips
   `true` → `onChange` fires → `coordinator.present(token: errorToken, dismiss: {...})`.
   `activeToken` (`loadingToken`) differs from `errorToken`, so the
   coordinator calls the loading popup's stored dismiss closure —
   `loadingIsPresented` flips to `false` for it, and it animates out via
   the existing `.animation(.easeInOut(duration: 0.2))`. Coordinator now
   tracks `errorToken` as active.
3. User dismisses the error popup normally: `isPresented` flips `false` →
   `onChange` fires → `coordinator.clear(token: errorToken)`. Since
   `errorToken` was the active one, the coordinator's state clears
   completely.

## Implementation risk to verify early

Calling `activeDismiss?()` from inside one modifier's `.onChange` mutates
a *different* view's `@Binding` during that handler. This is a supported
SwiftUI pattern (`.onChange` is an approved place to make further state
changes), but it should be the first thing checked once implementation
starts — if SwiftUI logs a "Modifying state during view update" warning
in practice, wrap the dismiss call in `DispatchQueue.main.async` as the
fix. Don't assume either way without running it.

## Testing

The coordinator's logic is pure and testable without any SwiftUI view
involved, matching the existing test suite's style (`PopupThemeTests`,
`PopupContentTests`, `PopupPositionTests` are all pure-logic tests, no
view-hosting):

- `test_present_firstToken_becomesActive` — no dismiss called (nothing
  else was active)
- `test_present_secondToken_dismissesFirst` — the first token's dismiss
  closure is invoked exactly once
- `test_clear_activeToken_clearsState` — a subsequent `present` for the
  same token that was just cleared doesn't dismiss anything (proves the
  active state actually cleared, not just went stale)
- `test_clear_staleToken_isNoOp` — clearing a token that isn't the
  currently-active one has no effect on the actually-active one

No new view-level tests — consistent with the project's existing testing
depth (logic layer only, not SwiftUI rendering).

## Example app & README impact

No change required to `PopupKitExample` — the fix is entirely invisible
at the call-site level, which is the point. Worth one line in the
README's "Position & drag-to-dismiss" area or a new short section noting
that presenting a second popup while one is already showing replaces it
rather than stacking — that's now a real, truthful behavior claim, not
an assumption.
