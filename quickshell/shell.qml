import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3._Ipc
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Widgets

ShellRoot {
	id: root

	readonly property string iconWifi: "\u{f05a9}"    // md-wifi
	readonly property string iconEth: "\u{f0200}"     // md-ethernet
	readonly property string iconNetOff: "\u{f0c9b}"  // md-network_off
	readonly property string iconCpu: "\u{f0ee0}"     // md-cpu_64_bit
	readonly property string iconMem: "\u{f035b}"     // md-memory

	// Notification state shared with the bar so its bottom outline can open a gap for the blob,
	// letting the outline trace one continuous contour across the bar and the notification.
	readonly property var notifScreen: Quickshell.screens[0]
	readonly property bool notifActive: (notifServer.trackedNotifications?.values.length ?? 0) > 0

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: bar

			required property var modelData
			readonly property var i3Monitor: I3.monitorFor(modelData)
			readonly property bool monitorKnown: i3Monitor !== null && i3Monitor !== undefined

			screen: modelData
			color: Theme.base00
			implicitHeight: Theme.barHeight
			exclusiveZone: Theme.barHeight
			exclusionMode: ExclusionMode.Normal

			anchors {
				top: true
				left: true
				right: true
			}

			Rectangle {
				anchors.fill: parent
				color: Theme.base00

				// Bottom outline, split into two segments with a centred gap where the
				// notification blob hangs, so the outline reads as one continuous contour
				// across the bar and the blob.
				Item {
					id: barOutline

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					height: Theme.borderWidth

					property real gap: root.notifActive && bar.modelData.name === root.notifScreen?.name ? Theme.notifWidth : 0
					Behavior on gap {
						NumberAnimation {
							duration: Theme.notifSpringDuration
							easing.type: Easing.OutCubic
						}
					}

					Rectangle {
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						height: parent.height
						width: Math.max(0, (parent.width - barOutline.gap) / 2)
						color: Theme.borderColor
					}

					Rectangle {
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						height: parent.height
						width: Math.max(0, (parent.width - barOutline.gap) / 2)
						color: Theme.borderColor
					}
				}

				Item {
					anchors.fill: parent
					anchors.leftMargin: Theme.barPadding
					anchors.rightMargin: Theme.barPadding

					RowLayout {
						id: leftGroup

						anchors.left: parent.left
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						spacing: Theme.workspaceSpacing

						Repeater {
							model: I3.workspaces

							delegate: Rectangle {
								id: ws

								required property var modelData
								readonly property bool onThisMonitor: !bar.monitorKnown || (modelData.monitor !== null && modelData.monitor.name === bar.i3Monitor.name)

								visible: onThisMonitor
								Layout.preferredWidth: visible ? Math.max(Theme.workspaceMinWidth, label.implicitWidth + Theme.workspaceLabelPadding) : 0
								Layout.preferredHeight: Theme.barHeight
								color: modelData.focused ? Theme.base02 : "transparent"

								Rectangle {
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.bottom: parent.bottom
									height: Theme.workspaceUnderlineHeight
									color: modelData.focused || modelData.active ? Theme.base05 : "transparent"
								}

								Text {
									id: label
									anchors.centerIn: parent
									text: modelData.name
									color: modelData.urgent ? Theme.base08 : Theme.base05
									font.family: Theme.fontFamily
									font.pointSize: Theme.fontSize
								}

								MouseArea {
									anchors.fill: parent
									enabled: ws.visible
									onClicked: ws.modelData.activate()
								}
							}
						}
					}

					Text {
						id: title
						anchors.centerIn: parent
						width: Math.round(parent.width * Theme.titleWidthFactor)
						height: parent.height
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						elide: Text.ElideRight
						text: focusedTitle.text
						color: Theme.base05
						font.family: Theme.fontFamily
						font.pointSize: Theme.fontSize
					}

					RowLayout {
						id: rightGroup

						anchors.right: parent.right
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						spacing: 0

						Repeater {
							model: SystemTray.items

							delegate: Rectangle {
								required property var modelData
								readonly property string iconSource: modelData.icon || ""

								Layout.preferredWidth: Theme.trayItemWidth
								Layout.preferredHeight: Theme.barHeight
								color: "transparent"
								visible: modelData.status !== 0

								IconImage {
									id: trayIcon

									anchors.centerIn: parent
									width: Theme.trayIconSize
									height: Theme.trayIconSize
									implicitSize: Theme.trayIconSize
									source: iconSource
									visible: iconSource !== "" && status !== Image.Error
									mipmap: true
								}

								Text {
									anchors.centerIn: parent
									text: trayFallbackText(modelData)
									visible: iconSource === "" || trayIcon.status === Image.Error
									color: Theme.base05
									font.family: Theme.fontFamily
									font.pointSize: Theme.fontSize
								}

								MouseArea {
									anchors.fill: parent
									acceptedButtons: Qt.LeftButton | Qt.RightButton
									onClicked: mouse => {
										if (mouse.button === Qt.RightButton && modelData.hasMenu) modelData.display(bar, parent.x, Theme.barHeight);
										else modelData.activate();
									}
								}
							}
						}

						BarText {
							text: (!networkd.online ? root.iconNetOff : networkd.wireless ? root.iconWifi : root.iconEth) + " " + networkd.text
							color: networkd.online ? Theme.base05 : Theme.base08
						}

						VolumeWidget {
							normalColor: Theme.base05
							mutedColor: Theme.base03
						}

						BarText {
							visible: UPower.displayDevice && UPower.displayDevice.isPresent
							text: batteryLabel()
							color: UPower.displayDevice && UPower.displayDevice.percentage <= 0.15 && UPower.onBattery ? Theme.base08 : Theme.base05
						}

						BarText {
							text: root.iconCpu + " " + cpu.text
							color: Theme.base05
						}

						BarText {
							text: root.iconMem + " " + memory.text
							color: Theme.base05
						}

						BarText {
							text: clock.text
							color: Theme.base05
						}
					}
				}
			}
		}
	}

	CommandPoller {
		id: clock
		interval: 1000
		command: ["date", "+%a %d %b %H:%M"]
	}

	CommandPoller {
		id: cpu
		interval: 5000
		command: ["bash", "-lc", "read _ u n s i rest < /proc/stat; t=$((u+n+s+i)); sleep 0.2; read _ u2 n2 s2 i2 rest < /proc/stat; t2=$((u2+n2+s2+i2)); d=$((t2-t)); idle=$((i2-i)); if [ \"$d\" -gt 0 ]; then printf '%d%%\\n' $((100*(d-idle)/d)); else echo '--'; fi"]
	}

	CommandPoller {
		id: memory
		interval: 5000
		command: ["awk", "/MemTotal/ { total=$2 } /MemAvailable/ { available=$2 } END { printf \"%d%%\\n\", (total - available) * 100 / total }", "/proc/meminfo"]
	}

	FocusedWindowTitle {
		id: focusedTitle
	}

	NetworkdStatus {
		id: networkd
		interval: 5000
	}

	NotificationServer {
		id: notifServer

		keepOnReload: false
		bodySupported: true
		bodyMarkupSupported: true
		imageSupported: true
		actionsSupported: false

		onNotification: notification => {
			notification.tracked = true;
		}
	}

	NotificationPopups {
		server: notifServer
		screen: root.notifScreen
	}

	function batteryLabel() {
		const battery = UPower.displayDevice;
		if (!battery || !battery.isPresent) return "";

		const state = battery.state === UPowerDeviceState.Charging ? " AC" : "";
		return "BAT " + Math.round(battery.percentage * 100) + "%" + state;
	}

	function trayFallbackText(item) {
		const label = item.tooltipTitle || item.title || item.id || "?";
		return label.length > 0 ? label[0].toUpperCase() : "?";
	}
}
