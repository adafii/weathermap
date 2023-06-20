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
            text: (marker.coordinate.latitude).toFixed(2) + '\n' + (marker.coordinate.longitude).toFixed(2)
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

    DragHandler {
        id: dragHandler

        cursorShape: Qt.ClosedHandCursor
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

        onGrabChanged: function (transition, point) {
            if (transition === PointerDevice.UngrabPassive) {
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