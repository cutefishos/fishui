import QtQuick 2.4
import FishUI 1.0 as FishUI

Item {
    id: indicator
    implicitWidth: 38
    implicitHeight: 32

    property Item control
    property alias handle: handle
    property color bgColor : control.checked ? FishUI.Theme.highlightColor : Qt.rgba(FishUI.Theme.textColor.r, 
                                                                                     FishUI.Theme.textColor.g,
                                                                                     FishUI.Theme.textColor.b, 0.2)
    Rectangle {
        width: parent.width
        height: 20
        radius: height / 2
        y: parent.height / 2 - height / 2
        color: control.enabled ? bgColor : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }
    }

    Rectangle {
        id: handle
        x: Math.max(2, Math.min(parent.width - width, control.visualPosition * parent.width - (width / 2)) - 2)
        y: (parent.height - height) / 2
        width: 16
        height: 16
        radius: width / 2
        color: control.enabled ? "white" : "transparent"

        Behavior on x {
            enabled: !control.pressed

            NumberAnimation {
                duration: 250
                easing.type: Easing.OutSine
            }
        }
    }
}
