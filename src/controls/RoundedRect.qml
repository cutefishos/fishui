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