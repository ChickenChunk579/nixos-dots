PanelWindow {
    id: centeredPanel

    visible: barPanel.openMenu === 2

      onVisibleChanged: {
          if (visible) fadeInPower.start()
          else fadeOutPower.start()
      }

      // React to state changes
      Connections {
          target: barPanel

          function onPowerMenuChanged() {
              if (barPanel.powerMenu && !barPanel.nixMenuOpen) {
                  fadeInPower.start()
              } else {
                  fadeOutPower.start()
              }
          }

          function onNixMenuOpenChanged() {
              if (barPanel.nixMenuOpen) {
                  fadeOutPower.start()
              }
          }
      }


      Connections {
          target: centeredPanel
          function onActiveChanged() {
              if (!centeredPanel.active) {
                  barPanel.openMenu = 0
              }
          }
      }

      // Explicit size instead of anchors.fill
      width: 600
      height: 300

      surfaceFormat: QsWindow.RGBA8888
      color: "transparent"

      property color fontColor: "white"
      property color backgroundColor: Qt.rgba(0.1, 0.1, 0.1, 0.7)

      Rectangle {
          id: powerMenuBackground
          anchors.fill: parent
          color: backgroundColor
          radius: height / 2   // pill shape

          Row {
              anchors.centerIn: parent
              spacing: 60

              // --- Shutdown ---
              Rectangle {
                  width: 60
                  height: 60
                  color: "transparent"

                  Text {
                      anchors.centerIn: parent
                      text: "\uf011"  // Nerd Font power icon
                      font.family: "FiraCode Nerd Font"
                      font.pixelSize: 80
                      color: fontColor
                      Behavior on color { ColorAnimation { duration: 200 } }
                  }

                  MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: {
                          console.log("Shutdown triggered")
                          var proc = Qt.createQmlObject(
                              'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                              playPauseButton
                          )
                          proc.command = ["bash", "-lc", "shutdown", "now"]
                          proc.running = true
                          barPanel.openMenu = 0
                      }
                      onEntered: parent.children[0].color = "#ff5555"
                      onExited: parent.children[0].color = fontColor
                  }
              }

              // --- Reboot ---
              Rectangle {
                  width: 60
                  height: 60
                  color: "transparent"

                  Text {
                      anchors.centerIn: parent
                      text: "\uf021"  // Nerd Font redo icon
                      font.family: "FiraCode Nerd Font"
                      font.pixelSize: 80
                      color: fontColor
                      Behavior on color { ColorAnimation { duration: 200 } }
                  }

                  MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: {
                          console.log("Reboot triggered")
                          var proc = Qt.createQmlObject(
                              'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                              playPauseButton
                          )
                          proc.command = ["bash", "-lc", "reboot"]
                          proc.running = true
                          barPanel.openMenu = 0
                      }
                      onEntered: parent.children[0].color = "#ffaa00"
                      onExited: parent.children[0].color = fontColor
                  }
              }

              // --- Lock ---
              Rectangle {
                  width: 60
                  height: 60
                  color: "transparent"

                  Text {
                      anchors.centerIn: parent
                      text: "\uf023"  // Nerd Font lock icon
                      font.family: "FiraCode Nerd Font"
                      font.pixelSize: 80
                      color: fontColor
                      Behavior on color { ColorAnimation { duration: 200 } }
                  }

                  MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: {
                          console.log("Lock triggered")
                          sessionLock.locked = true
                          barPanel.openMenu = 0
                      }
                      onEntered: parent.children[0].color = "#55ff55"
                      onExited: parent.children[0].color = fontColor
                  }
              }

              // --- Sleep ---
              Rectangle {
                  width: 60
                  height: 60
                  color: "transparent"

                  Text {
                      anchors.centerIn: parent
                      text: "\uf186"  // Nerd Font moon/sleep icon
                      font.family: "FiraCode Nerd Font"
                      font.pixelSize: 80
                      color: fontColor
                      Behavior on color { ColorAnimation { duration: 200 } }
                  }

                  MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: {
                          console.log("Sleep triggered")
                          var proc = Qt.createQmlObject(
                              'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                              playPauseButton
                          )
                          proc.command = [
                              "dbus-send", "--system", "--print-reply", 
                              "--dest=org.freedesktop.login1", 
                              "/org/freedesktop/login1", 
                              "org.freedesktop.login1.Manager.Suspend", 
                              "boolean:true"
                          ]
                          proc.running = true
                          barPanel.openMenu = 0
                      }
                      onEntered: parent.children[0].color = "#5555ff"
                      onExited: parent.children[0].color = fontColor
                  }
              }
          }
      }


      NumberAnimation {
          id: fadeInPower
          target: panelBackground
          property: "opacity"
          to: 1
          duration: 160
          easing.type: Easing.InOutQuad
      }

      NumberAnimation {
          id: fadeOutPower
          target: panelBackground
          property: "opacity"
          to: 0
          duration: 120
          easing.type: Easing.InOutQuad
      }
  }
