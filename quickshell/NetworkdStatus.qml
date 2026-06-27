import QtQuick
import Quickshell.Io

QtObject {
	id: root

	property int interval: 5000
	property string text: "--"
	property string linkName: ""
	property string address: ""
	property string state: "unknown"
	property bool online: false
	property bool wireless: false
	readonly property string scriptPath: Qt.resolvedUrl("scripts/networkd-status.sh").toString().replace("file://", "")

	property Process process: Process {
		command: ["bash", root.scriptPath]
		stdout: StdioCollector {
			id: stdout
		}

		onExited: {
			const lines = stdout.text.trim().split("\n");
			const payload = lines.length > 0 ? lines[lines.length - 1] : "";

			try {
				const status = JSON.parse(payload);
				root.linkName = status.name || "";
				root.address = status.address || "";
				root.state = status.state || "unknown";
				root.online = status.online === true;
				root.wireless = status.wireless === true;
				root.text = status.text || "--";
			} catch (error) {
				root.linkName = "";
				root.address = "";
				root.state = "error";
				root.online = false;
				root.wireless = false;
				root.text = "error";
			}
		}
	}

	property Timer timer: Timer {
		interval: root.interval
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: {
			if (!root.process.running) root.process.running = true;
		}
	}
}
