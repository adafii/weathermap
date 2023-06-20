import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    title: "Map view"
    visible: true

    MapView {
        id: mapview

        anchors.fill: parent
    }
}

