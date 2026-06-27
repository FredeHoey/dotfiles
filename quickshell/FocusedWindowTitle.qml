import QtQuick
import Quickshell.I3._Ipc
import Quickshell.Io

QtObject {
	id: root

	property string text: ""

	property Process readTitle: Process {
		command: ["bash", "-lc", "swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name // empty' 2>/dev/null || true"]
		stdout: StdioCollector {
			id: titleOut
		}

		onExited: root.text = titleOut.text.trim()
	}

	property Timer refreshDebounce: Timer {
		interval: 25
		repeat: false
		onTriggered: {
			if (!root.readTitle.running) root.readTitle.exec(root.readTitle.command);
		}
	}

	property I3IpcListener listener: I3IpcListener {
		subscriptions: ["window", "workspace"]
		onIpcEvent: event => {
			if (event.type === "window" || event.type === "workspace") root.refreshDebounce.restart();
		}
	}

	Component.onCompleted: refreshDebounce.restart()
}
