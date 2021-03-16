import QtQuick 2.6
import QtQuick.Templates 2.3 as T
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

T.TabBar {
    id: control

    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + Meui.Units.smallSpacing)
    implicitHeight: contentItem.implicitHeight

    spacing: 0

    contentItem: ListView {
        implicitWidth: contentWidth
        implicitHeight: control.contentModel.get(0).height

        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem

        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 48
        preferredHighlightEnd: width - 48

        highlight: Item {
            Rectangle {
                anchors {
                    fill: parent
                    margins: 2
                }
                color: Meui.Theme.darkMode ? Qt.lighter(Meui.Theme.backgroundColor, 2.2) : Meui.Theme.backgroundColor
                radius: Meui.Theme.smallRadius

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 2
                    samples: 2
                    horizontalOffset: 0
                    verticalOffset: 0
                    color: Qt.rgba(0, 0, 0, 0.11)
                }
            }
        }
    }

    background: Rectangle {
        color: Meui.Theme.darkMode ? Qt.lighter(Meui.Theme.backgroundColor, 1.5) : Meui.Theme.secondBackgroundColor
        radius: Meui.Theme.smallRadius + 2
    }
}