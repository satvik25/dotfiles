import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "Components"
// import QtGraphicalEffects 1.15

Item {
  id: root
  height: Screen.height
  width: Screen.width
  Rectangle {
    id: background
    anchors.fill: parent
    height: parent.height
    width: parent.width
    z: 0
    color: config.bgDefault
  }
  Image {
    id: backgroundImage
    anchors.fill: parent
    height: parent.height
    width: parent.width
    fillMode: Image.PreserveAspectCrop
    visible: config.CustomBackground == "true" ? true : false
    z: 1
    source: config.Background
    asynchronous: false
    cache: true
    mipmap: true
    clip: true
  }
  // GaussianBlur {
  //   anchors.fill: parent
  //   source: bgImage
  //   radius: 20      // Range: 0-50
  //   samples: 16     // more samples = smoother but slower
  // }
  // BrightnessContrast {
  //     anchors.fill: parent
  //     source: parent   // feeds on the blurred result
  //     brightness: -0.3 // negative dims (−1.0 … 1.0)
  //     contrast:   1.0  // leave contrast normal
  // }
  // Saturation {
  //     anchors.fill: parent
  //     source: parent    // feeds on the dimmed result
  //     saturation: 0.0   // 0 = fully grayscale, 1 = original color
  // }
  Item {
    id: mainPanel
    z: 3
    anchors {
      fill: parent
      leftMargin: Screen.width * 0.02
      rightMargin: Screen.width * 0.02
      bottomMargin: Screen.height * 0.02
    }
    Clock {
      id: time
      visible: config.ClockEnabled == "true"
      // pin to top-right corner:
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Screen.height * 0.022
      anchors.rightMargin: Screen.width  * 0.01
    }
    LoginPanel {
      id: loginPanel
      anchors.fill: parent
    }
  }
}
