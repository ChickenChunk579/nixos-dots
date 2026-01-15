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
    import QtQuick.LocalStorage

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

        // System info
        property int cpuUsage: 0
        property real lastCpuTotal: 0
        property real lastCpuIdle: 0
        property string currentWindowTitle: ""
        property string cpuTemp: "0"
        property string memUsageStr: "0"
        property real memPercent: 0

        // Network
        property bool wifiOn: false
        property int wifiPercent: 0
        property string wifiIcon: "󰤯"

        // Time and date
        property string currentTime: Qt.formatTime(new Date(), "HH:mm:ss")
        property string currentDate: Qt.formatDate(new Date(), "dd/MM/yyyy")

        // Theme
        property string walPath: "/home/rhys/.cache/wal/colors.json"
        property int themeEpoch: 0

        // Media
        property string mediaTitle: ""
        property string mediaStatus: "Stopped"
        property real mediaPosition: 0
        property real mediaLength: 0
        property bool isPlaying: false
        property string mediaArtUrl: ""
        property string pipewireVolume: ""

        // Menu
        property int openMenu: 0

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
