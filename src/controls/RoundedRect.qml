import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import FishUI 1.0 as FishUI

Item {
    id: control

    property real radius: FishUI.Theme.smallRadius
    property var color: FishUI.Theme.backgroundColor

    property bool animationEnabled: true
    property alias backgroundOpacity: _background.opacity

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
                easing.type: Easing.Linear
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
        visible: FishUI.Theme.darkMode
        border.color: Qt.rgba(255, 255, 255, 0.3)
        border.width: 1
        smooth: true
        antialiasing: true
    }
}