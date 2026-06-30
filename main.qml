import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: APPSETTINGS.getBrandDisplayName() + " Electronic Target"

    property bool isOpenGLEnabled: true
    property string userName: "TechAim"
    property string lane_number_text: "Lane1"
    property string eventName: shootingPage.currentGameDisplay1 + " " + shootingPage.currentGameDisplay2
    property string eventDate: "9/3/2017 4:34 PM"
    property string numberOfShots: "10"
    property string averageScore : "9.68"
    property string averageTime : "00:12"
    property int totalScore : shootingPage.totalScore
    property int totalTime: shootingPage.totalTime
    property int scWidth: Screen.width
    property int scHeight: Screen.height
    property bool isDefaultIcon: false
    property bool appMode: APPSETTINGS.getAppMode() // false for demo and true for live
    property bool isSaveGame: false
    property int gameRange: APPSETTINGS.get10or50mRange()   // 10 for 10m 50 for 50m
    property int shootsPerSeries: 10
    property string greenColor: "#00ff00" //"lightgreen"
    property string mpiColor: /*"transparent"//*/"blue"
    property bool isSingleDecimal: APPSETTINGS.getIsSingleDecimal()

    //property string valueString: ""

    signal appVisiblityModeChanged(int mode)

    flags: Qt.FramelessWindowHint | Qt.Window

    function scoreCutoffTofirstDecimal(value) {
        if (MATCHSESSION.decimalScoring)
            return MODREADER.getFormatedSCore(value).toFixed(1)
        return MATCHSESSION.displayScoreValue(value)
    }

    // ISSF EST decimal (10.0–10.9) for live shot log; official sheet totals stay integer.
    function formatEstDecimalScore(value) {
        var score = Number(value || 0)
        if (score >= 11.0)
            score = 10.9
        if (score < 0)
            score = 0
        score = MODREADER.getFormatedSCore(score)
        return Math.round(score * 10) / 10
    }

    function formatLiveShotScore(value) {
        return formatEstDecimalScore(value).toFixed(1)
    }

    // Official totals on the score sheet — integer or decimal per event profile.
    function formatSheetScore(value) {
        return MATCHSESSION.formatScoreText(Number(value || 0))
    }

    function formatEventScore(value) {
        return MATCHSESSION.formatScoreText(value)
    }

    function eventProfileUsesDecimalScoring() {
        return MATCHSESSION.decimalScoring
    }

    ListModel
    {
        id:globalModelOfData
        onCountChanged: {
            console.log("******globalModelOfData****"+count)
        }
    }

    ListModel {
        id: game10RangeEventModel

            ListElement {
                name: qsTr("10M AIR RIFLE FREE")
                count: -1
                gameDisplay1: qsTr("10M AIR")
                gameDisplay2: qsTr("RIFLE")
                matchDisplay: qsTr("UN-LIMITED")
            }
            ListElement {
            name: qsTr("10M AIR RIFLE 10")
            count: 10
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 20")
            count: 20
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-20")
        }

        ListElement {
            name: qsTr("10M AIR RIFLE 30")
            count: 30
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 40")
            count: 40
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 60")
            count: 60
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-60")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL FREE")
            count: -1
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 10")
            count: 10
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 20")
            count: 20
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-20")
        
	        }
        ListElement {
            name: qsTr("10M AIR PISTOL 30")
            count: 30
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 40")
            count: 40
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 60")
            count: 60
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-60")

        }
    }

    ListModel {
        id: game10RangeEventModel_15

        ListElement {
            name: qsTr("10M AIR RIFLE FREE")
            count: -1
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 10")
            count: 10
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 15")
            count: 15
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-15")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 20")
            count: 20
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-20")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 30")
            count: 30
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("10M AIR RIFLE 40")
            count: 40
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL FREE")
            count: -1
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 10")
            count: 10
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 15")
            count: 15
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-15")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 20")
            count: 20
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-20")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 30")
            count: 30
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("10M AIR PISTOL 40")
            count: 40
            gameDisplay1: qsTr("10M AIR")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-40")
        }
    }


//    ListModel {
//        id: gameEventModel
//    }

