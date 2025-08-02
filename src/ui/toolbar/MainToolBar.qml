/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:     _root
    color:  qgcPal.toolbarBackground

    property int currentToolbar: flyViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingYellow

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill:   viewButtonRow
        visible:        currentToolbar === flyViewToolbar

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
            visible:                currentToolbar === flyViewToolbar
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar
        }
    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorLoader.x + indicatorLoader.width
        flickableDirection:     Flickable.HorizontalFlick

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentToolbar === flyViewToolbar ?
                                    "qrc:/toolbar/MainToolBarIndicators.qml" :
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
        }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandingOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandingOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandingIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
    // QGCButton {
    //     id: customStatusButton
    //     text: "Vehicle Status"
    //     anchors.top: parent.top
    //     anchors.right: parent.right
    //     anchors.margins: 10
    //     height: 50
    //     onClicked: {
    //         missionControlDialog.visible = true
    //     }
    // }

    // QGCPopupDialog {
    //     id: missionControlDialog
    //     title: "Mission Control"
    //     anchors.right: parent.right
    //     width: 700
    //     height: 500
    //     visible: false    // Start hidden

    //     Rectangle {
    //         anchors.fill: parent
    //         color: "#000000"
    //         anchors.topMargin: 70
    //         // anchors.rightMargin: 10
    //         // anchors.bottom: parent.bottom

    //         QGCButton {
    //             text: "Close"
    //             anchors.bottom: parent.bottom
    //             anchors.right: parent.right
    //             anchors.margins: 10
    //             // background.color: "white"  // Set button background to white
    //             onClicked: {
    //                 missionControlDialog.visible = false
    //             }
    //         }
    //     }
    // }
    QGCButton {
        id: customStatusButton
        text: "Vehicle Status"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        height: 50
        onClicked: {
            missionControlDialog.visible = true
        }
    }

    QGCPopupDialog {
        id: missionControlDialog
        title: "Mission Control"
        anchors.right: parent.right
        width: 700
        height: 500
        visible: false    // Start hidden

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            anchors.topMargin: 70

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24

                // Use QGroundControl's API to check for connection and display data
                // QGroundControl.multiVehicleManager.activeVehicle is the "active" vehicle or undefined/null if no vehicle.
                // Defensive coding included to display a message when disconnected.
                Component.onCompleted: {} // Needed in some QGC contexts; safe to leave empty here.

                QGCLabel {
                    color: "white"
                    text: QGroundControl.multiVehicleManager.activeVehicle
                        ? "Mode: " + QGroundControl.multiVehicleManager.activeVehicle.flightMode
                        : "No vehicle connection"
                    font.pixelSize: 22
                }
                QGCLabel {
                    color: "white"
                    visible: QGroundControl.multiVehicleManager.activeVehicle !== null
                    text: QGroundControl.multiVehicleManager.activeVehicle
                        ? "GPS: " +
                            QGroundControl.multiVehicleManager.activeVehicle.gps.lat.toFixed(7)
                            + ", " +
                            QGroundControl.multiVehicleManager.activeVehicle.gps.lon.toFixed(7)
                        : ""
                    font.pixelSize: 22
                }
                QGCLabel {
                    color: "white"
                    visible: QGroundControl.multiVehicleManager.activeVehicle !== null
                    text: QGroundControl.multiVehicleManager.activeVehicle
                        && QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining !== undefined
                        ? "Battery: " +
                            QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining + "%"
                        : ""
                    font.pixelSize: 22
                }
            }

            // Custom Close "button" with white background, bottom-right
            Rectangle {
                width: 100
                height: 40
                color: "white"
                radius: 6
                border.color: "#aaaaaa"
                border.width: 1

                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 10

                QGCLabel {
                    anchors.centerIn: parent
                    text: "Close"
                    color: "black"
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        missionControlDialog.visible = false
                    }
                }
            }
        }
    }

    }



