package com.smsgateway.sms_gateway

import android.telephony.SmsManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsSenderHandler : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "SmsSenderHandler"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendSms" -> {
                try {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    
                    if (phoneNumber == null || message == null) {
                        result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
                        return
                    }

                    Log.d(TAG, "Attempting to send SMS to: $phoneNumber")
                    
                    // Get SmsManager instance
                    val smsManager = SmsManager.getDefault()
                    
                    // Split message if it's longer than 160 characters
                    if (message.length > 160) {
                        val parts = smsManager.divideMessage(message)
                        smsManager.sendMultipartTextMessage(
                            phoneNumber,
                            null,
                            parts,
                            null,
                            null
                        )
                        Log.d(TAG, "Multipart SMS sent successfully to: $phoneNumber")
                    } else {
                        smsManager.sendTextMessage(
                            phoneNumber,
                            null,
                            message,
                            null,
                            null
                        )
                        Log.d(TAG, "SMS sent successfully to: $phoneNumber")
                    }
                    
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending SMS: ${e.message}", e)
                    result.error("SMS_SEND_FAILED", e.message, e.stackTraceToString())
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
