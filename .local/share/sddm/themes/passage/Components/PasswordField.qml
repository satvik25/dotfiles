import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
  id: passwordField
  focus: true
  selectByMouse: true
  palette.text: "#ffffcc"
  placeholderText: "pass  󰟵"
  palette.placeholderText: "#afa8a6"
  echoMode: TextInput.Password
  // passwordCharacter: "•"
  passwordMaskDelay: config.PasswordShowLastLetter
  selectionColor: config.textDefault
  renderType: Text.NativeRendering
  font.family: config.Font
  font.pixelSize: 16
  font.bold: false
  //verticalAlignment: TextInput.AlignVCenter
  bottomPadding: 8
  horizontalAlignment: TextInput.AlignHCenter
  background: Rectangle {
    id: passFieldBackground
	width: parent.width * 1.0
	height: parent.height * 1.0
    color: "transparent"
    border.color: Qt.rgba(255/255, 248/255, 222/255, 0.7)
    border.width: 2
    radius: 6
    opacity: config.opacityDefault
  }
  states: [
    State {
      name: "hovered"
      when: passwordField.hovered
      PropertyChanges {
        target: passFieldBackground
        border.color: "#9ebd9e"
      }
    },
    State {
      name: "focused"
      when: passwordField.activeFocus
      PropertyChanges {
        target: passFieldBackground
        border.color: Qt.rgba(255/255, 248/255, 222/255, 1)
      }
    }
  ]
  transitions: Transition {
    PropertyAnimation {
      properties: "color"
      duration: 300
    }
  }
}
