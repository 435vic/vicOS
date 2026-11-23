import QtQuick
import Quickshell
import Quickshell.Wayland
import "audio" as Audio
import "bluetooth" as Bluetooth
import "settings" as Settings
import "wifi" as Wifi
import "calendar" as Calendar
import "media" as Media
import "notifications" as Notifications
import "workspaces" as Workspaces

PanelWindow {
  id: root
  required property bool expanded
  property string popup: ""
  property real collapseProgress: expanded ? 0 : 1
  signal toggleRequested
  readonly property real cardWidth: Theme.lerp(Theme.sidebarCardExpandedWidth,
      Theme.sidebarCardCollapsedWidth, Theme.collapseWidth(collapseProgress))
  readonly property real notificationCardCenterY: mainStack.y + notificationCard.y + 24

  readonly property real panelX: Theme.sidebarOuterMargin + cardWidth + Theme.sidebarCardGap
  readonly property bool panelOpen: wifiPanel.opened || audioPanel.opened || bluetoothPanel.opened
  readonly property var activePanel: wifiPanel.opened ? wifiPanel : audioPanel.opened ? audioPanel : bluetoothPanel.opened ? bluetoothPanel : null
  property string pendingPanel: ""
  readonly property var panels: ({wifi: wifiPanel, audio: audioPanel, bluetooth: bluetoothPanel})

  function dismissPanels() {
    panelSwitchDelay.stop();
    pendingPanel = "";
    for (const panel of Object.values(panels)) panel.closeAll();
  }

  function togglePanel(name) {
    const panel = panels[name];
    if (!panel) return;
    const wasOpen = panel.opened;
    const wasVisible = Object.values(panels).some(item => item.visible);
    dismissPanels();
    if (wasOpen) return;
    Settings.State.close();
    popup = "";
    Notifications.State.closePanel();
    if (wasVisible) {
      pendingPanel = name;
      panelSwitchDelay.restart();
    } else panel.open();
  }

  function togglePopup(name) {
    dismissPanels();
    Notifications.State.closePanel();
    popup = popup === name ? "" : name;
  }

  Timer {
    id: panelSwitchDelay
    interval: 200
    onTriggered: {
      const panel = root.panels[root.pendingPanel];
      if (panel) panel.open();
      root.pendingPanel = "";
    }
  }

  Connections {
    target: Settings.State
    function onOpening() {
      root.dismissPanels();
      root.popup = "";
      Notifications.State.closePanel();
    }
  }
  Connections {
    target: Notifications.State
    function onPanelOpenChanged() { if (Notifications.State.panelOpen) root.popup = ""; }
  }
  Connections {
    target: Bluetooth.State
    function onPanelCommand(command, outputName) {
      if (outputName !== root.screen.name) return;
      if (command === "close") bluetoothPanel.closeAll();
      else if (command === "toggle" || !bluetoothPanel.opened) root.togglePanel("bluetooth");
    }
  }
  Connections {
    target: Audio.State
    function onKeyboardOutputVolumeChanged(value) {
      if (Compositor.focusedOutputName === "" || root.screen.name === Compositor.focusedOutputName)
        controls.showKeyboardVolume();
    }
  }

  color: "transparent"
  BackgroundEffect.blurRegion: Theme.translucent ? cardBlur : null
  onHeightChanged: cardBlur.changed()
  Region {
    id: cardBlur
    regions: [timeCard.blurRegion, workspacesCard.blurRegion, mediaCard.blurRegion,
      notificationCard.blurRegion, controls.blurRegion,
      wifiPanel.blurRegion, audioPanel.blurRegion, bluetoothPanel.blurRegion]
  }
  // Always wide enough for the Wi-Fi, sound and Bluetooth panels; only the
  // input area shrinks. Upstream resizes the surface as panels open and close,
  // but Hyprland then shows the previous buffer squeezed into the new size for
  // a frame.
  implicitWidth: Math.ceil(Theme.sidebarOuterMargin + Theme.sidebarCardExpandedWidth
      + Theme.sidebarCardGap + Math.max(wifiPanel.width, audioPanel.width, bluetoothPanel.width) + 67)
  mask: Region {
    width: root.panelOpen ? root.implicitWidth : Math.ceil(Theme.sidebarOuterMargin + Math.max(root.cardWidth,
        workspacesCard.width, mediaCard.width, controls.width) + 8)
    height: root.height
    // Let the background receive clicks between the card stacks.
    Region {
      y: Math.ceil(mainStack.y + mainStack.height)
      width: root.width
      height: Math.max(0, Math.floor(bottomStack.y) - y)
      intersection: Intersection.Subtract
    }
    // Region.item can retain the opening animation's scaled bounds and leave
    // the close button outside the input mask. Track the panel bounds directly.
    Region {
      x: root.activePanel ? root.activePanel.x : 0
      y: root.activePanel ? root.activePanel.y : 0
      width: root.activePanel ? root.activePanel.width : 0
      height: root.activePanel ? root.activePanel.height : 0
    }
  }
  anchors { left: true; top: true; bottom: true }
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "pond-sidebar"
  WlrLayershell.keyboardFocus: panelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Normal
  exclusiveZone: Theme.sidebarOuterMargin + (expanded
      ? Theme.sidebarCardExpandedWidth : Theme.sidebarCardCollapsedWidth)
  Behavior on collapseProgress { Motion {} }

  Column {
    id: mainStack
    x: Theme.sidebarOuterMargin
    y: Theme.sidebarOuterMargin
    spacing: Theme.sidebarCardGap

    Calendar.Clock {
      id: timeCard
      width: root.cardWidth
      collapseProgress: root.collapseProgress
      onClicked: root.togglePopup("calendar")
      onBatteryClicked: root.togglePopup("battery")
    }

    Workspaces.Viewer {
      id: workspacesCard
      screen: root.screen
      collapseProgress: root.collapseProgress
      maximumHeight: Math.max(64,
          bottomStack.y - Theme.sidebarCardGap - mainStack.y
          - timeCard.height - mediaCard.height - notificationCard.height
          - Theme.sidebarCardGap * (2 + (mediaCard.visible ? 1 : 0)))
    }

    Media.Player {
      id: mediaCard
      collapseProgress: root.collapseProgress
    }

    Notifications.SidebarCard {
      id: notificationCard
      width: root.cardWidth
      collapseProgress: root.collapseProgress
      onPanelRequested: { root.dismissPanels(); Notifications.State.togglePanel(root.screen.name); }
    }
  }

  TapHandler {
    enabled: root.panelOpen
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    gesturePolicy: TapHandler.DragThreshold
    property var panelAtPress: null
    onPressedChanged: if (pressed) panelAtPress = root.activePanel
    onTapped: eventPoint => {
      const panel = root.activePanel;
      if (!panel || panel !== panelAtPress) return;
      const point = panel.mapFromItem(null, eventPoint.scenePosition);
      if (!panel.childAt(point.x, point.y))
        root.dismissPanels();
    }
  }

  Wifi.Panel {
    id: wifiPanel
    x: root.panelX
    z: 80
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.sidebarOuterMargin
  }

  Audio.Panel {
    id: audioPanel
    x: root.panelX
    z: 80
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.sidebarOuterMargin
  }

  Bluetooth.Panel {
    id: bluetoothPanel
    x: root.panelX
    z: 80
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.sidebarOuterMargin
  }

  Column {
    id: bottomStack
    onYChanged: cardBlur.changed()
    x: Theme.sidebarOuterMargin
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.sidebarOuterMargin
    width: controls.width
    spacing: Theme.sidebarCardGap
    BottomControls {
      id: controls
      collapseProgress: root.collapseProgress
      wifiOpen: wifiPanel.opened
      soundOpen: audioPanel.opened
      settingsOpen: Settings.State.opened && Settings.State.outputName === root.screen.name
      // Without NetworkManager there is nothing to manage.
      onWifiClicked: if (Wifi.State.available) root.togglePanel("wifi")
      onSoundClicked: root.togglePanel("audio")
      onSettingsClicked: Settings.State.toggle(root.screen.name)
      onCollapseClicked: root.toggleRequested()
    }
  }
}
