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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

Popup {
    id: control
    x: Math.round(parent.width / 2 - width / 2)
    y: parent.height - height - FishUI.Units.largeSpacing
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentWidth + leftPadding + rightPadding) + leftInset + rightInset
    implicitHeight: Math.max(background ? background.implicitHeight : 0 ,
                             contentHeight + topPadding + bottomPadding)+ topInset + bottomInset
    height: implicitHeight
    width: implicitWidth

    topPadding: FishUI.Units.smallSpacing
    leftPadding: FishUI.Units.smallSpacing
    rightPadding: FishUI.Units.smallSpacing
    bottomPadding: FishUI.Units.largeSpacing

    modal: false
    closePolicy: Popup.NoAutoClose
    focus: false
    clip: false

    function showNotification(message, timeout, actionText, callBack) {
        if (!message) {
            return
        }

        let interval = 7000

        if (timeout === "short") {
            interval = 4000
        } else if (timeout === "long") {
            interval = 12000
        } else if (timeout > 0) {
            interval = timeout
        }

        open()

        for (let i = 0; i < outerLayout.children.length - 3; ++i) {
            outerLayout.children[i].close()
        }

        let delegate = delegateComponent.createObject(outerLayout, {
            "text": message,
            "actionText": actionText || "",
            "callBack": callBack || (function(){}),
            "interval": interval
        });

        // Reorder items to have the last on top
        let children = outerLayout.children;
        for (let i in children) {
            children[i].Layout.row = children.length - 1 - i
        }
    }

    background: Item {}

    contentItem: GridLayout {
        id: outerLayout
        columns: 1
    }

    Component {
        id: delegateComponent

        Control {
            id: delegate
            property alias text: label.text
            property alias actionText: actionButton.text
            property alias interval: timer.interval
            property var callBack
            Layout.alignment: Qt.AlignCenter
            Layout.bottomMargin: -delegate.height
            opacity: 0

            function close() {
                closeAnim.running = true;
            }

            leftPadding: FishUI.Units.largeSpacing
            rightPadding: FishUI.Units.largeSpacing
            topPadding: FishUI.Units.largeSpacing
            bottomPadding: FishUI.Units.largeSpacing

            Component.onCompleted: openAnim.restart()
            ParallelAnimation {
                id: openAnim
                OpacityAnimator {
                    target: delegate
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: delegate
                    property: "Layout.bottomMargin"
                    from: -delegate.height
                    to: 0
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }

            SequentialAnimation {
                id: closeAnim
                ParallelAnimation {
                    OpacityAnimator {
                        target: delegate
                        from: 1
                        to: 0
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: delegate
                        property: "Layout.bottomMargin"
                        to: -delegate.height
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
                ScriptAction {
                    script: delegate.destroy();
                }
            }

            contentItem: RowLayout {
                id: mainLayout

                width: mainLayout.width
                //FIXME: why this is not automatic?
                implicitHeight: Math.max(label.implicitHeight, actionButton.implicitHeight)

                HoverHandler {
                    id: hover
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: delegate.close();
                }
                Timer {
                    id: timer
                    running: control.visible && !hover.hovered
                    onTriggered: delegate.close();
                }

                Label {
                    id: label
                    Layout.maximumWidth: Math.min(control.parent.width - FishUI.Units.largeSpacing * 4, implicitWidth)
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    maximumLineCount: 4
                }

                Button {
                    id: actionButton
                    visible: text.length > 0
                    onClicked: {
                        delegate.close();;
                        if (delegate.callBack && (typeof delegate.callBack === "function")) {
                            delegate.callBack();
                        }
                    }
                }
            }

            background: Rectangle {
                color: FishUI.Theme.backgroundColor
                radius: FishUI.Theme.mediumRadius
                opacity: 0.9
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 32
                    samples: 32
                    horizontalOffset: 0
                    verticalOffset: 0
                    color: Qt.rgba(0, 0, 0, 0.14)
                }
            }
        }
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
    }

    Overlay.modeless: Item {}
}
