package com.smsgateway.sms_gateway

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.provider.Telephony

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            android.util.Log.d("SmsGateway", "Native SmsReceiver: Message received")
            // SMS messages are handled by the telephony plugin
            // This receiver is registered to ensure the app has priority
            // The actual processing is done in the Flutter layer via telephony plugin
        }
    }
}
