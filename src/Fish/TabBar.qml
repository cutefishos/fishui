import QtQuick
import QtQuick.Templates as T
import Qt5Compat.GraphicalEffects
import FishUI 1.0 as FishUI

T.TabBar {
    id: control

    // The implicit size must come from T.TabBar's own contentWidth/contentHeight,
    // never from the ListView: the ListView's contentWidth follows the tab
    // widths, which follow the bar's width, so routing the implicit size
    // through it makes a Layout re-polish for ever at 100% CPU.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding + FishUI.Units.smallSpacing)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    spacing: 0

    contentItem: ListView {
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
                color: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 2)
                                             : FishUI.Theme.secondBackgroundColor
                radius: FishUI.Theme.smallRadius

                layer.enabled: FishUI.Theme.darkMode
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
        color: FishUI.Theme.alternateBackgroundColor
        radius: FishUI.Theme.smallRadius + 2
    }
}
