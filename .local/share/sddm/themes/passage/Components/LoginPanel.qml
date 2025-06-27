import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

Item {
  property var user: userField.text
  property var password: passwordField.text
  property var session: sessionPanel.session
  property var inputHeight: 144
  property var inputWidth: 256
  Rectangle {
    id: loginBackground
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    height: inputHeight * 1.5
    width: inputWidth * 1.5
    radius: 4
    visible: config.LoginBackground == "true" ? true : false
    color: config.bgDark
    opacity: config.opacityPanel
  }
  Column {
    spacing: 12
    bottomPadding: 12
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    PowerButton {
      id: powerButton
    }
    RebootButton {
      id: rebootButton
    }
    SleepButton {
      id: sleepButton
    }
    z: 5
  }
  Column {
    spacing: 8
    anchors {
      bottom: parent.bottom
      right: parent.right
    }
    bottomPadding: 12
    SessionPanel {
      id: sessionPanel
    }
    z: 5
  }
  Column {
    id: column
    spacing: 16
    z: 5
    width: inputWidth
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
      verticalCenterOffset: 130
      horizontalCenterOffset: -26
    }
    UserField {
      id: userField
      height: 30
      width: parent.width
    }
    RowLayout {
      id: row
      spacing: 8
      anchors {
        // verticalCenter: userField
        horizontalCenter: parent.horizontalCenter
      }
      PasswordField {
        id: passwordField
        Layout.preferredWidth: (inputWidth - loginButton.width - row.spacing)
        Layout.preferredHeight: 30
        onAccepted: loginButton.clicked()
      }
      Button {
        id: loginButton
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        enabled: user != "" && password != "" ? true : false
        hoverEnabled: true
        // icon {
        //   source: Qt.resolvedUrl("../icons/login.svg")
        //   color: "#9ebd9e"
        //   color: Qt.rgba(255/255, 248/255, 222/255, 0.7)
        // }
      	Text {
          id: submitIcon
          text: ""
          color: "#b6ceb6"
          font.pixelSize: 14
          anchors.centerIn: parent
          bottomPadding: 2
          // leftPadding: 1	
      	}
        background: Rectangle {
          id: buttonBackground
          // gradient: Gradient {
          //   GradientStop { id: gradientStop0; position: 0.0; color: config.buttonBgNormal }
          //   GradientStop { id: gradientStop1; position: 1.0; color: config.buttonBgNormal }
          // }
          border.color: Qt.rgba(255/255, 248/255, 222/255, 0.7)
          border.width: 2
          radius: 6
          opacity: config.opacityDefault
          color: "transparent"
        }
        states: [
          State {
            name: "pressed"
            when: loginButton.down
            PropertyChanges {
              target: buttonBackground
              border.color: Qt.rgba(255/255, 248/255, 222/255, 1)
              opacity: 1
            }
            PropertyChanges {
              target: gradientStop0
              color: config.buttonBgPressed
            }
            PropertyChanges {
              target: gradientStop1
              color: config.buttonBgPressed
            }
          },
          State {
            name: "hovered"
            when: loginButton.hovered
            PropertyChanges {
              target: buttonBackground
              border.color: "#9ebd9e"
              opacity: 1
            }
            PropertyChanges {
              target: gradientStop0
              color: config.buttonBgHovered0
            }
            PropertyChanges {
              target: gradientStop1
              color: config.buttonBgHovered1
            }
          },
          State {
            name: "enabled"
            when: loginButton.enabled
            PropertyChanges {
              target: buttonBackground
            }
            PropertyChanges {
              target: buttonBackground
            }
          }
        ]
        transitions: Transition {
          PropertyAnimation {
            properties: "color"
            duration: 300
          }
        }
        onClicked: {
          sddm.login(user, password, session)
        }
      }
    }
  }
  Connections {
    target: sddm

    function onLoginFailed() {
      passwordField.text = "Incorrect Password"
      passwordField.focus = true
    }
  }
}
