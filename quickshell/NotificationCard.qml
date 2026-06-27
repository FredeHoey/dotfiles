import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Item {
	id: card

	required property var modelData
	readonly property var notif: modelData
	readonly property bool critical: notif.urgency === NotificationUrgency.Critical

	implicitWidth: Theme.notifWidth
	implicitHeight: layout.implicitHeight + Theme.notifPadding * 2

	function close() {
		notif.dismiss();
	}

	function iconSource() {
		if (notif.image && notif.image.length > 0)
			return notif.image;

		const ic = notif.appIcon || "";
		if (ic.length === 0)
			return "";
		if (ic[0] === "/" || ic.indexOf("file:") === 0 || ic.indexOf("image:") === 0 || ic.indexOf("qrc:") === 0)
			return ic;

		return Quickshell.iconPath(ic, true);
	}

	// Auto-dismiss after a timeout (paused while hovered; critical notifications stay).
	Timer {
		interval: card.notif.expireTimeout > 0 ? card.notif.expireTimeout : Theme.notifTimeout
		running: !card.critical && !hover.hovered
		onTriggered: card.close()
	}

	// Divider between stacked notifications inside the blob.
	Rectangle {
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: Theme.notifPadding
		anchors.rightMargin: Theme.notifPadding
		height: 1
		visible: card.y > 0
		color: Theme.base02
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
		anchors.margins: Theme.notifPadding
		spacing: Theme.notifPadding

		IconImage {
			visible: source.toString().length > 0
			source: card.iconSource()
			implicitSize: Theme.notifIconSize
			Layout.alignment: Qt.AlignTop
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 2

			Text {
				Layout.fillWidth: true
				text: card.notif.summary
				color: Theme.base05
				font.family: Theme.fontFamily
				font.pointSize: Theme.fontSize
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
				color: Theme.base05
				font.family: Theme.fontFamily
				font.pointSize: Theme.fontSize - 2
				wrapMode: Text.Wrap
				elide: Text.ElideRight
				maximumLineCount: 4
			}

			Text {
				Layout.fillWidth: true
				visible: text.length > 0
				text: card.notif.appName
				color: Theme.base03
				font.family: Theme.fontFamily
				font.pointSize: Theme.fontSize - 3
				elide: Text.ElideRight
			}
		}
	}
}
