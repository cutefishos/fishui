import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

QQC2.Menu {
    id: control

    property real blurRadius: 100
    // property alias blurRadius: bkground.blurRadius
    property alias backgroundOpacity: _menubg.backgroundOpacity
    property real backgroundRadius: Meui.Theme.smallRadius

    background: Meui.RoundedRect {
        id: _menubg
        backgroundOpacity: 0.7
        radius: control.backgroundRadius
        blurEnabled: true
        sourceItem: control.parent

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 32
            samples: 32
            horizontalOffset: 0
            verticalOffset: 0
            color: Qt.rgba(0, 0, 0, 0.11)
        }
    }

    // background: Meui.BlurBackground {
    //     id: bkground
    //     sourceItem: control.parent
    //     backgroundColor: "transparent"
    //     startX: control.x
    //     startY: control.y
    //     blurRadius: 144
    //     radius: control.backgroundRadius

    //     Meui.RoundedRect {
    //         id: roundedRect
    //         anchors.fill: parent
    //         backgroundOpacity: 0.7
    //         radius: control.backgroundRadius
    //     }

    //     layer.enabled: true
    //     layer.effect: DropShadow {
    //         transparentBorder: true
    //         radius: 32
    //         samples: 32
    //         horizontalOffset: 0
    //         verticalOffset: 0
    //         color: Qt.rgba(0, 0, 0, 0.11)
    //     }
    // }

    // onVisibleChanged: {
    //     var jx = contentItem.mapToItem(control.parent, control.x, control.y)
    //     bkground.startX = jx.x
    //     bkground.startY = jx.y
    // }
}