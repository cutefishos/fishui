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

Item {
    id: control

    property bool newTabVisibile: true
    property alias model: _listView.model
    property alias delegate: _listView.delegate
    property alias count: _listView.count
    property alias currentIndex: _listView.currentIndex

    signal newTabClicked()

    RowLayout {
        anchors.fill: parent
        spacing: FishUI.Units.smallSpacing / 2

        ListView {
            id: _listView
            Layout.fillHeight: true
            Layout.preferredWidth: _listView.childrenRect.width
            Layout.alignment: Qt.AlignLeft
            orientation: ListView.Horizontal
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            clip: true
        }

        Loader {
            active: control.newTabVisibile
            visible: active
            asynchronous: true

            // Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.preferredHeight: 31
            Layout.preferredWidth: visible ? height : 0

            sourceComponent: FishUI.RoundImageButton {
                source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "add.svg"
                onClicked: control.newTabClicked()
                iconMargins: 2
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
