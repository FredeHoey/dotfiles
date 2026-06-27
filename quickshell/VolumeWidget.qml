import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Text {
	id: root

	required property color normalColor
	required property color mutedColor

	property bool muted: false
	property int volume: -1

	Layout.preferredHeight: Theme.widgetHeight
	Layout.alignment: Qt.AlignVCenter
	leftPadding: Theme.widgetPadding
	rightPadding: Theme.widgetPadding
	verticalAlignment: Text.AlignVCenter
	// Material Design Icons glyphs from the Nerd Font: md-volume_mute / md-volume_high
	text: muted ? "\u{f075f} mute" : "\u{f057e} " + (volume >= 0 ? volume + "%" : "--")
	color: muted ? mutedColor : normalColor
	font.family: Theme.fontFamily
	font.pointSize: Theme.fontSize

	Process {
		id: readVolume
		command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
		stdout: StdioCollector {
			id: volumeOut
		}

		onExited: {
			const output = volumeOut.text.trim();
			const match = output.match(/Volume:\s+([0-9.]+)/);
			root.volume = match ? Math.round(Number(match[1]) * 100) : -1;
			root.muted = output.indexOf("[MUTED]") !== -1;
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
