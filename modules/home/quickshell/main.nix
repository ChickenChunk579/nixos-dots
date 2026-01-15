{ pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
  ];

  home.file.".config/quickshell/shell.qml".text = ''
    import Quickshell
    import Quickshell.Hyprland
    import Quickshell.Wayland
    import Quickshell.Io
    import Quickshell.Services.Pam
    import Quickshell.Services.Pipewire
    import Quickshell.Services.Notifications
    import Quickshell.Widgets


    import QtQuick
    import QtQuick.Layouts
    import QtQuick.Controls
    import QtQuick.Effects


    PanelWindow {
        id: barPanel
        anchors.top: true
        anchors.left: true
        anchors.right: true

        readonly property string font: "Roboto"
        readonly property int panelHeight: 56
        readonly property int fontSize: 20

        // Wal colors
        property color backgroundColor: "#333333"
        property color lighterBackgroundColor: "#555555"
        property color accentColor: "#ffffff"
        property string fontColor: "white"

        property int cpuUsage: 0
        property real lastCpuTotal: 0
        property real lastCpuIdle: 0
        property string cpuTemp: "0";

        property string memUsageStr: "0"
        property real memPercent: 0

        property string pipewireVolume: ""
        property string currentWindowTitle: ""

        property int openMenu: 0

        property bool wifiOn: false

        // Time in HH:MM:SS
        property string currentTime: Qt.formatTime(new Date(), "HH:mm:ss")

        // Date in DD/MM/YYYY
        property string currentDate: Qt.formatDate(new Date(), "dd/MM/yyyy")

        property int wifiPercent: 0
        property string wifiIcon: "󰤯"

        property string walPath: "/home/rhys/.cache/wal/colors.json"

        // Media properties
        property string mediaTitle: ""
        property string mediaStatus: "Stopped"
        property real mediaPosition: 0
        property real mediaLength: 0
        property bool isPlaying: false
        property string mediaArtUrl: ""

        // ============ UTILITY FUNCTIONS ============
        ${builtins.readFile ./utils.qml}

        // ============ DATA PROCESSES ============
        ${builtins.readFile ./processes.qml}

        Component.onCompleted: fetchTheme()

        Timer {
            interval: 2000
            running: true
            repeat: true
            onTriggered: fetchTheme()
        }

        Connections {
            target: Hyprland
            function onRawEvent(event) {
                windowTitleProc.running = true
            }
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

                // Update media info
                refreshMediaState()
                mediaArtProc.running = true

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

        ${builtins.readFile ./panel.qml}

        Loader {
            id: uiLoader
            anchors.fill: parent
            sourceComponent: uiComponent
            property int reloadTrigger: themeEpoch
            onReloadTriggerChanged: {
                uiLoader.sourceComponent = null
                uiLoader.sourceComponent = uiComponent
            }
        }

        ${builtins.readFile ./menu.qml}

        ${builtins.readFile ./power.qml}
    
        ${builtins.readFile ./lock.qml}

        ${builtins.readFile ./osd.qml}
        
        IpcHandler {
            target: "shell"

            function lock() { sessionLock.locked = true }
            function controlPanel() { barPanel.openMenu = 1 }
            function powerMenu() { barPanel.openMenu = 2 }
        }
    }
  '';

  home.file.".config/quickshell/pam/password.conf".text = "auth required pam_unix.so";

}
