PopupWindow {
    id: nixMenuPanel

    visible: barPanel.openMenu === 1

      onVisibleChanged: {
          if (visible) fadeIn.start()
          else fadeOut.start()
      }

      width: 500
      height: 375

      anchor.window: barPanel
      anchor.rect.x: 10
      anchor.rect.y: panelHeight + 5

      color: "transparent"

      Rectangle {
          id: panelBackground
          anchors.fill: parent
          radius: 12
          color: backgroundColor
          opacity: 0   // start hidden

          Column {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10
              
              RowLayout {
                  width: parent.width
                  spacing: 10

                  ColumnLayout {
                      spacing: 2

                      Text {
                          text: currentTime
                          font.family: font
                          font.pixelSize: fontSize + 10
                          color: fontColor
                      }
                      Text {
                          text: currentDate
                          font.family: font
                          font.pixelSize: fontSize
                          color: fontColor
                      }
                  }

                  Item { Layout.fillWidth: true }  // pushes next text to the right

                  Text {
                      text: "Rhys"
                      font.family: font
                      font.pixelSize: fontSize
                      color: fontColor
                  }

                  Rectangle {
                      id: nixButton
                      color: accentColor
                      radius: panelHeight / 2
                      Layout.preferredWidth: panelHeight
                      Layout.fillHeight: true

                      MouseArea {
                          anchors.fill: parent
                          onClicked: openMenu = openMenu == 0 ? 1 : 0
                          cursorShape: Qt.PointingHandCursor
                      }

                      Text {
                          id: logoText
                          font.family: font
                          font.pixelSize: fontSize + 15
                          text: "⏻"
                          color: fontColor
                          anchors.centerIn: parent
                      }
                  }
              }

              
              Item {
                  id: volumeSliderRoot // Explicit ID to prevent global naming collisions
                  width: parent.width
                  implicitHeight: 48

                  property real internalValue: 0

                  // Force internalValue to track system volume when NOT dragging
                  Binding {
                      target: volumeSliderRoot
                      property: "internalValue"
                      value: (parseInt(pipewireVolume) || 0) / 100
                      when: !volumeMouseArea.pressed
                  }

                  // 1. Unfilled track
                  Rectangle {
                      width: parent.width
                      height: 12
                      radius: 6
                      color: lighterBackgroundColor
                      anchors.verticalCenter: parent.verticalCenter
                  }

                  // 2. Filled track
                  Rectangle {
                      // Explicitly use the root ID
                      width: volumeThumb.x + (volumeThumb.width / 2) + 24
                      height: 48 
                      radius: 24
                      color: accentColor
                      anchors.verticalCenter: parent.verticalCenter

                      Behavior on width {
                          enabled: !volumeMouseArea.pressed
                          NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                      }
                  }

                  // 3. Thumb
                  Rectangle {
                      id: volumeThumb
                      width: 48
                      height: 48
                      radius: 24
                      color: accentColor
                      anchors.verticalCenter: parent.verticalCenter
                      
                      // Use the explicit root property
                      x: (parent.width - width) * volumeSliderRoot.internalValue

                      Behavior on x {
                          enabled: !volumeMouseArea.pressed
                          NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                      }

                      Text {
                          anchors.centerIn: parent
                          text: ""
                          color: fontColor
                          font.pixelSize: 18
                      }
                  }

                  MouseArea {
                      id: volumeMouseArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor

                      onPressed: (mouse) => updateVolume(mouse.x)
                      onPositionChanged: (mouse) => {
                          if (pressed) updateVolume(mouse.x)
                      }

                      function updateVolume(mouseX) {
                          var percent = Math.max(0, Math.min(100, Math.round((mouseX / width) * 100)))
                          
                          // Update the EXPLICIT ID property
                          volumeSliderRoot.internalValue = percent / 100
                          
                          var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', volumeMouseArea)
                          proc.command = ["sh", "-c", "wpctl set-volume @DEFAULT_SINK@ " + percent + "%"]
                          proc.running = true
                      }
                  }
              }

              Row {
                  width: parent.width
                  spacing: 10

                  Rectangle {
                      id: wifiToggleButton
                      width: (parent.width - parent.spacing) / 2
                      height: 50
                      radius: 25

                      property bool wifiOn: false

                      // Direct reactive color based on wifiOn
                      color: wifiToggleButton.wifiOn ? accentColor : lighterBackgroundColor

                      Behavior on color {
                          ColorAnimation { duration: 200 }
                      }

                      Text {
                          id: wifiLabel
                          anchors.centerIn: parent
                          text: wifiToggleButton.wifiOn ? `${wifiIcon}  Wi-Fi` : "󰖪  Wi-Fi"
                          color: fontColor
                          font.pixelSize: 18
                      }

                      MouseArea {
                          anchors.fill: parent
                          onClicked: {
                              if (wifiToggleButton.wifiOn) {
                                  wifiTurnOff.running = true
                              } else {
                                  wifiTurnOn.running = true
                              }
                          }
                      }

                      Component.onCompleted: wifiCheck.running = true

                      Timer {
                          interval: 2000
                          running: true
                          repeat: true
                          onTriggered: wifiCheck.running = true
                      }

                      Process {
                          id: wifiCheck
                          command: ["bash", "-lc", "nmcli radio wifi"]
                          stdout: SplitParser { 
                              onRead: { 
                                  var enabled = data.trim().toLowerCase() === "enabled"
                                  wifiToggleButton.wifiOn = enabled
                              } 
                          }
                          stderr: SplitParser { onRead: { console.log("CHECK WIFI ERROR:", data) } }
                      }

                      Process {
                          id: wifiTurnOn
                          command: ["bash", "-lc", "nmcli radio wifi on"]
                          onExited: { 
                              Qt.callLater(function() { wifiCheck.running = true })
                          }
                          stderr: SplitParser { onRead: { console.log("TURN ON ERROR:", data) } }
                      }

                      Process {
                          id: wifiTurnOff
                          command: ["bash", "-lc", "nmcli radio wifi off"]
                          onExited: { 
                              Qt.callLater(function() { wifiCheck.running = true })
                          }
                          stderr: SplitParser { onRead: { console.log("TURN OFF ERROR:", data) } }
                      }
                  }

                  Rectangle {
                      id: bluetoothToggleButton
                      width: (parent.width - parent.spacing) / 2
                      height: 50
                      radius: 25

                      property bool bluetoothOn: false

                      // Direct reactive color based on bluetoothOn
                      color: bluetoothToggleButton.bluetoothOn ? accentColor : lighterBackgroundColor

                      Behavior on color {
                          ColorAnimation { duration: 200 }
                      }

                      Text {
                          id: bluetoothLabel
                          anchors.centerIn: parent
                          text: bluetoothToggleButton.bluetoothOn ? "󰂯  Bluetooth" : "󰂲  Bluetooth"
                          color: fontColor
                          font.pixelSize: 18
                      }

                      MouseArea {
                          anchors.fill: parent
                          onClicked: {
                              if (bluetoothToggleButton.bluetoothOn) {
                                  bluetoothTurnOff.running = true
                              } else {
                                  bluetoothTurnOn.running = true
                              }
                          }
                      }

                      Component.onCompleted: bluetoothCheck.running = true

                      Timer {
                          interval: 2000
                          running: true
                          repeat: true
                          onTriggered: bluetoothCheck.running = true
                      }

                      Process {
                          id: bluetoothCheck
                          command: ["bash", "-lc", "bluetoothctl show | grep -q 'Powered: yes' && echo 'on' || echo 'off'"]
                          stdout: SplitParser { 
                              onRead: { 
                                  var enabled = data.trim().toLowerCase() === "on"
                                  bluetoothToggleButton.bluetoothOn = enabled
                              } 
                          }
                          stderr: SplitParser { onRead: { console.log("CHECK BLUETOOTH ERROR:", data) } }
                      }

                      Process {
                          id: bluetoothTurnOn
                          command: ["bash", "-lc", "bluetoothctl power on"]
                          onExited: { 
                              Qt.callLater(function() { bluetoothCheck.running = true })
                          }
                          stderr: SplitParser { onRead: { console.log("TURN ON ERROR:", data) } }
                      }

                      Process {
                          id: bluetoothTurnOff
                          command: ["bash", "-lc", "bluetoothctl power off"]
                          onExited: { 
                              Qt.callLater(function() { bluetoothCheck.running = true })
                          }
                          stderr: SplitParser { onRead: { console.log("TURN OFF ERROR:", data) } }
                      }
                  }
              }

              // Media widget
              RowLayout {
                  width: parent.width
                  height: 120  // same as album cover
                  spacing: 16   // optional, space between cover and text/buttons


                  // Album cover
                  Rectangle {
                      width: 120
                      height: 120
                      radius: 8
                      color: lighterBackgroundColor
                      Layout.alignment: Qt.AlignVCenter

                      Image {
                          anchors.fill: parent
                          source: mediaArtUrl
                          fillMode: Image.PreserveAspectCrop
                          asynchronous: true
                      }
                  }

                  ColumnLayout {
                      Layout.fillHeight: true
                      Layout.fillWidth: true
                      spacing: 8

                      Text {
                          text: mediaTitle.length > 0 ? mediaTitle : "No media playing"
                          font.family: font
                          font.pixelSize: fontSize
                          color: fontColor
                          elide: Text.ElideRight
                          maximumLineCount: 1
                          width: parent.width
                          Layout.fillWidth: true
                      }

                      Row {
                          anchors.horizontalCenter: parent.horizontalCenter
                          spacing: 10
                          Layout.alignment: Qt.AlignVCenter

                      Rectangle {
                          id: prevButton
                          width: 50
                          height: 50
                          radius: 25
                          color: lighterBackgroundColor

                          Text {
                              anchors.centerIn: parent
                              text: "󰒮"
                              color: fontColor
                              font.pixelSize: 20
                          }

                          MouseArea {
                              anchors.fill: parent
                              onClicked: {
                                  var proc = Qt.createQmlObject(
                                      'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                                      prevButton
                                  )
                                  proc.command = ["bash", "-lc", "playerctl previous"]
                                  proc.running = true
                              }
                          }
                      }

                      Rectangle {
                          id: playPauseButton
                          width: 50
                          height: 50
                          radius: 25
                          color: accentColor

                          Text {
                              anchors.centerIn: parent
                              text: isPlaying ? "󰏤" : "󰐊"
                              color: fontColor
                              font.pixelSize: 20
                          }

                          MouseArea {
                              anchors.fill: parent
                              onClicked: {
                                  var proc = Qt.createQmlObject(
                                      'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                                      playPauseButton
                                  )
                                  proc.command = ["bash", "-lc", "playerctl play-pause"]
                                  proc.running = true
                              }
                          }
                      }

                      Rectangle {
                          id: nextButton
                          width: 50
                          height: 50
                          radius: 25
                          color: lighterBackgroundColor

                          Text {
                              anchors.centerIn: parent
                              text: "󰒭"
                              color: fontColor
                              font.pixelSize: 20
                          }

                          MouseArea {
                              anchors.fill: parent
                              onClicked: {
                                  var proc = Qt.createQmlObject(
                                      'import Quickshell.Io; Process { onExited: { barPanel.refreshMediaState() } }',
                                      nextButton
                                  )
                                  proc.command = ["bash", "-lc", "playerctl next"]
                                  proc.running = true
                              }
                          }
                      }
                  }
              }
          }
          }
      }

      NumberAnimation {
          id: fadeIn
          target: panelBackground
          property: "opacity"
          to: 1
          duration: 160
          easing.type: Easing.InOutQuad
      }

      NumberAnimation {
          id: fadeOut
          target: panelBackground
          property: "opacity"
          to: 0
          duration: 120
          easing.type: Easing.InOutQuad
      }
  }
