import QtQuick 2.4
import QtQuick.Templates 2.4 as T
import MeuiKit 1.0 as Meui
import QtQuick.Controls.impl 2.4

T.Button
{
    id: control
    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + Meui.Units.largeSpacing)
    implicitHeight: background.implicitHeight
    hoverEnabled: true

    property color hoveredColor: Qt.tint(Meui.Theme.textColor, Qt.rgba(Meui.Theme.backgroundColor.r,
                                                                       Meui.Theme.backgroundColor.g,
                                                                       Meui.Theme.backgroundColor.b, 0.9))
    property color pressedColor: Qt.tint(Meui.Theme.textColor, Qt.rgba(Meui.Theme.backgroundColor.r,
                                                                       Meui.Theme.backgroundColor.g,
                                                                       Meui.Theme.backgroundColor.b, 0.8))

    property color flatHoveredColor: Qt.lighter(Meui.Theme.highlightColor, 1.1)
    property color flatPressedColor: Qt.darker(Meui.Theme.highlightColor, 1.1)

    icon.width: Meui.Units.iconSizes.small
    icon.height: Meui.Units.iconSizes.small

    icon.color: control.enabled ? (control.highlighted ? control.Meui.Theme.highlightColor : control.Meui.Theme.textColor) : control.Meui.Theme.disabledTextColor
    spacing: Meui.Units.smallSpacing

    contentItem: IconLabel {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? control.Meui.Theme.disabledTextColor : control.flat ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }

    background: Item {
        implicitWidth:  (Meui.Units.iconSizes.medium * 3) + Meui.Units.largeSpacing + Meui.Units.extendBorderWidth
        implicitHeight: Meui.Units.iconSizes.medium + Meui.Units.smallSpacing + Meui.Units.extendBorderWidth

        Rectangle {
            id: _border
            anchors.fill: parent
            visible: control.activeFocus
            color: "transparent"
            border.color: Qt.rgba(Meui.Theme.highlightColor.r,
                                  Meui.Theme.highlightColor.g,
                                  Meui.Theme.highlightColor.b, 0.3)
            border.width: Meui.Units.extendBorderWidth
            radius: Meui.Theme.mediumRadius
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: Meui.Units.extendBorderWidth
            radius: Meui.Theme.mediumRadius - Meui.Units.extendBorderWidth
            border.color: control.flat && control.enabled ? Meui.Theme.highlightColor : control.activeFocus || control.pressed ? Meui.Theme.highlightColor : 
                          Qt.tint(Meui.Theme.textColor, Qt.rgba(Meui.Theme.backgroundColor.r, Meui.Theme.backgroundColor.g, Meui.Theme.backgroundColor.b, 0.7))
            border.width: 1

            color: control.flat && control.enabled ? control.pressed ? control.flatPressedColor : control.hovered ? control.flatHoveredColor : Meui.Theme.highlightColor
                                : control.pressed ? control.pressedColor : control.hovered ? control.hoveredColor : Meui.Theme.backgroundColor
        }
    }
}
