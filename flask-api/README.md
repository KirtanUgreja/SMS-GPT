# SMS-GPT Backend API 🚀

This directory contains the **FastAPI** backend for SMS-GPT. It acts as the bridge between Twilio (or the Android SMS Gateway) and Google Gemini AI.

## 📁 What's Inside?

- **`main.py`**: The core application logic. It handles the web server and Twilio webhooks.
- **`model.py`**: Connects to OpenRouter.ai to access various LLMs (default: `xiaomi/mimo-v2-flash:free`).
- **`.env`**: Stores your `OPENROUTER_API_KEY`.
- **`manifest.json` / `Procfile`**: (Optional) Configuration for deployments.

## 🛠️ Prerequisites

- Python 3.10+
- A Google Cloud Project (Optional, if using Gemini directly) OR an **OpenRouter Account**.
- An API Key from [OpenRouter](https://openrouter.ai/).

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
    This automatically installs dependencies (`fastapi`, `uvicorn`, `twilio`, `requests`, etc.) and starts the server.

### Option 2: Using standard `pip`

1.  **Create a virtual environment**:
    ```bash
    python -m venv .venv
    ```
2.  **Activate the virtual environment**:
    ```bash
    source .venv/bin/activate
    ```
3.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
4.  **Run the server**:
    ```bash
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```

## 🔑 Configuration

Create a `.env` file in this directory:

```env
OPENROUTER_API_KEY=your_actual_openrouter_api_key
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
