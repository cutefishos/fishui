import QtQuick 2.1
import QtQuick.Window 2.2
import QtQuick.Templates 2.3 as T
import FishUI 1.0 as FishUI

T.Label {
    id: control

    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false
    //Text.NativeRendering is broken on non integer pixel ratios
    renderType: Window.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering

    font.capitalization: FishUI.Theme.defaultFont.capitalization
    font.family: FishUI.Theme.defaultFont.family
    font.italic: FishUI.Theme.defaultFont.italic
    font.letterSpacing: FishUI.Theme.defaultFont.letterSpacing
    font.pointSize: FishUI.Theme.fontSize
    font.strikeout: FishUI.Theme.defaultFont.strikeout
    font.underline: FishUI.Theme.defaultFont.underline
    font.weight: FishUI.Theme.defaultFont.weight
    font.wordSpacing: FishUI.Theme.defaultFont.wordSpacing
    color: FishUI.Theme.textColor
    linkColor: FishUI.Theme.linkColor

    opacity: enabled ? 1 : 0.6

    Accessible.role: Accessible.StaticText
    Accessible.name: text
}
