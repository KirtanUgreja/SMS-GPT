# SMS-GPT 📩🤖

A lightweight FastAPI webhook that connects **Twilio SMS** to **Google Gemini (Generative AI)** to create a friendly SMS-based Q&A bot ("Shiksha Bot"). This project is designed for rural education, providing AI-powered answers via basic SMS without requiring internet access on the student's phone.

---

## 🔧 Installation & Setup (The `uv` Way)

This project uses **uv**, an extremely fast Python package manager.

### 1. Install `uv`

On your Ubuntu machine, run the following to install `uv` globally:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Initialize and Install Dependencies

Navigate to your project folder and use `uv` to manage your environment:

```bash
# Initialize the project structure
uv init --app

# Add required dependencies to pyproject.toml
uv add fastapi uvicorn python-dotenv twilio google-genai python-multipart
```

---

## 💡 Configuration (.env)

Create a file named `.env` in the project root to store your API credentials securely:

```
GEMINI_API_KEY=your_actual_gemini_api_key
```

---

## 🚀 Running the Server

Start your FastAPI application using `uv`. This runs the script inside a managed virtual environment:

```bash
uv run main.py
```

---

## 🌐 Exposing with ngrok

Twilio needs a public URL to send SMS data to your laptop. Use ngrok to create this tunnel:

1. **Start ngrok:**

```bash
ngrok http 8000
```

2. **Copy the Forwarding URL:**
   - (e.g., `https://abcd-1234.ngrok-free.app`)

3. **Configure Twilio Webhook:**
   - Go to **Twilio Console > Phone Numbers > Active Numbers**
   - Under **Messaging**, set "A Message Comes In" to **Webhook**
   - Paste your ngrok URL and **MUST ADD `/sms` at the end**
   - Example URL: `https://abcd-1234.ngrok-free.app/sms`
   - Set the method to **HTTP POST** and click **Save**

---

## ⚠️ Twilio Trial Restrictions (Critical)

If you are using a **Twilio Trial Account**, you will face specific limitations:

- **The Problem:** You can only send/receive SMS with numbers that are **Verified Caller IDs**
- **The Symptom:** If you text from an unverified number, your terminal will show the message arrived and the AI will generate a response, but Twilio will not deliver the SMS to the phone
- **The Fix:** Go to **Twilio Console > Phone Numbers > Manage > Verified Caller IDs** and add every phone number you plan to test with

---

## 🛠️ Testing & Debugging

### 1. Terminal Test (curl)

Test your server logic without using Twilio credits:

```bash
curl -X POST http://localhost:8000/sms -d "Body=Hi" -d "From=+919876543210"
```

### 2. The ngrok Dashboard (Port 4040)

Monitor real-time traffic between Twilio and your laptop:

- Open `http://localhost:4040` in your browser
- If you see a **500 error**, check your Python terminal for a **Traceback**
- If you see a **404 error**, ensure you added `/sms` to your Twilio Webhook URL

---

## 📄 Summary of Flow

1. User texts the Twilio Number
2. Twilio sends a POST request to your `ngrok-url/sms`
3. FastAPI processes the message and gets a response from Gemini
4. FastAPI returns a TwiML XML response (`application/xml`)
5. Twilio sends that response back to the user as an SMS

---

## 📝 License

This project is open source and available for educational purposes.
