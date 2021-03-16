import QtQuick 2.9
import QtQuick.Templates 2.2 as T
import MeuiKit 1.0 as Meui

T.TabButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Meui.Units.iconSizes.medium + Meui.Units.smallSpacing

    property color pressedColor: Qt.rgba(Meui.Theme.textColor.r, Meui.Theme.textColor.g, Meui.Theme.textColor.b, 0.5)

    padding: 0
    spacing: 0

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        text: control.text
        font: control.font
        color: !control.enabled ? Meui.Theme.disabledTextColor : control.pressed ? pressedColor : control.checked ? Meui.Theme.textColor : Meui.Theme.textColor
    }
}