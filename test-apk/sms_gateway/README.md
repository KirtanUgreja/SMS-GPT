# SMS Gateway App (Android Only) 📱

A Flutter-based **Android SMS Gateway** application designed to forward incoming SMS messages to a backend API (like our `flask-api`) and send replies back via SMS.

**⚠️ IMPORTANT**: This application will **ONLY** work on Android devices. iOS does not support the necessary background SMS interception features.

## 🎯 What is this for?

This app turns your Android phone into a programmable SMS server. It allows you to:
1.  **Receive SMS** on your phone.
2.  **Forward** the message content to a web server (e.g., your laptop running the `flask-api`).
3.  **Receive a reply** from the server.
4.  **Send the reply** back to the original sender automatically.

It is perfect for building SMS bots (like "Shiksha Bot") without paying for expensive cloud numbers.

## 📥 Download APK

You can find the pre-built debug APK in this repository:
`build/app/outputs/flutter-apk/app-debug.apk`

(Or look in the `test-apk` folder if you are browsing the root of the repo).

## 🧪 How to Test (Step-by-Step)

### Prerequisites
1.  An Android Phone with a SIM card.
2.  The `flask-api` running on your computer (exposed via ngrok).

### Testing Steps

1.  **Install the APK**: Transfer the `.apk` file to your phone and install it. You may need to allow "Install from Unknown Sources".
2.  **Grant Permissions**: Open the app and allow ALL requested permissions (SMS, Contacts, etc.).
3.  **Configure Webhook**:
    - In the "Webhook URL" field, enter your ngrok URL ending with `/sms`.
    - Example: `https://abcd-1234.ngrok-free.app/sms`
4.  **Start Service**: Tap the **Start Service** button. Ensure the status says "Running".
5.  **Test with Another Phone**:
    - Use a *different* phone to send an SMS to the phone running the app.
    - Message: "Hello Shiksha Bot"
6.  **Verify**:
    - The App log should show: `Received from +123...`
    - Your `flask-api` terminal should show the incoming request.
    - The *other* phone should receive a reply SMS from the app.

## ⚙️ Features

- **24/7 Background Service**: Runs even when the app is closed (disable Battery Optimization!).
- **Daily Counter**: Tracks how many SMS messages have been processed today.
- **Filters**: Option to only reply to specific numbers or messages starting with a specific prefix.

## 🛠️ Build from Source

If you want to modify the code:

```bash
cd sms_gateway
flutter pub get
flutter run
```
