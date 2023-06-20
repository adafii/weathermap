import QtQuick
import QtLocation
import QtPositioning

Item {
    function createMarker(map, coordinate) {
        const component = Qt.createComponent("Marker.qml");
        if (component.status === Component.Ready) {
            const marker = component.createObject(map, {
                    "coordinate": coordinate,
                    "map": map
                });
            map.addMapItem(marker);
        }
    }

    Plugin {
        id: mapPlugin

        name: "osm"
        locales: "en_US"

        PluginParameter {
            name: "osm.useragent"
            value: "test"
        }
        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "http://maps-redirect.qt.io/osm/"
        }
    }

    Map {
        id: map

        property geoCoordinate startCentroid

        anchors.fill: parent
        center: QtPositioning.coordinate(65, 25)
        plugin: mapPlugin
        zoomLevel: 6

        PinchHandler {
            id: pinch

            grabPermissions: PointerHandler.TakeOverForbidden
            target: null

            onActiveChanged: if (active) {
                map.startCentroid = map.toCoordinate(pinch.centroid.position, false);
            }
            onRotationChanged: delta => {
                map.bearing -= delta;
                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position);
            }
            onScaleChanged: delta => {
                map.zoomLevel += Math.log2(delta);
                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position);
            }
        }
        WheelHandler {
            id: wheel

            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland" ? PointerDevice.Mouse | PointerDevice.TouchPad : PointerDevice.Mouse
            property: "zoomLevel"
            rotationScale: 1 / 40
        }
        DragHandler {
            id: drag

            target: null

            onTranslationChanged: delta => map.pan(-delta.x, -delta.y)
        }
        TapHandler {
            id: tap

            acceptedButtons: Qt.RightButton

            onTapped: {
                createMarker(map, map.toCoordinate(tap.point.position));
            }
        }
    }
}
