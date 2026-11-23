pragma ComponentBehavior: Bound

import QtQuick
import "." as Settings
import ".." as Shell
import "../battery" as Battery
import Quickshell
import Quickshell.Wayland

// Pond's settings overlay, reduced for vicOS to the Bluetooth card, the
// session buttons, the power profile selector (on machines with a battery) and
// the tray.
PanelWindow {
  id: root

  required property var menuScreen

  property bool presented: false
  property int revealStep: -1
  property var revealRanks: []
  readonly property int cardCount: 1 + sessionButtons.length

  readonly property bool cardsOpen: Settings.State.opened
      && Settings.State.outputName === (menuScreen ? menuScreen.name : "")

  readonly property var sessionButtons: [
    {
      slot: 1, y: 0, action: "lock", name: "Lock screen",
      source: Qt.resolvedUrl("../assets/lock.svg"),
      hover: "#FFE51D", control: "#632B0F", labelWidth: 170, dot: false
    },
    {
      slot: 2, y: 137, action: "suspend", name: "Sleep",
      source: Qt.resolvedUrl("../assets/settings/sleep.svg"),
      hover: "#E99FFF", control: "#681D4F", labelWidth: 74, dot: false
    },
    {
      slot: 3, y: 274, action: "logout", name: "Log out",
      source: Qt.resolvedUrl("../assets/settings/logout.svg"),
      hover: "#FF9F67", control: "#632B0F", labelWidth: 110, dot: false
    },
    {
      slot: 4, y: 411, action: "reboot", name: "Restart",
      source: Qt.resolvedUrl("../assets/settings/restart.svg"),
      hover: "#CEF058", control: "#1B322D", labelWidth: 99, dot: false
    },
    {
      slot: 5, y: 548, action: "shutdown", name: "Power off",
      source: Qt.resolvedUrl("../assets/settings/power.svg"),
      hover: "#FE6146", control: "#632B0F", labelWidth: 127, dot: true
    }
  ]

  screen: menuScreen
  visible: presented
  color: "transparent"
  BackgroundEffect.blurRegion: Shell.Theme.translucent ? cardBlur : null
  onWidthChanged: cardBlur.changed()
  onHeightChanged: cardBlur.changed()
  Region {
    id: cardBlur
    regions: Array.from(composition.children).concat(profileSelector, tray)
        .filter(Boolean).map(item => item.blurRegion).filter(Boolean)
  }

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-settings-"
      + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: root.cardsOpen
      ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  mask: Region {
    x: 0
    y: 0
    width: root.presented ? root.width : 0
    height: root.presented ? root.height : 0
  }

  onCardsOpenChanged: {
    if (cardsOpen)
      beginOpen();
    else
      beginClose();
  }

  Rectangle {
    anchors.fill: parent
    color: Settings.Style.overlay
    opacity: root.cardsOpen ? Settings.Style.overlayOpacity : 0

    Behavior on opacity {
      NumberAnimation {
        duration: Settings.Style.closeDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.cardsOpen
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    onClicked: Settings.State.close()
  }

  Item {
    id: composition
    z: 2
    width: 274 + Settings.Style.sessionSize
    height: 548 + Settings.Style.sessionSize
    anchors.centerIn: parent
    enabled: root.cardsOpen
    visible: opacity > 0
    opacity: root.cardsOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Settings.Style.closeDuration; easing.type: Easing.OutCubic } }

    CategoryButton {
      x: 0
      y: (composition.height - height) / 2
      width: 264
      height: 264
      iconSource: Qt.resolvedUrl("../assets/settings/bluetooth.svg")
      iconBoxWidth: 30
      iconBoxHeight: 48
      iconWidth: 30
      iconHeight: 48
      accessibleName: "Bluetooth"
      onClicked: Settings.State.openBluetooth()
      revealed: root.cardsOpen && root.revealStep >= root.revealRanks[0]
    }

    Repeater {
      model: root.sessionButtons

      delegate: SessionButton {
        required property var modelData

        x: 274
        y: modelData.y
        width: Settings.Style.sessionSize
        height: Settings.Style.sessionSize
        iconSource: modelData.source
        iconWidth: 32
        iconHeight: 32
        showStatusDot: modelData.dot
        hoverColor: modelData.hover
        hoverControlColor: modelData.control
        label: modelData.name
        labelWidth: modelData.labelWidth
        accessibleName: modelData.name
        revealed: root.cardsOpen
            && root.revealStep >= root.revealRanks[modelData.slot]
        onClicked: Settings.State.requestSessionAction(modelData.action)
      }
    }
  }

  Battery.ProfileSelector {
    id: profileSelector
    z: 2
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    enabled: root.cardsOpen && Battery.State.present
    visible: opacity > 0
    opacity: enabled ? 1 : 0
    Keys.onEscapePressed: Settings.State.close()
    Behavior on opacity {
      NumberAnimation { duration: Settings.Style.closeDuration; easing.type: Easing.OutCubic }
    }
  }

  Tray {
    id: tray
    z: 3
    anchors.fill: parent
    enabled: root.cardsOpen
    visible: opacity > 0
    opacity: root.cardsOpen ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: Settings.Style.closeDuration; easing.type: Easing.OutCubic }
    }
  }

  Item {
    focus: root.cardsOpen
    Keys.onEscapePressed: Settings.State.close()
  }

  Timer {
    id: revealTimer
    interval: Settings.Style.staggerInterval
    repeat: true
    onTriggered: {
      if (root.revealStep >= root.cardCount - 1) {
        stop();
        return;
      }
      root.revealStep += 1;
    }
  }

  Timer {
    id: closeCleanup
    interval: Settings.Style.closeDuration
    onTriggered: {
      if (!root.cardsOpen)
        root.presented = false;
    }
  }

  function beginOpen() {
    closeCleanup.stop();
    revealTimer.stop();
    revealRanks = shuffledRanks();
    revealStep = -1;
    presented = true;
    Qt.callLater(function() {
      if (!root.cardsOpen)
        return;
      root.revealStep = 0;
      revealTimer.restart();
    });
  }

  function beginClose() {
    revealTimer.stop();
    revealStep = -1;
    if (presented)
      closeCleanup.restart();
  }

  function shuffledRanks() {
    const order = Array.from({length: root.cardCount}, (_, index) => index);
    for (let index = order.length - 1; index > 0; --index) {
      const other = Math.floor(Math.random() * (index + 1));
      const held = order[index];
      order[index] = order[other];
      order[other] = held;
    }
    return order;
  }
}
