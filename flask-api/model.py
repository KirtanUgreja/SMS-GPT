import os
import sys
import requests
import json
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

def get_ai_response(query: str) -> str:
    API_KEY = os.getenv("OPENROUTER_API_KEY")
    if not API_KEY:
        print("❌ Error: OPENROUTER_API_KEY not found in environment variables.")
        return "System Error: API Key missing."

    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": "xiaomi/mimo-v2-flash:free",
                "messages": [
                    {
                        "role": "system",
                        "content": "You are Shiksha Bot, a friendly village teacher. Keep answers under 160 characters. Use local analogies."
                    },
                    {
                        "role": "user",
                        "content": query
                    }
                ]
            },
            timeout=(5, 15),
        )

        if response.status_code == 200:
            try:
                data = response.json()
                return data['choices'][0]['message']['content']
            except (ValueError, KeyError) as e:
                print(f"❌ JSON Parse Error: {e}")
                return "Error parsing AI response."
        else:
            print(f"❌ API Error: {response.status_code} - {response.text}")
            return "The teacher is busy right now. Please try again later!"

    except requests.exceptions.RequestException as e:
        print(f"❌ Request Failed: {e}")
        return "Connection error. Please try again."
