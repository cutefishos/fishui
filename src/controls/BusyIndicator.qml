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
 
import QtQuick 2.4
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

Image {
    id: control
    width: 22
    height: width
    source: "qrc:/fishui/kit/images/refresh.svg"
    sourceSize: Qt.size(width, height)
    visible: true

    property alias running: rotationAnimator.running

    ColorOverlay {
        anchors.fill: control
        source: control
        color: FishUI.Theme.textColor
        opacity: 1
        visible: true
    }

    RotationAnimator {
        id: rotationAnimator
        target: control
        running: control.visible
        from: 0
        to: 360
        loops: Animation.Infinite
        duration: 1000
    }
}
