import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property alias name: hiddenName.text
    property alias gameDisplay1: hiddenGame1.text
    property alias gameDisplay2: hiddenGame2.text
    property alias matchDisplay: hiddenMatch.text
    property alias settingsX: settingsButton.x
    property alias settingsY: settingsButton.y
    property alias settingsWidth: settingsButton.width
    property alias playVisible: playButton.visible
    property real abhi: 1
    property bool isShowMPI: APPSETTINGS.getShowGroupAndMPI()
    property bool sighterActive: true

    signal homeButtonClicked()
    signal settingsClicked()

    color: "#11171d"
    border.color: "#2c3640"
    border.width: 1

    Text { id: hiddenName; visible: false }
    Text { id: hiddenGame1; visible: false }
    Text { id: hiddenGame2; visible: false }
    Text { id: hiddenMatch; visible: false }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 132
            radius: 14
            color: "#1b232c"
            border.color: "#303b47"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 5

                Text {
                    text: MATCHSESSION.positionName !== ""
                          ? MATCHSESSION.positionName : qsTr("50 m Rifle")
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Text {
                    text: MATCHSESSION.eventName
                    color: "#aeb8c4"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.preferredWidth: modeText.implicitWidth + 20
                    Layout.preferredHeight: 28
                    radius: 14
                    color: sighterActive ? "#163b48" : "#421728"

                    Text {
                        id: modeText
                        anchors.centerIn: parent
                        text: sighterActive ? qsTr("SIGHTER") : qsTr("MATCH")
                        color: sighterActive ? "#73d8ff" : "#ff6c9e"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 12
            color: "#1b232c"
            border.color: "#303b47"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 19
                    color: "#b90042"

                    Text {
                        anchors.centerIn: parent
                        text: root.name.length ? root.name.charAt(0).toUpperCase() : "A"
                        color: "white"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.name
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MATCHSESSION.shotPlan
                        color: "#929eaa"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        ToolButton {
            id: summaryButton
            Layout.fillWidth: true
            text: qsTr("Summary")
            onClicked: showSummary()
        }

        ToolButton {
            Layout.fillWidth: true
            text: qsTr("Match report")
            onClicked: showMatchReport()
        }

        ToolButton {
            id: settingsButton
            Layout.fillWidth: true
            text: qsTr("Settings")
            onClicked: settingsClicked()
        }

        ToolButton {
            Layout.fillWidth: true
            text: isShowMPI ? qsTr("Hide MPI") : qsTr("Show MPI")
            onClicked: isShowMPI = !isShowMPI
        }

        ToolButton {
            Layout.fillWidth: true
            text: qsTr("Home")
            onClicked: homeButtonClicked()
        }

        Item { Layout.fillHeight: true }

        Button {
            id: playButton
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            text: MATCHSESSION.phaseName === "Prone Changeover / Sighting"
                  ? qsTr("Start prone")
                  : (MATCHSESSION.phaseName === "Standing Changeover / Sighting"
                     ? qsTr("Start standing")
                     : (sighterActive ? qsTr("Start match") : qsTr("Resume")))
            onClicked: rightPanel.startClicked()
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 12
                color: parent.down ? "#8e0033" : "#b90042"
                border.color: "#e31b54"
            }
        }
    }

    component ToolButton: Button {
        Layout.preferredHeight: 46
        contentItem: Text {
            text: parent.text
            color: "#dce3ea"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: 14
        }
        background: Rectangle {
            radius: 10
            color: parent.down ? "#303b47" : "#202832"
            border.color: "#303b47"
        }
    }

    function showSummary() {
        if (sligterMode) {
            cannotGenerate.text = sighterSummaryText
            cannotGenerate.visible = true
        } else {
            showSummaryPage.visible = true
        }
    }

    function showMatchReport() {
        if (sligterMode) {
            cannotGenerate.text = sighterMatchText
            cannotGenerate.visible = true
        } else {
            matchReportPage.visible = true
        }
    }

    function showReport() {
        showMatchReport()
    }

    function showSettings() {
        settingsClicked()
    }

    function enableSighterMode(enableFlag) {
        sighterActive = enableFlag
    }

    function startFromServer() {
    }
}