//    ListView {
//        id: gemeEventListView
//        visible: false
//        model: gameRange === 10 ? game10RangeEventModel : game50RangeEventModel
//    }

    ListModel {
        id: game50RangeEventModel

        ListElement {
            name: qsTr("50 Meter RIFLE FREE")
            count: -1
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 10")
            count: 10
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 20")
            count: 20
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-20")
        } 
	        ListElement {
            name: qsTr("50 Meter RIFLE 30")
            count: 30
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 40")
            count: 40
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 60")
            count: 60
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-60")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL FREE")
            count: -1
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 10")
            count: 10
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 20")
            count: 20
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-20")
        }

        ListElement {
            name: qsTr("50 Meter Free PISTOL 30")
            count: 30
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 40")
            count: 40
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 60")
            count: 60
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-60")
        }
    }

    ListModel {
        id: game50RangeEventModel_15

        ListElement {
            name: qsTr("50 Meter RIFLE FREE")
            count: -1
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 10")
            count: 10
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 15")
            count: 15
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-15")
        }
            ListElement {
            name: qsTr("50 Meter RIFLE 20")
            count: 20
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-20")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 30")
            count: 30
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("50 Meter RIFLE 40")
            count: 40
            gameDisplay1: qsTr("50 Meter")
            gameDisplay2: qsTr("RIFLE")
            matchDisplay: qsTr("MATCH-40")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL FREE")
            count: -1
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("UN-LIMITED")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 10")
            count: 10
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-10")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 15")
            count: 15
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-15")
        }

        ListElement {
            name: qsTr("50 Meter Free PISTOL 20")
            count: 20
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-20")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 30")
            count: 30
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-30")
        }
        ListElement {
            name: qsTr("50 Meter Free PISTOL 40")
            count: 40
            gameDisplay1: qsTr("50 Meter Free")
            gameDisplay2: qsTr("PISTOL")
            matchDisplay: qsTr("MATCH-40")
        }
    }


    Component.onCompleted: {
        MODREADER.setIsSingleDecimal(isSingleDecimal)
        shootingPage.setCurrentGameType(1)
        title = APPSETTINGS.getBrandDisplayName() + " Electronic Target"
        MODREADER.setGame_range(gameRange)
        MODREADER.setShotPerSeries(shootsPerSeries)
        //MODREADER.on_pushButton_clicked();
    }

//    visibility: "FullScreen"
    visibility: "Maximized"

    onVisibilityChanged: {
        console.log("wiiiiiin visibility changed .... ", visibility)
        appVisiblityModeChanged(visibility)
    }

    Rectangle {
        id: fullRect
        color: "#202020"
        anchors.fill: parent
    }

    Header {
        id: header
        width: parent.width
        height: 40
        anchors.top: parent.top
        z: 5

        onMinimize: {
            console.log("windows visibility ", window.visibility)

            if (window.visibility == 2)
                window.visibility = 5
            else if (window.visibility == 5)
                window.visibility = 2
            else
                window.visibility = 5

            window.visibility = "Minimized"
        }

        onClose: {
            if (loginPage.visible)
            {
                window.close()
                Qt.quit()
            } else
                closeDia.visible = true
        }
    }

    ShootingPage {
        id: shootingPage
        z: 0
        height: parent.height - header.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        visible: !loginPage.visible

        Component.onCompleted: {
            console.log("srinivas", MODREADER.getNetworkPath(), "ssssssssssssss")
            if (MODREADER.getNetworkPath() == "") {
                console.log("testing")
                
                setCurrentGameType(7)
            }
        }

        onVisibleChanged: {
            if (visible) {
                APPSETTINGS.updateStatusFeedbackFile(2)
            } else {
                APPSETTINGS.updateStatusFeedbackFile(1)
            }
        }
    }

    ModernLoginPage {
        id: loginPage

//        visible: false
        height: parent.height - header.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: 20

        onUsername_loginPageChanged: {
            window.userName = loginPage.username_loginPage
        }

        onGameModeChanged: updateGameType()
        onGameEventChanged: updateGameType()

        function updateGameType()
        {
            MATCHSESSION.selectProfileByIndex(gameEvent)
            shootingPage.configureFromMatchSession()
        }
           




    ClosePopupDialog {
        id: closeDia
        visible: false

        width: 300
        height: 100

        onCancel: {
            closeDia.visible = false
        }

        onDiscard: {
            window.close()
            Qt.quit()
        }

        onSave: {
            APPSETTINGS.saveMatch()
            closeDia.visible = false
            window.close()
            Qt.quit()
        }
    }

}
}
