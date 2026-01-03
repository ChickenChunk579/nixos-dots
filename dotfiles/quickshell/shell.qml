import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    property color colBg: "#2a273f"
    property color colFg: "#e0def4"
    property color colMuted: "#6e6a86"
    property color colCyan: "#9ccfd8"
    property color colPurple: "#c4a7e7"
    property color colDarkPurple: "#907aa9"
    property color colRed: "#eb6f92"
    property color colYellow: "#f6c177"
    property color colBlue: "#3e8fb0"

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property string kernelVersion: "Linux"
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 0
    property string activeWindow: "Window"
    property string currentLayout: "Tile"

    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property var cpuTemperature: "0.0"

    property bool hasCpuTemp: false
    property bool hasBattery: false

    property int batteryPercent: 0

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    kernelVersion = data.trim();
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;

                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal;
                    var idleDiff = idleTime - lastCpuIdle;
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);
                    }
                }
                lastCpuTotal = total;
                lastCpuIdle = idleTime;
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                memUsage = Math.round(100 * used / total);
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var percentStr = parts[4] || "0%";
                diskUsage = parseInt(percentStr.replace('%', '')) || 0;
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var match = data.match(/Volume:\s*([\d.]+)/);
                if (match) {
                    volumeLevel = Math.round(parseFloat(match[1]) * 100);
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    activeWindow = data.trim();
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    currentLayout = data.trim();
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: pauvControlProc
        command: ["pavucontrol"]
    }

    Process {
        id: cpuTempProc
        command: ["sh", "-c", "/home/rhys/.config/quickshell/temp.sh"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim().length === 0) {
                    hasCpuTemp = false;
                    return;
                }

                cpuTemperature = data.trim();
                hasCpuTemp = true;
            }
        }
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || isNaN(parseInt(data))) {
                    hasBattery = false;
                    return;
                }

                batteryPercent = parseInt(data);
                hasBattery = true;
            }
        }
    }


    // Slow timer for system stats
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            volProc.running = true;
            cpuTempProc.running = true;
            batteryProc.running = true;
        }
    }

    // Event-based updates for window/layout (instant)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            //console.log("Event")
            windowProc.running = true;
            layoutProc.running = true;
        }
    }

    // Backup timer for window/layout (catches edge cases)
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true;
            layoutProc.running = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            margins {
                top: 6
                bottom: 6
                left: 6
                right: 6
            }

            Rectangle {
                anchors.fill: parent
                color: root.colBg
                radius: 10

                border.color: root.colDarkPurple
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: 8
                    }

                    Repeater {
                        model: 9

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: parent.height
                            color: "transparent"

                            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                            property bool hasWindows: workspace !== null

                            Text {
                                text: index + 1
                                color: parent.isActive ? root.colPurple : (parent.hasWindows ? root.colDarkPurple : root.colMuted)
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            Rectangle {
                                width: 20
                                height: 2
                                color: parent.isActive ? root.colPurple : root.colDarkPurple
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: activeWindow
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        text: " " + kernelVersion
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: " " + cpuUsage + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        visible: hasCpuTemp
                        text: cpuTemperature
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        visible: hasCpuTemp
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        visible: hasBattery
                        text: batteryPercent + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        visible: hasBattery
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: " " + memUsage + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: " " + diskUsage + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: " " + volumeLevel + "%"
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pauvControlProc
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        id: clockText
                        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        }
                    }

                    Item {
                        width: 8
                    }
                }
            }
        }
    }
}
