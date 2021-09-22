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
import QtQuick.Window 2.3
import QtQuick.Controls 2.4
import FishUI 1.0 as FishUI

Item {
    id: control

    property var size: 32
    property var iconMargins: 0
    height: size
    width: size

    property alias background: _background
    property color backgroundColor: "transparent"
    property color hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.backgroundColor, 2)
                                                   : Qt.darker(FishUI.Theme.backgroundColor, 1.2)
    property color pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.backgroundColor, 1.5)
                                                     : Qt.darker(FishUI.Theme.backgroundColor, 1.3)
    property alias source: _image.source
    property alias image: _image
    signal clicked()

    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.margins: size * 0.1
        radius: control.height / 2
        color: mouseArea.pressed ? pressedColor : mouseArea.containsMouse ? control.hoveredColor : control.backgroundColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: control.clicked()
    }

    Image {
        id: _image
        objectName: "image"
        anchors.fill: parent
        anchors.margins: control.iconMargins
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
        cache: true
        asynchronous: false
    }
}
