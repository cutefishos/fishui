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

import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI
import QtQuick.Controls.impl 2.12

T.Button {
    id: control
    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + FishUI.Units.largeSpacing)
    implicitHeight: background.implicitHeight
    hoverEnabled: true

    icon.width: FishUI.Units.iconSizes.small
    icon.height: FishUI.Units.iconSizes.small

    icon.color: control.enabled ? (control.highlighted ? control.FishUI.Theme.highlightColor : control.FishUI.Theme.textColor) : control.FishUI.Theme.disabledTextColor
    spacing: FishUI.Units.smallSpacing

    property color hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.alternateBackgroundColor, 1.2)
                                                       : Qt.darker(FishUI.Theme.alternateBackgroundColor, 1.1)

    property color pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.alternateBackgroundColor, 1.1)
                                                       : Qt.darker(FishUI.Theme.alternateBackgroundColor, 1.2)

    property color borderColor: Qt.rgba(FishUI.Theme.highlightColor.r,
                                        FishUI.Theme.highlightColor.g,
                                        FishUI.Theme.highlightColor.b, 0.5)

    property color flatHoveredColor: Qt.lighter(FishUI.Theme.highlightColor, 1.1)
    property color flatPressedColor: Qt.darker(FishUI.Theme.highlightColor, 1.1)

    contentItem: IconLabel {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? control.FishUI.Theme.disabledTextColor : control.flat ? FishUI.Theme.highlightedTextColor : FishUI.Theme.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }

    background: Item {
        implicitWidth: (FishUI.Units.iconSizes.medium * 3) + FishUI.Units.largeSpacing
        implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing

        Rectangle {
            id: _flatBackground
            anchors.fill: parent
            radius: FishUI.Theme.mediumRadius
            border.width: 1
            border.color: control.enabled ? control.activeFocus ? FishUI.Theme.highlightColor : "transparent"
                                          : "transparent"
            visible: control.flat

            color: {
                if (!control.enabled)
                    return FishUI.Theme.alternateBackgroundColor

                if (control.pressed)
                    return control.flatPressedColor

                if (control.hovered)
                    return control.flatHoveredColor

                return FishUI.Theme.highlightColor
            }

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(_flatBackground.color.r,
                                                             _flatBackground.color.g,
                                                             _flatBackground.color.b, 0.85) }
                GradientStop { position: 1.0; color: Qt.rgba(_flatBackground.color.r,
                                                             _flatBackground.color.g,
                                                             _flatBackground.color.b, 1) }
            }
        }

        Rectangle {
            id: _background
            anchors.fill: parent
            radius: FishUI.Theme.mediumRadius
            border.width: 1
            visible: !control.flat
            border.color: control.enabled ? control.activeFocus ? FishUI.Theme.highlightColor : "transparent"
                                          : "transparent"

            color: {
                if (!control.enabled)
                    return FishUI.Theme.alternateBackgroundColor

                if (control.pressed)
                    return control.pressedColor

                if (control.hovered)
                    return control.hoveredColor

                return FishUI.Theme.alternateBackgroundColor
            }
        }
    }
}
