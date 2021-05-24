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

    default property alias content : _mainLayout.data

    FishUI.RoundedRect {
        id: _background
        anchors.fill: parent
        // opacity: 0.6
        // color: FishUI.Theme.backgroundColor
        radius: FishUI.Theme.hugeRadius
        backgroundOpacity: 0.6

        FishUI.WindowShadow {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            radius: _background.radius
        }

        FishUI.WindowBlur {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            windowRadius: _background.radius
            enabled: true
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 8
    }

    function open() {
        control.show()
    }

    function popup() {
        control.show()
    }
}
