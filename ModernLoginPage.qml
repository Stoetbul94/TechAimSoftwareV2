import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Item {
    id: root

    property alias username_loginPage: athleteName.text
    property int gameMode: 1
    property int gameEvent: 0
    property int gameType: 1
    property int papermode: 0
    property bool mod_connected: false
    property bool connectToMaster: false
    property bool popupMode: false
    property bool showComportConnector: true
    property bool showLaneConnector: false
    property bool hideFreePractice: false
    property bool trainingProfile: gameEvent === 1 || gameEvent === 5
    property bool threePositionTraining: gameEvent === 5

    readonly property color background: "#0f1318"
    readonly property color surface: "#171d24"
    readonly property color surfaceRaised: "#202832"
    readonly property color borderColor: "#303b47"
    readonly property color primary: "#b90042"
    readonly property color primaryBright: "#e31b54"
    readonly property color textPrimary: "#f7f9fb"
    readonly property color textSecondary: "#aeb8c4"
    readonly property color success: "#35c98b"

    readonly property var eventProfiles: [
        {
            profileId: 0,
            name: qsTr("50 m Rifle Prone"),
            subtitle: qsTr("ISSF 2026 • 60 shots")
        },
        {
            profileId: 1,
            name: qsTr("50 m Rifle Prone Training"),
            subtitle: qsTr("Flexible prone practice")
        },
        {
            profileId: 2,
            name: qsTr("50 m 3P Qualification — Outdoor"),
            subtitle: qsTr("20 K • 20 P • 20 S")
        },
        {
            profileId: 4,
            name: qsTr("50 m 3P Final"),
            subtitle: qsTr("10 K • 10 P • 15 S • decimal"),
            note: qsTr("Simplified final format. Full CRO elimination workflow is planned.")
        },
        {
            profileId: 5,
            name: qsTr("50 m 3P Training"),
            subtitle: qsTr("Position-based practice")
        }
    ]

    signal loadSavedGame()
    signal sighterStartedFromServer()
    signal matchStartedFromServer()
    signal backHomeFromServer()

    onUsername_loginPageChanged: APPSETTINGS.setUsername(username_loginPage)

    onGameEventChanged: {
        APPSETTINGS.setGameEvent(gameEvent)
        APPSETTINGS.setGameMode(1)
        APPSETTINGS.set10or50mRange(50)
        window.gameRange = 50
        MATCHSESSION.selectProfileByIndex(gameEvent)
        if (trainingProfile)
            applyTrainingConfig()
    }

    onVisibleChanged: MODREADER.setOnLoginPage(visible)

    Component.onCompleted: {
        gameMode = 1
        athleteName.text = MODREADER.getUserName()
        portField.text = MODREADER.getPortNumber()
        networkPath.text = MODREADER.getNetworkPath()
        APPSETTINGS.setSetaSettingsFilePathFromQML(networkPath.text)
        gameEvent = normalizeGameEvent(APPSETTINGS.getGameEvent())
        mod_connected = APPSETTINGS.getAppMode()
                ? MODREADER.isModBusConnected() : false
    }

    Connections {
        target: APPSETTINGS

        function onUserNameChanged(name) {
            athleteName.text = name
        }

        function onPortNumberChanged(port) {
            portField.text = port
        }

        function onStartSighter() {
            if (root.visible)
                performStart()
            sighterStartedFromServer()
        }

        function onStartMatch() {
            if (root.visible)
                performStart()
            matchStartedFromServer()
        }

        function onBackHome() {
            if (!root.visible)
                backHomeFromServer()
        }
    }

    MessageDialog {
        id: alertDialog
        title: qsTr("TechAim")
        buttons: MessageDialog.Ok
    }

    Rectangle {
        anchors.fill: parent
        color: background

        Rectangle {
            width: parent.width * 0.55
            height: width
            radius: width / 2
            color: "#28101a"
            opacity: 0.58
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -width * 0.36
            anchors.topMargin: -height * 0.52
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: Math.max(18, Math.min(parent.width, parent.height) * 0.035)
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 22

            RowLayout {
                Layout.fillWidth: true
                spacing: 18

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: qsTr("Start a shooting session")
                        color: textPrimary
                        font.pixelSize: Math.max(26, root.width * 0.022)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: qsTr("Choose an ISSF event or training profile. TechAim configures the target, scoring and timing.")
                        color: textSecondary
                        font.pixelSize: Math.max(13, root.width * 0.009)
                        wrapMode: Text.WordWrap
                        Layout.maximumWidth: root.width * 0.57
                    }
                }

                Image {
                    source: APPSETTINGS.getBrandLogo()
                    Layout.preferredWidth: Math.min(300, root.width * 0.21)
                    Layout.preferredHeight: Layout.preferredWidth * 0.28
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.width >= 1050 ? 2 : 1
                columnSpacing: 22
                rowSpacing: 22

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(trainingProfile ? 620 : 500,
                                                     root.height * 0.68)
                    radius: 18
                    color: surface
                    border.color: borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 18

                        Text {
                            text: qsTr("Session details")
                            color: textPrimary
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: qsTr("ATHLETE")
                            color: textSecondary
                            font.pixelSize: 11
                            font.letterSpacing: 1.2
                        }

                        TextField {
                            id: athleteName
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            placeholderText: qsTr("Enter athlete name")
                            color: textPrimary
                            font.pixelSize: 16
                            leftPadding: 16
                            rightPadding: 16
                            background: Rectangle {
                                radius: 10
                                color: surfaceRaised
                                border.color: athleteName.activeFocus
                                              ? primaryBright : borderColor
                            }
                        }

                        Text {
                            text: qsTr("TARGET CONNECTION")
                            color: textSecondary
                            font.pixelSize: 11
                            font.letterSpacing: 1.2
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            TextField {
                                id: portField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: qsTr("COM port")
                                color: textPrimary
                                leftPadding: 16
                                visible: showComportConnector
                                background: Rectangle {
                                    radius: 10
                                    color: surfaceRaised
                                    border.color: portField.activeFocus
                                                  ? primaryBright : borderColor
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 134
                                Layout.preferredHeight: 48
                                radius: 10
                                color: mod_connected ? "#15392e" : surfaceRaised
                                border.color: mod_connected ? success : borderColor

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Rectangle {
                                        width: 9
                                        height: 9
                                        radius: 5
                                        color: mod_connected ? success : "#7b8794"
                                    }

                                    Text {
                                        text: mod_connected
                                              ? qsTr("Connected") : qsTr("Demo / Offline")
                                        color: mod_connected ? success : textSecondary
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: borderColor
                        }

                        Text {
                            text: qsTr("Selected profile")
                            color: textSecondary
                            font.pixelSize: 12
                        }

                        Text {
                            text: MATCHSESSION.eventName
                            color: textPrimary
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 10
                            rowSpacing: 10

                            Repeater {
                                model: [
                                    { label: qsTr("SHOT PLAN"), value: MATCHSESSION.shotPlan },
                                    { label: qsTr("SCORING"), value: MATCHSESSION.scoringName },
                                    { label: qsTr("PREP"), value: Math.round(MATCHSESSION.preparationSeconds / 60) + qsTr(" min") },
                                    { label: qsTr("MATCH"), value: MATCHSESSION.matchSeconds > 0 ? Math.round(MATCHSESSION.matchSeconds / 60) + qsTr(" min") : qsTr("Flexible") },
                                    { label: qsTr("DISTANCE"), value: qsTr("50 m") },
                                    { label: qsTr("RULES"), value: qsTr("ISSF 2026") }
                                ]

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 64
                                    radius: 10
                                    color: surfaceRaised

                                    Column {
                                        anchors.centerIn: parent
                                        width: parent.width - 12
                                        spacing: 3

                                        Text {
                                            width: parent.width
                                            text: modelData.label
                                            color: textSecondary
                                            font.pixelSize: 9
                                            horizontalAlignment: Text.AlignHCenter
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: modelData.value
                                            color: textPrimary
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            horizontalAlignment: Text.AlignHCenter
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: threePositionTraining ? 170 : 116
                            radius: 12
                            color: "#141a20"
                            border.color: primary
                            visible: trainingProfile

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 9

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: qsTr("Customize training")
                                        color: textPrimary
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: qsTr("Changes apply immediately")
                                        color: textSecondary
                                        font.pixelSize: 10
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: threePositionTraining ? 3 : 3
                                    columnSpacing: 10
                                    rowSpacing: 8

                                    TrainingSpinField {
                                        id: trainingPrep
                                        label: qsTr("PREP MIN")
                                        value: 15
                                        from: 0
                                        to: 60
                                        onValueModified: applyTrainingConfig()
                                        fieldKey: "prep"
                                    }

                                    TrainingSpinField {
                                        id: trainingTime
                                        label: qsTr("SESSION MIN")
                                        value: threePositionTraining ? 120 : 60
                                        from: 1
                                        to: 480
                                        onValueModified: applyTrainingConfig()
                                        fieldKey: "time"
                                    }

                                    TrainingSpinField {
                                        id: trainingProne
                                        label: threePositionTraining
                                               ? qsTr("PRONE SHOTS") : qsTr("SHOTS")
                                        value: threePositionTraining ? 20 : 60
                                        from: 1
                                        to: threePositionTraining ? 200 : 300
                                        onValueModified: applyTrainingConfig()
                                        fieldKey: "prone"
                                    }

                                    TrainingSpinField {
                                        id: trainingKneeling
                                        label: qsTr("KNEELING SHOTS")
                                        value: 20
                                        from: 1
                                        to: 200
                                        visible: threePositionTraining
                                        onValueModified: applyTrainingConfig()
                                        fieldKey: "kneeling"
                                    }

                                    TrainingSpinField {
                                        id: trainingStanding
                                        label: qsTr("STANDING SHOTS")
                                        value: 20
                                        from: 1
                                        to: 200
                                        visible: threePositionTraining
                                        onValueModified: applyTrainingConfig()
                                        fieldKey: "standing"
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                text: qsTr("Load saved session")
                                Layout.preferredHeight: 50
                                Layout.fillWidth: true
                                onClicked: loadSavedSession()
                                contentItem: Text {
                                    text: parent.text
                                    color: textPrimary
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: 11
                                    color: parent.down ? "#2d3742" : surfaceRaised
                                    border.color: borderColor
                                }
                            }

                            Button {
                                text: qsTr("Start session")
                                Layout.preferredHeight: 50
                                Layout.fillWidth: true
                                onClicked: performStart()
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: 11
                                    color: parent.down ? "#920035" : primary
                                    border.color: primaryBright
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(trainingProfile ? 620 : 500,
                                                     root.height * 0.68)
                    radius: 18
                    color: surface
                    border.color: borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 14

                        Text {
                            text: qsTr("Choose an event")
                            color: textPrimary
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: qsTr("The official match settings are applied automatically.")
                            color: textSecondary
                            font.pixelSize: 13
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: root.width >= 1350 ? 2 : 1
                            columnSpacing: 12
                            rowSpacing: 12

                            Repeater {
                                model: eventProfiles

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 92
                                    radius: 13
                                    color: gameEvent === modelData.profileId ? "#321321" : surfaceRaised
                                    border.color: gameEvent === modelData.profileId
                                                  ? primaryBright : borderColor
                                    border.width: gameEvent === modelData.profileId ? 2 : 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 13

                                        Rectangle {
                                            Layout.preferredWidth: 42
                                            Layout.preferredHeight: 42
                                            radius: 21
                                            color: gameEvent === modelData.profileId ? primary : "#2d3742"

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.profileId === 0 || modelData.profileId === 1 ? "P" : "3P"
                                                color: "white"
                                                font.pixelSize: modelData.profileId < 2 ? 17 : 13
                                                font.weight: Font.Bold
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                color: textPrimary
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                                wrapMode: Text.WordWrap
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.subtitle
                                                color: textSecondary
                                                font.pixelSize: 11
                                                wrapMode: Text.WordWrap
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                visible: modelData.note !== undefined && modelData.note !== ""
                                                text: modelData.note || ""
                                                color: primaryBright
                                                font.pixelSize: 10
                                                wrapMode: Text.WordWrap
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 18
                                            Layout.preferredHeight: 18
                                            radius: 9
                                            color: gameEvent === modelData.profileId ? primaryBright : "transparent"
                                            border.color: gameEvent === modelData.profileId
                                                          ? primaryBright : "#687583"
                                            border.width: 2
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: gameEvent = modelData.profileId
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: qsTr("TechAim • Electronic target control")
                    color: textSecondary
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: APPSETTINGS.getAppMode()
                          ? qsTr("LIVE MODE") : qsTr("DEMO MODE")
                    color: APPSETTINGS.getAppMode() ? success : textSecondary
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    Text {
        id: networkPath
        visible: false
    }

    function validateSession() {
        if (athleteName.text.trim() === "") {
            alertDialog.text = qsTr("Please enter the athlete's name.")
            alertDialog.open()
            athleteName.forceActiveFocus()
            return false
        }
        return true
    }

    function performStart() {
        if (!validateSession())
            return

        MATCHSESSION.selectProfileByIndex(gameEvent)
        if (trainingProfile && !applyTrainingConfig()) {
            alertDialog.text = qsTr("Please check the custom training settings.")
            alertDialog.open()
            return
        }
        MATCHSESSION.reset()
        if (!MATCHSESSION.startPreparation()) {
            alertDialog.text = qsTr("Unable to start the selected event.")
            alertDialog.open()
            return
        }

        shootingPage.configureFromMatchSession()

        if (APPSETTINGS.getAppMode()) {
            if (showComportConnector && portField.text.trim() !== "") {
                MODREADER.connectedModbus(portField.text.trim())
                mod_connected = MODREADER.isModBusConnected()
            }
            if (!MODREADER.isModBusConnected()) {
                alertDialog.text = qsTr("The target COM port is not connected.")
                alertDialog.open()
                return
            }
            if (!MODREADER.isHardwareConnected()) {
                alertDialog.text = qsTr("The electronic target hardware is not responding.")
                alertDialog.open()
                return
            }
        }

        APPSETTINGS.saveMatch(true)
        APPSETTINGS.updateUserHistoryData(athleteName.text.trim())
        MODREADER.saveNameAndPort(
                    athleteName.text.trim(),
                    portField.text.trim(),
                    networkPath.text)
        MODREADER.resetShootinCount()
        root.visible = false
        shootingPage.beginSessionTimers()
    }

    function perfromStart() {
        performStart()
    }

    function loadSavedSession() {
        if (!APPSETTINGS.uploadGame())
            return

        athleteName.text = APPSETTINGS.getUserName()
        gameMode = 1
        gameEvent = normalizeGameEvent(APPSETTINGS.getGameEvent())
        if (APPSETTINGS.getLoadedSessionJson() !== "") {
            MATCHSESSION.restoreSessionJson(APPSETTINGS.getLoadedSessionJson())
            shootingPage.restoreFromMatchSession()
        }
        gameType = APPSETTINGS.getGameType()
        isSaveGame = true
        loadSavedGame()
        root.visible = false
    }

    function startButtonClickedOnLoadGame() {
        root.visible = false
    }

    function disableControls() {
        root.enabled = false
    }

    function reset() {
        athleteName.clear()
        gameEvent = 0
        gameMode = 1
    }

    function normalizeGameEvent(profileId) {
        if (profileId === 3)
            return 2
        if (profileId < 0 || profileId > 5)
            return 0
        return profileId
    }

    function trainingValue(key, fallback) {
        if (key === "prep") return trainingPrep.value
        if (key === "time") return trainingTime.value
        if (key === "prone") return trainingProne.value
        if (key === "kneeling") return trainingKneeling.value
        if (key === "standing") return trainingStanding.value
        return fallback
    }

    function applyTrainingConfig() {
        if (!trainingProfile)
            return true
        return MATCHSESSION.configureTraining(
                    trainingValue("prep", 15),
                    trainingValue("time", threePositionTraining ? 120 : 60),
                    trainingValue("prone", threePositionTraining ? 20 : 60),
                    trainingValue("kneeling", 20),
                    trainingValue("standing", 20))
    }

    component TrainingSpinField: ColumnLayout {
        property alias value: spin.value
        property alias from: spin.from
        property alias to: spin.to
        property string label: ""
        property string fieldKey: ""
        signal valueModified()

        Layout.fillWidth: true
        spacing: 4

        Text {
            text: parent.label
            color: root.textSecondary
            font.pixelSize: 9
            font.letterSpacing: 0.6
        }

        SpinBox {
            id: spin
            Layout.fillWidth: true
            editable: true
            onValueModified: parent.valueModified()
            contentItem: TextInput {
                text: spin.textFromValue(spin.value, spin.locale)
                color: root.textPrimary
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                readOnly: !spin.editable
                validator: spin.validator
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
            background: Rectangle {
                radius: 8
                color: root.surfaceRaised
                border.color: spin.activeFocus ? root.primaryBright : root.borderColor
            }
        }
    }
}
