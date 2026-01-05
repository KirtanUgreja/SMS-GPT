import os
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

# FORCE the stable 'v1' API version to fix the 404 NOT FOUND error
client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY"),
    http_options=types.HttpOptions(api_version='v1')
)

def get_ai_response(query: str) -> str:
    try:
        # 1. Use 'gemini-2.5-flash' for the best balance of speed and intelligence
        response = client.models.generate_content(
            model='gemini-2.5-flash', 
            contents=(
                "System: You are Shiksha Bot, a friendly village teacher. "
                "Keep answers under 160 characters. Use local analogies. "
                f"Student Question: {query}"
            )
        )
        return response.text

    except Exception as e:
        print(f"❌ Error: {e}")
        # 2. Fallback to Gemini 2.0 Flash if 2.5 has a temporary outage
        try:
            fallback_response = client.models.generate_content(
                model='gemini-2.0-flash', 
                contents=f"Keep this under 160 characters: {query}"
            )
            return fallback_response.text
        except:
            return "The teacher is busy right now. Please try again later!"
