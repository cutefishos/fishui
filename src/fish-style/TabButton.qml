import QtQuick 2.9
import QtQuick.Templates 2.2 as T
import FishUI 1.0 as FishUI

T.TabButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing

    property color pressedColor: Qt.rgba(FishUI.Theme.textColor.r, FishUI.Theme.textColor.g, FishUI.Theme.textColor.b, 0.5)

    padding: 0
    spacing: 0

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        text: control.text
        font: control.font
        color: !control.enabled ? FishUI.Theme.disabledTextColor : control.pressed ? pressedColor : control.checked ? FishUI.Theme.textColor : FishUI.Theme.textColor
    }
}