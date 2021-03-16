import QtQuick 2.4
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

Image {
    id: control
    width: 22
    height: width
    source: "qrc:/meui/kit/images/refresh.svg"
    sourceSize: Qt.size(width, height)
    visible: true

    property alias running: rotationAnimator.running

    ColorOverlay {
        anchors.fill: control
        source: control
        color: Meui.Theme.textColor
        opacity: 1
        visible: true
    }

    RotationAnimator {
        id: rotationAnimator
        target: control
        running: control.visible
        from: 0
        to: 360
        loops: Animation.Infinite
        duration: 1000
    }
}
