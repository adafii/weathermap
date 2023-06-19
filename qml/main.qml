import QtQuick
import QtLocation
import QtPositioning
import QtQuick.Controls
import QtQuick.Layouts
import app

ApplicationWindow {
    id: window

    title: "Main window"
    visible: true

    Plugin {
        id: mapPlugin

        name: "osm"

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
        center: QtPositioning.coordinate(65, 27)
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

            // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
            // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
            // and we don't yet distinguish mice and trackpads on Wayland either
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland" ? PointerDevice.Mouse | PointerDevice.TouchPad : PointerDevice.Mouse
            property: "zoomLevel"
            rotationScale: 1 / 80
        }
        DragHandler {
            id: drag

            target: null

            onTranslationChanged: delta => map.pan(-delta.x, -delta.y)
        }
        TapHandler {
            id: tap

            acceptedButtons: Qt.RightButton

            onTapped: console.log(map.toCoordinate(tap.point.position))
        }
    }
}
