import QtQuick
import Quickshell.Widgets
import ".." as Shell

// One window marker, after Pond's minimap WindowIcon: an outlined circle with
// the app icon, scaled between the 40px expanded rail and the 32px stack.
Item {
  id: root

  property var toplevel: null
  property real controlSize: Shell.Theme.workspaceControlSize
  readonly property bool hovered: pointer.containsMouse
  readonly property bool urgent: !!root.toplevel && Shell.Compositor.isUrgent(root.toplevel.address)
  // Pond's attention/unread orange from its minimap indicator.
  readonly property color urgentColor: "#FF9F67"

  implicitWidth: controlSize
  implicitHeight: controlSize

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    color: root.hovered ? Shell.Theme.workspaceControlHover
        : root.urgent ? Qt.rgba(root.urgentColor.r, root.urgentColor.g, root.urgentColor.b, 0.16)
        : Qt.rgba(Shell.Theme.workspaceControlHover.r, Shell.Theme.workspaceControlHover.g,
                  Shell.Theme.workspaceControlHover.b, 0)
    border.color: root.urgent ? root.urgentColor : Shell.Theme.workspaceIconOutline
    border.width: root.urgent ? 1.5 : root.hovered ? 0 : Shell.Theme.sidebarStrokeWidth
    Behavior on color {
      ColorAnimation { duration: Shell.Theme.sidebarHoverDuration; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
      ColorAnimation { duration: Shell.Theme.sidebarHoverDuration; easing.type: Easing.OutCubic }
    }
  }

  IconImage {
    anchors.centerIn: parent
    width: Shell.Theme.workspaceIconSize
    height: width
    source: Shell.Compositor.iconFor(root.toplevel?.lastIpcObject?.class ?? "")
    asynchronous: true
    opacity: Shell.Theme.translucent || root.hovered || root.urgent ? 1.0 : 0.9
    Behavior on opacity { Shell.HoverAnimation {} }
  }

  Rectangle {
    visible: root.urgent
    width: 7
    height: 7
    radius: 3.5
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 1
    anchors.rightMargin: 1
    color: root.urgentColor
    antialiasing: true

    SequentialAnimation on opacity {
      running: root.urgent && root.visible
      loops: Animation.Infinite
      NumberAnimation { from: 1.0; to: 0.45; duration: 900; easing.type: Easing.InOutSine }
      NumberAnimation { from: 0.45; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    Accessible.role: Accessible.Button
    Accessible.name: root.toplevel?.title ?? ""
    onClicked: if (root.toplevel) Shell.Compositor.focusWindow(root.toplevel.address)
  }
}
