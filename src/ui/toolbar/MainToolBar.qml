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


/* ──────  Logout button  ────── */
        ToolButton {
            id: logoutBtn
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            height: 50
            anchors.rightMargin: 150
            icon.source: "qrc:/res/logout.svg"     // pick any icon you like
            text: qsTr("Logout")
            background: Rectangle {
                    color: "white"
                    radius: 4
                    border.color: qgcPal.text
                    border.width: 1
                }

            onClicked: confirmLogout.open()
        }


    /* ──────  confirmation popup  ────── */
    MessageDialog {
        id: confirmLogout
        title: qsTr("Confirm Logout")
        text:  qsTr("You are about to log out.\nDo you want to continue?")
        visible: false
        standardButtons: Dialog.Yes | Dialog.No
        onYes: {
            loginManager.requestLogout()   // calls the C++ slot
            close()
        }
    }

    ToolButton {
        id: customStatusButton
        text: "Vehicle Status"
        anchors.top: parent.top
        anchors.right: logoutBtn.left
        anchors.margins: 10
        height: 50
        onClicked: {
            missionControlDialog.visible = true
        }
        background: Rectangle {
                color: "white"
                radius: 4
                border.color: qgcPal.text
                border.width: 1
            }
    }

    QGCPopupDialog {
        id: missionControlDialog
        title: "Mission Control Dashboard"
        anchors.right:parent.right
        width: 800
        height: 700
        visible: false

        // Timer for real-time updates
        Timer {
            id: updateTimer
            interval: 1000  // 1 second
            running: missionControlDialog.visible
            repeat: true
            onTriggered: {
                // Force update of all bindings
                if (QGroundControl.multiVehicleManager.activeVehicle) {
                    // This will trigger property change notifications
                    var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"
            anchors.topMargin: 70
            radius: 8

            // Header with status indicator
            Rectangle {
                id: headerBar
                width: parent.width
                height: 60
                color: "#2d2d2d"
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 6

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 15

                    // Connection Status Indicator
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: QGroundControl.multiVehicleManager.activeVehicle ? "#4CAF50" : "#F44336"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QGCLabel {
                        color: "white"
                        text: QGroundControl.multiVehicleManager.activeVehicle ? "Vehicle Connected" : "No Vehicle Connected"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ScrollView {
                anchors.top: headerBar.bottom
                anchors.bottom: closeButton.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20

                Column {
                    width: parent.width
                    spacing: 20

                    // No Vehicle Connected Message
                    Rectangle {
                        width: parent.width
                        height: 200
                        color: "#2d2d2d"
                        radius: 8
                        border.color: "#404040"
                        border.width: 1
                        visible: !QGroundControl.multiVehicleManager.activeVehicle

                        Column {
                            anchors.centerIn: parent
                            spacing: 15

                            QGCLabel {
                                color: "#FF9800"
                                text: "⚠️ No Vehicle Connected"
                                font.pixelSize: 24
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            QGCLabel {
                                color: "#CCCCCC"
                                text: "Please connect a vehicle to view telemetry data"
                                font.pixelSize: 16
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Vehicle Dashboard (when connected)
                    Column {
                        visible: !!QGroundControl.multiVehicleManager.activeVehicle
                        width: parent.width
                        spacing: 15

                        // Flight Mode Card
                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#2d2d2d"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 20

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: "#2196F3"

                                    QGCLabel {
                                        anchors.centerIn: parent
                                        text: "✈️"
                                        color: "white"
                                        font.pixelSize: 20
                                    }
                                }

                                Column {
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Flight Mode"
                                        font.pixelSize: 14
                                    }

                                    QGCLabel {
                                        id: flightModeLabel
                                        color: "white"
                                        text: {
                                            var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                            return vehicle ? vehicle.flightMode : "N/A"
                                        }
                                        font.pixelSize: 20
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Battery Card
                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#2d2d2d"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1

                            property real batteryPercent: {
                                var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                // if (!vehicle || !vehicle.battery) {
                                //     return -1
                                // }
                                return vehicle.battery.current.value
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 20

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: {
                                        var battery = parent.parent.batteryPercent
                                        if (battery < 0) return "#757575"
                                        if (battery > 50) return "#4CAF50"
                                        else if (battery > 20) return "#FF9800"
                                        else return "#F44336"
                                    }

                                    QGCLabel {
                                        anchors.centerIn: parent
                                        text: "🔋"
                                        color: "white"
                                        font.pixelSize: 18
                                    }
                                }

                                Column {
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Battery Level"
                                        font.pixelSize: 14
                                    }

                                    QGCLabel {
                                        id: batteryLabel
                                        color: "white"
                                        text: {
                                            var battery = parent.parent.parent.batteryPercent
                                            return battery >= 0 ? Math.round(battery) + "%" : "N/A"
                                        }
                                        font.pixelSize: 20
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // GPS Card
                        Rectangle {
                            width: parent.width
                            height: 100
                            color: "#2d2d2d"
                            radius: 8
                            border.color: "#404040"
                            border.width: 1

                            property int satelliteCount: {
                                var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                return vehicle ? vehicle.gps.count.value : -1
                            }

                            property real latitude: {
                                var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                return vehicle && vehicle.coordinate ? vehicle.coordinate.latitude : NaN
                            }

                            property real longitude: {
                                var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                return vehicle && vehicle.coordinate ? vehicle.coordinate.longitude : NaN
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 20

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: {
                                        var sats = parent.parent.satelliteCount
                                        if (sats < 0) return "#757575"
                                        if (sats >= 6) return "#4CAF50"
                                        else if (sats >= 4) return "#FF9800"
                                        else return "#F44336"
                                    }

                                    QGCLabel {
                                        anchors.centerIn: parent
                                        text: "🛰️"
                                        color: "white"
                                        font.pixelSize: 16
                                    }
                                }

                                Column {
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "GPS Status"
                                        font.pixelSize: 14
                                    }

                                    QGCLabel {
                                        id: satelliteLabel
                                        color: "white"
                                        text: {
                                            var sats = parent.parent.parent.satelliteCount
                                            return sats >= 0 ? "Satellites: " + sats : "Satellites: N/A"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                    }

                                    QGCLabel {
                                        id: coordinatesLabel
                                        color: "#CCCCCC"
                                        text: {
                                            var lat = parent.parent.parent.latitude
                                            var lon = parent.parent.parent.longitude
                                            if (!isNaN(lat) && !isNaN(lon)) {
                                                return "Lat: " + lat.toFixed(7) + ", Lon: " + lon.toFixed(7)
                                            }
                                            return "Coordinates: N/A"
                                        }
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        // Additional Status Cards
                        Row {
                            width: parent.width
                            spacing: 15

                            // Altitude Card
                            Rectangle {
                                width: (parent.width - 15) / 2
                                height: 80
                                color: "#2d2d2d"
                                radius: 8
                                border.color: "#404040"
                                border.width: 1

                                property real altitudeValue: {
                                    var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                    return vehicle && vehicle.altitudeRelative && vehicle.altitudeRelative.rawValue !== undefined ?
                                           vehicle.altitudeRelative.rawValue : NaN
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Altitude"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    QGCLabel {
                                        id: altitudeLabel
                                        color: "white"
                                        text: {
                                            var alt = parent.parent.altitudeValue
                                            return !isNaN(alt) ? alt.toFixed(1) + " m" : "N/A"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // Ground Speed Card
                            Rectangle {
                                width: (parent.width - 15) / 2
                                height: 80
                                color: "#2d2d2d"
                                radius: 8
                                border.color: "#404040"
                                border.width: 1

                                property real speedValue: {
                                    var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                    return vehicle && vehicle.groundSpeed && vehicle.groundSpeed.rawValue !== undefined ?
                                           vehicle.groundSpeed.rawValue : NaN
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Ground Speed"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    QGCLabel {
                                        id: speedLabel
                                        color: "white"
                                        text: {
                                            var speed = parent.parent.speedValue
                                            return !isNaN(speed) ? speed.toFixed(1) + " m/s" : "N/A"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }

                        // Additional Row with more parameters
                        Row {
                            width: parent.width
                            spacing: 15

                            // Heading Card
                            Rectangle {
                                width: (parent.width - 15) / 2
                                height: 80
                                color: "#2d2d2d"
                                radius: 8
                                border.color: "#404040"
                                border.width: 1

                                property real headingValue: {
                                    var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                    return vehicle && vehicle.heading && vehicle.heading.rawValue !== undefined ?
                                           vehicle.heading.rawValue : NaN
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Heading"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    QGCLabel {
                                        id: headingLabel
                                        color: "white"
                                        text: {
                                            var heading = parent.parent.headingValue
                                            return !isNaN(heading) ? Math.round(heading) + "°" : "N/A"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // Armed Status Card
                            Rectangle {
                                width: (parent.width - 15) / 2
                                height: 80
                                color: "#2d2d2d"
                                radius: 8
                                border.color: "#404040"
                                border.width: 1

                                property bool armedStatus: {
                                    var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                    return vehicle ? vehicle.armed : false
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    QGCLabel {
                                        color: "#CCCCCC"
                                        text: "Armed Status"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    QGCLabel {
                                        id: armedLabel
                                        color: parent.parent.armedStatus ? "#F44336" : "#4CAF50"
                                        text: {
                                            var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                                            if (!vehicle) return "N/A"
                                            return vehicle.armed ? "ARMED" : "DISARMED"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Enhanced Close Button
            Rectangle {
                id: closeButton
                width: 120
                height: 45
                color: "#F44336"
                radius: 8
                border.color: "#D32F2F"
                border.width: 1
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 20

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    QGCLabel {
                        text: "✖️"
                        color: "white"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QGCLabel {
                        text: "Close"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onEntered: parent.color = "#E53935"
                    onExited: parent.color = "#F44336"

                    onClicked: {
                        missionControlDialog.visible = false
                    }
                }
            }
        }
    }

}
