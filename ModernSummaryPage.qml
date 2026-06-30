import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: root
    title: "Match Summary"
    modal: true
    padding: 0

    property var matchSummary: ({})
    property var positions: []
    property var series: []
    property var matchShots: []
    signal savePdfRequested()

    function refresh() {
        matchSummary = MATCHSESSION.positionSummary("")
        positions = MATCHSESSION.positionSummaries()
        series = MATCHSESSION.seriesSummaries("")
        matchShots = MATCHSESSION.matchShotsFor("")
    }

    function printSummaryPdf() {
        refresh()
        CUSTOMPRINT.clearImagesList()
        Qt.callLater(function() {
            summaryCapture.grabToImage(function(result) {
                CUSTOMPRINT.addImage(result.image)
                CUSTOMPRINT.createPdfWithDefaultName("TechAim_Summary_Report.pdf")
            }, Qt.size(1785, 2526))
        })
    }

    function score(value) {
        if (MATCHSESSION.decimalScoring)
            return Number(value || 0).toFixed(1)
        return String(Math.max(0, Math.floor(Number(value || 0))))
    }

    function mm(value) {
        return Number(value || 0).toFixed(2) + " mm"
    }

    function timeText(seconds) {
        var total = Math.max(0, Number(seconds || 0))
        var minutes = Math.floor(total / 60)
        var secs = Math.floor(total % 60)
        return (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs
    }

    onVisibleChanged: if (visible) refresh()

    Connections {
        target: MATCHSESSION
        function onShotStored() {
            if (root.visible)
                root.refresh()
        }
    }

    background: Rectangle { color: "#0b1118" }

    contentItem: Item {
        id: summaryCapture

        Rectangle {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 64
            color: "#111923"

            Image {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                width: 175
                height: 44
                source: "qrc:/images/logo/techaim.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.centerIn: parent
                text: "MATCH SUMMARY"
                color: "#f8fafc"
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 1.5
            }

            Button {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: "Close"
                onClicked: root.close()
            }
        }

        Rectangle {
            id: sheet
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: footer.top
            anchors.margins: 18
            radius: 14
            color: "#f8fafc"

            Row {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 22

                Rectangle {
                    width: parent.width * 0.57
                    height: parent.height
                    radius: 12
                    color: "#fffef0"
                    border.color: "#dbe2ea"

                    ModernReportTarget {
                        anchors.fill: parent
                        anchors.margins: 12
                        shots: root.matchShots
                    }
                }

                Item {
                    width: parent.width * 0.43 - 22
                    height: parent.height

                    Text {
                        id: eventTitle
                        anchors.left: parent.left
                        anchors.right: parent.right
                        text: MATCHSESSION.eventName
                        color: "#111827"
                        font.pixelSize: 22
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        id: athlete
                        anchors.top: eventTitle.bottom
                        anchors.topMargin: 5
                        text: userName + "  •  " + new Date().toLocaleDateString(Qt.locale("en-ZA"), "dd MMM yyyy")
                        color: "#64748b"
                        font.pixelSize: 13
                    }

                    Grid {
                        id: metrics
                        anchors.top: athlete.bottom
                        anchors.topMargin: 18
                        width: parent.width
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        Repeater {
                            model: [
                                ["MATCH TOTAL", root.score(root.matchSummary.decimalTotal) + " (" + Number(root.matchSummary.integerTotal || 0) + ")"],
                                ["COUNTING SHOTS", Number(root.matchSummary.shots || 0)],
                                ["GROUP", root.mm(root.matchSummary.group)],
                                ["MPI", "X " + root.mm(root.matchSummary.mpiX) + "  Y " + root.mm(root.matchSummary.mpiY)],
                                ["INNER 10", Number(root.matchSummary.innerTens || 0)],
                                ["ELAPSED", root.timeText(MATCHSESSION.matchElapsed)]
                            ]

                            delegate: Rectangle {
                                width: (metrics.width - metrics.columnSpacing) / 2
                                height: 72
                                radius: 10
                                color: "#eaf0f6"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.top: parent.top
                                    anchors.topMargin: 10
                                    text: modelData[0]
                                    color: "#64748b"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 10
                                    text: modelData[1]
                                    color: "#111827"
                                    font.pixelSize: modelData[0] === "MPI" ? 13 : 18
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Text {
                        id: positionHeading
                        anchors.top: metrics.bottom
                        anchors.topMargin: 18
                        text: "POSITION TOTALS"
                        color: "#334155"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Column {
                        id: positionList
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: positionHeading.bottom
                        anchors.topMargin: 8
                        spacing: 7

                        Repeater {
                            model: root.positions

                            delegate: Rectangle {
                                width: positionList.width
                                height: 48
                                radius: 8
                                color: "#18222e"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.position
                                    color: "#f8fafc"
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.score(modelData.decimalTotal)
                                          + "  (" + Number(modelData.integerTotal) + ")"
                                    color: "#f8fafc"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Text {
                        id: seriesHeading
                        anchors.top: positionList.bottom
                        anchors.topMargin: 16
                        text: "SERIES TOTALS"
                        color: "#334155"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Flow {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: seriesHeading.bottom
                        anchors.topMargin: 8
                        spacing: 7

                        Repeater {
                            model: root.series
                            delegate: Rectangle {
                                width: 94
                                height: 50
                                radius: 8
                                color: "#fff"
                                border.color: "#cbd5e1"

                                Text {
                                    anchors.centerIn: parent
                                    text: "S" + modelData.series + "   " + root.score(modelData.decimalTotal)
                                    color: "#111827"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 70
            color: "#111923"

            Button {
                anchors.centerIn: parent
                text: "Save summary PDF"
                onClicked: root.printSummaryPdf()
            }
        }
    }
}
