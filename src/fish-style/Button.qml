import QtQuick 2.4
import QtQuick.Templates 2.4 as T
import FishUI 1.0 as FishUI
import QtQuick.Controls.impl 2.4

T.Button {
    id: control
    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + FishUI.Units.largeSpacing)
    implicitHeight: background.implicitHeight
    hoverEnabled: true
    scale: control.pressed ? 0.95 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }

    property color hoveredColor: Qt.tint(FishUI.Theme.textColor, Qt.rgba(FishUI.Theme.backgroundColor.r,
                                                                       FishUI.Theme.backgroundColor.g,
                                                                       FishUI.Theme.backgroundColor.b, 0.9))
    property color pressedColor: Qt.tint(FishUI.Theme.textColor, Qt.rgba(FishUI.Theme.backgroundColor.r,
                                                                       FishUI.Theme.backgroundColor.g,
                                                                       FishUI.Theme.backgroundColor.b, 0.8))

    property color flatHoveredColor: Qt.lighter(FishUI.Theme.highlightColor, 1.1)
    property color flatPressedColor: Qt.darker(FishUI.Theme.highlightColor, 1.1)

    icon.width: FishUI.Units.iconSizes.small
    icon.height: FishUI.Units.iconSizes.small

    icon.color: control.enabled ? (control.highlighted ? control.FishUI.Theme.highlightColor : control.FishUI.Theme.textColor) : control.FishUI.Theme.disabledTextColor
    spacing: FishUI.Units.smallSpacing

    contentItem: IconLabel {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? control.FishUI.Theme.disabledTextColor : control.flat ? FishUI.Theme.highlightedTextColor : FishUI.Theme.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }

    background: Item {
        implicitWidth: (FishUI.Units.iconSizes.medium * 3) + FishUI.Units.largeSpacing
        implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing

        Rectangle {
            id: _background
            anchors.fill: parent
            radius: FishUI.Theme.mediumRadius
            border.width: 1
            border.color: control.flat && control.enabled ? FishUI.Theme.highlightColor : control.activeFocus || control.pressed ? FishUI.Theme.highlightColor : "transparent"

            color: control.flat && control.enabled ? control.pressed ? control.flatPressedColor : control.hovered ? control.flatHoveredColor : FishUI.Theme.highlightColor
                                                   : control.pressed ? control.pressedColor : control.hovered ? control.hoveredColor : FishUI.Theme.alternateBackgroundColor
        }
    }
}
