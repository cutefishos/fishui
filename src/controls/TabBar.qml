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

TabBar {
    id: control

    implicitWidth: _content.width

    default property alias content : _content.data
    property bool newTabVisibile: true

    signal newTabClicked()

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Item {
        RowLayout {
            anchors.fill: parent
            spacing: FishUI.Units.smallSpacing

            ScrollView {
                id: _scrollView

                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                clip: true

                Flickable {
                    id: _flickable

                    Row {
                        id: _content
                        width: _scrollView.width
                        height: _scrollView.height
                    }
                }
            }

            Loader {
                active: control.newTabVisibile
                visible: active
                asynchronous: true

                // Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: 31
                Layout.preferredWidth: visible ? height : 0

                sourceComponent: FishUI.RoundImageButton {
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "add.svg"
                    onClicked: control.newTabClicked()
                }
            }
        }
    }
}
