import QtQuick
import QtQuick.Layouts

Text {
	Layout.preferredHeight: Theme.widgetHeight
	Layout.alignment: Qt.AlignVCenter
	leftPadding: Theme.widgetPadding
	rightPadding: Theme.widgetPadding
	verticalAlignment: Text.AlignVCenter
	font.family: Theme.fontFamily
	font.pointSize: Theme.fontSize
	elide: Text.ElideRight
}
