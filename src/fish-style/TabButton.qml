import QtQuick 2.9
import QtQuick.Templates 2.2 as T
import FishUI 1.0 as FishUI

T.TabButton {
    id: control

    property int standardHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing
    property color pressedColor: Qt.rgba(FishUI.Theme.textColor.r, FishUI.Theme.textColor.g, FishUI.Theme.textColor.b, 0.5)

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             standardHeight)
    baselineOffset: contentItem.y + contentItem.baselineOffset

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
