//@ pragma Env QSG_RENDER_LOOP = threaded
import QtQuick
import Quickshell
import Quickshell.Io
import "battery" as Battery
import "calendar" as Calendar
import "fnpreview" as FnPreview
import "settings" as Settings
import "notifications" as Notifications

// Pond's desktop shell (github.com/bflycomputer/pond-interface), adapted for
// Hyprland. hypridle owns idle and pre-sleep locking, hyprpaper the wallpaper.
ShellRoot {
  id: root
  property bool expanded: true

  Shortcuts {}

  IpcHandler {
    target: "sidebar"
    function toggle() { root.expanded = !root.expanded; }
  }

  IpcHandler {
    target: "settings"
    function toggle() { Settings.State.toggle(); }
    function open() { Settings.State.open(""); }
    function close() { Settings.State.close(); }
  }

  IpcHandler {
    target: "fnPreview"
    function open() { FnPreview.State.open(); }
    function close() { FnPreview.State.close(); }
    function toggle() { FnPreview.State.toggle(); }
  }

  Variants {
    model: Quickshell.screens
    delegate: Scope {
      required property var modelData
      Sidebar {
        id: sidebar
        screen: modelData
        expanded: root.expanded
        onToggleRequested: root.expanded = !root.expanded
      }
      Notifications.ToastWindow { id: toast; bar: sidebar }
      Notifications.CenterWindow { bar: sidebar }
      Calendar.Window { bar: sidebar }
      Battery.Window { bar: sidebar }
      Battery.Notification { bar: sidebar; above: toast }
      PanelDismissWindow { bar: sidebar }
      Settings.Window { menuScreen: modelData }
      FnPreview.Window { targetScreen: modelData }
    }
  }
}
