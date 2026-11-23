pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "." as FnPreview
import ".." as Shell
import "../audio" as Audio

// Full-width bottom Fn-row preview aligned to the Framework 13 top key row
// (1.5fr Esc, 12 x 1fr F1-F12, 1.5fr Delete). Lives in its own Overlay
// PanelWindow so the sidebar buffer stays narrow and nothing is allocated
// while hidden.
PanelWindow {
  id: root
  required property var targetScreen

  readonly property bool requested: FnPreview.State.active
      && FnPreview.State.showsOnScreen(root.targetScreen)
  property real reveal: requested ? 1 : 0
  readonly property int barHeight: FnPreview.State.barHeight
  readonly property int horizontalMargin: 28
  readonly property int bottomMargin: Shell.Theme.sidebarOuterMargin
  readonly property int shadowTop: 55
  readonly property int innerPad: 8
  readonly property int keyGap: 12
  readonly property real totalWeight: 15.0

  screen: targetScreen

  // Framework 13 top row: Esc (Fn Lock), F1-F12, Delete (Insert).
  readonly property var keys: [
    { key: "Esc", caption: "Fn", icon: "../assets/lock.svg", iconSize: 14, weight: 1.5, offset: 0.0, fnLockKey: true },
    { key: "F1",  caption: "", icon: "../assets/volume-mute.svg", iconSize: 17, weight: 1.0, offset: 1.5, muteKey: true },
    { key: "F2",  caption: "", icon: "../assets/fnpreview/volume-down.svg", iconSize: 17, weight: 1.0, offset: 2.5 },
    { key: "F3",  caption: "", icon: "../assets/fnpreview/volume-up.svg", iconSize: 17, weight: 1.0, offset: 3.5 },
    { key: "F4",  caption: "", icon: "../assets/media/previous-hover.svg", iconSize: 20, weight: 1.0, offset: 4.5 },
    { key: "F5",  caption: "", icon: "../assets/fnpreview/play-pause.svg", iconSize: 17, weight: 1.0, offset: 5.5 },
    { key: "F6",  caption: "", icon: "../assets/media/next-hover.svg", iconSize: 20, weight: 1.0, offset: 6.5 },
    { key: "F7",  caption: "", icon: "../assets/fnpreview/brightness-down.svg", iconSize: 18, weight: 1.0, offset: 7.5 },
    { key: "F8",  caption: "", icon: "../assets/brightness.svg", iconSize: 17, weight: 1.0, offset: 8.5 },
    { key: "F9",  caption: "", icon: "../assets/fnpreview/display.svg", iconSize: 17, weight: 1.0, offset: 9.5 },
    { key: "F10", caption: "", icon: "../assets/fnpreview/airplane.svg", iconSize: 16, weight: 1.0, offset: 10.5 },
    { key: "F11", caption: "", icon: "../assets/fnpreview/screenshot.svg", iconSize: 17, weight: 1.0, offset: 11.5 },
    { key: "F12", caption: "", icon: "../assets/settings.svg", iconSize: 16, weight: 1.0, offset: 12.5 },
    { key: "Del", caption: "Ins", icon: "../assets/fnpreview/insert.svg", iconSize: 14, weight: 1.5, offset: 13.5 }
  ]

  visible: requested || reveal > 0.001
  color: "transparent"
  BackgroundEffect.blurRegion: Shell.Theme.translucent ? barBlur : null
  onRevealChanged: barBlur.changed()

  Region {
    id: barBlur
    item: root.requested && root.reveal > Shell.PanelStyle.blurRevealOpacity ? barSurface : null
    radius: barSurface.radius
  }

  anchors {
    left: true
    right: true
    bottom: true
  }
  implicitHeight: shadowTop + barHeight + bottomMargin
  mask: Region {}

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-fn-preview"
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  Behavior on reveal { Shell.Motion { duration: 160 } }

  Item {
    id: barContainer
    x: root.horizontalMargin
    y: root.shadowTop + (1 - root.reveal) * 10
    width: Math.max(0, root.width - root.horizontalMargin * 2)
    height: root.barHeight
    opacity: root.reveal

    Shell.Shadow {
      anchors.fill: barSurface
      cornerRadius: barSurface.radius
      shadows: Shell.PanelStyle.frontShadows
    }

    Shell.PanelBackground {
      id: barSurface
      anchors.fill: parent

      Item {
        id: keyRow
        anchors.fill: parent
        anchors.margins: root.innerPad
        readonly property real usableWidth: Math.max(0, width - (root.keys.length - 1) * root.keyGap)

        Repeater {
          model: root.keys

          delegate: Rectangle {
            id: keyTile
            required property int index
            required property var modelData

            readonly property real leftPx: Math.round(modelData.offset / root.totalWeight * keyRow.usableWidth)
                + index * root.keyGap
            readonly property real rightPx: Math.round((modelData.offset + modelData.weight)
                / root.totalWeight * keyRow.usableWidth) + index * root.keyGap
            readonly property bool isFnLockKey: !!modelData.fnLockKey
            readonly property bool isFnRowKey: !isFnLockKey && modelData.caption === ""
            readonly property bool highlighted: (!!modelData.muteKey && Audio.State.outputMuted)
                || (isFnLockKey && FnPreview.State.fnLocked)
            readonly property bool isFirst: index === 0
            readonly property bool isLast: index === root.keys.length - 1

            x: leftPx
            y: 0
            width: Math.max(0, rightPx - leftPx)
            height: keyRow.height
            topLeftRadius: isFirst ? 10 : 8
            bottomLeftRadius: isFirst ? 10 : 8
            topRightRadius: isLast ? 10 : 8
            bottomRightRadius: isLast ? 10 : 8
            color: highlighted ? Qt.alpha(Shell.PanelStyle.accent, 0.16) : Shell.PanelStyle.drawerFill
            border.width: 1
            border.color: highlighted ? Qt.alpha(Shell.PanelStyle.accent, 0.4) : Shell.Theme.colors.outline
            antialiasing: true

            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Rectangle {
              visible: keyTile.isFnLockKey
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.topMargin: 8
              anchors.rightMargin: 8
              width: 5
              height: 5
              radius: 2.5
              color: FnPreview.State.fnLocked ? Shell.PanelStyle.accent : Shell.Theme.colors.feedbackDotOff
              Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            Text {
              x: 7
              y: 4
              text: keyTile.modelData.key
              color: Shell.Theme.colors.text
              opacity: keyTile.isFnRowKey && FnPreview.State.fnLocked ? 0.95
                  : keyTile.highlighted ? 0.8 : 0.45
              font.family: Shell.Theme.plexFontFamily
              font.weight: Font.Medium
              font.pixelSize: 10
              Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            Row {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: 1
              spacing: 6

              Image {
                anchors.verticalCenter: parent.verticalCenter
                width: keyTile.modelData.iconSize
                height: keyTile.modelData.iconSize
                source: Qt.resolvedUrl(keyTile.modelData.icon)
                sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
                fillMode: Image.PreserveAspectFit
                smooth: true
                antialiasing: true
                opacity: keyTile.isFnRowKey && FnPreview.State.fnLocked ? 0.42
                    : keyTile.highlighted ? 1 : 0.9
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
              }

              Text {
                visible: keyTile.modelData.caption !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: keyTile.modelData.caption
                color: Shell.Theme.colors.text
                opacity: keyTile.highlighted ? 1 : 0.85
                font.family: Shell.Theme.fontFamily
                font.weight: Font.Medium
                font.pixelSize: 12
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
              }
            }
          }
        }
      }
    }
  }
}
