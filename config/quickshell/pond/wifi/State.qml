pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// vicOS replacement for Pond's NetworkManager-backed Wi-Fi state. Link state
// comes from systemd-networkd (networkctl); Wi-Fi client support is left out
// until a machine runs NetworkManager. Rates read the kernel's byte counters.
Singleton {
  id: root

  property var links: []
  readonly property var wiredLinks: links.filter(l => l.Type === "ether"
      && (l.OperationalState === "routable" || l.OperationalState === "degraded"))
  readonly property bool wiredConnected: wiredLinks.length > 0
  readonly property bool wifiConnected: false
  // Unknown online state does not mean no internet.
  readonly property bool internetUnavailable: wiredConnected
      && wiredLinks.every(l => l.OnlineState === "offline")
  readonly property string statusIcon: wiredConnected
      ? (internetUnavailable ? "wifi/ethernet-no-internet.svg" : "wifi/ethernet.svg")
      : "wifi/disconnected.svg"
  readonly property string rateDevice: wiredConnected ? wiredLinks[0].Name : ""
  readonly property string uploadRate: txCounter.rate
  readonly property string downloadRate: rxCounter.rate
  property var rateConsumers: []
  readonly property bool samplingRates: rateConsumers.length > 0 && rateDevice !== ""

  function setRateConsumer(consumer, active) {
    const next = rateConsumers.filter(item => item !== consumer);
    if (active)
      next.push(consumer);
    rateConsumers = next;
  }

  function formatRate(bytesPerSecond) {
    const value = Math.max(0, Number(bytesPerSecond) || 0) * 8;
    if (value >= 1e9)
      return (value / 1e9).toFixed(value >= 1e10 ? 0 : 1) + "Gb";
    if (value >= 1e6)
      return (value / 1e6).toFixed(value >= 1e7 ? 0 : 1) + "Mb";
    if (value >= 1e3)
      return (value / 1e3).toFixed(value >= 1e4 ? 0 : 1) + "Kb";
    return Math.round(value) + "b";
  }

  Process {
    id: linkQuery
    command: ["networkctl", "list", "--json=short"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.links = JSON.parse(text).Interfaces || [];
        } catch (error) {
          console.warn("networkctl:", error);
        }
      }
    }
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    onTriggered: linkQuery.running = true
  }

  component Counter: FileView {
    required property string counterName
    property real previous: -1
    property double previousTime: 0
    property string rate: "0b"
    path: root.samplingRates
        ? "/sys/class/net/" + root.rateDevice + "/statistics/" + counterName : ""
    printErrors: false
    onPathChanged: { previous = -1; previousTime = 0; rate = "0b"; }
    onLoaded: {
      const bytes = Number(text().trim());
      if (!root.samplingRates || !Number.isFinite(bytes)) return;
      const now = Date.now();
      if (previous >= 0)
        rate = root.formatRate((bytes - previous) / Math.max(0.05, (now - previousTime) / 1000));
      previous = bytes;
      previousTime = now;
    }
  }
  Counter { id: txCounter; counterName: "tx_bytes" }
  Counter { id: rxCounter; counterName: "rx_bytes" }

  Timer {
    interval: 1000
    repeat: true
    running: root.samplingRates
    onTriggered: { txCounter.reload(); rxCounter.reload(); }
  }
}
