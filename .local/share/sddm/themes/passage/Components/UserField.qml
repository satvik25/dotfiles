import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
  id: userField
  selectByMouse: true
  anchors.verticalCenterOffset: 400    // move it 40px down
  echoMode: TextInput.Normal
  selectionColor: config.textDefault
  renderType: Text.NativeRendering
  font {
    family: config.Font
    pixelSize: 16
    bold: false
  }
  palette.text: "#efeded"
  palette.placeholderText: "#b6ceb6"
  verticalAlignment: Text.AlignVCenter
  horizontalAlignment: Text.AlignHCenter
  placeholderText: "user  "
  font.letterSpacing: text.length > 0 ? 4 : 0
  text: userModel.lastUser
  background: Rectangle {
    id: userFieldBackground
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
      when: userField.hovered
      PropertyChanges {
        target: userFieldBackground
        border.color: "#9ebd9e"
      }
    },
    State {
      name: "focused"
      when: userField.activeFocus
      PropertyChanges {
        target: userFieldBackground
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
