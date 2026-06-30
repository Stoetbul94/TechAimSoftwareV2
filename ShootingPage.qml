import QtQuick 2.0
import QtQuick.Dialogs
import QtQuick.Controls 2.15

//import Qt.labs.platform 1.0


Item {
    id: shootingPage

    visible: false

    property int matchShootCount: MATCHSESSION.configuredMatchShots
    property alias currentGameDisplay1: leftPanel.gameDisplay1
    property alias currentGameDisplay2: leftPanel.gameDisplay2
    property alias currentmatchDisplay: leftPanel.matchDisplay
    property alias totalScore : rightPanel.grandTotal
    property alias totalScoreWithoutDecimal: rightPanel.grandTotalExculdeDec
    property alias totalTime: rightPanel.totalTimeConsume

    property alias isBackgroudBlack: settingsPage.isBackGroundBlack
    property alias isPalletRed: settingsPage.isPalletRedColor
    property alias currentPageIndexOfSer: rightPanel.currentPageIndex

    property bool sligterMode: true

    property bool matchFinished :false

    property string messageText: "Match is completed, restart to stimulate"
    property string sighterSummaryText: "You are in Sighter. You can't generate Match Summary"
    property string sighterMatchText: "You are in Sighter. You can't generate Match Report"
    property string minimumShotsSummary: "Minimum 10 shots required to generate Summary"
    property string minimumShotsMatchReport: "Minimum 10 shots required to generate Match Report"

    onTotalScoreChanged: {
        console.log("Total score changed ............................"+ totalScore)

    }

    MessageDialog
    {
        id: matchInfoDialog
        text: messageText
        visible: false
    }


    Rectangle {
        id:settingsMask
        anchors.fill:parent
        color: "transparent"
        visible: false
        z:100
        MouseArea
        {
            id:parentMouseArea
            anchors.fill: parent
            onClicked: {
                settingsMask.visible = false
            }
        }

        SettingsPage
        {
            id:settingsPage
            x:leftPanel.settingsX + leftPanel.settingsWidth
            y:leftPanel.settingsY

            onIsBackGroundBlackChanged: {
                settingsMask.visible = false
            }
            onIsPalletRedColorChanged: {
                settingsMask.visible = false
            }
        }
    }


    Dialog
    {
        id:matchFinishConfirmation
        width: 200//parent.width*0.2
        height: 75//parent.height*0.2
        Label{
            text: "Are you sure you want to finish the match ?"
            anchors.centerIn: parent
        }

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            changedToMatchFinish()
        }
    }

    MessageDialog
    {
        id: matchNotStarted
        title: "Warning"
        text: "Match Not Started"
        visible: false
    }



    MessageDialog
    {
        id: cannotGenerate
        text: sighterSummaryText
        title: "Warning"
        visible: false
    }

    ListModel
    {
        id:globalModelOfData
        onCountChanged: {
            centerPanel.disableMotorMovement = false
            centerPanel.currentPageIndexChanged()
            console.log("globalModelOfData count changes ", count)
        }
    }

    ListModel
    {
        id:globalSlighterModel
        onCountChanged: {
            console.log("******globalSlighterModel****"+count)
        }
    }

    ListModel
    {
        id:globalMatchModel
        onCountChanged: {
            console.log("******globalMatchModel****"+count)
        }
    }

    function loadGameInMatchMode() {
        rightPanel.startClickedThroughLoad()
        sligterMode = false
        centerPanel.showSlighter(false)
    }

    function setCurrentGameType(index)
    {
        console.log("setCurrentGameType  ", index)
        if (gameRange === 10)
        {
            // if 15 shoots
            if (APPSETTINGS.getIs15Shoot()) {
                if (index >= game10RangeEventModel_15.count)
                    return

                matchShootCount = game10RangeEventModel_15.get(index).count
                currentGameDisplay1 = game10RangeEventModel_15.get(index).gameDisplay1
                currentGameDisplay2 = game10RangeEventModel_15.get(index).gameDisplay2
                currentmatchDisplay = game10RangeEventModel_15.get(index).matchDisplay
            } else {
                if (index >= game10RangeEventModel.count)
                    return

                matchShootCount = game10RangeEventModel.get(index).count
                currentGameDisplay1 = game10RangeEventModel.get(index).gameDisplay1
                currentGameDisplay2 = game10RangeEventModel.get(index).gameDisplay2
                currentmatchDisplay = game10RangeEventModel.get(index).matchDisplay
            }
        } else if (gameRange === 50) {
            // if 15 shoots
            if (APPSETTINGS.getIs15Shoot()) {
                if (index >= game50RangeEventModel_15.count)
                    return

                matchShootCount = game50RangeEventModel_15.get(index).count
                currentGameDisplay1 = game50RangeEventModel_15.get(index).gameDisplay1
                currentGameDisplay2 = game50RangeEventModel_15.get(index).gameDisplay2
                currentmatchDisplay = game50RangeEventModel_15.get(index).matchDisplay
            } else {
                if (index >= game50RangeEventModel.count)
                    return

                matchShootCount = game50RangeEventModel.get(index).count
                currentGameDisplay1 = game50RangeEventModel.get(index).gameDisplay1
                currentGameDisplay2 = game50RangeEventModel.get(index).gameDisplay2
                currentmatchDisplay = game50RangeEventModel.get(index).matchDisplay
            }

        }
    }

    function configureFromMatchSession()
    {
        currentGameDisplay1 = MATCHSESSION.eventName
        currentGameDisplay2 = qsTr("RIFLE")
        currentmatchDisplay = MATCHSESSION.shotPlan
        centerPanel.showSlighter(true)
        sligterMode = true
        syncHardwareShotLimit()
        centerPanel.syncTimersFromSession()
    }

    function restoreFromMatchSession()
    {
        currentGameDisplay1 = MATCHSESSION.eventName
        currentGameDisplay2 = qsTr("RIFLE")
        currentmatchDisplay = MATCHSESSION.shotPlan
        centerPanel.showSlighter(MATCHSESSION.sighterMode)
        sligterMode = MATCHSESSION.sighterMode
        syncHardwareShotLimit()
        centerPanel.syncTimersFromSession()
        if (MATCHSESSION.completed)
            changedToMatchFinish()
    }

    function syncHardwareShotLimit()
    {
        centerPanel.shotCount = MATCHSESSION.configuredMatchShots
        MODREADER.setCurrentMatchTotalShotsCount(MATCHSESSION.configuredMatchShots)
    }

    function beginSessionTimers()
    {
        centerPanel.prepareSessionTimers()
    }

    onVisibleChanged: {
        if (visible) {
            centerPanel.circleCordinates()
            rightPanel.resetTimer()
            if (MATCHSESSION.phaseName === "Preparation and Sighting")
                centerPanel.prepareSessionTimers()
        }
        if (!isSaveGame)
            MODREADER.removeSetaLaneShootDataFile()
    }

    onMatchShootCountChanged: syncHardwareShotLimit()

    Connections {
        target: MATCHSESSION

        function onProfileChanged() {
            syncHardwareShotLimit()
        }

        function onPreparationExpired() {
            leftPanel.playVisible = true
            centerPanel.timerNotification.visible = true
            centerPanel.timerNotification.opacity = 1
        }

        function onPhaseChanged() {
            if (MATCHSESSION.sighterMode && !sligterMode)
                changedToSigherMode()
            else if (!MATCHSESSION.sighterMode && sligterMode && MATCHSESSION.matchPhaseActive)
                changedToMatchMode()
            centerPanel.syncTimersFromSession()
            centerPanel.resumeSessionTimers()
            if (MATCHSESSION.phaseName === "Ready for Match"
                    || MATCHSESSION.phaseName === "Prone Changeover / Sighting"
                    || MATCHSESSION.phaseName === "Standing Changeover / Sighting")
                leftPanel.playVisible = true
            if (MATCHSESSION.completed)
                changedToMatchFinish()
        }

        function onEventCompleted() {
            changedToMatchFinish()
        }
    }

    ModernLeftPanel {
        id: leftPanel
        width: Math.max(190, 0.17*parent.width)
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        name: window.userName
        z: 10

        onHomeButtonClicked: {
            loginPage.visible = true
            resetDataModels()
        }
        onSettingsClicked:
        {
            settingsMask.visible = true
        }
    }

    RightPanel {
        id: rightPanel
        width: Math.max(360, 0.28*parent.width)
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        z: 10
        onSwitchToSighter:
        {
            if(sighterEnable)
            {
                changedToSigherMode()
            }
            else
            {
                changedToMatchMode()
            }
        }

        onMatchFinished: {
            changedToMatchFinish()
        }
    }

    CenterPane {
        id: centerPanel
        width: parent.width - leftPanel.width - rightPanel.width
        height: parent.height
        anchors.left: leftPanel.right
        anchors.right: rightPanel.left
        anchors.top: parent.top

        property alias showMesures: leftPanel.isShowMPI


        onPointAddedToSeries: {
            rightPanel.addToSeries(xPosition,yPosition,currentCalculatedScore)
            MATCHSESSION.recordShot(
                        centerPanel.currentShotX,
                        centerPanel.currentShotY,
                        currentCalculatedScore,
                        rightPanel.lastShotElapsed,
                        rightPanel.lastShotTimestamp)
            console.log("x ", xPosition, " y ", yPosition, " score ", currentCalculatedScore, " matchShootCount ", matchShootCount)

        }

        onSighterModeTimerEnds: {
            // Preparation time ended — session is at Interlock; athlete presses Start.
            if (MATCHSESSION.phaseName === "Ready for Match")
                leftPanel.playVisible = true
        }

        onShowMesuresChanged: {
            refreshShowMesureStatus(showMesures)
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: window.userName
            font.pixelSize: 32
            font.capitalization: Font.AllUppercase
            font.bold: true
            color: "red"
        }
    }

    ModernSummaryPage {
        id:showSummaryPage
        visible: false
        width:parent.width*3/4
        height:parent.height*3/4

        contentWidth: parent.width*3/4
        contentHeight: parent.height*3/4
        onSavePdfRequested: showSummaryPage.printSummaryPdf()

        onVisibleChanged: {
            // The official match clock continues while the summary is viewed.
        }
        //z: 20
    }

    ModernMatchReport
    {
        id:matchReportPage
        visible: false
        width:parent.width*3/4
        height:parent.height*3/4

        onVisibleChanged: {
            // The official match clock continues while the report is viewed.
        }
    }

    Connections {
        target: APPSETTINGS
        onPrintPDF: {
            if (leftPanel.playVisible)
                return;

            matchReportPage.isAutoPrintOn = true
            matchReportPage.visible = true
            console.log("-APPSETTINGS-----------------------------onPrintPDF--------------------------")
//            matchReportPage.printImageInNetworkPath()
        }
    }
    ConnectionError {
        id: conError
        z: 10
        height: parent.height// - header.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        visible: false
    }

    function resetDataModels()
    {
        globalModelOfData.clear()
        globalSlighterModel.clear()
        globalMatchModel.clear()
        matchFinished = false
        rightPanel.resetRightPanelModels()
        centerPanel.refreshCentralPanelPage()
        centerPanel.backEndShootCount = 0
    }

    function changedToSigherMode()
    {
        centerPanel.disableMotorMovement = true
        rightPanel.prepareModeTransition()
        var isInitialPrep = MATCHSESSION.phaseName === "Preparation and Sighting"
        var isOfficialChangeover = MATCHSESSION.phaseName === "Prone Changeover / Sighting"
                || MATCHSESSION.phaseName === "Standing Changeover / Sighting"
        if (isOfficialChangeover)
            globalSlighterModel.clear()
        sligterMode = true
        if (isOfficialChangeover)
            MODREADER.beginChangeoverSighting()
        else
            MODREADER.changeSighterMode(true)
        centerPanel.backEndShootCount = MODREADER.getShootCount()
        centerPanel.showSlighter(true)
        leftPanel.enableSighterMode(true)
        globalModelOfData.clear()
        for(var index = 0; index <globalSlighterModel.count; ++index )
        {
            globalModelOfData.append(globalSlighterModel.get(index))
        }
        rightPanel.updateTotal()
        centerPanel.currentPageIndexChanged()
        centerPanel.disableMotorMovement = false
        APPSETTINGS.updateStatusFeedbackFile(2)
    }

    function changedToMatchMode()
    {
        centerPanel.disableMotorMovement = true
        rightPanel.prepareModeTransition()
        centerPanel.showSlighter(false)
        leftPanel.enableSighterMode(false)
        globalModelOfData.clear()
        for(var index = 0; index <globalMatchModel.count; ++index )
        {
            globalModelOfData.append(globalMatchModel.get(index))
        }
        sligterMode = false
        MODREADER.changeSighterMode(false)
        MODREADER.resetActiveShootBuffer()
        centerPanel.backEndShootCount = 0
        APPSETTINGS.setGame_is_sighter_mode(0)
        APPSETTINGS.updateStatusFeedbackFile(3)
        rightPanel.updateTotal()
        centerPanel.currentPageIndexChanged()
        centerPanel.syncTimersFromSession()
        centerPanel.resumeSessionTimers()
        centerPanel.disableMotorMovement = false
    }

    function changedToMatchFinish()
    {
        matchFinished = true
        centerPanel.stopSessionTimers()
    }

    function minutesToseconds(totalSecs)
    {
        var minutes = Math.floor(totalSecs / 60);
        var seconds = totalSecs - minutes * 60;
        var finalTime = str_pad_left(minutes,'0',2)+':'+str_pad_left(seconds,'0',2);
        return finalTime
    }

    function str_pad_left(string,pad,length) {
        return (new Array(length+1).join(pad)+string).slice(-length);
    }

    function startFromServer()
    {
//        rightPanel.startFromServer()
//        settingsPage.startFromServer()
//        leftPanel.startFromServer()
//        centerPanel.startFromServer()
    }

    function applyServerSettings(st, mt, spf, mpf)
    {
        if (MATCHSESSION.matchSeconds > 0)
            return
        console.log("Legacy server timing ignored for unofficial profile", st, mt, spf, mpf)
        centerPanel.syncTimersFromSession()
    }
}
