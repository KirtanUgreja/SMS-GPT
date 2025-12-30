# SMS-GPT 📩🤖

A lightweight FastAPI webhook that connects Twilio SMS to Google Gemini (Generative AI) to create a friendly SMS-based Q&A bot (“Shiksha Bot”). This repository shows how to run the service locally with Uvicorn and expose it publicly using ngrok so Twilio can POST incoming SMS messages to your /sms endpoint.

---

## 🔧 Requirements

- Python 3.12+ (project `pyproject.toml` specifies >=3.12)
- pip (or Poetry) to install dependencies
- ngrok (for exposing local server to the public internet)
- A Google Gemini API key (set as `GEMINI_API_KEY` in `.env`)
- (Optional) Twilio account and phone number if you want to receive real SMS messages

---

## ⚡ Installation

1. Clone this repository and change into the folder:

```bash
git clone <repo-url>
cd SMS-GPT
```

2. Create and activate a virtual environment (recommended):

```bash
python -m venv .venv
source .venv/bin/activate   # Linux/macOS
.\.venv\Scripts\activate  # Windows (PowerShell)
```

3. Install dependencies (choose one):

- Using pip (simple):

```bash
python -m pip install --upgrade pip
python -m pip install .
# or install exact deps
python -m pip install fastapi uvicorn python-dotenv twilio google-genai python-multipart
```

- Using Poetry (if you use Poetry):

```bash
poetry install
```

> Note: `uvicorn` is included in `pyproject.toml` and provides the ASGI server used to run the app.

---

## .env file (what to put in it) 💡

Create a file named `.env` in the project root and add at least the following key:

```env
GEMINI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Optional Twilio-related keys you may want to store for convenience:

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
```

The app reads the `.env` using `python-dotenv` at startup. The only required key for the project as-is is `GEMINI_API_KEY`.

---

## 🚀 Running locally with Uvicorn (dev mode / live reload)

There are a couple of ways to run:

- Using Python module directly (recommended for development with auto-reload):

```bash
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

- Or run the file (the `main.py` contains `uvicorn.run` in `__main__`):

```bash
python main.py
```

- If you have the `uv` CLI (some projects provide a short command), using:

```bash
uv run main.py
```

The `--reload` flag enables live reloading when you change Python source files — useful during development.

---

## 🌐 Expose local server with ngrok

1. Install ngrok (Linux example using the official download):

```bash
# Download and unzip (replace with latest version link from ngrok.com)
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
```

2. Configure your ngrok auth token (one-time):

```bash
ngrok config add-authtoken <YOUR_NGROK_AUTH_TOKEN>
```

3. Start an HTTP tunnel that forwards to your local port 8000:

```bash
ngrok http 8000
```

4. ngrok will print a public forwarding URL, e.g. `https://abcd-1234.ngrok-free.app`. Use that URL in your Twilio webhook configuration and append `/sms`.

Example webhook (Twilio) URL:

```
https://abcd-1234.ngrok-free.app/sms
```

---

## 🔁 What does the `/sms` endpoint do?

- The application exposes POST `/sms` that accepts `Form` fields `Body` and `From` (as Twilio does when forwarding SMS).
- It forwards the message text to Google Gemini to generate a short reply and returns TwiML XML so Twilio responds to the sender.
- Logs incoming messages and AI answers to console for debugging.

You can test locally (without Twilio) with curl:

```bash
curl -X POST http://localhost:8000/sms -d "Body=Hello Shiksha Bot" -d "From=+919054453132"
```

Or test the full flow by configuring your Twilio phone number to send webhooks to the ngrok URL `/sms`.

---

## ✅ Example .env + test

1. Populate `.env` with `GEMINI_API_KEY`.
2. Start server: `python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload`
3. Start ngrok: `ngrok http 8000`
4. Copy the ngrok `https://...` URL into your Twilio number SMS webhook (Messaging > Configure > A Message Comes In)
5. Send an SMS to your Twilio number — your app should log the message and Twilio will deliver the AI-generated reply.

---

## 🛠️ Troubleshooting & Tips

- If you see `404` when calling the API from the public URL, ensure your server is started and ngrok is forwarding to port `8000` and that you use the correct path `/sms`.
- Use `--reload` when developing to see code changes without restarting the server.
- Keep the AI responses short (the code instructs Gemini to respond < 160 chars).
- If the Gemini model `gemini-2.5-flash` returns errors or is unavailable, the code attempts a fallback to `gemini-2.0-flash`.

---

## 📄 License & Notes

This project is a simple demo. Be mindful of API usage limits and costs when using Google Gemini or Twilio in production.

---

If you want, I can also add a `Makefile` or example systemd/service file to keep the app running or a small `requirements.txt` for users who don't use Poetry. Would you like that? ✅
