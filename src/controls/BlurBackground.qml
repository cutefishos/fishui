
/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
import QtQuick 2.12
import QtGraphicalEffects 1.0

Item {
    id: blurBackground

    property QtObject sourceItem: null

    property real blurRadius: 0
    property real radius: 0
    property color backgroundColor

    property int startX: 0
    property int startY: 0

    ShaderEffectSource {
        id:eff
        anchors.fill: parent
        sourceItem: blurBackground.sourceItem
        sourceRect: Qt.rect(blurBackground.startX,blurBackground.startY,blurBackground.width,blurBackground.height)
        visible: false
    }

    onStartXChanged: {
        var jx = eff.mapToItem(blurBackground.sourceItem, blurBackground.x, blurBackground.y)
        blurBackground.startX = jx.x
        blurBackground.startY = jx.y
        eff.sourceRect = Qt.rect(blurBackground.startX,blurBackground.startY,blurBackground.width,blurBackground.height)
    }

    FastBlur {
        id:fastBlur
        anchors.fill: parent
        source: eff
        radius: blurBackground.blurRadius
        cached: true
        visible: true
    }

    Rectangle {
        id: maskRect
        anchors.fill: parent
        color: blurBackground.backgroundColor
        radius: blurBackground.radius
        visible: false
    }

    OpacityMask {
        id:mask
        anchors.fill: maskRect
        source: fastBlur
        maskSource: maskRect
    }

    Rectangle {
        anchors.fill: parent
        color: blurBackground.backgroundColor
        radius: blurBackground.radius
    }
}