import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    title: "Main window"
    visible: true

    MapView {
        id: mapview

        anchors.fill: parent
    }
}

