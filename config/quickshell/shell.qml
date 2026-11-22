// Minimal bar: Hyprland workspaces, clock, battery and tray.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

ShellRoot {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            readonly property var monitor: Hyprland.monitorFor(modelData)

            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 26
            color: "#1d2021"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 8
                spacing: 4

                Repeater {
                    model: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.monitor === bar.monitor)

                    Rectangle {
                        required property var modelData
                        implicitWidth: 22
                        implicitHeight: 18
                        radius: 4
                        color: modelData.focused ? "#d79921" : "#3c3836"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.id
                            color: modelData.focused ? "#1d2021" : "#ebdbb2"
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.activate()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Repeater {
                    model: SystemTray.items

                    Image {
                        id: trayIcon
                        required property var modelData
                        source: modelData.icon
                        sourceSize.width: 16
                        sourceSize.height: 16

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton || trayIcon.modelData.onlyMenu) {
                                    if (trayIcon.modelData.hasMenu) {
                                        const pos = trayIcon.mapToItem(null, 0, trayIcon.height);
                                        trayIcon.modelData.display(bar, pos.x, pos.y);
                                    }
                                } else {
                                    trayIcon.modelData.activate();
                                }
                            }
                        }
                    }
                }

                Text {
                    readonly property var battery: UPower.displayDevice
                    visible: battery.isLaptopBattery && battery.isPresent
                    text: (UPower.onBattery ? "BAT " : "AC ") + Math.round(battery.percentage * 100) + "%"
                    color: UPower.onBattery && battery.percentage < 0.15 ? "#fb4934" : "#ebdbb2"
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                    color: "#ebdbb2"
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
    }
}
