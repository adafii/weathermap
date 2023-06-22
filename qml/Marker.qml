import QtLocation
import QtQuick
import App

MapQuickItem {
    id: marker

    property Map map

    anchorPoint.x: markerImage.width / 2
    anchorPoint.y: markerImage.height

    sourceItem: Item {
        height: markerImage.height
        width: markerImage.width

        Item {
            id: info
            anchors {
                left: markerImage.right
                top: markerImage.top
            }

            height: locationText.height + weatherText.height;

            Text {
                id: locationText

                anchors.left: info.left
                anchors.top: info.top
                text: {}
            }
            Text {
                id: weatherText

                anchors.left: locationText.left
                anchors.top: locationText.text !== "" ? locationText.bottom : info.top
                text: weather.isValid ? weather.temperature + " °C" : ""
            }
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

    Weather {
        id: weather

        Component.onCompleted: {
            setCoordinate(marker.coordinate.latitude, marker.coordinate.longitude);
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
                if (count === 0) {
                    break;
                }
                const address = get(0).address;
                if (address.city) {
                    locationText.text = address.city + ', ' + address.country;
                } else if (address.country) {
                    locationText.text = address.country;
                } else {
                    locationText.text = "";
                }
                break;
            case GeocodeModel.Loading:
                locationText.text = "";
                break;
            default:
                markerText.text = "";
            }
        }
    }
    DragHandler {
        id: dragHandler

        cursorShape: Qt.ClosedHandCursor
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

        onGrabChanged: function (transition, point) {
            if (transition === PointerDevice.UngrabPassive) {
                weather.setCoordinate(marker.coordinate.latitude, marker.coordinate.longitude);
                geocodeModel.query = marker.coordinate;
                geocodeModel.update();
                info.visible = true;
            }
            if (transition === PointerDevice.GrabPassive) {
                info.visible = false;
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