import QtQuick
import QtQuick.Controls as QQC2
import FishUI 1.0 as FishUI

QQC2.Button {
    id: control

    property bool primary: false
    property bool destructive: false
    readonly property color actionColor: destructive
                                        ? (FishUI.Theme.darkMode ? "#ff453a" : "#d92d20")
                                        : FishUI.Theme.highlightColor
    readonly property color surfaceColor: primary ? actionColor : FishUI.Theme.alternateBackgroundColor

    implicitWidth: Math.max(64, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(32, implicitContentHeight + topPadding + bottomPadding)
    leftPadding: 12
    rightPadding: 12
    topPadding: 6
    bottomPadding: 6
    hoverEnabled: true
    font.pixelSize: 12
    font.weight: Font.Medium
    opacity: enabled ? 1 : 0.5

    contentItem: QQC2.Label {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.primary ? "white" : FishUI.Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 10
        border.width: 1
        border.color: control.primary ? Qt.darker(control.actionColor, 1.25)
                                     : (FishUI.Theme.darkMode ? "#545455" : "#d9dadd")
        color: {
            if (control.enabled && control.down)
                return Qt.darker(control.surfaceColor, 1.08)
            if (control.enabled && control.hovered)
                return control.primary || FishUI.Theme.darkMode
                        ? Qt.lighter(control.surfaceColor, 1.05)
                        : Qt.darker(control.surfaceColor, 1.04)
            return control.surfaceColor
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 9
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, control.primary ? 0.2 : 0.08)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 13
            color: "transparent"
            border.width: 2
            border.color: Qt.alpha(control.primary ? control.actionColor : FishUI.Theme.highlightColor, 0.3)
            visible: control.visualFocus
        }
    }
}
