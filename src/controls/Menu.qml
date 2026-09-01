import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import QtQuick.Window
import Qt5Compat.GraphicalEffects

import FishUI 1.0 as FishUI

T.Menu {
    id: control

    // A menu is intentionally a little wider than its longest label. This
    // keeps icons, checkmarks and submenu arrows aligned without making short
    // menus feel oversized.
    implicitWidth: Math.max(146,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentItem.implicitHeight + topPadding + bottomPadding)

    margins: 4
    padding: 4
    spacing: 2
    transformOrigin: !cascade ? Item.Top : (mirrored ? Item.TopRight : Item.TopLeft)

    delegate: FishUI.MenuItem { }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 120
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.96
                to: 1
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 90
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.98
                duration: 90
                easing.type: Easing.InCubic
            }
        }
    }

    contentItem: ListView {
        id: menuList

        implicitHeight: contentHeight
        implicitWidth: {
            var maxWidth = 0
            for (var i = 0; i < contentItem.children.length; ++i)
                maxWidth = Math.max(maxWidth, contentItem.children[i].implicitWidth)
            return maxWidth
        }

        model: control.contentModel
        interactive: Window.window ? contentHeight > Window.window.height : false
        clip: true
        currentIndex: control.currentIndex
        spacing: control.spacing
        keyNavigationEnabled: true
        keyNavigationWraps: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    background: Rectangle {
        radius: FishUI.Theme.smallRadius
        color: Qt.rgba(FishUI.Theme.secondBackgroundColor.r,
                       FishUI.Theme.secondBackgroundColor.g,
                       FishUI.Theme.secondBackgroundColor.b,
                       FishUI.Theme.darkMode ? 0.96 : 0.92)
        border.width: 1 / FishUI.Units.devicePixelRatio
        border.color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.16)
                                            : Qt.rgba(0, 0, 0, 0.12)

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 18
            samples: 32
            horizontalOffset: 0
            verticalOffset: 4
            color: Qt.rgba(0, 0, 0, FishUI.Theme.darkMode ? 0.2 : 0.1)
        }
    }
}
