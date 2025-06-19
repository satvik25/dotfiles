import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  implicitHeight: powerButton.height
  implicitWidth: powerButton.width
  Button {
    id: powerButton
    height: 32
    width: 32
    hoverEnabled: true
    icon {
      source: Qt.resolvedUrl("../icons/power.svg")
      color: "#afa8a6"
    }
    background: Rectangle {
      id: powerButtonBackground
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
        when: powerButton.down
        PropertyChanges {
          target: powerButtonBackground
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
        when: powerButton.hovered
        PropertyChanges {
          target: powerButtonBackground
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
      }
    ]
    transitions: Transition {
      PropertyAnimation {
        properties: "color"
        duration: 300
      }
    }
    onClicked: sddm.powerOff()
  }
}
