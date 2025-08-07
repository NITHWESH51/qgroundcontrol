import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: Screen.width
    height: Screen.height
    Rectangle {
        anchors.fill: parent
        color: "white"

        Image {
            anchors.centerIn: parent
            source: "qrc:/custom/img/Splashscreen.png"
            fillMode: Image.PreserveAspectFit
        }
    }
}
