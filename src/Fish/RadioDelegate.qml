import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import FishUI 1.0 as FishUI

T.RadioDelegate {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    topPadding: control.FishUI.Units.smallSpacing
    bottomPadding: control.FishUI.Units.smallSpacing
    leftPadding: control.FishUI.Units.smallSpacing
    rightPadding: control.FishUI.Units.smallSpacing

    spacing: control.FishUI.Units.smallSpacing

    opacity: control.enabled ? 1.0 : 0.5

    contentItem: Text {
        leftPadding: !control.mirrored ? 0 : control.indicator.width + control.spacing
        rightPadding: control.mirrored ? 0 : control.indicator.width + control.spacing

        text: control.text
        font: control.font
        color: FishUI.Theme.textColor

        elide: Text.ElideRight
        visible: control.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    indicator: RadioIndicator {
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        control: control
    }

    background: Rectangle {
        implicitHeight: FishUI.Units.fontMetrics.height + FishUI.Units.largeSpacing
        radius: FishUI.Theme.smallRadius
        color: control.down ? FishUI.Theme.alternateBackgroundColor
                            : control.hovered ? FishUI.Theme.secondBackgroundColor
                                              : "transparent"
    }
}
