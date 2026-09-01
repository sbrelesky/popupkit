# PopupKit — Design Spec

Date: 2026-09-01
Status: Approved for planning

## Purpose

A SwiftUI-native library for presenting branded modal popups (error,
success, loading, and generic/confirmation), extracted from a pattern
Shane has hand-built from scratch in three separate past apps (Hermes,
Impromptu, Wedding Bettors), each time with its own name and its own
UIKit-based implementation. Every option in `awesome-ios`'s Popup
category is UIKit-era; there is currently no widely-known SwiftUI-native
equivalent.

Primary goal: a portfolio-quality pinned repo demonstrating the ability
to recognize a repeated in-house pattern and generalize it into a clean,
reusable public API — a senior-level signal distinct from a one-off demo
project. Secondary goal (does not drive design decisions): eventual
submission to a curated list such as `awesome-ios`.

## Non-goals (v1)

- UIKit interop / UIViewController wrapper — SwiftUI-only for v1.
- Popup queueing or stacking multiple simultaneous popups — one popup
  at a time, matching `.alert`/`.sheet` idiom.
- Per-call visual overrides — all styling flows through one injected
  theme, not per-invocation parameters.
- CocoaPods/Carthage distribution — Swift Package Manager only.

## Platform & Distribution

- SwiftUI-only, no UIKit dependency.
- Distributed as a Swift Package (SPM). Minimum platform version to be
  set during implementation based on the SwiftUI APIs actually used
  (e.g. if `.presentationDetents` or similar recent APIs are used,
  floor accordingly — otherwise default to a broadly-compatible floor
  like iOS 16).
- License: MIT.

## Popup Types (v1)

Four types, matching what Shane has independently rebuilt three times:

1. **Error** — icon, message, single dismiss/acknowledge action.
2. **Success** — icon, message, auto-dismiss or explicit dismiss.
3. **Loading** — indeterminate progress indicator, optional message,
   no user-initiated dismissal (see Dismiss Behavior below).
4. **Generic** — title, message, and one or two custom-labeled actions
   (confirmation/decision use case, e.g. "Cancel" / "Confirm").

## API Shape

Modifier-based, one popup presented at a time, following the same
idiom as SwiftUI's built-in `.alert` and `.sheet`:

```swift
someView
    .popupKit(isPresented: $showError, content: .error(message: "..."))
```

The exact parameter shape (a single `PopupContent` enum with associated
values per type vs. one modifier per type) is an implementation detail
to be resolved during planning — the constraint from this spec is: one
binding drives presentation, call sites read like native SwiftUI
modifiers, and only one popup can be presented at a time per modifier
attachment.

## Theming

A single injectable `PopupTheme` value (colors, fonts, corner radius,
icon set) configured once — via `View.environment(\.popupTheme, ...)`
or an explicit init parameter, whichever proves cleaner during
implementation — rather than customized per call. Ships with a
sensible default theme (system colors, SF Symbols) so the library works
out of the box with zero configuration, and can be re-themed app-wide
in one place.

## Dismiss Behavior

- **Error, Success, Generic**: dismissible via an explicit action
  button and via tap-outside-to-dismiss.
- **Loading**: not dismissible by the user (no tap-outside, no close
  button) — it represents a blocking async operation and should only
  clear when the presenting code sets `isPresented` to `false`.

## Accessibility

All four popup types must be properly labeled for VoiceOver (meaningful
`accessibilityLabel`s, and the popup content should be announced when
presented). This is a v1 requirement, not a stretch goal — a public
library with broken accessibility undercuts the "well-engineered"
signal this repo exists to demonstrate.

## Example App

The repo includes a minimal SwiftUI example app target that presents
each of the four popup types on demand (e.g. one button per type).
This is the primary source for the README's screenshot/GIF and
supports eventual `awesome-ios` submission, which expects a
demonstrable example.

## Testing

Unit tests covering the presentation/state logic (e.g. binding
behavior, that the correct content renders for a given type, dismiss
behavior per type) — not full UI/snapshot testing. Scope is "enough to
show testing discipline," not exhaustive coverage.

## Repository & Commit Workflow

- New standalone git repo at
  `/Users/shane/Desktop/Projects/Public Repos/popupkit` (already
  initialized).
- Kept **private** on GitHub during development; visibility flipped to
  public once the example app, README, and tests are in reasonable
  shape. This mirrors the pattern already used for `Wedding-Bettors`
  and `WeatherUI`.
- Commit directly to `main`, no PR ceremony (solo project) — but commit
  in small, logical, descriptively-messaged units as each piece is
  built (theme config, each popup type's view, the view modifier, the
  example app, tests, README) rather than one large commit at the end.
  The commit history is itself part of the portfolio artifact once this
  goes public, the same way a squashed "Initial commit" was flagged as
  a weaker signal for several of Shane's older repos during the GitHub
  presence audit.
- Naming: `PopupKit` is a working name only. Several small, low-traction
  repos already exist under this name on GitHub (none with real
  traction), so it may be renamed before or after going public —
  GitHub redirects the old name automatically, so this is low-stakes
  and does not block starting implementation under this name.

## Out of Scope for This Spec

This spec covers `PopupKit` only. The Empty/Loading/Error State Kit
(the second library Shane wants to build) is a separate subsystem and
will go through its own brainstorming/spec/plan cycle once this one is
implemented or well underway.
