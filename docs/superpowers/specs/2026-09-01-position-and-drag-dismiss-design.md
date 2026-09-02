# PopupKit — Position & Drag-to-Dismiss — Design Spec

Date: 2026-09-01
Status: Approved for planning
Builds on: `2026-09-01-popupkit-design.md` (v1, already implemented and committed)

## Purpose

PopupKit v1 shipped with a single presentation style: every popup type
appears centered. Reviewing PopupKit against the two most comparable
SwiftUI popup libraries already on `awesome-ios` (`exyte/PopupView`,
~4k stars; `Mijick/Popups`, ~1.8k stars) surfaced two real, headline
capabilities both of them offer that PopupKit doesn't: multiple
presentation positions (Mijick's first advertised feature) and
drag-to-dismiss (exyte's headline interaction). This spec adds both,
so PopupKit has a genuine, defensible answer to "why does this exist
next to more popular alternatives" beyond the accessibility gap already
identified (see v1 spec) — not to match either library's full feature
set (both also offer popup stacking/queueing, multiple presentation
strategies, and other capabilities explicitly out of scope here).

## Non-goals

- Popup stacking/queueing (Mijick's other headline feature) — explicitly
  decided against: higher architectural risk (ordering/animation
  choreography across layers) for less visual payoff than position or
  drag-to-dismiss, and it's a bigger departure from PopupKit's current
  one-popup-at-a-time model than either of the features below.
- Free-direction/Tinder-style drag dismissal — rejected in favor of
  single-axis drag matching each popup's position, to stay consistent
  with PopupKit's existing simple, discrete dismiss model.
- Multiple simultaneous presentation strategies (overlay vs. sheet vs.
  UIWindow, per exyte) — PopupKit stays overlay-only.
- Changing `PopupContent`'s case signatures — no new associated values
  on `.error`/`.success`/`.loading`/`.generic`. Position is additive via
  a computed property and an optional modifier parameter, not baked
  into the enum's call sites.

## PopupPosition

A new public enum:

```swift
public enum PopupPosition {
    case top
    case center
    case bottom
}
```

`.bottom` ships even though no `PopupContent` case defaults to it — it's
available for explicit override (e.g., someone building a bottom-toast
pattern), matching the same "sensible default, overridable" shape as
the rest of the API.

## Default position per type

Added to `PopupContent` as a new computed property, `defaultPosition:
PopupPosition`, following the same pattern as the existing
`isDismissibleByTapOutside` and `accessibilityLabel` computed
properties (no changes to the enum's cases themselves):

- `.error` → `.top` (transient notification — doesn't require the same
  blocking acknowledgment `.generic` does)
- `.success` → `.top` (transient notification)
- `.loading` → `.center` (represents blocking state)
- `.generic` → `.center` (represents a decision the user must make)

This gives a coherent semantic split: **top banner = "FYI, doesn't need
acknowledgment," centered = "needs your attention or a decision."**

## API change

`.popupKit(isPresented:content:)` gains one new optional parameter:

```swift
public func popupKit(
    isPresented: Binding<Bool>,
    content: PopupContent,
    position: PopupPosition? = nil
) -> some View
```

When `position` is `nil` (the common case, including every existing
call site in the example app and README), the modifier uses
`content.defaultPosition`. When set explicitly, it overrides. This is
fully additive — no existing call site needs to change.

## Drag-to-dismiss

- **Eligibility**: identical to `isDismissibleByTapOutside` — `.error`,
  `.success`, and `.generic` are draggable; `.loading` is not, matching
  its existing non-dismissible-by-any-gesture rule. No new eligibility
  concept is introduced; drag reuses the same computed property.
- **Direction**: matches the popup's resolved position — a
  top-positioned popup drags **up** to dismiss (the same direction it
  entered from); the centered `.generic` drags **down** (the common
  iOS "push it away" gesture). A `.bottom`-positioned popup (only
  reachable via explicit override, since no type defaults there) drags
  **down** to dismiss, mirroring `.top`'s "back where it came from"
  rule.
- **Mechanics**: standard `DragGesture`, tracking translation along the
  single allowed axis only. Dragging in the disallowed direction
  rubber-bands (resists, snaps back) rather than doing nothing or
  moving freely. Dismissal triggers when either the drag distance
  exceeds a threshold (a fixed point value, tuned during
  implementation against how the popup actually looks/feels — no
  magic number is being pre-committed here) or the gesture's predicted
  end translation (velocity-based "flick") exceeds a threshold,
  whichever happens first. On release without crossing either
  threshold, the popup animates back to its resting position.

## Position-aware transitions

Today's single transition (`.scale.combined(with: .opacity)`, applied
uniformly regardless of position) is replaced with a position-aware
one:

- `.top`: slide in/out from the top edge, combined with opacity
  (`.move(edge: .top).combined(with: .opacity)`)
- `.bottom`: slide in/out from the bottom edge, combined with opacity
- `.center`: keeps the existing scale + opacity transition

## Reduce Motion

Folded into this same effort since it touches the identical transition
code path (already agreed as a v1 accessibility follow-up, not new
scope): read `@Environment(\.accessibilityReduceMotion)` in
`PopupContainerView`. When enabled, all three transitions above
collapse to a plain opacity fade — no movement, no scaling.

## Testing

Unit-testable (pure logic, no view hosting required, same approach as
`isDismissibleByTapOutside`):
- `PopupContent.defaultPosition` returns the correct value per case.
- Drag-eligibility (reusing `isDismissibleByTapOutside`) is already
  tested — no new test needed there, but a test confirming the drag
  direction logic (a pure function mapping `PopupPosition` →
  dismiss-direction) is added.

Not unit-tested, consistent with the rest of the view layer:
- The actual `DragGesture` handling, rubber-banding, and transition
  animations — verified manually via the example app, same as the four
  base popup views were in v1.

## Example app & README impact

- The example app's existing four `.popupKit(...)` calls need no
  changes to keep compiling (the new parameter is optional), but the
  demo should be updated to actually show off position and
  drag-to-dismiss — otherwise this is the same mistake as v1's demo
  not exercising `PopupTheme` before the fix. At minimum: visibly
  demonstrate a top-banner popup and a drag-to-dismiss interaction
  (a screen recording/GIF of a drag dismiss is worth more here than
  another static screenshot).
- README needs its "Why" section extended to state position and
  drag-to-dismiss as capabilities, alongside the existing accessibility
  differentiation — all three together are the answer to "why this
  exists next to more popular alternatives."

## Out of Scope for This Spec

Popup stacking/queueing remains explicitly deferred (see Non-goals).
If it's ever picked up, it goes through its own brainstorming/spec/plan
cycle, same as this addition did.
