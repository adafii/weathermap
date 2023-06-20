import QtLocation
import QtQuick

MapQuickItem {
    id: marker

    property Map map

    anchorPoint.x: markerImage.width / 2
    anchorPoint.y: markerImage.height

    sourceItem: Item {
        height: markerImage.height
        width: markerImage.width

        Text {
            id: markerText

            anchors.left: markerImage.right
            text: ""
        }
        Image {
            id: markerImage

            height: 30
            source: "qrc:images/marker.svg"
            sourceSize.height: 30
            sourceSize.width: 30
            width: 30
        }
    }

    GeocodeModel {
        id: geocodeModel

        autoUpdate: false
        plugin: map.plugin

        Component.onCompleted: {
            query = marker.coordinate;
            update();
        }
        onStatusChanged: {
            switch (status) {
            case GeocodeModel.Ready:
                const address = get(0).address;
                if (address.city) {
                    markerText.text = address.city + ', ' + address.country;
                } else if (address.country) {
                    markerText.text = address.country;
                } else {
                    markerText.text = "Unknown";
                }
                break;
            case GeocodeModel.Loading:
                markerText.text = "Fetching";
                break;
            default:
                markerText.text = "Unknown";
            }
        }
    }
    DragHandler {
        id: dragHandler

        cursorShape: Qt.ClosedHandCursor
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

        onGrabChanged: function (transition, point) {
            if (transition === PointerDevice.UngrabPassive) {
                geocodeModel.query = marker.coordinate;
                geocodeModel.update();
                markerText.visible = true;
            }
            if (transition === PointerDevice.GrabPassive) {
                markerText.visible = false;
            }
        }
    }
    TapHandler {
        id: tapHandler

        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.WithinBounds

        onTapped: {
            map.removeMapItem(marker);
            marker.destroy();
        }
    }
}