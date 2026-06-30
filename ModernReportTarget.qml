import QtQuick 2.15

Item {
    id: root

    property var shots: []
    property bool showNumbers: true
    property real targetDiameterMm: TARGETGEOMETRY.targetFaceMillimeters(
                                        window.gameRange, shootingPage.currentGameDisplay2 === qsTr("PISTOL"))

    Image {
        id: target
        anchors.fill: parent
        source: "qrc:/images/centerPanel/black_50_Rifle.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Item {
        id: plot
        width: Math.min(parent.width, parent.height)
        height: width
        anchors.centerIn: parent

        Repeater {
            model: root.shots

            delegate: Rectangle {
                property real scaleFactor: plot.width / root.targetDiameterMm
                width: Math.max(7, APPSETTINGS.bullet_diameter() * scaleFactor)
                height: width
                radius: width / 2
                x: plot.width / 2 + Number(modelData.x) * scaleFactor - width / 2
                y: plot.height / 2 - Number(modelData.y) * scaleFactor - height / 2
                color: Number(modelData.decimalScore) >= 10.2
                       ? "#10b981"
                       : (Number(modelData.decimalScore) >= 9 ? "#f59e0b" : "#ef4444")
                border.color: "white"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    visible: root.showNumbers && parent.width >= 11
                    text: modelData.positionShotNumber
                    color: "white"
                    font.pixelSize: Math.max(7, parent.width * 0.45)
                    font.bold: true
                }
            }
        }
    }
}
