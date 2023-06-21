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

        Rectangle {
            id: info

            property var margin: 10

            anchors.left: markerImage.right
            anchors.verticalCenter: markerImage.verticalCenter
            color: "#aaefefef"
            height: weatherText.height + locationText.height + margin
            radius: 5
            width: locationText.width > weatherText.width ? locationText.width + margin : weatherText.width + margin

            Text {
                id: locationText

                anchors.left: info.left
                anchors.margins: 5
                anchors.top: info.top
                text: ""
            }
            Text {
                id: weatherText

                anchors.left: locationText.left
                anchors.top: locationText.bottom
                text: weather.temperature
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
                    locationText.text = "NA";
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