/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import FishUI 1.0 as FishUI

FishUI.MenuPopupWindow {
    id: control

    property bool blurEnabled: FishUI.Theme.blurEnabled

    default property alias content : _mainLayout.data

    popupContentItem: _contentItem

    Item {
        id: _contentItem

        readonly property int contentMargin: Math.max(4, FishUI.Units.smallSpacing - 2)
        implicitWidth: _mainLayout.implicitWidth + contentMargin * 2
        implicitHeight: _mainLayout.implicitHeight + contentMargin * 2
        width: implicitWidth
        height: implicitHeight

        Rectangle {
            id: _background
            anchors.fill: parent
            color: Qt.rgba(FishUI.Theme.secondBackgroundColor.r,
                           FishUI.Theme.secondBackgroundColor.g,
                           FishUI.Theme.secondBackgroundColor.b,
                           control.blurEnabled && !control.submenu ? 0.86 : 1)
            radius: FishUI.Theme.smallRadius
            border.color: _background.borderColor
            border.width: 1 / FishUI.Units.devicePixelRatio
            border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true

            property var borderColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                            : Qt.rgba(0, 0, 0, 0.2)

            FishUI.WindowShadow {
                view: control
                radius: _background.radius
                strength: 0.4
                enabled: true
            }

            FishUI.WindowBlur {
                view: control
                windowRadius: _background.radius
                enabled: control.blurEnabled && !control.submenu
            }
        }

        ColumnLayout {
            id: _mainLayout
            x: _contentItem.contentMargin
            y: _contentItem.contentMargin
            width: implicitWidth
            height: implicitHeight
            spacing: 1
        }
    }

    function open() {
        control.show()
    }

    function popup() {
        control.show()
    }

    function popupSubMenu() {
        control.show()
    }

    // A submenu closes immediately after the pointer has actually entered
    // and then left it. The timer only covers the short handoff gap between
    // the parent popup and this popup.
    property bool pointerEntered: false

    onPointerInsideChanged: {
        if (!control.submenu)
            return

        if (control.pointerInside) {
            pointerEntered = true
        } else if (pointerEntered) {
            pointerEntered = false
            if (!control.containsGlobalCursor() &&
                    !control.parentItemContainsGlobalCursor() &&
                    !control.parentPopupContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }

    onVisibleChanged: {
        if (!visible)
            pointerEntered = false
    }

    property Timer submenuDismissTimer: Timer {
        interval: 160
        repeat: true
        running: control.visible

        onTriggered: {
            if (!control.parentItem) {
                stop()
                return
            }

            if (!control.pointerInside &&
                    !control.parentItemHovered() &&
                    !control.parentItemContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }
}
