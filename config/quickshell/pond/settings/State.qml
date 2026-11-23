pragma Singleton

import QtQuick
import "." as Settings
import "../bluetooth" as Bluetooth
import ".." as Shell
import Quickshell

// vicOS keeps only Pond's session overlay: session actions, Bluetooth and the
// tray. Settings pages are left out.
Singleton {
  id: root

  property bool opened: false
  property string outputName: ""
  signal opening
  property string pendingSessionAction: ""

  readonly property var sessionCommands: ({
    lock: ["pond-lock"],
    // hypridle locks before sleep (before_sleep_cmd, inhibit_sleep).
    suspend: ["systemctl", "suspend"],
    logout: ["uwsm", "stop"],
    reboot: ["systemctl", "reboot"],
    shutdown: ["systemctl", "poweroff"]
  })

  Timer {
    id: sessionActionDelay
    interval: Settings.Style.closeDuration
    onTriggered: {
      const command = root.sessionCommands[root.pendingSessionAction];
      root.pendingSessionAction = "";
      if (command) Quickshell.execDetached(command);
    }
  }

  function open(requestedOutputName) {
    sessionActionDelay.stop();
    pendingSessionAction = "";
    outputName = requestedOutputName || focusedOutputName();
    opening();
    opened = true;
  }

  function close() {
    opened = false;
  }

  function toggle(requestedOutputName) {
    const targetOutput = requestedOutputName || focusedOutputName();
    if (opened && outputName === targetOutput)
      close();
    else
      open(targetOutput);
  }

  function requestSessionAction(action) {
    if (!sessionCommands[action])
      return;
    pendingSessionAction = action;
    opened = false;
    sessionActionDelay.restart();
  }

  function openBluetooth() {
    const targetOutput = outputName || focusedOutputName();
    close();
    Bluetooth.State.requestPanel("open", targetOutput);
  }

  function focusedOutputName() {
    if (Shell.Compositor.focusedOutputName !== "")
      return Shell.Compositor.focusedOutputName;
    return Quickshell.screens.length ? Quickshell.screens[0].name : "";
  }
}
