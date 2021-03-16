import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls 2.12
import QtQuick.Controls.impl 2.12

import MeuiKit 1.0 as Meui

T.MenuItem
{
    id: control

    property color hoveredColor: Meui.Theme.highlightColor
    property color pressedColor: Qt.darker(Meui.Theme.highlightColor, 1.2)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: visible ? Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                       implicitContentHeight + topPadding + bottomPadding,
                                       implicitIndicatorHeight + topPadding + bottomPadding) : 0
    verticalPadding: Meui.Units.smallSpacing
    hoverEnabled: true

    icon.width: Meui.Units.iconSizes.medium
    icon.height: Meui.Units.iconSizes.medium

    icon.color: control.enabled ? (control.highlighted ? control.Meui.Theme.highlightColor : control.Meui.Theme.textColor) :
                             control.Meui.Theme.disabledTextColor

    contentItem: IconLabel {
        readonly property real arrowPadding: control.subMenu && control.arrow ? control.arrow.width + control.spacing : 0
        readonly property real indicatorPadding: control.checkable && control.indicator ? control.indicator.width + control.spacing : 0
        leftPadding: !control.mirrored ? indicatorPadding + Meui.Units.smallSpacing * 2 : arrowPadding
        rightPadding: control.mirrored ? indicatorPadding : arrowPadding + Meui.Units.smallSpacing * 2

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft

        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? control.pressed || control.hovered ? control.Meui.Theme.highlightedTextColor : 
               Meui.Theme.textColor : control.Meui.Theme.disabledTextColor
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.visible ? Meui.Units.rowHeightAlt : 0
        radius: 4
        opacity: 1

        anchors {
            fill: parent
            leftMargin: Meui.Units.smallSpacing
            rightMargin: Meui.Units.smallSpacing
        }

        color: control.pressed ? control.pressedColor : control.hovered ? control.hoveredColor : "transparent"
    }
}
