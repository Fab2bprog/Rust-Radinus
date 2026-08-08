// Leaving a window.
//
// A Radinus window is built once and **never destroyed**: leaving it hides it,
// and coming back shows it again. Destroying windows cost two separate faults
// (Fabrice, 25/07/2026) — rebuilding one under a label still being torn down
// crashed the application, and a list asked for again just after being closed
// came back as an empty grey panel, a dead window still answering. Hiding
// removes the race rather than racing better.
//
// The request is also posted to the next turn of the event loop, so the
// handler that asked for it has finished running and the dialog it may have
// been showing is really gone.

import { getCurrentWindow } from "@tauri-apps/api/window";

/// Hides this window once the current handler has finished running.
export function closeCurrentWindow(): void {
  setTimeout(() => {
    void getCurrentWindow().hide();
  }, 0);
}
