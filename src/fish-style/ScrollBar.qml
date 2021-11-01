import QtQuick 2.4
import QtQuick.Templates 2.12 as T
import QtQuick.Controls.Material 2.12
import FishUI 1.0 as FishUI

T.ScrollBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    hoverEnabled: true
    padding: control.interactive ? 1 : 2
    visible: control.policy !== T.ScrollBar.AlwaysOff
    minimumSize: orientation == Qt.Horizontal ? height / width : width / height

    onHoveredChanged: {
        if (hovered)
            control.active = true
    }

    contentItem: Rectangle {
        radius: FishUI.Theme.smallRadius
        implicitWidth: control.interactive ? 6 : 4
        implicitHeight: control.interactive ? 6 : 4

        color: control.pressed ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.5)
                               : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.5) : Qt.rgba(0, 0, 0, 0.4)
        opacity: 0.0
    }

    states: State {
        name: "active"
        when: control.policy === T.ScrollBar.AlwaysOn || (control.active && control.size < 1.0)
    }

    transitions: [
        Transition {
            to: "active"
            NumberAnimation { target: control.contentItem; property: "opacity"; to: 1.0 }
        },
        Transition {
            from: "active"
            SequentialAnimation {
                PropertyAction{ target: control.contentItem; property: "opacity"; value: 1.0 }
                PauseAnimation { duration: 1000 }
                NumberAnimation { target: control.contentItem; property: "opacity"; to: 0.0 }
            }
        }
    ]
}
