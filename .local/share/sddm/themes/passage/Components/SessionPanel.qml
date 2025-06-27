import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

Item {
  property var session: sessionList.currentIndex
  implicitHeight: sessionButton.height
  implicitWidth: sessionButton.width
  DelegateModel {
    id: sessionWrapper
    model: sessionModel
    delegate: ItemDelegate {
      id: sessionEntry
      height: 30
      width: parent.width
      highlighted: sessionList.currentIndex == index
      contentItem: Text {
        renderType: Text.NativeRendering
        font.family: config.Font
        font.pixelSize: 14
        font.bold: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#ffffee"
        text: name
      }
      background: Rectangle {
        id: sessionEntryBackground
        color: "transparent"
        border.color: Qt.rgba(255/255, 248/255, 222/255, 0.7)
        border.width: 2
        radius: 6
      }
      states: [
        State {
          name: "pressed"
          when: sessionEntry.down
          PropertyChanges {
            target: sessionEntryBackground
			border.color: Qt.rgba(255/255, 248/255, 222/255, 1)
          }
        },
        State {
          name: "hovered"
          when: sessionEntry.hovered
          PropertyChanges {
            target: sessionEntryBackground
            border.color: "#9ebd9e"
          }
        }
      ]
      transitions: Transition {
        PropertyAnimation {
          property: "color"
          duration: 300
        }
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          sessionList.currentIndex = index
          sessionPopup.close()
        }
      }
    }
  }
  Button {
    id: sessionButton
    height: 32
    width: 32
    hoverEnabled: true
    icon {
      source: Qt.resolvedUrl("../icons/settings.svg")
      color: "#afa8a6"
    }
    background: Rectangle {
      id: sessionButtonBackground
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
        when: sessionButton.down
        PropertyChanges {
          target: sessionButtonBackground
          // color: config.buttonBorderPressed
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
        when: sessionButton.hovered
        PropertyChanges {
          target: sessionButtonBackground
          border.color:"#9ebd9e"
          opacity: 1
        }
        PropertyChanges {
          target: gradientStop0
          color: config.buttonBgHovered0
          }
        PropertyChanges {
          target: gradientStop1
          color:config.buttonBgHovered1
        }
      },
      State {
        name: "focused"
        when: sessionButton.activeFocus
        PropertyChanges {
          target: sessionButtonBackground
	  	  border.color: Qt.rgba(255/255, 248/255, 222/255, 1)
          opacity: 1
        }
        PropertyChanges {
          target: gradientStop0
          color: config.buttonBgFocused0
          }
        PropertyChanges {
          target: gradientStop1
          color: config.buttonBgFocused1
        }
      }
    ]
    transitions: Transition {
      PropertyAnimation {
        properties: "color"
        duration: 150
      }
    }
    onClicked: {
      sessionPopup.visible ? sessionPopup.close() : sessionPopup.open()
      sessionButton.state = "pressed"
    }
  }
  Popup {
    id: sessionPopup
    width: inputWidth
    x: -(inputWidth + padding * 2)
    y: -(contentHeight + padding * 2) + sessionButton.height
    padding: 8
    background: Rectangle {
      color: "transparent"
 	  border.color: Qt.rgba(255/255, 248/255, 222/255, 0.7)
      border.width: 2
      radius: 6
    }
    contentItem: ListView {
      id: sessionList
      implicitHeight: contentHeight
      spacing: 8
      model: sessionWrapper
      currentIndex: sessionModel.lastIndex
      clip: true
    }
    enter: Transition {
      ParallelAnimation {
        NumberAnimation {
          property: "opacity"
          from: 0
          to: 1
          duration: 400
          easing.type: Easing.OutExpo
        }
        NumberAnimation {
          property: "x"
          from: sessionPopup.x + (inputWidth * 0.1)
          to: sessionPopup.x
          duration: 500
          easing.type: Easing.OutExpo
        }
      }
    }
    exit: Transition {
      NumberAnimation {
        property: "opacity"
        from: 1
        to: 0
        duration: 300
        easing.type: Easing.OutExpo
      }
    }
  }
}
