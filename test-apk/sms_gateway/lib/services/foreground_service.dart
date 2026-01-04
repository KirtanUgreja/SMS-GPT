import 'package:flutter/services.dart';

class ForegroundService {
  static const MethodChannel _channel = MethodChannel('sms_gateway/foreground_service');

  // Start foreground service
  Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
      print('Foreground service started');
    } on PlatformException catch (e) {
      print('Error starting foreground service: ${e.message}');
    }
  }

  // Stop foreground service
  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
      print('Foreground service stopped');
    } on PlatformException catch (e) {
      print('Error stopping foreground service: ${e.message}');
    }
  }

  // Check if service is running
  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result as bool;
    } on PlatformException catch (e) {
      print('Error checking service status: ${e.message}');
      return false;
    }
  }
}
