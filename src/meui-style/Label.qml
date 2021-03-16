import QtQuick 2.1
import QtQuick.Window 2.2
import QtQuick.Templates 2.3 as T
import MeuiKit 1.0 as Meui

T.Label {
    id: control

    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false
    //Text.NativeRendering is broken on non integer pixel ratios
    renderType: Window.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering

    font.capitalization: Meui.Theme.defaultFont.capitalization
    font.family: Meui.Theme.defaultFont.family
    font.italic: Meui.Theme.defaultFont.italic
    font.letterSpacing: Meui.Theme.defaultFont.letterSpacing
    font.pointSize: Meui.Theme.defaultFont.pointSize
    font.strikeout: Meui.Theme.defaultFont.strikeout
    font.underline: Meui.Theme.defaultFont.underline
    font.weight: Meui.Theme.defaultFont.weight
    font.wordSpacing: Meui.Theme.defaultFont.wordSpacing
    color: Meui.Theme.textColor
    linkColor: Meui.Theme.linkColor

    opacity: enabled? 1 : 0.6

    Accessible.role: Accessible.StaticText
    Accessible.name: text
}
