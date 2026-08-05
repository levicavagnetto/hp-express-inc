# Cognito Forms Scroll Capture Issue

## Summary
When the Cognito form is embedded on the application page, mouse/trackpad/touch scrolling stops working for the parent page whenever the mouse is hovering over the embedded form area. The desired behavior is that the Cognito form is rendered as a full, non-embedded-scrolling form (so inner scrolling is undesirable) and that scroll input while over the form is forwarded to the parent page instead of being captured by the form.

This document summarizes the current investigation, what was changed, reproduction steps, analysis of root causes, non-hacky options, what was implemented during initial remediation, and recommended next steps and tests for hand-off to another assistant or developer.

---

## Environment
- Project: HPExpressInc (Flutter web)
- Files of interest:
  - `lib/apply_screen.dart` — registers platform view iframes for Cognito forms and listens for postMessage events (scroll & height updates).
  - `lib/config.dart` — builds `srcdoc` HTML used as the iframe `srcdoc` and injects a forwarder script for wheel/touch and height messaging.
- Cognito embed: uses `https://www.cognitoforms.com/f/seamless.js` script via `seamless` embed.

---

## Reproduction Steps
1. Build and open the app as Flutter Web and navigate to the Apply/Forms page.
2. Hover the mouse over the Cognito form area (the embedded form) and attempt to scroll using mouse wheel, trackpad, or touch gestures.
3. Observe that the parent page (the full page / SingleChildScrollView) does not scroll while the pointer is over the form area.

---

## Observed Behavior
- Scrolling fails to move the parent page when the cursor is over the embedded Cognito form.
- The Cognito form itself is intended to be full-page (no inner scrollbars) — that is correct and should remain so.

## Expected Behavior
- The Cognito form remains visually full-size (no inner scrollable viewport), but the parent page should accept scroll input when the user scrolls over the form area.

---

## What I inspected
- `lib/config.dart` contains `cognitoFormEmbedHtml(...)` which returns an `srcdoc` HTML document with an injected `_scrollForwarderScript`. That script posts messages to `window.parent`:
  - `COGNITO_SCROLL` with `{ deltaY }` on `wheel` / `touchmove` events
  - `COGNITO_HEIGHT` periodically and on DOM mutations to let the parent size the iframe
- `lib/apply_screen.dart` registers platform views (iframes) with `ui_web.platformViewRegistry` and sets `iframe.srcdoc` to the value returned by `AppConfig.cognitoFormEmbedHtml(...)`.
- `lib/apply_screen.dart` listens for incoming messages from the iframe and updates the parent `ScrollController` accordingly.
- I fetched the `seamless.js` script and inspected it — it mounts the form in the same `srcdoc` document (i.e., not necessarily creating a nested cross-origin iframe in the embed document) and uses a handshake/proxying mechanism when using different embed contexts.

---

## Analysis / Root cause possibilities
1. If `seamless.js` mounts the form inline in the `srcdoc` document, the forwarder script placed in `srcdoc` can capture `wheel` and touch events and post them to the parent. That approach should work but is sensitive to:
   - Event listener options (`capture` vs bubble), ordering, and whether Cognito itself attaches handlers that call `preventDefault()` before the forwarder gets the event.
   - Browser differences (wheel vs mousewheel vs DOMMouseScroll, trackpad delta scaling, and passive event listeners on touch).
2. If `seamless.js` or Cognito creates an additional nested (cross-origin) iframe inside the `srcdoc` at runtime, the forwarder inside `srcdoc` would not observe wheel/touch events occurring inside that nested iframe. In that scenario forwarding is not possible from `srcdoc` and other approaches are needed (overlay forwarder, Cognito config, or different embed method).

Based on the inspected `seamless.js` code and behavior, it generally mounts inline by default for the `seamless` embed method; however, specific embed contexts or Cognito internals can create nested iframes in some embed modes.

---

## Non-hacky options considered
1. Harden the postMessage bridge (forward wheel/touch events from `srcdoc` to parent) — clean and controllable if the form is mounted inline (recommended first approach).
2. Make the embedded document non-scrollable and size the iframe to the full form height (rely on `COGNITO_HEIGHT` messages) so the parent handles all scrolling — nearly ideal when measuring height is reliable.
3. Use Cognito embed options (seamless or inline) if the API supports a mode that guarantees inline mounting or exposes lifecycle hooks (less code, preferable if available).
4. If cross-origin nested iframe exists and cannot be avoided, use a transparent wheel-capturing overlay in the parent that forwards wheel events to the parent scroll controller (works but is more fragile).
5. Provide keyboard / UI scroll affordances (page up/down buttons) as a fallback (least favored UX).

