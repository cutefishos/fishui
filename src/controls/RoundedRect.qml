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
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import FishUI 1.0 as FishUI

Item {
    id: control

    property real radius: FishUI.Theme.smallRadius
    property var color: FishUI.Theme.backgroundColor
    property bool borderEnabled: true

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
        anchors.fill: parent
        color: "transparent"
        radius: _background.radius
        border.width: 1 / FishUI.Theme.devicePixelRatio
        border.pixelAligned: FishUI.Theme.devicePixelRatio > 1 ? false : true
        border.color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.1)
        visible: control.borderEnabled
        antialiasing: true
    }
}
