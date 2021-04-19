import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Window 2.12
import FishUI 1.0 as FishUI
import QtGraphicalEffects 1.0

T.Menu
{
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 0
    verticalPadding: FishUI.Units.smallSpacing
    spacing: FishUI.Units.smallSpacing
    transformOrigin: !cascade ? Item.Top : (mirrored ? Item.TopRight : Item.TopLeft)

    delegate: MenuItem { }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            easing.type: Easing.InOutCubic
            duration: 100
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            easing.type: Easing.InOutCubic
            duration: 200
        }
    }

    Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            color: 'transparent'
        }
    }

    contentItem: ListView {
        implicitHeight: contentHeight

        implicitWidth: {
            var maxWidth = 0;
            for (var i = 0; i < contentItem.children.length; ++i) {
                maxWidth = Math.max(maxWidth, contentItem.children[i].implicitWidth);
            }
            return maxWidth;
        }

        model: control.contentModel
        interactive: Window.window ? contentHeight > Window.window.height : false
        clip: true
        currentIndex: control.currentIndex || 0
        spacing: control.spacing
        keyNavigationEnabled: true
        keyNavigationWraps: true

        ScrollBar.vertical: ScrollBar {}
    }

    background: FishUI.RoundedRect {
        radius: FishUI.Theme.hugeRadius
        opacity: 1

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

    T.Overlay.modal: Rectangle  {
        color: Qt.rgba(control.FishUI.Theme.backgroundColor.r,
                       control.FishUI.Theme.backgroundColor.g,
                       control.FishUI.Theme.backgroundColor.b, 0.4)
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }
    }

    T.Overlay.modeless: Rectangle {
        color: Qt.rgba(control.FishUI.Theme.backgroundColor.r,
                       control.FishUI.Theme.backgroundColor.g,
                       control.FishUI.Theme.backgroundColor.b, 0.4)
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }
    }
}
