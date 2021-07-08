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
import QtGraphicalEffects 1.0
import QtQuick.Templates 2.3 as T
import FishUI 1.0 as FishUI

T.Dialog {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentWidth > 0 ? contentWidth + leftPadding + rightPadding : 0)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentWidth > 0 ? contentHeight + topPadding + bottomPadding : 0)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight + header.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0) + header.implicitHeight + footer.implicitHeight
    padding: FishUI.Theme.hugeRadius

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            easing.type: Easing.InOutCubic
            duration: 200
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            easing.type: Easing.InOutCubic
            duration: 200
        }
    }

    contentItem: Item {}

    background: Rectangle {
        radius: FishUI.Theme.hugeRadius
        color: FishUI.Theme.secondBackgroundColor
        border.width: 0

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 32
            samples: 32
            horizontalOffset: 0
            verticalOffset: 0
            color: Qt.rgba(0, 0, 0, 0.15)
        }
    }

    header: Item {
        id: _headerItem
        implicitHeight: _headerLabel.visible ? _headerLabel.implicitHeight + FishUI.Units.largeSpacing : 0

        Label {
            id: _headerLabel
            anchors.centerIn: parent
            text: control.title
            visible: control.title != ""
            elide: Label.ElideRight
            bottomPadding: 0
        }
    }

    footer: DialogButtonBox {
        visible: count > 0
        padding: FishUI.Units.largeSpacing * 2
    }
}