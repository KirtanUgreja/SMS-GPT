import os
from fastapi import FastAPI, Form, Response
from twilio.twiml.messaging_response import MessagingResponse
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# FORCE the stable 'v1' API version to fix the 404 NOT FOUND error
client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY"),
    http_options=types.HttpOptions(api_version='v1')
)

@app.post("/sms")
async def handle_sms(Body: str = Form(...), From: str = Form(...)):
    print(f"📩 Message from {From}: {Body}")
    
    twiml_resp = MessagingResponse()
    
    try:
        # 1. Use 'gemini-2.5-flash' for the best balance of speed and intelligence
        response = client.models.generate_content(
            model='gemini-2.5-flash', 
            contents=(
                "System: You are Shiksha Bot, a friendly village teacher. "
                "Keep answers under 160 characters. Use local analogies. "
                f"Student Question: {Body}"
            )
        )
        
        answer = response.text
        print(f"🤖 AI Answer: {answer}")
        twiml_resp.message(answer)

    except Exception as e:
        print(f"❌ Error: {e}")
        # 2. Fallback to Gemini 2.0 Flash if 2.5 has a temporary outage
        try:
            fallback_response = client.models.generate_content(
                model='gemini-2.0-flash', 
                contents=f"Keep this under 160 characters: {Body}"
            )
            twiml_resp.message(fallback_response.text)
        except:
            twiml_resp.message("The teacher is busy right now. Please try again later!")
    
    # 3. Explicitly return as XML so Twilio doesn't throw Error 12300
    return Response(
        content=str(twiml_resp), 
        media_type="application/xml" 
    )

if __name__ == "__main__":
    import uvicorn
    # 0.0.0.0 is necessary for ngrok to tunnel to your Ubuntu machine
    uvicorn.run(app, host="0.0.0.0", port=8000)