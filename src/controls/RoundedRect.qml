import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import MeuiKit 1.0 as Meui

Item {
    id: control

    property real radius: Meui.Theme.smallRadius
    property var color: Meui.Theme.backgroundColor

    property bool animationEnabled: false

    property alias backgroundOpacity: _background.opacity

    property QtObject sourceItem: null
    property bool blurEnabled: false
    property real blurRadius: 100
    property int startX: 0
    property int startY: 0

    onStartXChanged: {
        var jx = eff.mapToItem(sourceItem.parent, control.x, control.y)
        control.startX = jx.x
        control.startY = jx.y
        eff.sourceRect = Qt.rect(control.startX, control.startY, control.width, control.height)
    }

    ShaderEffectSource {
        id: eff
        anchors.fill: parent
        sourceItem: control.sourceItem
        sourceRect: Qt.rect(control.startX, control.startY, control.width, control.height)
        visible: false
    }

    FastBlur {
        id: fastBlur
        anchors.fill: parent
        source: eff
        radius: control.blurRadius
        cached: true
        visible: true
    }

    OpacityMask {
        id: mask
        anchors.fill: _background
        source: fastBlur
        maskSource: _background
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        color: control.color
        radius: control.radius
        antialiasing: true
        smooth: true

        Behavior on color {
            ColorAnimation {
                duration: control.animationEnabled ? 200 : 0
                easing.type: Easing.InOutCubic
            }
        }
    }

    Rectangle {
        id: _border
        anchors.fill: parent
        radius: control.radius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.3)
        smooth: true
        antialiasing: true
    }

    Rectangle {
        id: _border2
        anchors.fill: parent
        anchors.margins: 1
        radius: control.radius - 1
        color: "transparent"
        border.color: Qt.rgba(255, 255, 255, 0.3)
        border.width: 1
        smooth: true
        antialiasing: true
    }
}