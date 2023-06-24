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

        locales: "en_US"
        name: "osm"

        PluginParameter {
            name: "osm.useragent"
            value: "weathermap/0.1 github.com/adafii/weathermap"
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
        copyrightsVisible: false
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
    Text {
        text: 'Map data from <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>. Weather data from <a href="https://api.met.no/doc/License">MET Norway</a>.'
        font.family: "Monospace"
        onLinkActivated: Qt.openUrlExternally(link)

        anchors {
            bottom: parent.bottom
            left: parent.left
        }
    }
}
