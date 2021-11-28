/*
 * Copyright 2017 Marco Martin <mart@kde.org>
 * Copyright 2017 The Qt Company Ltd.
 *
 * GNU Lesser General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU Lesser
 * General Public License version 3 as published by the Free Software
 * Foundation and appearing in the file LICENSE.LGPLv3 included in the
 * packaging of this file. Please review the following information to
 * ensure the GNU Lesser General Public License version 3 requirements
 * will be met: https://www.gnu.org/licenses/lgpl.html.
 *
 * GNU General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU
 * General Public License version 2.0 or later as published by the Free
 * Software Foundation and appearing in the file LICENSE.GPL included in
 * the packaging of this file. Please review the following information to
 * ensure the GNU General Public License version 2.0 requirements will be
 * met: http://www.gnu.org/licenses/gpl-2.0.html.
 */


import QtQuick 2.6
import QtQuick.Window 2.1
import QtQuick.Controls 2.3 as Controls
import QtQuick.Templates 2.3 as T
import FishUI 1.0 as FishUI

T.TextField {
    id: control

    implicitWidth: Math.max(200,
                            placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
                            || contentWidth + leftPadding + rightPadding + FishUI.Units.extendBorderWidth
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             placeholder.implicitHeight + topPadding + bottomPadding + FishUI.Units.extendBorderWidth)

    // padding: 6
    leftPadding: FishUI.Units.smallSpacing + FishUI.Units.extendBorderWidth
    rightPadding: FishUI.Units.smallSpacing + FishUI.Units.extendBorderWidth

    //Text.NativeRendering is broken on non integer pixel ratios
    // renderType: Window.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
    renderType: FishUI.Theme.renderType

    color: control.enabled ? FishUI.Theme.textColor : FishUI.Theme.disabledTextColor
    selectionColor: FishUI.Theme.highlightColor
    selectedTextColor: FishUI.Theme.highlightedTextColor
    selectByMouse: true

    horizontalAlignment: Text.AlignLeft
    verticalAlignment: TextInput.AlignVCenter

    opacity: control.enabled ? 1.0 : 0.5

 	// cursorDelegate: CursorDelegate { }

    Controls.Label {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font: control.font
        color: FishUI.Theme.textColor
        opacity: 0.4
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
	}

    background: Rectangle {
        implicitWidth: (FishUI.Units.iconSizes.medium * 3) + FishUI.Units.smallSpacing + FishUI.Units.extendBorderWidth
        implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing + FishUI.Units.extendBorderWidth
        // color: control.activeFocus ? Qt.lighter(FishUI.Theme.backgroundColor, 1.4) : FishUI.Theme.backgroundColor
        color: FishUI.Theme.alternateBackgroundColor
        radius: FishUI.Theme.smallRadius

        border.width: 1
        border.color: control.activeFocus ? FishUI.Theme.highlightColor : FishUI.Theme.alternateBackgroundColor

        // Rectangle {
        //     id: _border
        //     anchors.fill: parent
        //     color: "transparent"
        //     border.color: control.activeFocus ? Qt.rgba(FishUI.Theme.highlightColor.r,
        //                                                 FishUI.Theme.highlightColor.g,
        //                                                 FishUI.Theme.highlightColor.b, 0.2) : "transparent"
        //     border.width: FishUI.Units.extendBorderWidth
        //     radius: FishUI.Theme.smallRadius + FishUI.Units.extendBorderWidth

        //     Behavior on border.color {
        //         ColorAnimation {
        //             duration: 50
        //         }
        //     }
        // }

        // Rectangle {
        //     anchors.fill: parent
        //     anchors.margins: FishUI.Units.extendBorderWidth
        //     radius: FishUI.Theme.smallRadius
        //     color: FishUI.Theme.backgroundColor
        //     border.color: control.activeFocus ? FishUI.Theme.highlightColor : Qt.tint(FishUI.Theme.textColor, Qt.rgba(FishUI.Theme.backgroundColor.r, FishUI.Theme.backgroundColor.g, FishUI.Theme.backgroundColor.b, 0.7))
        //     border.width: 1
        // }
    }
}
