// GlassField.qml
// ---------------------------------------------------------------
// A text field whose frosted-glass rectangle automatically matches
// the length of the text:
//   * empty field  -> rectangle fits the hint ("Username" / "Password")
//   * you type     -> rectangle grows and shrinks with the text
//   * password     -> rectangle follows the number of dots
// The rectangle always stays centered behind the text.
//
// How the glass effect works:
//   1. Take a snapshot of the wallpaper area behind the rectangle.
//   2. Blur that snapshot.
//   3. Cut it into a rounded shape and add a very faint white tint.
//   4. The text sits on top.
//
// Needs Qt 6.5+ (MultiEffect). Arch ships a newer Qt, so this is fine.
// ---------------------------------------------------------------

import QtQuick
import QtQuick.Controls
import QtQuick.Effects          // gives us MultiEffect (the blur)

TextField {
    id: control

    // ---------- THINGS YOU CAN CHANGE FROM Main.qml ----------
    property Item  blurSource                       // the item to blur: the wallpaper (set in Main.qml)
    property color textColour: "#ffffff"            // color of the typed text
    property color hintColour: "#b0b0b0"            // color of the "Username"/"Password" hint
    property real  blurAmount: 0.1                  // 0 = sharp, 1 = very blurry
    property real  tintOpacity: 0.08                // white overlay strength (0 = fully clear)
    property int   cornerRadius: 12                 // roundness of the corners
    property int   sidePadding: 24                  // space left and right of the text, in pixels
    property int   minPillWidth: 120                // the rectangle never gets narrower than this

    // ---------- SIZE AND TEXT LOOK ----------
    implicitHeight: 46
    horizontalAlignment: TextInput.AlignHCenter     // text centered inside the field
    verticalAlignment: TextInput.AlignVCenter
    color: textColour
    placeholderTextColor: hintColour
    selectionColor: "#80ffffff"                     // highlight color when selecting text

    // ---------- MEASURING THE TEXT ----------
    // TextMetrics measures how wide a piece of text will be when drawn.
    TextMetrics {
        id: metrics
        font: control.font                          // same font as the field, so the width is accurate
        text: {
            if (control.text.length === 0)
                return control.placeholderText      // empty: measure the hint text
            if (control.echoMode === TextInput.Password)
                return control.passwordCharacter.repeat(control.text.length)  // password: measure the dots
            return control.text                     // normal: measure what you typed
        }
    }

    // ---------- THE GLASS BACKGROUND ----------
    // "background" replaces the default look of the TextField.
    background: Item {

        // The glass rectangle ("pill"). Its width follows the text.
        Item {
            id: pill
            anchors.centerIn: parent                // always centered behind the text
            height: parent.height
            // text width + padding on both sides, but never below the minimum
            // and never wider than the field itself
            width: Math.min(control.width,
                            Math.max(control.minPillWidth,
                                     metrics.advanceWidth + control.sidePadding * 2))

            // Smoothly animate when the width changes while typing
            Behavior on width { NumberAnimation { duration: 80 } }

            // Step 1: snapshot of the wallpaper area behind the pill.
            ShaderEffectSource {
                id: snapshot
                visible: false                      // only used as input for the blur
                sourceItem: control.blurSource
                sourceRect: {
                    // These lines only exist so QML re-runs this block when things move
                    // (a binding re-runs when any value it reads changes).
                    var watch = pill.x + pill.width + pill.height
                              + control.x + control.y + control.parent.x + control.parent.y
                    // Position of the pill in wallpaper coordinates
                    var p = pill.mapToItem(control.blurSource, 0, 0)
                    return Qt.rect(p.x, p.y, pill.width, pill.height)
                }
            }

            // Step 2: blur the snapshot and clip it to rounded corners.
            MultiEffect {
                anchors.fill: parent
                source: snapshot
                blurEnabled: true
                blur: control.blurAmount            // 0..1 strength
                blurMax: 40                         // largest blur radius in pixels
                autoPaddingEnabled: false           // keep the picture exactly pill-sized
                maskEnabled: true                   // use the rounded shape below as a cutout
                maskSource: roundedMask
            }

            // The cutout shape (invisible). Opaque = keep, transparent = hide.
            Rectangle {
                id: roundedMask
                anchors.fill: parent
                radius: control.cornerRadius
                visible: false
                layer.enabled: true                 // MultiEffect needs this as a texture
            }

            // Step 3: very faint white tint so the pill is still visible on dark areas.
            Rectangle {
                anchors.fill: parent
                radius: control.cornerRadius
                color: Qt.rgba(1, 1, 1, control.tintOpacity)
            }
        }
    }
}
