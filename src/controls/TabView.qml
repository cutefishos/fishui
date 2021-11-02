/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     Reion Wong <reion@cutefishos.com>
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

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FishUI 1.0 as FishUI

Container {
    id: control

    spacing: 0

    contentItem: ColumnLayout {
        spacing: 0

        ListView {
            id: _view
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: false
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            currentIndex: control.currentIndex

            model: control.contentModel

            boundsBehavior: Flickable.StopAtBounds
            boundsMovement :Flickable.StopAtBounds

            spacing: 0

            preferredHighlightBegin: 0
            preferredHighlightEnd: width

            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            highlightFollowsCurrentItem: true
            highlightResizeDuration: 0
            highlightMoveVelocity: -1
            highlightResizeVelocity: -1

            maximumFlickVelocity: 4 * width

            cacheBuffer: _view.count * width
            keyNavigationEnabled : false
            keyNavigationWraps : false
        }
    }

    function closeTab(index) {
        control.removeItem(control.takeItem(index))
        control.currentItemChanged()
        control.currentItem.forceActiveFocus()
    }

    function addTab(component, properties) {
        const object = component.createObject(control.contentModel, properties)

        control.addItem(object)
        control.currentIndex = Math.max(control.count - 1, 0)
        object.forceActiveFocus()

        return object
    }
}
