Scope {
	id: notificationRoot

	/* =========================
	 * State
	 * ========================= */
	property var notifications: []

	function pushNotification(n) {
		notifications.unshift({
			id: n.id,
			appName: n.appName,
			summary: n.summary,
			body: n.body,
			icon: n.icon
		})

		removeTimer.restart()
	}

	/* =========================
	 * Notification backend
	 * ========================= */
	Connections {
		target: NotificationServer

		onNotification: (n) => {
			pushNotification(n)
		}
	}

	/* =========================
	 * Auto removal
	 * ========================= */
	Timer {
		id: removeTimer
		interval: 5000
		onTriggered: {
			if (notificationRoot.notifications.length > 0)
				notificationRoot.notifications.pop()
		}
	}

	/* =========================
	 * Notification window
	 * ========================= */
	LazyLoader {
		active: notificationRoot.notifications.length > 0

		PanelWindow {
			anchors.bottom: true
			margins.bottom: 140
			exclusiveZone: 0

			implicitWidth: 420
			color: "transparent"
			mask: Region {}

			Column {
				spacing: 12

				Repeater {
					model: notificationRoot.notifications

					Rectangle {
						width: 420
						radius: 16
						color: barPanel.backgroundColor
						implicitHeight: content.implicitHeight + 24

						RowLayout {
							id: content
							anchors.fill: parent
							anchors.margins: 16
							spacing: 12

							/* Icon */
							Image {
								source: modelData.icon
								visible: source !== ""
								width: 32
								height: 32
								fillMode: Image.PreserveAspectFit
							}

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 4

								Text {
									text: modelData.summary
									font.family: barPanel.font
									font.pixelSize: 16
									font.bold: true
									color: barPanel.accentColor
									elide: Text.ElideRight
								}

								Text {
									text: modelData.body
									font.family: barPanel.font
									font.pixelSize: 14
									color: "#ffffff"
									wrapMode: Text.Wrap
								}
							}
						}
					}
				}
			}
		}
	}
}
