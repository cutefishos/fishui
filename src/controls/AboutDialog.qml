import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

Dialog {
    id: control

    width: 500
    height: 430

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: "hello"
        }
    }
}
