{ pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
  ];

  home.file.".config/quickshell/shell.qml".text = ''
    import Quickshell
    import Quickshell.Hyprland
    import Quickshell.Io
    import QtQuick
    import QtQuick.Layouts

    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true

        readonly property string font: "RobotoMono Nerd Font"
        readonly property int panelHeight: 56
        readonly property int fontSize: 20;

        // Wal colors
        property color backgroundColor: "#333333"
        property color accentColor: "#ffffff"


        property int cpuUsage: 0
        property real lastCpuTotal: 0
        property real lastCpuIdle: 0
        property string cpuTemp: "0";

        property string memUsageStr: "0"
        property real memPercent: 0

        property string pipewireVolume: ""
        property string currentWindowTitle: ""


        // Time in HH:MM:SS
        property string currentTime: Qt.formatTime(new Date(), "HH:mm:ss")

        // Date in DD/MM/YYYY
        property string currentDate: Qt.formatDate(new Date(), "dd/MM/yyyy")

        property int wifiPercent: 0
        property string wifiIcon: "󰤯"

        property string walPath: "/home/rhys/.cache/wal/colors.json"

        Timer {
            interval: 2000
            running: true
            repeat: true
            onTriggered: {
                var xhr = new XMLHttpRequest()
                xhr.open("GET", "file:///home/rhys/.cache/wal/colors.json")
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (!xhr.responseText) return

                        console.log("Raw JSON:", xhr.responseText)  // <--- log raw data

                        try {
                            var clean = xhr.responseText.replace(/^\uFEFF/, "").replace(/\0/g, "").trim()
                            console.log("Clean JSON:", clean)  // <--- log cleaned data

                            var data = JSON.parse(clean)
                            console.log("Parsed JSON object:", data)  // <--- log JS object

                            if (data.special && data.special.background)
                                backgroundColor = data.special.background
                            if (data.colors && data.colors.color1)
                                accentColor = data.colors.color1

                            console.log("Applied colors -> Background:", backgroundColor, "Accent:", accentColor)
                        } catch(e) {
                            console.warn("Failed to parse wal colors.json:", e)
                        }
                    }
                }
                xhr.send()
            }
        }



        Process {
            id: wifiProc
            command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2"]

            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    wifiPercent = parseInt(data.trim())
                }
            }
        }


        Process {
            id: cpuTempProc
            // Using single quotes inside the shell command to minimize shell-escaping drama
            command: ["sh", "-c", "sensors | grep 'Package id 0' | awk '{print ''$4}' | tr -d '+°C'"]
            
            stdout: SplitParser {
                onRead: (data) => {
                    if (data) {
                        cpuTemp = data.trim();
                    }
                }
            }
            Component.onCompleted: running = true
        }






        Process {
            id: pipewireVolumeProc
            command: ["sh", "-c", "wpctl get-volume @DEFAULT_SINK@"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    pipewireVolume = data.trim().replace(/^0\./, "").replace(/^Volume:\s*0\./, "") + "%"
                }
            }
            Component.onCompleted: running = true
        }

        Process {
            id: memProc
            command: ["sh", "-c", "free | grep Mem"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    var parts = data.trim().split(/\s+/)
                    
                    // Column 2 is "Used" (what Fastfetch shows)
                    var usedKiB = parseInt(parts[2]) || 0
                    var usedGiB = usedKiB / (1024 * 1024)
                    
                    // Column 1 is "Total"
                    var totalKiB = parseInt(parts[1]) || 1
                    var totalGiB = totalKiB / (1024 * 1024)
                    
                    // Column 6 is "Available" (what you saw as 9.9)
                    var availableKiB = parseInt(parts[6]) || 0
                    
                    // Fastfetch Style String: "5.7 GiB / 15.5 GiB"
                    memUsageStr = usedGiB.toFixed(2);
                    
                    // Percentage for your progress bar
                    memPercent = (usedKiB / totalKiB)
                }

            }
            Component.onCompleted: running = true
        }

        // Logic to fetch and parse CPU data
        Process {
            id: cpuProc
            command: ["sh", "-c", "head -1 /proc/stat"]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) return;
                    var p = data.trim().split(/\s+/);
                    var idle = parseInt(p[4]) + parseInt(p[5]);
                    var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                    
                    if (lastCpuTotal > 0) {
                        cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)));
                    }
                    
                    lastCpuTotal = total;
                    lastCpuIdle = idle;
                }
            }
        }

        Process {
            id: windowTitleProc
            // Command to get current window title in Hyprland
            command: ["sh", "-c", "hyprctl activewindow | grep 'title:' | cut -d ':' -f2- | sed 's/^ //'"]

            stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    currentWindowTitle = data.trim()
                }
            }

            // Automatically run on startup
            Component.onCompleted: running = true
        }

        Connections {
            target: Hyprland
            function onRawEvent(event) {
                windowTitleProc.running = true
            }
        }

        function wifiIconForPercent(p) {
            if (p >= 80) return "󰤨" // full
            if (p >= 60) return "󰤥" // strong
            if (p >= 40) return "󰤢" // medium
            if (p >= 20) return "󰤟" // weak
            return "󰤯"              // none
        }


        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                cpuProc.running = true;
                memProc.running = true;
                cpuTempProc.running = true;
                wifiProc.running = true
                wifiIcon = wifiIconForPercent(wifiPercent)

                var now = new Date()
                currentTime = Qt.formatTime(now, "HH:mm:ss")
                currentDate = Qt.formatDate(now, "dd/MM/yyyy")
            }
        }

        Timer {
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                pipewireVolumeProc.running = true;
            }
        }


        
        implicitHeight: panelHeight
        color: "transparent"

        property int themeEpoch: 0

        Component {
            id: uiComponent

            Item {
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 6;
                    anchors.bottomMargin: 6;
                    spacing: 10

                    // LEFT PILL
                    Rectangle {
                        color: accentColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: panelHeight // Makes it a perfect circle
                        Layout.fillHeight: true

                        Text {
                            id: logoText
                            font.family: font
                            font.pixelSize: fontSize + 15
                            text: "󱄅"
                            color: backgroundColor
                            // Center the text inside this specific white rectangle
                            anchors.centerIn: parent 
                        }
                    }

                    Rectangle {
                        color: backgroundColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: leftLayout.implicitWidth + 40 // Increased padding for 3 items
                        Layout.fillHeight: true

                        RowLayout {
                            id: leftLayout
                            anchors.centerIn: parent
                            spacing: 16 // Consistent spacing

                            Row {
                                id: workspaceRow
                                spacing: 12
                                Layout.alignment: Qt.AlignVCenter // Added alignment

                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        id: dot
                                        property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1
                                        height: 12
                                        radius: 6
                                        color: isActive ? accentColor : "#666666"
                                        width: isActive ? 30 : 12 // Simplified width logic for cleaner layout

                                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        color: backgroundColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: statsLayout.implicitWidth + 40 
                        Layout.fillHeight: true

                        RowLayout {
                            id: statsLayout
                            anchors.centerIn: parent
                            spacing: 16 

                            Text {
                                text: `  ''${cpuUsage}%`
                                font.family: font 
                                font.pixelSize: fontSize 
                                color: accentColor
                                Layout.alignment: Qt.AlignVCenter // Proper way to align in RowLayout
                            }

                            Text {
                                id: memText
                                text: `  ''${memUsageStr} GiB`
                                font.family: font
                                font.pixelSize: fontSize
                                color: accentColor
                                Layout.alignment: Qt.AlignVCenter // Removed anchors.centerIn (it was breaking layout)
                            }

                            Text {
                                id: cpuTempText
                                text: `󰔏 ''${cpuTemp}°C`
                                font.family: font
                                font.pixelSize: fontSize
                                color: accentColor
                                Layout.alignment: Qt.AlignVCenter // Removed anchors.centerIn (it was breaking layout)
                            }
                        }
                    }

                    // SPACER
                    Item { Layout.fillWidth: true }

                    // RIGHT
                    Rectangle {
                        color: backgroundColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: rightRow.width + 30
                        Layout.fillHeight: true

                        Row {
                            id: rightRow
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                font.family: font;
                                font.pixelSize: fontSize;
                                text: `  ''${pipewireVolume}`;
                                color: accentColor
                            }
                            Text {
                                font.family: font;
                                font.pixelSize: fontSize;
                                text: `''${wifiIcon}`;
                                color: accentColor
                            }
                        }
                    }

                    Rectangle {
                        color: backgroundColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: rightClockRow.implicitWidth + 30
                        Layout.fillHeight: true

                        Row {
                            id: rightClockRow
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                font.family: font;
                                font.pixelSize: fontSize;
                                text: `  ''${currentTime}`;
                                color: accentColor
                            }
                            Text {
                                font.family: font;
                                font.pixelSize: fontSize;
                                text: `  ''${currentDate}`;
                                color: accentColor
                            }
                        }
                    }

                    Rectangle {
                        color: accentColor
                        radius: panelHeight / 2
                        Layout.preferredWidth: panelHeight // Makes it a perfect circle
                        Layout.fillHeight: true

                        Text {
                            id: powerText
                            font.family: font
                            font.pixelSize: fontSize + 15
                            text: "󰐥"
                            color: backgroundColor
                            // Center the text inside this specific white rectangle
                            anchors.centerIn: parent 
                        }
                    }
                }

                Rectangle {
                    id: topPill
                    color: accentColor
                    radius: panelHeight / 2
                    z: 10

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    height: panelHeight - 16
                    width: contentItem.implicitWidth + 32

                    Row {
                        id: contentItem
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: currentWindowTitle
                            color: "black"
                            font.family: font
                            font.pixelSize: fontSize
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }
            }
        }

        Loader {
            id: uiLoader
            anchors.fill: parent
            sourceComponent: uiComponent
            // bind the sourceComponent to themeEpoch so it reloads automatically
            property int reloadTrigger: themeEpoch
            onReloadTriggerChanged: {
                uiLoader.sourceComponent = null
                uiLoader.sourceComponent = uiComponent
            }
        }


        



    }

  '';
}
