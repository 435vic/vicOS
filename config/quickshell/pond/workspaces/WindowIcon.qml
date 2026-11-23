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

  implicitWidth: controlSize
  implicitHeight: controlSize

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    color: root.hovered ? Shell.Theme.workspaceControlHover
        : Qt.rgba(Shell.Theme.workspaceControlHover.r, Shell.Theme.workspaceControlHover.g,
                  Shell.Theme.workspaceControlHover.b, 0)
    border.color: Shell.Theme.workspaceIconOutline
    border.width: root.hovered ? 0 : Shell.Theme.sidebarStrokeWidth
    Behavior on color {
      ColorAnimation { duration: Shell.Theme.sidebarHoverDuration; easing.type: Easing.OutCubic }
    }
  }

  IconImage {
    anchors.centerIn: parent
    width: Shell.Theme.workspaceIconSize
    height: width
    source: Shell.Compositor.iconFor(root.toplevel?.lastIpcObject?.class ?? "")
    asynchronous: true
    opacity: Shell.Theme.translucent || root.hovered ? 1.0 : 0.9
    Behavior on opacity { Shell.HoverAnimation {} }
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
