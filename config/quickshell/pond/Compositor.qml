pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Hyprland stand-in for Pond's NiriMsg: the focused output, workspace focus,
// window focus, and urgent window tracking for the sidebar and notifications.
Singleton {
  id: root

  readonly property string focusedOutputName: Hyprland.focusedMonitor?.name ?? ""
  property string activeAddress: ""
  property var urgentAddresses: ({})

  function normalizeAddress(address) {
    return String(address || "").replace(/^0x/i, "").toLowerCase();
  }

  function setUrgent(address, urgent) {
    const key = normalizeAddress(address);
    if (!key) return;
    if (urgent && !!urgentAddresses[key]) return;
    if (!urgent && !urgentAddresses[key]) return;
    const next = Object.assign({}, urgentAddresses);
    if (urgent) next[key] = true;
    else delete next[key];
    urgentAddresses = next;
  }

  function isUrgent(address) {
    const key = normalizeAddress(address);
    return key !== "" && !!urgentAddresses[key];
  }

  function hasUrgent(windows) {
    if (!windows) return false;
    for (let i = 0; i < windows.length; i++) {
      if (isUrgent(windows[i]?.address)) return true;
    }
    return false;
  }

  function dispatch(lua) { Hyprland.dispatch(lua); }

  function focusWorkspace(id) {
    if (id > 0) dispatch("hl.dsp.focus({ workspace = " + id + " })");
  }

  function focusWindow(address) {
    const hex = normalizeAddress(address);
    if (/^[0-9a-f]+$/i.test(hex)) {
      setUrgent(hex, false);
      dispatch("hl.dsp.focus({ window = \"address:0x" + hex + "\" })");
    }
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
      if (event.name === "urgent") {
        const addr = root.normalizeAddress(event.data);
        if (addr && addr !== root.activeAddress) root.setUrgent(addr, true);
      } else if (event.name === "activewindowv2") {
        const addr = root.normalizeAddress(event.data);
        root.activeAddress = addr;
        root.setUrgent(addr, false);
      } else if (event.name === "closewindow") {
        root.setUrgent(event.data, false);
      }
      if (["openwindow", "closewindow", "movewindowv2", "windowtitlev2"].includes(event.name))
        Hyprland.refreshToplevels();
    }
  }
}
