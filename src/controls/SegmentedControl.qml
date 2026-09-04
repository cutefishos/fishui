import QtQuick
import QtQuick.Templates as T
import Qt5Compat.GraphicalEffects
import FishUI 1.0 as FishUI

T.TabBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding + FishUI.Units.smallSpacing)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 2
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
                radius: height / 2

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 3
                    samples: 6
                    horizontalOffset: 0
                    verticalOffset: 1
                    color: Qt.rgba(0, 0, 0, FishUI.Theme.darkMode ? 0.18 : 0.12)
                }
            }
        }
    }

    background: Rectangle {
        color: FishUI.Theme.alternateBackgroundColor
        radius: height / 2
    }
}
