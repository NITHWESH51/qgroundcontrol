import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12

ApplicationWindow {
    id: loginWindow
    width: 800
    height: 850
    visible: true
    visibility: Window.FullScreen
    title: "QGroundControl – Login"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.FramelessWindowHint

    /* ──────  signals  ────── */
    signal loginSuccessful()
    signal loginCancelled()

    /* ──────  state  ────── */
    property bool isLoggingIn: false

    /* ──────  Yellow & Black Background  ────── */
    Rectangle {
        anchors.fill: parent

        // Yellow to black gradient background
        gradient: Gradient {
            GradientStop { position: 0; color: "#FFD700" }
            GradientStop { position: 0.3; color: "#FFA500" }
            GradientStop { position: 0.7; color: "#2C2C2C" }
            GradientStop { position: 1; color: "#000000" }
        }

        // Optional: Subtle animated overlay elements
        Repeater {
            model: 8
            Rectangle {
                width: Math.random() * 4 + 2
                height: width
                radius: width / 2
                color: Qt.rgba(1, 1, 0, Math.random() * 0.15 + 0.05)
                x: Math.random() * parent.width
                y: Math.random() * parent.height

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: -10
                        duration: Math.random() * 20000 + 10000
                    }
                    PropertyAction { value: parent.height + 10 }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.6; duration: 4000 }
                    NumberAnimation { to: 0.1; duration: 4000 }
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.4, 420)
            spacing: 40

            /* Simple title section without logo */
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Text {
                    text: "indrones"
                    color: "black"
                    font.pixelSize: 48  // Increased from 36 to 48
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Text shadow for better readability
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 6
                        samples: 13
                        color: "#80000000"
                        horizontalOffset: 2
                        verticalOffset: 2
                    }
                }

                Text {
                    text: "Sign in to continue"
                    color: "black"
                    font.pixelSize: 24  // Increased from 18 to 24
                    font.weight: Font.Light
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Text shadow for better readability
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 4
                        samples: 9
                        color: "#80000000"
                        horizontalOffset: 2
                        verticalOffset: 2
                    }
                }

                Text {
                    text: "Welcome back, please enter your credentials"
                    color: "#333333"
                    font.pixelSize: 18  // Increased from 14 to 18
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Text shadow for better readability
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 3
                        samples: 7
                        color: "#80000000"
                        horizontalOffset: 1
                        verticalOffset: 1
                    }
                }
            }

            /* Enhanced login card with glass effect */
            Rectangle {
                id: loginCard
                Layout.fillWidth: true
                Layout.preferredHeight: 420  // Increased from 380 to accommodate larger text
                color: Qt.rgba(1, 1, 1, 0.95)  // Semi-transparent white
                radius: 16

                // Enhanced shadow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 35
                    samples: 71
                    color: "#60000000"
                    horizontalOffset: 0
                    verticalOffset: 20
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 25

                    /* Username field with modern styling */
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Username"
                            color: "#2c3e50"
                            font.pixelSize: 18  // Increased from 14 to 18
                            font.weight: Font.Medium
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 56  // Increased from 52 to 56
                            border.color: usernameField.activeFocus ? "#FFD700" : "#e1e8ed"
                            border.width: usernameField.activeFocus ? 2 : 1
                            radius: 10
                            color: usernameField.activeFocus ? "#FFFACD" : "white"

                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                // User icon
                                Rectangle {
                                    width: 24  // Increased from 20 to 24
                                    height: 24  // Increased from 20 to 24
                                    color: usernameField.activeFocus ? "#FFD700" : "#bdc3c7"
                                    radius: 12  // Increased from 10 to 12

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👤"
                                        font.pixelSize: 16  // Increased from 12 to 16
                                        color: "white"
                                    }

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                TextField {
                                    id: usernameField
                                    Layout.fillWidth: true
                                    placeholderText: "Enter your username"
                                    font.pixelSize: 20  // Increased from 16 to 20
                                    color: "#2c3e50"
                                    background: Rectangle { color: "transparent" }
                                    selectByMouse: true
                                }
                            }
                        }
                    }

                    /* Password field with modern styling */
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Password"
                            color: "#2c3e50"
                            font.pixelSize: 18  // Increased from 14 to 18
                            font.weight: Font.Medium
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 56  // Increased from 52 to 56
                            border.color: passwordField.activeFocus ? "#FFD700" : "#e1e8ed"
                            border.width: passwordField.activeFocus ? 2 : 1
                            radius: 10
                            color: passwordField.activeFocus ? "#FFFACD" : "white"

                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                // Lock icon
                                Rectangle {
                                    width: 24  // Increased from 20 to 24
                                    height: 24  // Increased from 20 to 24
                                    color: passwordField.activeFocus ? "#FFD700" : "#bdc3c7"
                                    radius: 12  // Increased from 10 to 12

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🔒"
                                        font.pixelSize: 14  // Increased from 10 to 14
                                        color: "white"
                                    }

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                TextField {
                                    id: passwordField
                                    Layout.fillWidth: true
                                    placeholderText: "Enter your password"
                                    echoMode: TextInput.Password
                                    font.pixelSize: 20  // Increased from 16 to 20
                                    color: "#2c3e50"
                                    background: Rectangle { color: "transparent" }
                                    selectByMouse: true

                                    Keys.onReturnPressed: loginButton.clicked()
                                }
                            }
                        }
                    }

                    /* Enhanced buttons row */
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56  // Increased from 52 to 56
                        spacing: 12

                        /* Modern Login Button */
                        Button {
                            id: loginButton
                            Layout.fillWidth: true
                            text: isLoggingIn ? "Signing In..." : "Sign In"
                            enabled: !isLoggingIn
                                     && usernameField.text.length > 0
                                     && passwordField.text.length > 0

                            background: Rectangle {
                                color: {
                                    if (!loginButton.enabled) return "#bdc3c7"
                                    if (loginButton.pressed) return "#FFA500"
                                    if (loginButton.hovered) return "#FFD700"
                                    return "#FFD700"
                                }
                                radius: 10

                                Behavior on color { ColorAnimation { duration: 200 } }

                                // Loading spinner
                                Rectangle {
                                    visible: isLoggingIn
                                    width: 20  // Increased from 16 to 20
                                    height: 20  // Increased from 16 to 20
                                    radius: 10  // Increased from 8 to 10
                                    color: "transparent"
                                    border.color: "black"
                                    border.width: 2
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter

                                    RotationAnimation on rotation {
                                        running: isLoggingIn
                                        loops: Animation.Infinite
                                        duration: 1000
                                        from: 0
                                        to: 360
                                    }
                                }
                            }

                            contentItem: Text {
                                anchors.centerIn: parent
                                text: loginButton.text
                                color: "black"
                                font.pixelSize: 20  // Increased from 16 to 20
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                            }

                            onClicked: performLogin()
                        }

                        /* Modern Close Button */
                        Button {
                            id: cancelButton
                            Layout.preferredWidth: 100
                            text: "Close"
                            enabled: !isLoggingIn

                            background: Rectangle {
                                color: {
                                    if (!cancelButton.enabled) return "#bdc3c7"
                                    if (cancelButton.pressed) return "#1a1a1a"
                                    if (cancelButton.hovered) return "#333333"
                                    return "#000000"
                                }
                                radius: 10

                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            contentItem: Text {
                                anchors.centerIn: parent
                                text: cancelButton.text
                                color: "white"
                                font.pixelSize: 20  // Increased from 16 to 20
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                            }

                            onClicked: {
                                loginCancelled()
                                loginWindow.close()
                            }
                        }
                    }

                    /* Enhanced error message */
                    Rectangle {
                        Layout.fillWidth: true
                        height: errorMessage.visible ? Math.max(errorMessage.implicitHeight + 20, 40) : 0
                        color: "#fff3cd"
                        border.color: "#FFD700"
                        border.width: 1
                        radius: 8
                        visible: errorMessage.text.length > 0

                        Behavior on height {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutQuart
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "⚠️"
                                font.pixelSize: 20  // Increased from 16 to 20
                            }

                            Text {
                                id: errorMessage
                                color: "#8B6914"
                                font.pixelSize: 18  // Increased from 14 to 18
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            /* Footer text with shadow */
            Text {
                text: "Secure login powered by indrones"
                color: "black"
                font.pixelSize: 16  // Increased from 12 to 16
                Layout.alignment: Qt.AlignHCenter

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 3
                    samples: 7
                    color: "#80000000"
                    horizontalOffset: 1
                    verticalOffset: 1
                }
            }
        }
    }

    /* ──────  Original logic (unchanged)  ────── */
    function performLogin() {
        if (!usernameField.text || !passwordField.text) {
            errorMessage.text = "Please enter username and password"
            return
        }
        isLoggingIn = true
        errorMessage.text = ""
        loginTimer.start()
    }

    Timer {
        id: loginTimer
        interval: 1500
        onTriggered: {
            isLoggingIn = false
            if (validateCredentials(usernameField.text, passwordField.text)) {
                loginManager.setLoggedInUser(usernameField.text)
                loginSuccessful()
                loginWindow.close()
            } else {
                errorMessage.text = "Invalid username or password"
                passwordField.clear()
                passwordField.forceActiveFocus()
            }
        }
    }

    function validateCredentials(user, pass) {
        return (user === "admin" && pass === "admin123") ||
               (user === "user"  && pass === "user123")
    }

    Keys.onEscapePressed: {
        loginCancelled()
        loginWindow.close()
    }
}
