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
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layout 1.12
import FishUI 1.0 as FishUI

QQC2.Popup {
    id: control

    property string title
    property string text
    property string leftButtonText
    property string rightButtonText

    property QtObject sourceItem: null

    signal rightButtonClicked()
    signal leftButtonClicked()

    anchors.centerIn: applicationWindow().overlay
    parent: applicationWindow().overlay

    modal: true
    closePolicy: QQC2.Popup.NoAutoClose

    height: 22 * 14
    width: 22 * 25

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent

            Text {
                text: control.title
            }

            Text {
                text: control.text
            }

            RowLayout {
                Button {
                    text: control.leftButtonText
                }

                Button {
                    text: control.rightButtonText
                }
            }
        }
    }
}