// Main.qml
// ---------------------------------------------------------------
// QML basics so the code below makes sense:
//   * QML describes a tree of objects:  Type { property: value ... }
//   * "id: foo" gives an object a name so other objects can use it.
//   * "anchors" glue an object to the edges/center of another one.
//   * "parent" means the object this one is placed inside.
//   * Properties can hold expressions; they re-evaluate automatically
//     when the things they depend on change (this is called a "binding").
//
// SDDM gives us some ready-made objects:
//   * sddm         -> sddm.login(...), sddm.powerOff(), sddm.reboot() ...
//   * userModel    -> list of users, userModel.lastUser = last one who logged in
//   * sessionModel -> list of sessions (Hyprland, Plasma ...)
//   * config       -> values from theme.conf
// ---------------------------------------------------------------

import QtQuick 2.15                 // basic shapes, text, images
import QtQuick.Controls 2.15        // TextField, ComboBox
import QtMultimedia                 // MediaPlayer + VideoOutput (for mp4/webm backgrounds)

// Rectangle is the root (outermost) object = the whole screen.
Rectangle {
    id: root
    color: "black"                  // shown if the background image is missing

    // ---------- SETTINGS (read from theme.conf, with fallbacks) ----------
    // "readonly property" = a named value we can reuse below.
    // "a || b" means: use a, but if it is empty use b.
    readonly property string fontName:  config.fontFamily || "Open Sans"
    readonly property color  textColor: config.textColor  || "#ffffff"
    readonly property color  dimColor:  config.dimColor   || "#8a8a8a"
    readonly property color  errorColor: config.errorColor || "#ff5555"
    // ---- background type, decided from the file extension in theme.conf ----
    readonly property string bgFile: config.background || "assets/background.png"
    readonly property string bgExt:  bgFile.split(".").pop().toLowerCase()
    readonly property bool   bgIsGif:   bgExt === "gif"
    readonly property bool   bgIsVideo: ["mp4", "webm", "mkv", "mov", "avi"].indexOf(bgExt) !== -1
    readonly property bool   bgIsImage: !bgIsGif && !bgIsVideo
    // Number (0..1): how far from the left the column sits.
    readonly property real   colPos:    Number(config.columnPosition || 0.10)

    // Holds "right now". The Timer below refreshes it every second.
    property date now: new Date()

    // ---------- BACKGROUND (image, GIF or video) ----------
    // bgImage is now a plain container Item. GlassField blurs whatever is
    // inside it, so the glass effect works for all three background types.
    // Only the child that matches the file type gets a "source"; the others stay empty.
    Item {
        id: bgImage
        anchors.fill: parent

        // 1) normal still picture (png / jpg)
        Image {
            anchors.fill: parent
            visible: root.bgIsImage
            source: root.bgIsImage ? Qt.resolvedUrl(root.bgFile) : ""
            fillMode: Image.PreserveAspectCrop
        }

        // 2) animated GIF
        AnimatedImage {
            anchors.fill: parent
            visible: root.bgIsGif
            source: root.bgIsGif ? Qt.resolvedUrl(root.bgFile) : ""
            fillMode: Image.PreserveAspectCrop
            playing: true
        }

        // 3) video (mp4 / webm ...): MediaPlayer decodes, VideoOutput draws
        MediaPlayer {
            id: player
            source: root.bgIsVideo ? Qt.resolvedUrl(root.bgFile) : ""
            loops: MediaPlayer.Infinite             // repeat forever
            videoOutput: videoOut
            audioOutput: AudioOutput { muted: true } // login screen should be silent
            Component.onCompleted: if (root.bgIsVideo) play()
        }
        VideoOutput {
            id: videoOut
            anchors.fill: parent
            visible: root.bgIsVideo
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }

    // ---------- DARK FADE AT THE BOTTOM ----------
    // In your screenshot the bottom fades to black so the session text is readable.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.18              // 18% of screen height
        gradient: Gradient {                      // top color -> bottom color
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#e6000000" }  // #AARRGGBB, e6 = mostly opaque
        }
    }

    // ---------- CLOCK TIMER ----------
    Timer {
        interval: 1000                            // milliseconds
        running: true                             // start immediately
        repeat: true                              // keep firing
        onTriggered: root.now = new Date()        // update "now" -> clock text updates itself
    }

    // ---------- LOGIN COLUMN (clock, date, fields) ----------
    // Column stacks its children vertically, top to bottom.
    Column {
        id: loginColumn
        width: 370
        x: root.width * root.colPos               // horizontal position
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -root.height * 0.08   // nudge up a bit
        spacing: 14                               // gap between children

        // Big clock, e.g. 10:57
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatTime(root.now, "hh:mm")   // hh = hour, mm = minute
            color: root.textColor
            font.family: root.fontName
            font.pixelSize: 150
            font.bold: true
        }

        // Date, e.g. "Sunday 25"  (dddd = weekday name, d = day number)
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(root.now, "dddd d")
            color: root.textColor
            font.family: root.fontName
            font.pixelSize: 34
            font.bold: true
        }

        // Empty block just to create vertical space
        Item { width: 1; height: 90 }

        // ----- USERNAME FIELD -----
        // GlassField is our own component (see GlassField.qml).
        GlassField {
            id: userField
            width: parent.width
            blurSource: bgImage                     // blur the wallpaper behind it
            text: userModel.lastUser                // pre-fill with the last user
            placeholderText: "Username"
            font.family: root.fontName
            font.pixelSize: 20
            font.bold: true
            // Tab or Enter moves the cursor to the password field
            KeyNavigation.tab: passwordField
            Keys.onReturnPressed: passwordField.forceActiveFocus()
        }

        // ----- PASSWORD FIELD -----
        GlassField {
            id: passwordField
            width: parent.width
            blurSource: bgImage
            echoMode: TextInput.Password            // show dots instead of letters
            placeholderText: "Password"
            font.family: root.fontName
            font.pixelSize: 20
            font.bold: true
            focus: true                             // start typing here immediately
            // Pressing Enter (main key or numpad Enter) tries to log in
            Keys.onReturnPressed: root.doLogin()
            Keys.onEnterPressed:  root.doLogin()
        }

        // ----- ERROR MESSAGE (empty until a login fails) -----
        Text {
            id: errorText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ""
            color: root.errorColor
            font.family: root.fontName
            font.pixelSize: 16
        }

        // ----- LOGIN "BUTTON" -----
        // A plain Text that reacts to clicks. Dim when the password is empty.
        Text {
            id: loginButton
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Login"
            color: root.textColor
            opacity: passwordField.text.length > 0 ? 1.0 : 0.4   // brighter when ready
            font.family: root.fontName
            font.pixelSize: 20
            font.bold: true

            // MouseArea makes the area clickable
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.doLogin()
            }
        }
    }

    // ---------- SESSION SELECTOR (bottom, under the column) ----------
    // Hidden ComboBox: we only use it to store the list + the selected index.
    ComboBox {
        id: sessionBox
        visible: false
        model: sessionModel                         // list from SDDM
        textRole: "name"                            // which field of each item is the name
        currentIndex: sessionModel.lastIndex        // start with the last used session
    }

    // Visible label: "Session (Hyprland)". Click to cycle to the next session.
    Text {
        id: sessionLabel
        x: loginColumn.x
        width: loginColumn.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        horizontalAlignment: Text.AlignHCenter
        text: "Session (" + sessionBox.currentText + ")"
        color: root.dimColor
        font.family: root.fontName
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            // % wraps back to 0 after the last session
            onClicked: sessionBox.currentIndex = (sessionBox.currentIndex + 1) % sessionBox.count
        }
    }

    // ---------- POWER BUTTONS (bottom right) ----------
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40
        spacing: 24

        Text {
            text: "Reboot"
            visible: sddm.canReboot                 // hide if the system doesn't allow it
            color: root.dimColor
            font.family: root.fontName
            font.pixelSize: 15
            MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
        }
        Text {
            text: "Shutdown"
            visible: sddm.canPowerOff
            color: root.dimColor
            font.family: root.fontName
            font.pixelSize: 15
            MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
        }
    }

    // ---------- LOGIC ----------
    // A function: a reusable block of code we call from several places above.
    function doLogin() {
        errorText.text = ""                         // clear any old error
        // sddm.login(user, password, sessionIndex) asks SDDM to authenticate
        sddm.login(userField.text, passwordField.text, sessionBox.currentIndex)
    }

    // Listen for signals that SDDM sends us.
    Connections {
        target: sddm
        // Runs when the password was wrong
        function onLoginFailed() {
            errorText.text = "Wrong password"
            passwordField.text = ""                 // empty the field
            passwordField.forceActiveFocus()        // put the cursor back in it
        }
    }

    // Runs once when the theme finishes loading
    Component.onCompleted: passwordField.forceActiveFocus()
}
