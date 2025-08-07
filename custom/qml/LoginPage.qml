import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: loginWindow
    visible: true
    width: Screen.width
    height: Screen.height
    flags: Qt.Window // Remove FramelessWindowHint to show taskbar
    color: "#1e1e1e"
    title: "QGroundControl Login"
    
    // Signals to communicate with C++
    signal loginAccepted()
    signal loginRejected()
    
    // Properties for UI state
    property bool isLoading: false
    property string errorMessage: ""
    
    // JavaScript functions for authentication
    function attemptLogin() {
        if (usernameField.text.length === 0 || passwordField.text.length === 0) {
            errorMessage = "Please enter both username and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Simulate loading delay
        loadingTimer.start()
    }

    function handleLoginResult(success) {
    isLoading = false
    if (success) {
        console.log("Login successful!")
        loginAccepted()
        if (typeof loginResultHandler !== "undefined") {
            // Use a single-shot timer instead of Qt.callLater
            delayTimer.start()
        }
    } else {
        errorMessage = "Invalid username or password"
        passwordField.text = ""
        passwordField.forceActiveFocus()
    }
}

// Timer for property setting delay
Timer {
    id: delayTimer
    interval: 50
    repeat: false
    onTriggered: {
        if (typeof loginResultHandler !== "undefined") {
            loginResultHandler.loginSuccessful = true
            console.log("QML-debug: loginSuccessful set")
        }
    }
}


    function handleCancel() {
        console.log("Login cancelled!")
        loginRejected()  // Keep the existing signal  
        if (typeof loginResultHandler !== "undefined") {
            console.log("Calling setLoginCancelled(true)")
            // loginResultHandler.setLoginCancelled = true
            loginResultHandler.loginCancelled = true
        }
    }
    
    // Timer for simulating authentication delay
    Timer {
        id: loadingTimer
        interval: 1000
        onTriggered: {
            // Simple authentication check (you can modify this logic)
            var username = usernameField.text
            var password = passwordField.text
            var success = false
            
            // Authentication logic
            if ((username === "admin" && password === "password123") ||
                (username === "engineer" && password === "qgc2024") ||
                (username === "user" && password === "qgc123")) {
                success = true
            }
            
            handleLoginResult(success)
        }
    }
    
    // Handle window close button (X button)
    onClosing: {
        if (!close.accepted) {
            handleCancel()
        }
    }
    
    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2c3e50" }
            GradientStop { position: 1.0; color: "#1e1e1e" }
        }
    }
    
    // Main content container
    Rectangle {
        id: loginContainer
        width: 400
        height: 520
        anchors.centerIn: parent
        color: "#34495e"
        radius: 10
        border.color: "#5d6d7e"
        border.width: 1
        
        // Drop shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            color: "transparent"
            border.color: "#000000"
            border.width: 1
            radius: parent.radius + 3
            opacity: 0.2
            z: parent.z - 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            // Logo/Title area
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "transparent"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "QGroundControl"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#ecf0f1"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Please log in to continue"
                        font.pixelSize: 14
                        color: "#bdc3c7"
                    }
                }
            }
            
            // Login form
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 20
                
                // Username field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Username:"
                        color: "#bdc3c7"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: "Enter your username"
                        color: "#2c3e50"
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: "#ecf0f1"
                            border.color: usernameField.activeFocus ? "#3498db" : "#95a5a6"
                            border.width: 2
                            radius: 6
                        }
                        
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                passwordField.forceActiveFocus()
                                event.accepted = true
                            }
                        }
                    }
                }
                
                // Password field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Password:"
                        color: "#bdc3c7"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: "Enter your password"
                        echoMode: TextInput.Password
                        color: "#2c3e50"
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: "#ecf0f1"
                            border.color: passwordField.activeFocus ? "#3498db" : "#95a5a6"
                            border.width: 2
                            radius: 6
                        }
                        
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (loginButton.enabled) {
                                    attemptLogin()
                                }
                                event.accepted = true
                            }
                        }
                    }
                }
                
                // Error message
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: errorText.visible ? 40 : 0
                    color: errorText.visible ? "#e74c3c" : "transparent"
                    radius: 4
                    visible: errorText.visible
                    
                    Text {
                        id: errorText
                        anchors.centerIn: parent
                        text: errorMessage
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        wrapMode: Text.WordWrap
                        visible: errorMessage.length > 0
                    }
                }
                
                // Login button
                Button {
                    id: loginButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: isLoading ? "Authenticating..." : "LOGIN"
                    enabled: !isLoading && usernameField.text.length > 0 && passwordField.text.length > 0
                    
                    background: Rectangle {
                        color: {
                            if (!loginButton.enabled) return "#7f8c8d"
                            if (loginButton.pressed) return "#27ae60"
                            if (loginButton.hovered) return "#2ecc71"
                            return "#2ecc71"
                        }
                        radius: 6
                        border.color: loginButton.enabled ? "#27ae60" : "#95a5a6"
                        border.width: 1
                        
                        // Subtle animation
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Row {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        // Loading spinner
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: "transparent"
                            border.color: "white"
                            border.width: 2
                            visible: isLoading
                            
                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                color: "white"
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 2
                                
                                RotationAnimation {
                                    // target: parent
                                    property: "rotation"
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: isLoading
                                }
                            }
                        }
                        
                        Text {
                            text: loginButton.text
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }
                    
                    onClicked: {
                        attemptLogin()
                    }
                }
                
                // Credentials hint (remove in production)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#34495e"
                    border.color: "#5d6d7e"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Demo Credentials:\nadmin/password123\nengineer/qgc2024\nuser/qgc123"
                        color: "#95a5a6"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.2
                    }
                }
            }
            
            // Bottom button
            Button {
                id: exitButton
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "Exit Application"
                enabled: !isLoading
                
                background: Rectangle {
                    color: {
                        if (!exitButton.enabled) return "#7f8c8d"
                        if (exitButton.pressed) return "#c0392b"
                        if (exitButton.hovered) return "#e74c3c"
                        return "#e74c3c"
                    }
                    radius: 6
                    border.color: exitButton.enabled ? "#c0392b" : "#95a5a6"
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: exitButton.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    handleCancel()
                }
            }
        }
    }
    
    // Set initial focus when window loads
    Component.onCompleted: {
        usernameField.forceActiveFocus()
    }
}
