pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Hyprland stand-in for Pond's NiriMsg: the focused output, workspace focus
// and window focus for the sidebar and notifications.
Singleton {
  id: root

  readonly property string focusedOutputName: Hyprland.focusedMonitor?.name ?? ""

  function dispatch(lua) { Hyprland.dispatch(lua); }

  function focusWorkspace(id) {
    if (id > 0) dispatch("hl.dsp.focus({ workspace = " + id + " })");
  }

  function focusWindow(address) {
    const hex = String(address).replace(/^0x/, "");
    if (/^[0-9a-f]+$/i.test(hex))
      dispatch("hl.dsp.focus({ window = \"address:0x" + hex + "\" })");
  }

  function appMatches(appId, appName, desktopEntry) {
    function normalize(value) {
      return String(value || "").toLowerCase().replace(/\.desktop$/, "").replace(/[^a-z0-9]+/g, "");
    }
    const wanted = desktopEntry || appName;
    if (!appId || !wanted) return false;
    const entry = DesktopEntries.heuristicLookup(appId);
    const target = DesktopEntries.heuristicLookup(wanted);
    if (entry && target) return entry.id === target.id;
    return [appId, entry?.id, entry?.name].some(value => normalize(value) === normalize(wanted));
  }

  function focusApp(appName, desktopEntry) {
    const window = Hyprland.toplevels.values.find(t =>
        appMatches(t.lastIpcObject?.class, appName, desktopEntry));
    if (window) focusWindow(window.address);
    return !!window;
  }

  function iconFor(appId) {
    if (!appId) return "";
    const entry = appId && (DesktopEntries.heuristicLookup(appId)
        || DesktopEntries.heuristicLookup(appId.toLowerCase()));
    return Quickshell.iconPath(entry?.icon || appId.toLowerCase(), "application-x-executable");
  }

  // Window classes come from Hyprland's IPC snapshot, which is empty until
  // the first refresh.
  Component.onCompleted: Hyprland.refreshToplevels()
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (["openwindow", "closewindow", "movewindowv2", "windowtitlev2"].includes(event.name))
        Hyprland.refreshToplevels();
    }
  }
}
