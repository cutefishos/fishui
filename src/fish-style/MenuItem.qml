import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls 2.12
import QtQuick.Controls.impl 2.12

import FishUI 1.0 as FishUI

T.MenuItem
{
    id: control

    property color hoveredColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.2)
                                                       : Qt.rgba(0, 0, 0, 0.1)
    property color pressedColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                                       : Qt.rgba(0, 0, 0, 0.2)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    verticalPadding: FishUI.Units.smallSpacing
    hoverEnabled: true
    topPadding: FishUI.Units.smallSpacing
    bottomPadding: FishUI.Units.smallSpacing

    icon.width: FishUI.Units.iconSizes.medium
    icon.height: FishUI.Units.iconSizes.medium

    icon.color: control.enabled ? (control.highlighted ? control.FishUI.Theme.highlightColor : control.FishUI.Theme.textColor) :
                             control.FishUI.Theme.disabledTextColor

    contentItem: IconLabel {
        readonly property real arrowPadding: control.subMenu && control.arrow ? control.arrow.width + control.spacing : 0
        readonly property real indicatorPadding: control.checkable && control.indicator ? control.indicator.width + control.spacing : 0
        leftPadding: !control.mirrored ? indicatorPadding + FishUI.Units.smallSpacing * 2 : arrowPadding
        rightPadding: control.mirrored ? indicatorPadding : arrowPadding + FishUI.Units.smallSpacing * 2

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft

        icon: control.icon
        text: control.text
        font: control.font
        color: control.enabled ? control.pressed || control.hovered ? control.FishUI.Theme.textColor : 
               FishUI.Theme.textColor : control.FishUI.Theme.disabledTextColor
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.visible ? FishUI.Units.gridUnit + FishUI.Units.largeSpacing : 0
        radius: FishUI.Theme.mediumRadius
        opacity: 1

        anchors {
            fill: parent
            leftMargin: FishUI.Units.smallSpacing
            rightMargin: FishUI.Units.smallSpacing
        }

        color: control.pressed || highlighted ? control.pressedColor : control.hovered ? control.hoveredColor : "transparent"
    }
}
