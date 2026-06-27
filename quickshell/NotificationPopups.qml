import QtQuick
import Quickshell

PanelWindow {
	id: root

	// The NotificationServer whose trackedNotifications should be displayed.
	property var server

	// Natural height the content wants to be.
	readonly property real contentHeight: list.count > 0 ? content.implicitHeight : 0
	// Actual surface height. It grows immediately to fit, but only shrinks once the blob has
	// finished retracting. Resizing a Wayland layer-shell surface every frame is what made the
	// animation laggy — this way the surface resizes at most twice per change, while the blob
	// height animates cheaply inside it and is never clipped mid-animation.
	property real surfaceHeight: 0

	anchors {
		top: true
	}
	exclusiveZone: 0
	color: "transparent"

	implicitWidth: Theme.notifWidth
	implicitHeight: surfaceHeight
	// Driven by the count so the content is laid out before it grows; the surfaceHeight term
	// keeps the surface alive while the blob retracts on the last dismissal.
	visible: list.count > 0 || surfaceHeight > 1

	onContentHeightChanged: {
		if (contentHeight >= surfaceHeight) {
			shrinkTimer.stop();
			surfaceHeight = contentHeight; // grow to fit immediately
		} else {
			shrinkTimer.restart(); // defer the shrink until the blob has retracted
		}
	}

	Timer {
		id: shrinkTimer
		interval: Theme.notifSpringDuration
		onTriggered: root.surfaceHeight = root.contentHeight
	}

	// The blob: bar-coloured, square top (tucked under the bar), rounded bottom.
	Rectangle {
		id: blob

		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width
		clip: true
		color: Theme.notifSurface
		border.width: Theme.borderWidth
		border.color: Theme.borderColor
		topLeftRadius: 0
		topRightRadius: 0
		bottomLeftRadius: Theme.notifRadius
		bottomRightRadius: Theme.notifRadius

		// Cheap inner-item height animation — this is the emerge/retract.
		height: root.contentHeight
		Behavior on height {
			NumberAnimation {
				duration: Theme.notifSpringDuration
				easing.type: Easing.OutCubic
			}
		}

		// Paint over the top border so the blob's outline is open at the top — its side
		// outlines then continue straight from the gap in the bar's bottom outline.
		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			height: Theme.borderWidth
			color: Theme.notifSurface
			z: 1
		}

		Column {
			id: content

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top

			// Reflow the stack with the same duration/easing as the blob, so a surviving
			// notification slides up exactly as the blob retracts around it.
			move: Transition {
				NumberAnimation {
					properties: "y"
					duration: Theme.notifSpringDuration
					easing.type: Easing.OutCubic
				}
			}

			// Gentle fade-in for each new notification as the blob grows to fit it.
			add: Transition {
				NumberAnimation {
					property: "opacity"
					from: 0
					to: 1
					duration: Theme.notifFadeDuration
				}
			}

			Repeater {
				id: list
				model: root.server ? root.server.trackedNotifications : null
				delegate: NotificationCard {}
			}
		}
	}
}
