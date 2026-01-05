# SMS-GPT Backend API 🚀

This directory contains the **FastAPI** backend for SMS-GPT. It acts as the bridge between Twilio (or the Android SMS Gateway) and Google Gemini AI.

## 📁 What's Inside?

- **`main.py`**: The core application logic. It handles the web server and Twilio webhooks.
- **`model.py`**: Contains the logic for interacting with the Google Gemini API. It handles model selection and fallback mechanisms.
- **`.env`**: Stores your `GEMINI_API_KEY`.
- **`manifest.json` / `Procfile`**: (Optional) Configuration for deployments.

## 🛠️ Prerequisites

- Python 3.10+
- A Google Cloud Project with the **Gemini API** enabled.
- An API Key for Gemini.

## 📦 Installation & Setup

We recommend using `uv` for a fast setup, but `pip` works too.

### Option 1: Using `uv` (Recommended)

1.  **Install `uv`**:
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
2.  **Run the App**:
    ```bash
    uv run main.py
    ```
    This automatically installs dependencies (`fastapi`, `uvicorn`, `twilio`, `google-genai`, etc.) and starts the server.

### Option 2: Using standard `pip`

1.  **Create a virtual environment**:
    ```bash
    python -m venv .venv
    source .venv/bin/activate
    ```
2.  **Install dependencies**:
    ```bash
    pip install fastapi uvicorn python-dotenv twilio google-genai python-multipart
    ```
3.  **Run the server**:
    ```bash
    python main.py
    ```

## 🔑 Configuration

Create a `.env` file in this directory:

```env
GEMINI_API_KEY=your_actual_gemini_api_key
```

## 🌐 Exposing to the Internet

To allow the SMS Gateway or Twilio to reach this local server, use **ngrok**:

```bash
ngrok http 8000
```

- Copy the **Forwarding URL** (e.g., `https://abcd-1234.ngrok-free.app`).
- The full webhook URL will be: `https://abcd-1234.ngrok-free.app/sms`.

## 🧪 Testing

You can test the API directly without sending an SMS:

```bash
curl -X POST http://localhost:8000/sms \
     -d "Body=Hello Shiksha Bot" \
     -d "From=+919876543210"
```

You should receive an XML response containing the AI's answer.
