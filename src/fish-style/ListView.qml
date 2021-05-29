import QtQuick 2.6
import QtQuick.Controls 2.3
import QtQuick.Templates 2.3 as T
import FishUI 1.0 as FishUI

T.ListView {
    id: control

    FishUI.WheelHandler {
        target: control
    }
}
