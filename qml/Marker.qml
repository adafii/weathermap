import QtLocation
import QtQuick

MapQuickItem {
    id: marker
    anchorPoint.x: markerImage.width / 2
    anchorPoint.y: markerImage.height
    property Map map

    sourceItem: Image {
        id: markerImage

        height: 30
        source: "qrc:images/marker.svg"
        sourceSize.height: 30
        sourceSize.width: 30
        width: 30
    }

    TapHandler {
        id: tapHandler

        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.WithinBounds

        onTapped: {
            map.removeMapItem(marker)
            marker.destroy();
        }
    }
}