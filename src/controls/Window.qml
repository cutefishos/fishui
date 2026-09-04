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
import QtQuick.Window 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Shapes 1.12
import Qt5Compat.GraphicalEffects
import FishUI 1.0 as FishUI

Window {
    id: control
    width: 640
    height: 480
    visible: true
    flags: Qt.FramelessWindowHint
    color: "transparent"

    default property alias content : _content.data
    property alias background: _background
    property alias header: _header
    property alias headerBackground: _headerBackground
    property Item headerItem

    // Window helper
    property var contentTopMargin: _header.height
    property var windowRadius: FishUI.Theme.windowRadius
    property alias helper: windowHelper

    // Other
    property bool isMaximized: control.visibility === Window.Maximized
    property bool isFullScreen: control.visibility === Window.FullScreen
    property var edgeSize: windowRadius <= 0 ? 8 : windowRadius / 2

    // Resize
    property bool widthResizable: maximumWidth > minimumWidth
    property bool heightResizable: maximumHeight > minimumHeight

    property bool minimizeButtonVisible: true

    property var windowButtonsAlignment: Qt.AlignTop
    property real windowButtonsTopMargin: FishUI.Units.smallSpacing
    property real windowButtonsRightMargin: windowButtonsTopMargin
    property real windowButtonsSpacing: FishUI.Units.smallSpacing / 2

    onHeaderItemChanged: {
        if (headerItem) {
            headerItem.parent = _headerContent
            headerItem.anchors.fill = _headerContent
        }
    }

    FishUI.WindowHelper {
        id: windowHelper
    }

    // A window that has just been mapped is about to be given the focus, and
    // the shadow it is opening with should be the one it will keep: building
    // the inactive shadow first only to replace it a frame later is what made
    // an opening window blink.
    property bool _wasActive: false
    onActiveChanged: if (active) _wasActive = true

    // Window shadows
    FishUI.WindowShadow {
        view: control
        radius: control.windowRadius
        strength: control.active || !control._wasActive ? 0.8 : 0.5
    }

    // Left bottom edge
    MouseArea {
        height: edgeSize * 2
        width: height
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        cursorShape: Qt.SizeBDiagCursor
        propagateComposedEvents: true
        preventStealing: false
        visible: !isMaximized && !isFullScreen
                              && control.widthResizable
                              && control.heightResizable
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.LeftEdge | Qt.BottomEdge)
    }

    // Right bottom edge
    MouseArea {
        height: edgeSize * 2
        width: height
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        cursorShape: Qt.SizeFDiagCursor
        propagateComposedEvents: true
        preventStealing: false
        visible: !isMaximized && !isFullScreen
                              && control.widthResizable
                              && control.heightResizable
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.RightEdge | Qt.BottomEdge)
    }

    // Top edge
    MouseArea {
        height: edgeSize / 2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: edgeSize * 2
        anchors.rightMargin: edgeSize * 2
        visible: !isMaximized && !isFullScreen && control.heightResizable
        cursorShape: Qt.SizeVerCursor
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.TopEdge)
    }

    // Bottom edge
    MouseArea {
        height: edgeSize / 2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: edgeSize * 2
        anchors.rightMargin: edgeSize * 2
        cursorShape: Qt.SizeVerCursor
        visible: !isMaximized && !isFullScreen && control.heightResizable
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.BottomEdge)
    }

    // Left edge
    MouseArea {
        width: edgeSize / 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: edgeSize
        anchors.bottomMargin: edgeSize * 2
        cursorShape: Qt.SizeHorCursor
        visible: !isMaximized && !isFullScreen && control.widthResizable
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.LeftEdge)
    }

    // Right edge
    MouseArea {
        width: edgeSize / 2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: edgeSize
        anchors.bottomMargin: edgeSize * 2
        cursorShape: Qt.SizeHorCursor
        visible: !isMaximized && !isFullScreen && control.widthResizable
        z: 999

        onPressed: windowHelper.startSystemResize(control, Qt.RightEdge)
    }

    // Background and border are one Rectangle on purpose: a separate
    // transparent-fill ring on top of the background is two antialiased
    // rounded shapes, and along the corner arc their feathers cancel so the
    // hairline never reaches full opacity - it reads soft and pale next to
    // the crisp straight edges.
    property real _borderWidth: !isMaximized && !isFullScreen ? 1 / FishUI.Dpi.ratio : 0

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: !isMaximized && !isFullScreen ? control.windowRadius : 0
        color: FishUI.Theme.backgroundColor
        antialiasing: true

        border.width: control._borderWidth
        border.pixelAligned: FishUI.Dpi.ratio <= 1
        border.color: FishUI.Theme.darkMode
                      ? Qt.rgba(1, 1, 1, control.active ? 0.16 : 0.10)
                      : Qt.rgba(0, 0, 0, control.active ? 0.18 : 0.12)

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.Linear
            }
        }
    }

    // Content
    Item {
        id: _contentItem
        anchors.fill: parent

        // Header
        Item {
            id: _header
            z: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 35

            property int buttonSize: 31
            property int spacing: (_header.height - _header.buttonSize) / 2

            Rectangle {
                id: _headerBackground
                anchors.fill: parent
                color: "transparent"
            }

            // Pointer handlers rather than a MouseArea: the whole title bar has
            // to start a window move, including the part covered by the window
            // buttons, and an item would either sit under them and never see
            // those presses or sit over them and swallow their clicks. A
            // handler sees the events wherever they land and only takes the
            // grab once the drag threshold is crossed, so a plain click still
            // reaches the button underneath.
            TapHandler {
                enabled: !control.isFullScreen
                onTapped: if (tapCount === 2) toggleMaximized()
                gesturePolicy: TapHandler.DragThreshold
            }

            DragHandler {
                target: null
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                grabPermissions: PointerHandler.CanTakeOverFromItems
                                 | PointerHandler.CanTakeOverFromHandlersOfDifferentType
                                 | PointerHandler.ApprovesTakeOverByAnything
                onActiveChanged: if (active) { windowHelper.startSystemMove(control) }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    id: _headerContent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: control.windowButtonsSpacing
                    Layout.alignment: control.windowButtonsAlignment

                    // Window buttons
                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "minimize.svg"
                        onClicked: windowHelper.minimizeWindow(control)
                        visible: control.minimizeButtonVisible
                        Layout.alignment: control.windowButtonsAlignment
                        Layout.topMargin: control.windowButtonsTopMargin
                        image.smooth: false
                        image.antialiasing: true
                        // The artwork is a 24x24 grid; anything else is soft.
                        iconSize: 24
                    }

                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" +
                            (FishUI.Theme.darkMode ? "dark/" : "light/") +
                            (control.visibility === Window.Maximized ? "restore.svg" : "maximize.svg")
                        onClicked: control.toggleMaximized()
                        visible: !control.isFullScreen &&  control.minimumWidth !== control.maximumWidth && control.maximumHeight !== control.minimumHeight
                        Layout.alignment: control.windowButtonsAlignment
                        Layout.topMargin: control.windowButtonsTopMargin
                        image.smooth: false
                        image.antialiasing: true
                        // The artwork is a 24x24 grid; anything else is soft.
                        iconSize: 24
                    }

                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "close.svg"
                        onClicked: control.close()
                        // visible: !control.isFullScreen
                        Layout.alignment: control.windowButtonsAlignment
                        Layout.topMargin: control.windowButtonsTopMargin
                        image.smooth: false
                        image.antialiasing: true
                        // The artwork is a 24x24 grid; anything else is soft.
                        iconSize: 24
                    }
                }

                Item {
                    width: control.windowButtonsRightMargin
                }
            }
        }

        // Content item.
        ColumnLayout {
            id: _contentLayout
            anchors.fill: parent
            anchors.topMargin: control.contentTopMargin
            spacing: 0

            Item {
                id: _content
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        // Mask. Inset by the border so opaque content (a sidebar, a view
        // background) stops at the hairline instead of painting over it.
        layer.enabled: _background.radius > 0
        layer.effect: OpacityMask {
            maskSource: Item {
                width: _contentItem.width
                height: _contentItem.height

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: control._borderWidth
                    radius: Math.max(0, _background.radius - control._borderWidth)
                }
            }
        }
    }

    QtObject {
        id: internal
        property QtObject passiveNotification
    }

    function showPassiveNotification(message, timeout, actionText, callBack) {
        if (!internal.passiveNotification) {
            var component = Qt.createComponent("qrc:/fishui/kit/Toast.qml")
            internal.passiveNotification = component.createObject(control)
        }

        internal.passiveNotification.showNotification(message, timeout, actionText, callBack)
    }

    function toggleMaximized() {
        if (isMaximized) {
            control.showNormal();
        } else {
            control.showMaximized();
        }
    }
}
