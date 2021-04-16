pragma Singleton

import QtQuick 2.4
import FishUI.Core 1.0 as FishUICore

QtObject {
    id: theme

    property real devicePixelRatio: FishUICore.ThemeManager.devicePixelRatio

    property bool darkMode: FishUICore.ThemeManager.darkMode

    property color blueColor: FishUICore.ThemeManager.blueColor
    property color redColor: FishUICore.ThemeManager.redColor
    property color greenColor: FishUICore.ThemeManager.greenColor
    property color purpleColor: FishUICore.ThemeManager.purpleColor
    property color pinkColor: FishUICore.ThemeManager.pinkColor
    property color orangeColor: FishUICore.ThemeManager.orangeColor

    property color backgroundColor: darkMode ? "#3B3B3D" : "#FFFFFF"
    property color secondBackgroundColor: darkMode ? "#2E2E2E" : "#F5F5F5"

    property color textColor: darkMode ? "#FFFFFF" : "#333338"
    property color disabledTextColor: darkMode ? "#888888" : "#64646E"

    property color highlightColor: FishUICore.ThemeManager.accentColor
    property color highlightedTextColor: darkMode ? "#FFFFFF" : "#FFFFFF"

    property color activeTextColor: "#0176D3"
    property color activeBackgroundColor: "#0176D3"

    property color linkColor: "#2196F3"
    property color linkBackgroundColor: "#2196F3"
    property color visitedLinkColor: "#2196F3"
    property color visitedLinkBackgroundColor: "#2196F3"

    property real smallRadius: 8.0
    property real mediumRadius: 10.0
    property real bigRadius: 12.0
    property real hugeRadius: 14.0

    property font defaultFont: fontMetrics.font
    property font smallFont: {
        let font = fontMetrics.font
        if (!!font.pixelSize) {
            font.pixelSize =- 2
        } else {
            font.pointSize =- 2
        }
        return font
    }

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
        }
    ]
}