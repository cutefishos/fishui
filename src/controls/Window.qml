import QtQuick 2.12
import QtQuick.Window 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Shapes 1.12
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

Window {
    id: root
    width: 640
    height: 480
    visible: true
    flags: Qt.FramelessWindowHint
    color: "transparent"

    property var backgroundColor: Meui.Theme.backgroundColor
    property var backgroundOpacity: 1.0
    property var windowRadius: Meui.Theme.bigRadius

    property alias headerBarHeight: _titlebar.height
    property bool hideHeaderOnMaximize: false
    property bool isMaximized: root.visibility === Window.Maximized
    property bool isFullScreen: root.visibility === Window.FullScreen

    property var edgeSize: windowRadius / 2

    default property alias content : _content.data
    property Item headerBar

    onHeaderBarChanged: {
        headerBar.parent = _header
        headerBar.anchors.fill = _header
    }

    function toggleMaximized() {
        if (isMaximized) {
            root.showNormal();
        } else {
            root.showMaximized();
        }
    }

    Meui.WindowHelper {
        id: windowHelper
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
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.LeftEdge | Qt.BottomEdge) }
        }
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
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.RightEdge | Qt.BottomEdge) }
        }
    }

    // Top edge
    MouseArea {
        height: edgeSize / 2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: edgeSize * 2
        anchors.rightMargin: edgeSize * 2
        visible: !isMaximized && !isFullScreen
        cursorShape: Qt.SizeVerCursor
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.TopEdge) }
        }
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
        visible: !isMaximized && !isFullScreen
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.BottomEdge) }
        }
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
        visible: !isMaximized && !isFullScreen
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.LeftEdge) }
        }
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
        visible: !isMaximized && !isFullScreen
        z: 999

        onPressed: mouse.accepted = false

        DragHandler {
            grabPermissions: TapHandler.CanTakeOverFromAnything
            target: null
            onActiveChanged: if (active) { windowHelper.startSystemResize(root, Qt.RightEdge) }
        }
    }

    // Window shadows
    Meui.WindowShadow {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        radius: _background.radius
    }

    // background
    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.margins: 0
        radius: !isMaximized && !isFullScreen ? root.windowRadius : 0
        color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                       root.backgroundColor.b, root.backgroundOpacity)
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.color: Qt.rgba(0, 0, 0, 0.3)
            antialiasing: true
            visible: !isMaximized && !isFullScreen
            z: 999
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            radius: parent.radius - 1
            border.color: Qt.rgba(255, 255, 255, 0.3)
            antialiasing: true
            visible: !isMaximized && !isFullScreen && Meui.Theme.darkMode
            z: 999
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: !isMaximized && !isFullScreen ? 1 : 0
            spacing: 0

            Item {
                id: _titlebar
                Layout.fillWidth: true
                height: 40

                Item {
                    anchors.fill: parent

                    TapHandler {
                        onTapped: if (tapCount === 2) toggleMaximized()
                        gesturePolicy: TapHandler.DragThreshold
                    }

                    DragHandler {
                        acceptedDevices: PointerDevice.GenericPointer
                        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
                        onActiveChanged: if (active) { windowHelper.startSystemMove(root) }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        id: _header
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Item {
                        id: _windowControl
                        Layout.fillHeight: true
                        width: _windowControlLayout.implicitWidth + Meui.Units.smallSpacing

                        RowLayout {
                            id: _windowControlLayout
                            anchors.fill: parent
                            anchors.topMargin: Meui.Units.smallSpacing
                            anchors.rightMargin: Meui.Units.smallSpacing
                            spacing: Meui.Units.largeSpacing

                            WindowButton {
                                size: 35
                                source: "qrc:/meui/kit/images/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "minimize.svg"
                                onClicked: windowHelper.minimizeWindow(root)
                                visible: root.visibility !== Window.FullScreen
                                Layout.alignment: Qt.AlignTop
                            }

                            WindowButton {
                                size: 35
                                source: "qrc:/meui/kit/images/" +
                                    (Meui.Theme.darkMode ? "dark/" : "light/") +
                                    (root.visibility === Window.Maximized ? "restore.svg" : "maximize.svg")
                                onClicked: root.toggleMaximized()
                                visible: root.visibility !== Window.FullScreen
                                Layout.alignment: Qt.AlignTop
                            }

                            WindowButton {
                                size: 35
                                source: "qrc:/meui/kit/images/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "close.svg"
                                onClicked: root.close()
                                visible: root.visibility !== Window.FullScreen
                                Layout.alignment: Qt.AlignTop
                            }
                        }
                    }
                }
            }

            Item {
                id: _content
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: _background.width
                    height: _background.height

                    Rectangle {
                        anchors.fill: parent
                        radius: _background.radius
                    }
                }
            }
        }
    }
}
