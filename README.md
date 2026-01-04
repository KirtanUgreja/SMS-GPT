# SMS-GPT: AI SMS Bot 🤖📱

**Turn your Android phone into an AI-powered SMS Gateway.**

This project bridges a simple Android device with Google's Gemini AI to create a text-based bot (like "Shiksha Bot") that works without internet on the user's end.

## 🏗️ Project Components

This repository contains two main parts:

### 1. [Flask API Backend](./flask-api/README.md) 🧠
- **What it is**: A Python FastAPI server that talks to the Google Gemini AI.
- **Role**: Receives the SMS text, asks the AI for an answer, and returns the response.
- **Location**: `/flask-api`

### 2. [SMS Gateway App](./test-apk/sms_gateway/README.md) 📱
- **What it is**: An Android application.
- **Role**: Sits on a phone, catches incoming SMS messages, forwards them to the Flask API, and sends the AI's reply back to the user via SMS.
- **Location**: `/test-apk/sms_gateway`
- **Compatibility**: **ANDROID ONLY** (iOS is not supported).

---

## 🚀 How to Run & Test (The Complete Flow)

To test the full system using your own number, follow these steps:

### Step 1: Start the Backend (Brain)
1.  Go to the `flask-api` folder.
2.  Install dependencies and start the server (see [Backend Instructions](./flask-api/README.md)).
3.  Run `ngrok http 8000` to get a public URL (e.g., `https://abcd.ngrok-free.app`).

### Step 2: Set up the Gateway (Ears & Mouth)
1.  **Get the APK**: Download the Android App from this repo:
    👉 `test-apk/sms_gateway/build/app/outputs/flutter-apk/app-debug.apk`
2.  Install it on an **Android Phone** (Phone A).
3.  Open the app and grant **all permissions**.
4.  In the **Webhook URL** field, paste your ngrok URL + `/sms` (e.g., `https://abcd.ngrok-free.app/sms`).
5.  Turn **ON** the "Start Service" switch.

### Step 3: Test It!
1.  Take a **SECOND Phone** (Phone B).
2.  Send an SMS to **Phone A's number**.
    - *Example*: "What is the capital of India?"
3.  **Watch the magic**:
    - Phone A receives the SMS.
    - Phone A forwards it to your Laptop (Flask API).
    - AI generates an answer.
    - Phone A automatically sends the reply back to Phone B.

---

## ⚠️ Important Notes

- **Android Only**: The customized APK will only work on Android devices.
- **Battery Optimization**: You MUST disable battery optimization for the SMS Gateway app on your Android phone, or the operating system will kill the background service.

For detailed development instructions, please refer to the specific README in each folder.
