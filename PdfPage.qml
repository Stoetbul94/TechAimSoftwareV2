import QtQuick 2.0

Item {
    id: rootItem
    width: 595 // A4 size for 72 dpi
    height: 842 // A4 sixe for 72 dpi

    property int pageIndex: 0
    property string title: appMode ? qsTr("Page ") + pageIndex : qsTr("Page ") + pageIndex + qsTr(" DEMO")
    property var sourceComp: null

    onVisibleChanged: {
        console.log("Pdf page visible ", visible)
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Text {
            id: headerTitle
            width: implicitWidth
            height: implicitHeight
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            text: title
            color: "black"
        }

        Image {
            id: reportLogo
            source: APPSETTINGS.getBrandLogo()
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 16
            width: 115
            height: 36
            fillMode: Image.PreserveAspectFit
        }
        Text {
            id: demoText
            width: implicitWidth
            height: reportLogo.height/2
            anchors.top: reportLogo.bottom
            anchors.topMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: 16
            text: "DEMO"
            color: "red"
            font.pixelSize: 11
            visible: !appMode
        }

        Loader {
            sourceComponent: sourceComp
            anchors.top: parent.top
            anchors.topMargin: 56
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        radius: 8
    }
}
