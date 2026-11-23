pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".." as Shell

Singleton {
  id: root
  property bool ipcActive: false
  property bool keydVisible: false
  property bool fnLocked: false
  readonly property bool active: ipcActive || keydVisible
  readonly property int barHeight: 48
  // Keep the bar visible briefly after releasing Fn.
  readonly property int hideDelayMs: 500

  function showsOnScreen(screen) {
    if (!screen) return false;
    const hasLaptop = Quickshell.screens.some(s => s.name.startsWith("eDP"));
    if (hasLaptop) return screen.name.startsWith("eDP");
    return Shell.Compositor.focusedOutputName === ""
        || screen.name === Shell.Compositor.focusedOutputName;
  }

  function open() { ipcActive = true; }
  function close() { ipcActive = false; }
  function toggle() { ipcActive = !ipcActive; }

  function applyState(raw) {
    try {
      const state = JSON.parse(raw);
      const nextPreview = !!state.preview;
      root.fnLocked = !!state.fnLock;
      if (nextPreview) {
        hideDelay.stop();
        root.keydVisible = true;
      } else if (root.keydVisible) {
        hideDelay.restart();
      }
    } catch (_) {}
  }

  // Read-only state published by the root-only fn-preview-state bridge.
  // Stays silent on machines without the file.
  FileView {
    id: stateFile
    path: "/run/fn-preview/state"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyState(text())
  }

  Timer {
    id: hideDelay
    interval: root.hideDelayMs
    onTriggered: root.keydVisible = false
  }
}
