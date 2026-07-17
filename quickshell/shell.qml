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

	// Font
	readonly property string fontFamily: "{{ fonts.monospace }}"
	readonly property int fontSize: 12

	// Palette
	readonly property color base00: "#{{ colors.base00 }}"
	readonly property color base01: "#{{ colors.base01 }}"
	readonly property color base02: "#{{ colors.base02 }}"
	readonly property color base03: "#{{ colors.base03 }}"
	readonly property color base05: "#{{ colors.base05 }}"
	readonly property color base08: "#{{ colors.base08 }}"
	readonly property color base0B: "#{{ colors.base0B }}"
	readonly property color base0D: "#{{ colors.base0D }}"
	readonly property color base0E: "#{{ colors.base0E }}"

	// Shared sizing
	readonly property int borderWidth: 1
	readonly property color borderColor: base02
	readonly property int barHeight: 32
	readonly property int barPadding: 6
	readonly property int widgetHeight: 28
	readonly property int widgetPadding: 5
	readonly property int trayItemWidth: 22
	readonly property int trayIconSize: 16
	readonly property int workspaceSpacing: 2
	readonly property int workspaceMinWidth: 28
	readonly property int workspaceLabelPadding: 14
	readonly property int workspaceUnderlineHeight: 3
	readonly property real titleWidthFactor: 0.42
	readonly property int notifWidth: 380
	readonly property int notifPadding: 14
	readonly property int notifRadius: 18
	readonly property int notifIconSize: 40
	readonly property int notifTimeout: 5000
	readonly property color notifSurface: base00
	readonly property int notifSpringDuration: 500
	readonly property int notifFadeDuration: 200

	readonly property string iconWifi: "\u{f05a9}"
	readonly property string iconEth: "\u{f0200}"
	readonly property string iconNetOff: "\u{f0c9b}"
	readonly property string iconCpu: "\u{f0ee0}"
	readonly property string iconMem: "\u{f035b}"

	readonly property var notifScreen: Quickshell.screens[0]
	readonly property bool notifActive: (notifServer.trackedNotifications?.values.length ?? 0) > 0

	Component {
		id: notificationCardComponent

		Item {
			id: card

			required property var modelData
			readonly property var notif: modelData
			readonly property bool critical: notif.urgency === NotificationUrgency.Critical

			implicitWidth: root.notifWidth
			implicitHeight: layout.implicitHeight + root.notifPadding * 2

			function close() {
				notif.dismiss();
			}

			function iconSource() {
				if (notif.image && notif.image.length > 0)
					return notif.image;

				const icon = notif.appIcon || "";
				if (icon.length === 0)
					return "";
				if (icon[0] === "/" || icon.indexOf("file:") === 0 || icon.indexOf("image:") === 0 || icon.indexOf("qrc:") === 0)
					return icon;

				return Quickshell.iconPath(icon, true);
			}

			Timer {
				interval: card.notif.expireTimeout > 0 ? card.notif.expireTimeout : root.notifTimeout
				running: !card.critical && !hover.hovered
				onTriggered: card.close()
			}

			Rectangle {
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: root.notifPadding
				anchors.rightMargin: root.notifPadding
				height: 1
				visible: card.y > 0
				color: root.base02
			}

			HoverHandler {
				id: hover
			}

			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton
				onClicked: card.close()
			}

			RowLayout {
				id: layout

				anchors.fill: parent
				anchors.margins: root.notifPadding
				spacing: root.notifPadding

				IconImage {
					visible: source.toString().length > 0
					source: card.iconSource()
					implicitSize: root.notifIconSize
					Layout.alignment: Qt.AlignTop
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					Text {
						Layout.fillWidth: true
						text: card.notif.summary
						color: root.base05
						font.family: root.fontFamily
						font.pointSize: root.fontSize
						font.bold: true
						elide: Text.ElideRight
						maximumLineCount: 2
						wrapMode: Text.Wrap
					}

					Text {
						Layout.fillWidth: true
						visible: text.length > 0
						text: card.notif.body
						textFormat: Text.StyledText
						color: root.base05
						font.family: root.fontFamily
						font.pointSize: root.fontSize - 2
						wrapMode: Text.Wrap
						elide: Text.ElideRight
						maximumLineCount: 4
					}

					Text {
						Layout.fillWidth: true
						visible: text.length > 0
						text: card.notif.appName
						color: root.base03
						font.family: root.fontFamily
						font.pointSize: root.fontSize - 3
						elide: Text.ElideRight
					}
				}
			}
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: bar

			required property var modelData
			readonly property var i3Monitor: I3.monitorFor(modelData)
			readonly property bool monitorKnown: i3Monitor !== null && i3Monitor !== undefined

			screen: modelData
			color: root.base00
			implicitHeight: root.barHeight
			exclusiveZone: root.barHeight
			exclusionMode: ExclusionMode.Normal

			anchors {
				top: true
				left: true
				right: true
			}

			Rectangle {
				anchors.fill: parent
				color: root.base00

				Item {
					id: barOutline

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					height: root.borderWidth

					property real gap: root.notifActive && bar.modelData.name === root.notifScreen?.name ? root.notifWidth : 0

					Behavior on gap {
						NumberAnimation {
							duration: root.notifSpringDuration
							easing.type: Easing.OutCubic
						}
					}

					Rectangle {
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						height: parent.height
						width: Math.max(0, (parent.width - barOutline.gap) / 2)
						color: root.borderColor
					}

					Rectangle {
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						height: parent.height
						width: Math.max(0, (parent.width - barOutline.gap) / 2)
						color: root.borderColor
					}
				}

				Item {
					anchors.fill: parent
					anchors.leftMargin: root.barPadding
					anchors.rightMargin: root.barPadding

					RowLayout {
						anchors.left: parent.left
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						spacing: root.workspaceSpacing

						Repeater {
							model: I3.workspaces

							delegate: Rectangle {
								id: ws

								required property var modelData
								readonly property bool onThisMonitor: !bar.monitorKnown || (modelData.monitor !== null && modelData.monitor.name === bar.i3Monitor.name)

								visible: onThisMonitor
								Layout.preferredWidth: visible ? Math.max(root.workspaceMinWidth, label.implicitWidth + root.workspaceLabelPadding) : 0
								Layout.preferredHeight: root.barHeight
								color: modelData.focused ? root.base02 : "transparent"

								Rectangle {
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.bottom: parent.bottom
									height: root.workspaceUnderlineHeight
									color: modelData.focused || modelData.active ? root.base05 : "transparent"
								}

								Text {
									id: label
									anchors.centerIn: parent
									text: modelData.name
									color: modelData.urgent ? root.base08 : root.base05
									font.family: root.fontFamily
									font.pointSize: root.fontSize
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
						anchors.centerIn: parent
						width: Math.round(parent.width * root.titleWidthFactor)
						height: parent.height
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						elide: Text.ElideRight
						text: focusedTitle.text
						color: root.base05
						font.family: root.fontFamily
						font.pointSize: root.fontSize
					}

					RowLayout {
						anchors.right: parent.right
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						spacing: 0

						Repeater {
							model: SystemTray.items

							delegate: Rectangle {
								required property var modelData
								readonly property string iconSource: modelData.icon || ""

								Layout.preferredWidth: root.trayItemWidth
								Layout.preferredHeight: root.barHeight
								color: "transparent"
								visible: modelData.status !== 0

								IconImage {
									id: trayIcon

									anchors.centerIn: parent
									width: root.trayIconSize
									height: root.trayIconSize
									implicitSize: root.trayIconSize
									source: iconSource
									visible: iconSource !== "" && status !== Image.Error
									mipmap: true
								}

								Text {
									anchors.centerIn: parent
									text: trayFallbackText(modelData)
									visible: iconSource === "" || trayIcon.status === Image.Error
									color: root.base05
									font.family: root.fontFamily
									font.pointSize: root.fontSize
								}

								MouseArea {
									anchors.fill: parent
									acceptedButtons: Qt.LeftButton | Qt.RightButton
									onClicked: mouse => {
										if (mouse.button === Qt.RightButton && modelData.hasMenu) modelData.display(bar, parent.x, root.barHeight);
										else modelData.activate();
									}
								}
							}
						}

						Text {
							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							font.family: root.fontFamily
							font.pointSize: root.fontSize
							elide: Text.ElideRight
							text: (!networkd.online ? root.iconNetOff : networkd.wireless ? root.iconWifi : root.iconEth) + " " + networkd.text
							color: networkd.online ? root.base05 : root.base08
						}

						Text {
							id: volumeWidget

							property bool muted: false
							property int volume: -1

							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							text: muted ? "\u{f075f} mute" : "\u{f057e} " + (volume >= 0 ? volume + "%" : "--")
							color: muted ? root.base03 : root.base05
							font.family: root.fontFamily
							font.pointSize: root.fontSize

							Process {
								id: readVolume
								command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
								stdout: StdioCollector {
									id: volumeOut
								}

								onExited: {
									const output = volumeOut.text.trim();
									const match = output.match(/Volume:\s+([0-9.]+)/);
									volumeWidget.volume = match ? Math.round(Number(match[1]) * 100) : -1;
									volumeWidget.muted = output.indexOf("[MUTED]") !== -1;
								}
							}

							Process {
								id: setVolume
								onExited: readVolume.exec(readVolume.command)
							}

							Process {
								id: openMixer
								command: ["pavucontrol"]
							}

							Timer {
								interval: 2000
								repeat: true
								running: true
								triggeredOnStart: true
								onTriggered: {
									if (!readVolume.running) readVolume.exec(readVolume.command);
								}
							}

							MouseArea {
								anchors.fill: parent
								acceptedButtons: Qt.LeftButton
								onClicked: openMixer.startDetached()
								onWheel: wheel => {
									if (setVolume.running) return;

									const delta = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
									setVolume.exec(["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", delta]);
									wheel.accepted = true;
								}
							}
						}

						Text {
							visible: UPower.displayDevice && UPower.displayDevice.isPresent
							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							font.family: root.fontFamily
							font.pointSize: root.fontSize
							elide: Text.ElideRight
							text: batteryLabel()
							color: UPower.displayDevice && UPower.displayDevice.percentage <= 0.15 && UPower.onBattery ? root.base08 : root.base05
						}

						Text {
							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							font.family: root.fontFamily
							font.pointSize: root.fontSize
							elide: Text.ElideRight
							text: root.iconCpu + " " + cpu.text
							color: root.base05
						}

						Text {
							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							font.family: root.fontFamily
							font.pointSize: root.fontSize
							elide: Text.ElideRight
							text: root.iconMem + " " + memory.text
							color: root.base05
						}

						Text {
							Layout.preferredHeight: root.widgetHeight
							Layout.alignment: Qt.AlignVCenter
							leftPadding: root.widgetPadding
							rightPadding: root.widgetPadding
							verticalAlignment: Text.AlignVCenter
							font.family: root.fontFamily
							font.pointSize: root.fontSize
							elide: Text.ElideRight
							text: clock.text
							color: root.base05
						}
					}
				}
			}
		}
	}

	QtObject {
		id: clock

		property var command: ["date", "+%a %d %b %H:%M"]
		property int interval: 1000
		property string text: ""

		property Process process: Process {
			command: clock.command
			stdout: StdioCollector {
				id: clockStdout
			}

			onExited: {
				const value = clockStdout.text.trim();
				if (value.length > 0) clock.text = value;
			}
		}

		property Timer timer: Timer {
			interval: clock.interval
			repeat: true
			running: true
			triggeredOnStart: true
			onTriggered: {
				if (!clock.process.running) clock.process.exec(clock.command);
			}
		}
	}

	QtObject {
		id: cpu

		property var command: ["bash", "-lc", "read _ u n s i rest < /proc/stat; t=$((u+n+s+i)); sleep 0.2; read _ u2 n2 s2 i2 rest < /proc/stat; t2=$((u2+n2+s2+i2)); d=$((t2-t)); idle=$((i2-i)); if [ \"$d\" -gt 0 ]; then printf '%d%%\\n' $((100*(d-idle)/d)); else echo '--'; fi"]
		property int interval: 5000
		property string text: ""

		property Process process: Process {
			command: cpu.command
			stdout: StdioCollector {
				id: cpuStdout
			}

			onExited: {
				const value = cpuStdout.text.trim();
				if (value.length > 0) cpu.text = value;
			}
		}

		property Timer timer: Timer {
			interval: cpu.interval
			repeat: true
			running: true
			triggeredOnStart: true
			onTriggered: {
				if (!cpu.process.running) cpu.process.exec(cpu.command);
			}
		}
	}

	QtObject {
		id: memory

		property var command: ["awk", "/MemTotal/ { total=$2 } /MemAvailable/ { available=$2 } END { printf \"%d%%\\n\", (total - available) * 100 / total }", "/proc/meminfo"]
		property int interval: 5000
		property string text: ""

		property Process process: Process {
			command: memory.command
			stdout: StdioCollector {
				id: memoryStdout
			}

			onExited: {
				const value = memoryStdout.text.trim();
				if (value.length > 0) memory.text = value;
			}
		}

		property Timer timer: Timer {
			interval: memory.interval
			repeat: true
			running: true
			triggeredOnStart: true
			onTriggered: {
				if (!memory.process.running) memory.process.exec(memory.command);
			}
		}
	}

	QtObject {
		id: focusedTitle

		property string text: ""

		property Process readTitle: Process {
			command: ["bash", "-lc", "swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name // empty' 2>/dev/null || true"]
			stdout: StdioCollector {
				id: titleOut
			}

			onExited: focusedTitle.text = titleOut.text.trim()
		}

		property Timer refreshDebounce: Timer {
			interval: 25
			repeat: false
			onTriggered: {
				if (!focusedTitle.readTitle.running) focusedTitle.readTitle.exec(focusedTitle.readTitle.command);
			}
		}

		property I3IpcListener listener: I3IpcListener {
			subscriptions: ["window", "workspace"]
			onIpcEvent: event => {
				if (event.type === "window" || event.type === "workspace") focusedTitle.refreshDebounce.restart();
			}
		}

		Component.onCompleted: refreshDebounce.restart()
	}

	QtObject {
		id: networkd

		property int interval: 5000
		property string text: "--"
		property string linkName: ""
		property string address: ""
		property string state: "unknown"
		property bool online: false
		property bool wireless: false
		readonly property string scriptPath: Qt.resolvedUrl("scripts/networkd-status.sh").toString().replace("file://", "")

		property Process process: Process {
			command: ["bash", networkd.scriptPath]
			stdout: StdioCollector {
				id: networkdStdout
			}

			onExited: {
				const lines = networkdStdout.text.trim().split("\n");
				const payload = lines.length > 0 ? lines[lines.length - 1] : "";

				try {
					const status = JSON.parse(payload);
					networkd.linkName = status.name || "";
					networkd.address = status.address || "";
					networkd.state = status.state || "unknown";
					networkd.online = status.online === true;
					networkd.wireless = status.wireless === true;
					networkd.text = status.text || "--";
				} catch (error) {
					networkd.linkName = "";
					networkd.address = "";
					networkd.state = "error";
					networkd.online = false;
					networkd.wireless = false;
					networkd.text = "error";
				}
			}
		}

		property Timer timer: Timer {
			interval: networkd.interval
			repeat: true
			running: true
			triggeredOnStart: true
			onTriggered: {
				if (!networkd.process.running) networkd.process.exec(networkd.process.command);
			}
		}
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

	PanelWindow {
		id: notificationPopups

		property var server: notifServer
		readonly property real contentHeight: list.count > 0 ? content.implicitHeight : 0
		property real surfaceHeight: 0

		screen: root.notifScreen
		anchors {
			top: true
		}
		exclusiveZone: 0
		color: "transparent"

		implicitWidth: root.notifWidth
		implicitHeight: surfaceHeight
		visible: list.count > 0 || surfaceHeight > 1

		onContentHeightChanged: {
			if (contentHeight >= surfaceHeight) {
				shrinkTimer.stop();
				surfaceHeight = contentHeight;
			} else {
				shrinkTimer.restart();
			}
		}

		Timer {
			id: shrinkTimer
			interval: root.notifSpringDuration
			onTriggered: notificationPopups.surfaceHeight = notificationPopups.contentHeight
		}

		Rectangle {
			id: blob

			anchors.top: parent.top
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.width
			clip: true
			color: root.notifSurface
			border.width: root.borderWidth
			border.color: root.borderColor
			topLeftRadius: 0
			topRightRadius: 0
			bottomLeftRadius: root.notifRadius
			bottomRightRadius: root.notifRadius

			height: notificationPopups.contentHeight
			Behavior on height {
				NumberAnimation {
					duration: root.notifSpringDuration
					easing.type: Easing.OutCubic
				}
			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				height: root.borderWidth
				color: root.notifSurface
				z: 1
			}

			Column {
				id: content

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top

				move: Transition {
					NumberAnimation {
						properties: "y"
						duration: root.notifSpringDuration
						easing.type: Easing.OutCubic
					}
				}

				add: Transition {
					NumberAnimation {
						property: "opacity"
						from: 0
						to: 1
						duration: root.notifFadeDuration
					}
				}

				Repeater {
					id: list
					model: notificationPopups.server ? notificationPopups.server.trackedNotifications : null
					delegate: notificationCardComponent
				}
			}
		}
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
