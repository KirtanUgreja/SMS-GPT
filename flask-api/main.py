import os
import uvicorn
from fastapi import FastAPI, Form, Response
from twilio.twiml.messaging_response import MessagingResponse
from model import get_ai_response

app = FastAPI()

@app.post("/sms")
async def handle_sms(Body: str = Form(...), From: str = Form(...)):
    print(f"📩 Message from {From}: {Body}")
    
    twiml_resp = MessagingResponse()
    
    answer = get_ai_response(Body)
    print(f"🤖 AI Answer: {answer}")
    twiml_resp.message(answer)
    
    # 3. Explicitly return as XML so Twilio doesn't throw Error 12300
    return Response(
        content=str(twiml_resp), 
        media_type="application/xml" 
    )
# 0.0.0.0 is necessary for ngrok to tunnel to your Ubuntu machine