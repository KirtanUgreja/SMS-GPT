import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request all required permissions
  Future<bool> requestAllPermissions() async {
    // Request SMS permissions
    final smsStatus = await Permission.sms.request();

    // Request phone state permission
    final phoneStatus = await Permission.phone.request();

    // Request notification permission (Android 13+)
    await Permission.notification.request();

    // Request to ignore battery optimization
    await requestBatteryOptimization();

    // Check if all critical permissions are granted
    return smsStatus.isGranted && phoneStatus.isGranted;
  }

  // Request battery optimization exemption
  Future<void> requestBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // Check if all permissions are granted
  Future<bool> hasAllPermissions() async {
    final sms = await Permission.sms.isGranted;
    final phone = await Permission.phone.isGranted;

    return sms && phone;
  }

  // Check individual permission status
  Future<PermissionStatus> getSmsPermissionStatus() async {
    return await Permission.sms.status;
  }

  Future<PermissionStatus> getPhonePermissionStatus() async {
    return await Permission.phone.status;
  }

  Future<PermissionStatus> getNotificationPermissionStatus() async {
    return await Permission.notification.status;
  }
}
