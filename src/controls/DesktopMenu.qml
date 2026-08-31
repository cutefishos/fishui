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

    // Statusbar menus keep their existing appearance; other callers bind this
    // property to the global blur preference.
    property bool blurEnabled: true

    default property alias content : _mainLayout.data

    Rectangle {
        id: _background
        anchors.fill: parent
        color: FishUI.Theme.secondBackgroundColor
        radius: FishUI.Theme.hugeRadius
        opacity: control.blurEnabled ? 0.6 : 1
        border.color: _background.borderColor
        border.width: 1 / FishUI.Units.devicePixelRatio
        border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true

        property var borderColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                        : Qt.rgba(0, 0, 0, 0.2)

        FishUI.WindowShadow {
            view: control
            radius: _background.radius
        }

        FishUI.WindowBlur {
            view: control
            windowRadius: _background.radius
            enabled: control.blurEnabled
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
    }

    function open() {
        control.show()
    }

    function popup() {
        control.show()
    }
}
