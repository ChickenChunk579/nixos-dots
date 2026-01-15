    // 1. Move PAM here so it's globally visible to all surfaces
    PamContext {
        id: pam
          configDirectory: "/home/rhys/.config/quickshell/pam"
          config: "password.conf"
          
          onCompleted: result => {
              if (result === PamResult.Success) {
                  sessionLock.locked = false;
              } else {
                  pam.active = false;
                  // passwordInput.text = ""; // We'll handle this in the UI
              }
          }
      }

      WlSessionLock {
          id: sessionLock
          locked: false

          WlSessionLockSurface {
              Rectangle {
                  anchors.fill: parent
                  color: backgroundColor

                  Image {
                      id: bgImage
                      anchors.fill: parent
                      source: "file:///home/rhys/wallpaper.png"
                      fillMode: Image.PreserveAspectCrop
                      smooth: true
                      visible: false   // IMPORTANT: hide original
                      layer.enabled: true
                  }

                  MultiEffect {
                      anchors.fill: parent
                      source: bgImage
                      blurEnabled: true
                      blur: 0.7
                      blurMax: 96
                  }

                  Column {
                      anchors.centerIn: parent
                      spacing: 15

                      Text { 
                          text: pam.messageIsError ? pam.message : `${currentTime}`
                          color: pam.messageIsError ? "red" : "white"
                          font.family: font
                          font.pixelSize: fontSize + 35
                          anchors.horizontalCenter: parent.horizontalCenter
                      }

                      Text { 
                          text: `${currentDate}`
                          color: fontColor
                          font.family: font
                          font.pixelSize: fontSize + 15
                          anchors.horizontalCenter: parent.horizontalCenter
                      }

                      Item {
                          height: 400    // 👈 gap
                          width: 1
                      }

                      Rectangle {
                          id: lockScreenPasswordBackground
                          width: 300
                          height: 64
                          color: lighterBackgroundColor
                          radius: height / 2

                          TextField {
                              id: passwordInput
                              anchors.fill: parent
                              anchors.margins: 14

                              echoMode: TextField.Password
                              focus: true

                              font.pixelSize: fontSize

                              color: "white"          // text color

                              horizontalAlignment: Text.AlignHCenter
                              verticalAlignment: Text.AlignVCenter

                              background: null
                              onAccepted: {
                                  if (pam.active) pam.respond(text);
                                  text = ""; 
                              }
                              onTextChanged: {
                                  if (!pam.active && text.length > 0) pam.active = true;
                              }
                          }
                      }
                  }
                  
                  // Allow physical Escape key to also bypass
                  Keys.onEscapePressed: {
                      sessionLock.locked = false;
                      Qt.quit();
                  }
              }
          }
      }
