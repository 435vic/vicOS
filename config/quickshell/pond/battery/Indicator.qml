import QtQuick
import QtQuick.Effects

// Fill the battery outline continuously from 0–100%.
Item {
  id: root
  property real percentage: 0
  property bool charging: false
  property color color: "white"
  readonly property real level: Math.max(0, Math.min(100, percentage)) / 100
  implicitWidth: 16; implicitHeight: 16
  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl("../assets/battery/outline.svg")
    sourceSize: Qt.size(width * 2, height * 2)
    layer.enabled: !Qt.colorEqual(root.color, "white")
    layer.effect: MultiEffect { colorization: 1; colorizationColor: root.color }
  }
  Rectangle {
    x: root.width * 6 / 16
    width: root.width * 4 / 16
    height: root.height * 9 / 16 * root.level
    y: root.height * 13 / 16 - height
    color: root.color
  }
  Image {
    x: root.width * 14 / 16
    y: root.height * 1 / 16
    width: root.width * 5 / 16
    height: root.height * 10 / 16
    visible: root.charging
    source: Qt.resolvedUrl("../assets/battery/bolt.svg")
    sourceSize: Qt.size(width * 2, height * 2)
    smooth: true
  }
}
