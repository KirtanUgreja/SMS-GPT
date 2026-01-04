package com.smsgateway.sms_gateway

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_gateway/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
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
