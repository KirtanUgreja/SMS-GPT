package com.smsgateway.sms_gateway

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_gateway/foreground_service"
    private val SMS_CHANNEL = "sms_gateway/sms_sender"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Foreground service channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startForegroundService()
                    result.success(true)
                }
                "stopService" -> {
                    stopForegroundService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(SmsGatewayService.isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // SMS sender channel (direct Android API)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler(SmsSenderHandler())
    }

    private fun startForegroundService() {
        val intent = Intent(this, SmsGatewayService::class.java)
        startForegroundService(intent)
    }

    private fun stopForegroundService() {
        val intent = Intent(this, SmsGatewayService::class.java)
        stopService(intent)
    }
}
