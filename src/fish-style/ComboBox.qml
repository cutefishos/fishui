/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Window 2.4
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.12 as T
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    topInset: FishUI.Units.smallSpacing
    bottomInset: FishUI.Units.smallSpacing

    spacing: FishUI.Units.smallSpacing
    padding: FishUI.Units.smallSpacing
    leftPadding: FishUI.Units.largeSpacing
    rightPadding: FishUI.Units.largeSpacing

    property bool darkMode: FishUI.Theme.darkMode

    onDarkModeChanged: {
        updateTimer.restart()
    }

    delegate: MenuItem {
        width: control.popup.width
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    indicator: Image {
        id: indicatorImage
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        height: FishUI.Units.iconSizes.small
        width: height

        cache: false

        source: "image://icontheme/go-down"
        sourceSize.width: width
        sourceSize.height: height
    }

    Timer {
        id: updateTimer
        triggeredOnStart: true
        interval: 10

        onTriggered: {
            indicatorImage.source = ""
            indicatorImage.source = "image://icontheme/go-down"
        }
    }

    contentItem: T.TextField {
        padding: FishUI.Units.smallSpacing
        leftPadding: 0
        rightPadding: FishUI.Units.smallSpacing

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator

        font: control.font
        color: control.enabled ? control.FishUI.Theme.textColor : control.FishUI.Theme.highlightColor
        selectionColor:  control.FishUI.Theme.highlightColor
        selectedTextColor: control.FishUI.Theme.highlightedTextColor
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth:  (FishUI.Units.iconSizes.medium * 3) + FishUI.Units.largeSpacing
        implicitHeight: FishUI.Units.iconSizes.medium + FishUI.Units.smallSpacing

        radius: FishUI.Theme.smallRadius
        color: FishUI.Theme.alternateBackgroundColor

        border.color: control.activeFocus ? FishUI.Theme.highlightColor : color
        border.width: 1
    }

    popup: T.Popup {
        width: Math.max(control.width, 150)
        implicitHeight: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin) + FishUI.Units.largeSpacing
        transformOrigin: Item.Top

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.InOutCubic
                duration: 150
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.InOutCubic
                duration: 150
            }
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            topMargin: FishUI.Units.smallSpacing
            bottomMargin: FishUI.Units.smallSpacing
            spacing: FishUI.Units.smallSpacing

            T.ScrollBar.vertical: ScrollBar {}
        }

        background: Rectangle {
            radius: FishUI.Theme.smallRadius
            color: parent.FishUI.Theme.secondBackgroundColor
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
    }
}
