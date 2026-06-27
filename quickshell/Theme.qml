pragma Singleton

import QtQuick
import Quickshell

Singleton {
	// Font
	readonly property string fontFamily: "Iosevka Nerd Font Mono"
	readonly property int fontSize: 12

	// Palette (Kanagawa)
	readonly property color base00: "#1f1f28"
	readonly property color base01: "#16161d"
	readonly property color base02: "#223249"
	readonly property color base03: "#54546d"
	readonly property color base05: "#dcd7ba"
	readonly property color base08: "#c34043"
	readonly property color base0B: "#76946a"
	readonly property color base0D: "#7e9cd8"
	readonly property color base0E: "#957fb8"

	// Subtle outline shared by the bar and the notification blob
	readonly property int borderWidth: 1
	readonly property color borderColor: base02

	// Bar
	readonly property int barHeight: 32
	readonly property int barPadding: 6      // horizontal inset of the bar contents

	// Right-side status widgets (BarText, VolumeWidget)
	readonly property int widgetHeight: 28
	readonly property int widgetPadding: 5   // left/right padding inside each widget

	// System tray
	readonly property int trayItemWidth: 22
	readonly property int trayIconSize: 16

	// Workspaces
	readonly property int workspaceSpacing: 2
	readonly property int workspaceMinWidth: 28
	readonly property int workspaceLabelPadding: 14   // added to label width to size the pill
	readonly property int workspaceUnderlineHeight: 3

	// Window title
	readonly property real titleWidthFactor: 0.42

	// Notifications — a "blob" that grows out from under the bar (Material 3 expressive spring)
	readonly property int notifWidth: 380
	readonly property int notifPadding: 14          // inner padding of each notification
	readonly property int notifRadius: 18           // rounded bottom of the blob
	readonly property int notifIconSize: 40
	readonly property int notifTimeout: 5000        // ms before a non-critical notification auto-dismisses
	readonly property color notifSurface: base00    // same as the bar, so the blob melds into it
	readonly property int notifSpringDuration: 500  // M3 expressiveDefaultSpatial
	readonly property int notifFadeDuration: 200    // fade-in for each notification
}
