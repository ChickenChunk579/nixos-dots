Component {
    id: uiComponent

    Item {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            spacing: 10

            // LEFT PILL
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
                    text: "󱄅"
                    color: fontColor
                    anchors.centerIn: parent
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
                        text: `  ${cpuUsage}%`
                        font.family: font
                        font.pixelSize: fontSize
                        color: fontColor
                        Layout.alignment: Qt.AlignVCenter // Proper way to align in RowLayout
                    }

                    Text {
                        id: memText

                        text: `  ${memUsageStr} GiB`
                        font.family: font
                        font.pixelSize: fontSize
                        color: fontColor
                        Layout.alignment: Qt.AlignVCenter // Removed anchors.centerIn (it was breaking layout)
                    }

                    Text {
                        id: cpuTempText

                        text: `󰔏  ${cpuTemp}°C`
                        font.family: font
                        font.pixelSize: fontSize
                        color: fontColor
                        Layout.alignment: Qt.AlignVCenter // Removed anchors.centerIn (it was breaking layout)
                    }

                }

            }

            // SPACER
            Item {
                Layout.fillWidth: true
            }

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
                        font.family: font
                        font.pixelSize: fontSize
                        text: `  ${pipewireVolume}`
                        color: fontColor
                    }

                    Text {
                        font.family: font
                        font.pixelSize: fontSize
                        text: `${wifiIcon}`
                        color: fontColor
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
                        font.family: font
                        font.pixelSize: fontSize
                        text: `  ${currentTime}`
                        color: fontColor
                    }

                    Text {
                        font.family: font
                        font.pixelSize: fontSize
                        text: `${currentDate}`
                        color: fontColor
                    }

                }

            }

            Rectangle {
                color: accentColor
                radius: panelHeight / 2
                Layout.preferredWidth: panelHeight // Makes it a perfect circle
                Layout.fillHeight: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: openMenu = openMenu == 0 ? 2 : 0
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    id: powerText

                    font.family: font
                    font.pixelSize: fontSize + 15
                    text: "󰐥"
                    color: fontColor
                    // Center the text inside this specific white rectangle
                    anchors.centerIn: parent
                }

            }

        }

        Rectangle {
            id: topPill

            property real maxWidth: parent.width * 0.4

            color: accentColor
            radius: panelHeight / 2
            z: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: panelHeight - 16
            width: Math.min(titleText.implicitWidth + 32, maxWidth)

            Row {
                id: contentItem

                anchors.centerIn: parent
                spacing: 10
                width: Math.min(titleText.implicitWidth, parent.width - 32)

                Text {
                    id: titleText

                    text: currentWindowTitle
                    color: fontColor
                    font.family: font
                    font.pixelSize: fontSize
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    width: parent.width
                }

            }

        }

    }

}