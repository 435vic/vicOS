pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "." as Workspaces
import ".." as Shell

// Hyprland workspace viewer in place of Pond's Niri minimap. It keeps the
// minimap's look (one 40px row per workspace, window icons, an active row
// highlight, numbers on hover, a compact stack when collapsed) without the
// drag and drop, which is built on Niri's columns.
Shell.Card {
  id: root

  property var screen: null
  property real collapseProgress: 0
  property real maximumHeight: 10000
  readonly property real widthProgress: Shell.Theme.collapseWidth(collapseProgress)
  readonly property real heightProgress: Shell.Theme.collapseHeight(collapseProgress)
  readonly property bool collapsed: collapseProgress >= 0.56

  readonly property var workspaces: Hyprland.workspaces.values
      .filter(ws => ws.id > 0 && (!root.screen || ws.monitor?.name === root.screen.name))
      .sort((a, b) => a.id - b.id)
  // One empty row below the occupied ones, like Pond's creation row.
  readonly property var rows: workspaces.concat([null])
  readonly property int renderedRows: Math.max(Shell.Theme.workspaceGridMinimumRows, rows.length)

  function windowsOf(ws) {
    if (!ws) return [];
    return ws.toplevels.values.slice().sort((a, b) => {
      const pa = a.lastIpcObject?.at ?? [0, 0], pb = b.lastIpcObject?.at ?? [0, 0];
      return pa[0] - pb[0] || pa[1] - pb[1];
    });
  }

  function focusWorkspace(ws) {
    if (ws) ws.activate();
    else Shell.Compositor.dispatch("hl.dsp.focus({ workspace = \"emptym\" })");
  }

  function launchOn(ws) {
    focusWorkspace(ws);
    Quickshell.execDetached(["vicinae", "open"]);
  }

  readonly property real expandedNaturalHeight: Shell.Theme.workspaceContentPadding * 2
      + renderedRows * Shell.Theme.workspaceControlSize
      + (renderedRows - 1) * Shell.Theme.workspaceRowGap
  readonly property real collapsedNaturalHeight: collapsedColumn.implicitHeight + 4
  readonly property real naturalHeight: Shell.Theme.lerp(
      expandedNaturalHeight, collapsedNaturalHeight, heightProgress)

  width: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, widthProgress)
  height: Math.min(maximumHeight, naturalHeight)
  radius: Shell.Theme.translucent
      ? Shell.Theme.lerp(12, Shell.Theme.sidebarCardRadius, widthProgress)
      : Shell.Theme.sidebarCardRadius
  contentClipped: collapsed

  Item {
    id: expandedLayer
    x: -10
    width: root.width - x
    height: root.height
    clip: true
    opacity: root.collapsed ? 0 : 1
    visible: opacity > 0.001
    enabled: !root.collapsed

    HoverHandler { id: cardHover }

    Column {
      x: 0
      y: Shell.Theme.workspaceContentPadding
      width: expandedLayer.width
      spacing: Shell.Theme.workspaceRowGap

      Repeater {
        model: root.renderedRows

        delegate: Item {
          id: row
          required property int index
          readonly property bool isWorkspace: index < root.workspaces.length
          readonly property bool isCreation: index === root.workspaces.length
          readonly property var workspace: isWorkspace ? root.workspaces[index] : null
          readonly property bool active: !!workspace && workspace.active
          readonly property var windows: root.windowsOf(workspace)
          readonly property int columns: Shell.Theme.workspaceGridColumns
          // Past three windows the last slot counts the rest.
          readonly property int overflow: Math.max(0, windows.length - columns + 1)

          width: parent.width
          height: Shell.Theme.workspaceControlSize

          Rectangle {
            x: Shell.Theme.workspaceActiveIndicatorInset - expandedLayer.x
            y: -Shell.Theme.workspaceRowGap / 2
            width: root.width - Shell.Theme.workspaceActiveIndicatorInset * 2
            height: Shell.Theme.workspaceRowPitch
            radius: 10
            color: row.active ? Shell.Theme.workspaceActiveIndicatorColor
                : Qt.rgba(Shell.Theme.workspaceActiveIndicatorColor.r,
                          Shell.Theme.workspaceActiveIndicatorColor.g,
                          Shell.Theme.workspaceActiveIndicatorColor.b, 0)
            Behavior on color {
              ColorAnimation { duration: Shell.Theme.sidebarWorkspaceSwitchDuration; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            x: -expandedLayer.x
            y: -Shell.Theme.workspaceRowGap / 2
            width: Shell.Theme.sidebarCardExpandedWidth
            height: Shell.Theme.workspaceRowPitch
            enabled: row.isWorkspace || row.isCreation
            cursorShape: Qt.PointingHandCursor
            onClicked: root.focusWorkspace(row.workspace)
          }

          HoverHandler { id: rowHover }

          Row {
            x: Shell.Theme.workspaceContentPadding - expandedLayer.x
            spacing: Shell.Theme.workspaceControlGap

            Repeater {
              model: row.columns

              delegate: Item {
                id: slot
                required property int index
                readonly property bool counts: row.overflow > 0 && index === row.columns - 1
                readonly property var toplevel: !counts && index < row.windows.length
                    ? row.windows[index] : null
                readonly property bool addSlot: (row.isWorkspace || row.isCreation)
                    && index === row.windows.length
                readonly property bool plusRevealed: addSlot && rowHover.hovered

                width: Shell.Theme.workspaceControlSize
                height: width

                Rectangle {
                  anchors.centerIn: parent
                  visible: !slot.toplevel && !slot.counts
                  width: Shell.Theme.workspacePlaceholderDotSize
                  height: width
                  radius: width / 2
                  color: Shell.Theme.workspacePlaceholderColor
                  opacity: slot.plusRevealed ? 0 : 1
                  Behavior on opacity { Shell.HoverAnimation {} }
                }

                Workspaces.WindowIcon {
                  anchors.fill: parent
                  visible: !!slot.toplevel
                  toplevel: slot.toplevel
                }

                Rectangle {
                  anchors.fill: parent
                  visible: slot.counts
                  radius: width / 2
                  color: "transparent"
                  border.color: Shell.Theme.workspaceIconOutline
                  border.width: Shell.Theme.sidebarStrokeWidth
                  antialiasing: true
                  Text {
                    anchors.centerIn: parent
                    text: "+" + row.overflow
                    color: Shell.Theme.sidebarForeground
                    font.family: Shell.Theme.plexFontFamily
                    font.weight: Font.Medium
                    font.pixelSize: 12
                  }
                }

                Workspaces.PlusButton {
                  anchors.fill: parent
                  revealed: slot.plusRevealed
                  onActivated: root.launchOn(row.workspace)
                }
              }
            }
          }

          // The workspace number sits on the screen edge while the card is hovered.
          Rectangle {
            x: 3
            anchors.verticalCenter: parent.verticalCenter
            z: 30
            width: 14
            height: 20
            radius: 10
            visible: cardHover.hovered && row.isWorkspace
            color: Shell.Theme.workspaceNumberBackground
            antialiasing: true
            Text {
              anchors.fill: parent
              text: row.workspace?.id ?? ""
              color: Shell.Theme.colors.workspaceNumberText
              font.family: Shell.Theme.plexFontFamily
              font.weight: Font.Medium
              font.pixelSize: 11
              font.letterSpacing: 0.11
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
          }
        }
      }
    }
  }

  Item {
    id: collapsedLayer
    width: Shell.Theme.sidebarCardCollapsedWidth
    height: collapsedColumn.implicitHeight
    opacity: root.collapsed ? 1 : 0
    visible: opacity > 0.001
    enabled: root.collapsed

    Column {
      id: collapsedColumn
      y: 4
      width: Shell.Theme.sidebarCardCollapsedWidth

      Repeater {
        model: root.workspaces

        delegate: Item {
          id: entry
          required property var modelData
          required property int index
          readonly property bool active: modelData.active
          readonly property var windows: root.windowsOf(modelData)
          readonly property int activeHeight: Shell.Theme.workspaceCollapsedHeaderHeight
              + windows.length * Shell.Theme.workspaceCollapsedControlPitch
              - (windows.length > 0 ? Shell.Theme.workspaceCollapsedControlGap : 0) + 4

          width: Shell.Theme.sidebarCardCollapsedWidth
          height: (active && windows.length > 0 ? activeHeight : 41) + Shell.Theme.workspaceCollapsedControlGap
          Behavior on height {
            enabled: root.collapseProgress === 1
            NumberAnimation { duration: Shell.Theme.sidebarWorkspaceSwitchDuration; easing.type: Easing.OutCubic }
          }

          Rectangle {
            x: 4
            width: parent.width - 8
            height: Math.max(0, parent.height - Shell.Theme.workspaceCollapsedControlGap)
            radius: 12
            color: Shell.Theme.colors.workspaceCollapsedActive
            opacity: entry.active || pointer.containsMouse ? 1 : 0
            Behavior on opacity {
              NumberAnimation { duration: Shell.Theme.sidebarWorkspaceSwitchDuration; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            id: pointer
            width: parent.width
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: entry.modelData.activate()
          }

          FontMetrics { id: numberMetrics; font: number.font }

          Text {
            id: number
            readonly property real blockHeight: numberMetrics.capitalHeight + (dots.visible ? 8 : 0)
            y: (41 - blockHeight) / 2 + numberMetrics.capitalHeight - baselineOffset
            width: parent.width
            text: entry.modelData.id < 10 ? "0" + entry.modelData.id : String(entry.modelData.id)
            color: Shell.Theme.sidebarForeground
            opacity: entry.active ? 1 : 0.5
            font.family: Shell.Theme.plexFontFamily
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
          }

          Column {
            visible: entry.active
            anchors.horizontalCenter: parent.horizontalCenter
            y: Shell.Theme.workspaceCollapsedHeaderHeight
            spacing: Shell.Theme.workspaceCollapsedControlGap
            Repeater {
              model: entry.windows
              delegate: Workspaces.WindowIcon {
                required property var modelData
                toplevel: modelData
                controlSize: Shell.Theme.workspaceCollapsedControlSize
              }
            }
          }

          Row {
            id: dots
            visible: !entry.active && entry.windows.length > 0
            y: number.y + number.baselineOffset + 4
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Repeater {
              model: Math.min(4, entry.windows.length)
              delegate: Rectangle {
                width: 4
                height: 4
                radius: 2
                color: Shell.Theme.sidebarForeground
                opacity: 0.6
              }
            }
          }

          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - Shell.Theme.workspaceCollapsedControlGap / 2 - height / 2
            width: 16
            height: 1
            color: Shell.Theme.sidebarDivider
            visible: entry.index < root.workspaces.length - 1
          }
        }
      }
    }
  }
}
