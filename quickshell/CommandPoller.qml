import QtQuick
import Quickshell.Io

QtObject {
	id: root

	required property var command
	property int interval: 1000
	property string text: ""

	property Process process: Process {
		command: root.command
		stdout: StdioCollector {
			id: stdout
		}

		onExited: {
			const value = stdout.text.trim();
			if (value.length > 0) root.text = value;
		}
	}

	property Timer timer: Timer {
		interval: root.interval
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: {
			if (!root.process.running) root.process.exec(root.command);
		}
	}
}
