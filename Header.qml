import QtQuick 2.15
Item {
    property int rootItemWidth:1366
    property int rootItemHeight:45
    signal close()
    signal minimize()

    Rectangle {
        id: fullRect
        color: "#11161c"
        anchors.fill: parent
        border.color: "#2b343e"
        border.width: 1
    }

    Rectangle {
        id: minimizeButton
        width: 42
        height: 30
        radius: 7
        color: minimizeMouse.containsMouse ? "#2b343e" : "transparent"
        anchors.right: closeButton.left
        anchors.rightMargin: 7
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -4
            text: "–"
            color: "#c5ced8"
            font.pixelSize: 24
        }

        MouseArea {
            id: minimizeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: minimize()
        }
    }
    Rectangle {
        id: closeButton
        width: 42
        height: 30
        radius: 7
        color: closeMouse.containsMouse ? "#b90042" : "transparent"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "×"
            color: "white"
            font.pixelSize: 23
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: close()
        }
    }
    Text {
        id: heading
      //  anchors.left: parent.left
       // anchors.leftMargin: 10
        height: implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "#e9eef4"
        text: APPSETTINGS.getBrandDisplayName() + "  •  ELECTRONIC TARGET"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        font.letterSpacing: 1.1
    }
    Text {
        anchors.right: closeButton.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: typeof TECHAIM_BUILD !== "undefined" ? TECHAIM_BUILD : ""
        color: "#4a5560"
        font.pixelSize: 9
        visible: text !== ""
    }
}
