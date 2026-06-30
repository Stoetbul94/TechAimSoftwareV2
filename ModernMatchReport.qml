import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: root
    title: "Match Report"
    modal: true
    padding: 0

    property bool isPrintFromBackend: false
    property bool isAutoPrintOn: false
    property var matchSummary: ({})
    property var positions: []
    property var overallSeries: []
    property var reportSections: []
    property var matchShots: []
    property var positionReportCards: []
    property var scoreGridRowsModel: []
    property bool exportToNetwork: false

    function refresh() {
        matchSummary = MATCHSESSION.positionSummary("")
        positions = MATCHSESSION.positionSummaries()
        overallSeries = MATCHSESSION.seriesSummaries("")
        matchShots = MATCHSESSION.matchShotsFor("")
        var sections = []
        for (var p = 0; p < positions.length; ++p) {
            var position = positions[p]
            var positionShots = MATCHSESSION.matchShotsFor(position.position)
            for (var offset = 0; offset < positionShots.length; offset += 20) {
                sections.push({
                    summary: position,
                    offset: offset,
                    shots: positionShots.slice(offset, offset + 20)
                })
            }
        }
        var cards = []
        var cardNames = ["Kneeling", "Prone", "Standing"]
        for (var c = 0; c < cardNames.length; ++c) {
            cards.push({
                name: cardNames[c],
                summary: positionSummaryFor(cardNames[c]),
                shots: MATCHSESSION.matchShotsFor(cardNames[c])
            })
        }
        reportSections = sections
        positionReportCards = cards
        scoreGridRowsModel = scoreGridRows()
    }

    function score(value) {
        if (MATCHSESSION.decimalScoring)
            return Number(value || 0).toFixed(1)
        return String(Math.max(0, Math.floor(Number(value || 0))))
    }

    function scoreFromShot(shot) {
        if (!shot)
            return "0"
        return MATCHSESSION.formatScoreText(
                    MATCHSESSION.decimalScoring
                    ? Number(shot.decimalScore || 0)
                    : Number(shot.integerScore || 0))
    }

    function mm(value) {
        return Number(value || 0).toFixed(2)
    }

    function timeText(seconds) {
        var total = Math.max(0, Number(seconds || 0))
        var minutes = Math.floor(total / 60)
        var secs = Math.floor(total % 60)
        return (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs
    }

    function todayText() {
        return new Date().toLocaleString(Qt.locale("en-ZA"), "dd-MM-yyyy")
    }

    function positionSummaryFor(positionName) {
        for (var i = 0; i < positions.length; ++i) {
            if (String(positions[i].position).toLowerCase() === String(positionName).toLowerCase())
                return positions[i]
        }
        return {
            position: positionName,
            shots: 0,
            decimalTotal: 0,
            integerTotal: 0,
            group: 0,
            mpiX: 0,
            mpiY: 0,
            innerTens: 0
        }
    }

    function positionShotsFor(positionName) {
        return MATCHSESSION.matchShotsFor(positionName)
    }

    function scoreGridRows() {
        var rows = []
        var names = ["Kneeling", "Prone", "Standing"]
        for (var p = 0; p < names.length; ++p) {
            var shots = MATCHSESSION.matchShotsFor(names[p])
            for (var start = 0; start < shots.length; start += 10) {
                var rowShots = shots.slice(start, start + 10)
                var total = 0
                for (var s = 0; s < rowShots.length; ++s) {
                    total += MATCHSESSION.decimalScoring
                            ? Number(rowShots[s].decimalScore || 0)
                            : Number(rowShots[s].integerScore || 0)
                }
                rows.push({
                    position: names[p],
                    series: "S" + (Math.floor(start / 10) + 1),
                    shots: rowShots,
                    total: total
                })
            }
        }
        return rows
    }

    function shotScore(row, index) {
        if (!row || !row.shots || index >= row.shots.length)
            return ""
        return scoreFromShot(row.shots[index])
    }

    function reportPages() {
        var pages = [overviewPage]
        for (var i = 0; i < positionRepeater.count; ++i)
            pages.push(positionRepeater.itemAt(i))
        return pages
    }

    function capturePage(pages, index) {
        if (index >= pages.length) {
            if (exportToNetwork)
                CUSTOMPRINT.createPdf(APPSETTINGS.getPrintPDFFilePath())
            else
                CUSTOMPRINT.createPdfWithDefaultName("TechAim_Target_Report.pdf")
            exportToNetwork = false
            isAutoPrintOn = false
            return
        }
        Qt.callLater(function() {
            pages[index].grabToImage(function(result) {
                CUSTOMPRINT.addImage(result.image)
                capturePage(pages, index + 1)
            }, Qt.size(1785, 2526))
        })
    }

    function printImage() {
        exportToNetwork = false
        CUSTOMPRINT.clearImagesList()
        capturePage(reportPages(), 0)
    }

    function printImageInNetworkPath() {
        exportToNetwork = true
        CUSTOMPRINT.clearImagesList()
        capturePage(reportPages(), 0)
    }

    function printSummaryImage() {
        refresh()
        CUSTOMPRINT.clearImagesList()
        Qt.callLater(function() {
            overviewPage.grabToImage(function(result) {
                CUSTOMPRINT.addImage(result.image)
                CUSTOMPRINT.createPdfWithDefaultName("TechAim_Summary_Report.pdf")
            }, Qt.size(1785, 2526))
        })
    }

    onVisibleChanged: {
        if (!visible)
            return
        refresh()
        if (isAutoPrintOn)
            autoPrintTimer.start()
    }

    Connections {
        target: MATCHSESSION
        function onShotStored() {
            if (root.visible)
                root.refresh()
        }
    }

    Timer {
        id: autoPrintTimer
        interval: 700
        repeat: false
        onTriggered: root.printImageInNetworkPath()
    }

    background: Rectangle { color: "#0b1118" }

    contentItem: Item {
        Rectangle {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 62
            color: "#111923"

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                text: "TechAim  •  MATCH REPORT"
                color: "#f8fafc"
                font.pixelSize: 19
                font.bold: true
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Button { text: "Save PDF"; onClicked: root.printImage() }
                Button { text: "Close"; onClicked: root.close() }
            }
        }

        ScrollView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            clip: true

            Column {
                width: Math.max(820, parent.width)
                spacing: 22
                topPadding: 22
                bottomPadding: 22

                Rectangle {
                    id: overviewPage
                    width: 760
                    height: 1075
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"

                    Rectangle {
                        id: officialOverview
                        anchors.fill: parent
                        z: 100
                        color: "white"

                        Image {
                            anchors.right: parent.right
                            anchors.rightMargin: 54
                            anchors.top: parent.top
                            anchors.topMargin: 22
                            width: 152
                            height: 48
                            source: "qrc:/images/logo/techaim.png"
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 22
                            text: "MATCH REPORT"
                            color: "#111827"
                            font.pixelSize: 22
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 78
                            height: 1
                            color: "#111827"
                        }

                        Rectangle {
                            id: officialInfo
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 98
                            height: 132
                            color: "transparent"
                            border.color: "#111827"
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 28
                                color: "#f8fafc"
                                border.color: "#111827"
                                border.width: 1

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Date: " + root.todayText()
                                    color: "#111827"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * 0.66
                                    text: "Event: " + MATCHSESSION.eventName
                                    color: "#111827"
                                    font.pixelSize: 10
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                }
                            }

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.top: parent.top
                                anchors.topMargin: 44
                                spacing: 7

                                Text { text: "Name: " + userName; color: "#111827"; font.pixelSize: 11; font.bold: true }
                                Text { text: "Total Shots: " + Number(root.matchSummary.shots || 0); color: "#111827"; font.pixelSize: 10 }
                                Text { text: "Total Score: " + root.score(root.matchSummary.decimalTotal) + " (" + Number(root.matchSummary.integerTotal || 0) + ")"; color: "#111827"; font.pixelSize: 10; font.bold: true }
                                Text { text: "Kneeling (Total): " + root.score(root.positionSummaryFor("Kneeling").decimalTotal) + " (" + root.positionSummaryFor("Kneeling").integerTotal + ")"; color: "#111827"; font.pixelSize: 10 }
                                Text { text: "Prone (Total): " + root.score(root.positionSummaryFor("Prone").decimalTotal) + " (" + root.positionSummaryFor("Prone").integerTotal + ")"; color: "#111827"; font.pixelSize: 10 }
                                Text { text: "Standing (Total): " + root.score(root.positionSummaryFor("Standing").decimalTotal) + " (" + root.positionSummaryFor("Standing").integerTotal + ")"; color: "#111827"; font.pixelSize: 10 }
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: 18
                                anchors.top: parent.top
                                anchors.topMargin: 42
                                width: 180
                                height: 76
                                radius: 4
                                color: "#6d1535"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "MATCH TOTAL"; color: "#f9d7e4"; font.pixelSize: 10; font.bold: true }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.score(root.matchSummary.decimalTotal) + " (" + Number(root.matchSummary.integerTotal || 0) + ")"; color: "white"; font.pixelSize: 20; font.bold: true }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Time " + root.timeText(MATCHSESSION.matchElapsed); color: "#f9d7e4"; font.pixelSize: 10 }
                                }
                            }
                        }

                        ModernReportTarget {
                            id: officialOverallTarget
                            anchors.right: parent.right
                            anchors.rightMargin: 64
                            anchors.top: officialInfo.bottom
                            anchors.topMargin: 22
                            width: 245
                            height: 245
                            shots: root.matchShots
                            showNumbers: false
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 58
                            anchors.top: officialInfo.bottom
                            anchors.topMargin: 28
                            spacing: 10

                            Repeater {
                                model: [
                                    ["Group", root.mm(root.matchSummary.group) + " mm"],
                                    ["MPI", "X " + root.mm(root.matchSummary.mpiX) + " / Y " + root.mm(root.matchSummary.mpiY) + " mm"],
                                    ["Inner 10", Number(root.matchSummary.innerTens || 0)],
                                    ["Scoring", MATCHSESSION.scoringName]
                                ]

                                delegate: Rectangle {
                                    width: 292
                                    height: 46
                                    radius: 4
                                    color: "#edf2f7"
                                    Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData[0]; color: "#475569"; font.pixelSize: 10; font.bold: true }
                                    Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; color: "#111827"; font.pixelSize: 12; font.bold: true }
                                }
                            }
                        }

                        Rectangle {
                            id: officialPositionHeading
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: officialOverallTarget.bottom
                            anchors.topMargin: 20
                            height: 30
                            color: "#f8fafc"
                            border.color: "#111827"
                            Text { anchors.centerIn: parent; text: "POSITION WISE PERFORMANCE"; color: "#111827"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 0.7 }
                        }

                        Row {
                            id: officialPositionCards
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: officialPositionHeading.bottom
                            anchors.topMargin: 12
                            spacing: 12

                            Repeater {
                                model: root.positionReportCards
                                delegate: Rectangle {
                                    width: (officialPositionCards.width - 24) / 3
                                    height: 212
                                    color: "#fffef0"
                                    border.color: "#111827"
                                    border.width: 1

                                    property var summary: modelData.summary

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        anchors.top: parent.top
                                        anchors.topMargin: 8
                                        text: "Position: " + modelData.name
                                        color: "#111827"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Column {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        anchors.top: parent.top
                                        anchors.topMargin: 30
                                        spacing: 4
                                        Text { text: "Total Shots: " + summary.shots; color: "#111827"; font.pixelSize: 8 }
                                        Text { text: "Score: " + root.score(summary.decimalTotal) + " (" + summary.integerTotal + ")"; color: "#111827"; font.pixelSize: 8; font.bold: true }
                                        Text { text: "Group: " + root.mm(summary.group) + " mm"; color: "#111827"; font.pixelSize: 8 }
                                        Text { text: "Inner 10: " + summary.innerTens; color: "#111827"; font.pixelSize: 8 }
                                    }

                                    ModernReportTarget {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 8
                                        width: 128
                                        height: 128
                                        shots: modelData.shots
                                        showNumbers: false
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: officialScoreGridHeading
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: officialPositionCards.bottom
                            anchors.topMargin: 18
                            height: 26
                            color: "#f8fafc"
                            border.color: "#111827"
                            Text { anchors.centerIn: parent; text: "SERIES SCORE GRID"; color: "#111827"; font.pixelSize: 13; font.bold: true }
                        }

                        Column {
                            id: officialScoreGrid
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: officialScoreGridHeading.bottom
                            anchors.topMargin: 8
                            spacing: 0

                            Rectangle {
                                width: officialScoreGrid.width
                                height: 25
                                color: "#18222e"
                                Row {
                                    anchors.fill: parent
                                    Text { width: 72; height: parent.height; text: "Position"; color: "white"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                    Text { width: 34; height: parent.height; text: "Ser"; color: "white"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                    Repeater { model: 10; Text { width: 45; height: parent.height; text: String(index + 1); color: "white"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter } }
                                    Text { width: 78; height: parent.height; text: "Total"; color: "white"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                }
                            }

                            Repeater {
                                model: root.scoreGridRowsModel
                                delegate: Rectangle {
                                    width: officialScoreGrid.width
                                    height: 27
                                    color: index % 2 === 0 ? "#ffffff" : "#eef2f6"
                                    border.color: "#cbd5e1"

                                    Row {
                                        anchors.fill: parent
                                        Text { width: 72; height: parent.height; text: modelData.position; color: "#111827"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                        Text { width: 34; height: parent.height; text: modelData.series; color: "#111827"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                        Repeater { model: 10; Text { width: 45; height: parent.height; text: root.shotScore(modelData, index); color: "#111827"; font.pixelSize: 8; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter } }
                                        Text { width: 78; height: parent.height; text: root.score(modelData.total); color: "#111827"; font.pixelSize: 8; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 24
                            text: "TechAim Electronic Target - Sighters excluded from all report totals"
                            color: "#94a3b8"
                            font.pixelSize: 9
                        }
                    }

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 42
                        anchors.top: parent.top
                        anchors.topMargin: 28
                        width: 180
                        height: 55
                        source: "qrc:/images/logo/techaim.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 42
                        anchors.top: parent.top
                        anchors.topMargin: 34
                        text: "MATCH REPORT"
                        color: "#111827"
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 42
                        anchors.rightMargin: 42
                        anchors.topMargin: 98
                        height: 1
                        color: "#cbd5e1"
                    }

                    Text {
                        id: reportEvent
                        anchors.left: parent.left
                        anchors.leftMargin: 42
                        anchors.top: parent.top
                        anchors.topMargin: 122
                        text: MATCHSESSION.eventName
                        color: "#111827"
                        font.pixelSize: 23
                        font.bold: true
                    }

                    Text {
                        anchors.left: reportEvent.left
                        anchors.top: reportEvent.bottom
                        anchors.topMargin: 6
                        text: "Athlete: " + userName + "   •   "
                              + new Date().toLocaleString(Qt.locale("en-ZA"), "dd MMM yyyy  HH:mm")
                        color: "#64748b"
                        font.pixelSize: 12
                    }

                    ModernReportTarget {
                        id: overallTarget
                        anchors.left: parent.left
                        anchors.leftMargin: 38
                        anchors.top: parent.top
                        anchors.topMargin: 190
                        width: 420
                        height: 420
                        shots: root.matchShots
                        showNumbers: false
                    }

                    Column {
                        anchors.left: overallTarget.right
                        anchors.leftMargin: 22
                        anchors.right: parent.right
                        anchors.rightMargin: 40
                        anchors.top: overallTarget.top
                        spacing: 10

                        Repeater {
                            model: [
                                ["Counting shots", Number(root.matchSummary.shots || 0)],
                                ["Match total", root.score(root.matchSummary.decimalTotal) + " (" + Number(root.matchSummary.integerTotal || 0) + ")"],
                                ["Group", root.mm(root.matchSummary.group) + " mm"],
                                ["MPI", "X " + root.mm(root.matchSummary.mpiX) + " / Y " + root.mm(root.matchSummary.mpiY) + " mm"],
                                ["Inner 10", Number(root.matchSummary.innerTens || 0)],
                                ["Elapsed", root.timeText(MATCHSESSION.matchElapsed)]
                            ]

                            delegate: Rectangle {
                                width: parent.width
                                height: 58
                                radius: 8
                                color: index === 1 ? "#6d1535" : "#edf2f7"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData[0]
                                    color: index === 1 ? "white" : "#64748b"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData[1]
                                    color: index === 1 ? "white" : "#111827"
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 42
                        anchors.top: parent.top
                        anchors.topMargin: 650
                        text: "POSITION SUMMARY"
                        color: "#111827"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Column {
                        id: overallPositions
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 42
                        anchors.rightMargin: 42
                        anchors.top: parent.top
                        anchors.topMargin: 686
                        spacing: 8

                        Repeater {
                            model: root.positions
                            delegate: Rectangle {
                                width: overallPositions.width
                                height: 54
                                radius: 7
                                color: "#18222e"

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.position + "  •  " + modelData.shots + " shots"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "Group " + root.mm(modelData.group) + " mm"
                                    color: "#b8c5d3"
                                    font.pixelSize: 12
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.score(modelData.decimalTotal) + " (" + modelData.integerTotal + ")"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Text {
                        id: overallSeriesHeading
                        anchors.left: parent.left
                        anchors.leftMargin: 42
                        anchors.top: overallPositions.bottom
                        anchors.topMargin: 28
                        text: "SERIES TOTALS"
                        color: "#111827"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Flow {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 42
                        anchors.rightMargin: 42
                        anchors.top: overallSeriesHeading.bottom
                        anchors.topMargin: 12
                        spacing: 10

                        Repeater {
                            model: root.overallSeries
                            delegate: Rectangle {
                                width: 102
                                height: 58
                                radius: 7
                                color: "#f8fafc"
                                border.color: "#cbd5e1"
                                Text {
                                    anchors.centerIn: parent
                                    text: "S" + modelData.series + "\n" + root.score(modelData.decimalTotal)
                                    horizontalAlignment: Text.AlignHCenter
                                    color: "#111827"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 42
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 26
                        text: "TechAim Electronic Target  •  Sighters excluded from all report totals"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                Repeater {
                    id: positionRepeater
                    model: root.reportSections

                    delegate: Rectangle {
                        id: positionPage
                        width: 760
                        height: 1075
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"

                        property var section: modelData
                        property var summary: section.summary
                        property var shots: section.shots

                        Image {
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 28
                            width: 170
                            height: 52
                            source: "qrc:/images/logo/techaim.png"
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 35
                            text: summary.position.toUpperCase() + " REPORT"
                                  + (summary.shots > 20
                                     ? "  •  SHOTS " + (section.offset + 1)
                                       + "–" + (section.offset + shots.length)
                                     : "")
                            color: "#111827"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        ModernReportTarget {
                            id: positionTarget
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 100
                            width: 330
                            height: 330
                            shots: positionPage.shots
                        }

                        Column {
                            anchors.left: positionTarget.right
                            anchors.leftMargin: 22
                            anchors.right: parent.right
                            anchors.rightMargin: 42
                            anchors.top: positionTarget.top
                            spacing: 9

                            Repeater {
                                model: [
                                    ["Total", root.score(summary.decimalTotal) + " (" + summary.integerTotal + ")"],
                                    ["Shots", summary.shots],
                                    ["Group", root.mm(summary.group) + " mm"],
                                    ["MPI X", root.mm(summary.mpiX) + " mm"],
                                    ["MPI Y", root.mm(summary.mpiY) + " mm"],
                                    ["Inner 10", summary.innerTens]
                                ]
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 45
                                    radius: 7
                                    color: index === 0 ? "#6d1535" : "#edf2f7"
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData[0]
                                        color: index === 0 ? "white" : "#64748b"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData[1]
                                        color: index === 0 ? "white" : "#111827"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 452
                            text: "SHOT DETAIL"
                            color: "#111827"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Rectangle {
                            id: tableHeader
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 42
                            anchors.rightMargin: 42
                            anchors.top: parent.top
                            anchors.topMargin: 482
                            height: 30
                            radius: 5
                            color: "#18222e"

                            Row {
                                anchors.fill: parent
                                Repeater {
                                    model: ["#", "Score", "X (mm)", "Y (mm)", "Time", "Series"]
                                    Text {
                                        width: tableHeader.width / 6
                                        height: tableHeader.height
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData
                                        color: "white"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Column {
                            id: shotRows
                            anchors.left: tableHeader.left
                            anchors.right: tableHeader.right
                            anchors.top: tableHeader.bottom

                            Repeater {
                                model: Math.min(positionPage.shots.length, 20)
                                delegate: Rectangle {
                                    property var shot: positionPage.shots[index]
                                    width: shotRows.width
                                height: 21
                                    color: index % 2 === 0 ? "#f8fafc" : "#eef2f6"

                                    Row {
                                        anchors.fill: parent
                                        Repeater {
                                            model: [
                                                shot.positionShotNumber,
                                                root.scoreFromShot(shot),
                                                root.mm(shot.x),
                                                root.mm(shot.y),
                                                shot.timestamp,
                                                "S" + shot.series
                                            ]
                                            Text {
                                                width: shotRows.width / 6
                                                height: 21
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: modelData
                                                color: "#1f2937"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            id: positionSeriesHeading
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.top: shotRows.bottom
                            anchors.topMargin: 24
                            text: "SERIES TOTALS"
                            color: "#111827"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.top: positionSeriesHeading.bottom
                            anchors.topMargin: 10
                            spacing: 10
                            Repeater {
                                model: MATCHSESSION.seriesSummaries(positionPage.summary.position)
                                delegate: Rectangle {
                                    width: 130
                                    height: 55
                                    radius: 7
                                    color: "#edf2f7"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "S" + modelData.series + "  "
                                              + root.score(modelData.decimalTotal)
                                              + " (" + modelData.integerTotal + ")"
                                        color: "#111827"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 42
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 26
                            text: userName + "  •  " + MATCHSESSION.eventName
                            color: "#94a3b8"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
}