---

## What I changed (initial remediation)
These are the changes applied in the repository in order to harden the forwarding approach:

- `lib/config.dart` — strengthened the `_scrollForwarderScript`:
  - Added `capture: true` for `wheel` and `touch` listeners so they receive events before most other listeners.
  - Added handlers for legacy event names: `mousewheel` and `DOMMouseScroll` to improve compatibility with different browsers and hardware.
  - Kept passive listeners for touch/wheel to avoid interfering with default touch handling and to avoid causing scrolling jank; used `capture: true` to ensure earlier observation.

- `lib/apply_screen.dart` — made message handling more robust:
  - Switched from assigning `window.onmessage = ...` to using `window.addEventListener('message', ...)` via the JS interop layer. This avoids overwriting other message handlers and is more robust in multi-script pages.

These changes were applied with small, focused edits to the two files. The goal was not to change UX (no inner-scroll) but to improve reliability of forwarded scroll events.

---

## Recommended next steps (for the assistant receiving this issue)
1. Verify runtime DOM structure in a browser when the Cognito form is mounted:
   - Check whether `seamless.js` results in the form being rendered inline into the `srcdoc` document or if it creates a nested iframe at runtime.
   - If it mounts inline, the forwarder approach is appropriate — test event capture across browsers (Chrome, Firefox, Safari) and with trackpads/touch.
   - If nested iframe is present, consider using Cognito embed configuration to avoid nested iframe or implement an overlay forwarder as a measured fallback.

2. Manual test checklist:
   - Build and run Flutter Web locally, open the form page.
   - Hover over the form area and scroll with mouse wheel, trackpad (two-finger), and touch (mobile). Confirm parent page scrolls.
   - Resize the form and ensure `COGNITO_HEIGHT` messages update the iframe height and parent layout.

3. If issues remain on specific browsers:
   - Try removing `passive: true` on the problematic handler temporarily to verify if `preventDefault()` is interfering (but avoid shipping non-passive touch handlers unless necessary — can hurt performance).
   - Consider adding a small synthetic test harness inside the `srcdoc` temporarily that logs or visually indicates received wheel/touch events to confirm listener order.

4. If nested cross-origin iframe blocks forwarding:
   - Investigate whether Cognito `seamless` embed has an option to render inline or provide scroll/handshake APIs.
   - If no option exists, implement a focused overlay element in the parent around the iframe that captures wheel events and forwards them to the parent `ScrollController`. The overlay must: capture wheel, but allow clicks to pass through (use pointer-events toggling or temporarily disable overlay on pointerdown). This is more complex and should be a last resort.

---

## Tests to run (commands / manual)
- Manual run (local):

```bash
# Build and serve Flutter web
flutter build web
# Then host web/build/index.html with a static server, or use `flutter run -d chrome` in dev.
flutter run -d chrome
```

- In the browser devtools console:
  - Inspect the iframe element created by the application and check its `contentDocument` and children (for `srcdoc` rendering) to see if an inner iframe exists.
  - In the `srcdoc` document (if accessible), check for the presence of the `_scrollForwarderScript` and test whether `wheel`/`touchmove` listeners fire.

---

## Helpful code references
- `lib/config.dart` — contains `cognitoFormEmbedHtml` and the `_scrollForwarderScript` executed inside `srcdoc`.
- `lib/apply_screen.dart` — creates the `HtmlElementView` platform views and listens for `message` events to adjust the parent `ScrollController`.

---

## Acceptance criteria for a final fix
- While hovering over the Cognito form, the parent page scrolls normally in all target browsers and input devices (mouse wheel, trackpad, touch), and the Cognito form remains full-size with no inner scrolling.
- No perceptible performance regressions are introduced by new listeners.
- The solution is maintainable and avoids brittle overlays unless strictly required.

---

If you want, I can now produce a small checklist for the receiving assistant to run in the browser and gather live evidence (DOM snapshots, console logs, screenshots) to confirm whether the embed actually creates a nested iframe at runtime. That data will determine whether we proceed with the postMessage approach or a fallback overlay approach.
