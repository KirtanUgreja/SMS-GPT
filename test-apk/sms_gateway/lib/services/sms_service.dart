import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:telephony/telephony.dart';
import '../models/sms_transaction.dart';
import 'storage_service.dart';
import 'webhook_service.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;
  final StorageService _storage = StorageService();
  final WebhookService _webhook = WebhookService();

  // Initialize SMS listener
  Future<void> initializeSmsListener() async {
    // Set up background SMS handler
    telephony.listenIncomingSms(
      onNewMessage: onMessageReceived,
      onBackgroundMessage: onBackgroundMessage,
    );
  }

  // Handle incoming SMS
  Future<void> onMessageReceived(SmsMessage message) async {
    await processSms(
      from: message.address ?? '',
      body: message.body ?? '',
    );
  }

  // Process SMS message
  Future<void> processSms({
    required String from,
    required String body,
  }) async {
    try {
      print('Received SMS from $from: $body');

      // Increment total received counter immediately
      await _storage.incrementTotalReceived();

      // Get settings
      final settings = await _storage.getSettings();

      // Check filters
      if (!settings.shouldProcessNumber(from)) {
        print('Number $from not in filter list, ignoring');
        return;
      }

      if (!settings.shouldProcessMessage(body)) {
        print('Message does not match prefix filter, ignoring');
        return;
      }

      // Validate webhook URL
      if (!settings.isWebhookValid()) {
        print('Invalid webhook URL');
        return;
      }

      print('✅ All checks passed, sending to webhook: ${settings.webhookUrl}');

      // Send to webhook
      final reply = await _webhook.sendToWebhook(
        webhookUrl: settings.webhookUrl,
        from: from,
        body: body,
      );

      print(
          '📨 Webhook response received: ${reply != null ? "\"$reply\"" : "NULL"}');

      if (reply != null && reply.isNotEmpty) {
        print('🚀 Attempting to send SMS reply to $from');

        // Send reply SMS
        await sendSms(
          to: from,
          message: reply,
          subscriptionId: settings.subscriptionId,
        );

        print('✅ SMS sending completed');

        // Increment counter
        await _storage.incrementSmsCounter();

        // Save transaction
        final transaction = SmsTransaction(
          timestamp: DateTime.now().toIso8601String(),
          from: from,
          receivedBody: body,
          sentReply: reply,
        );
        await _storage.saveTransaction(transaction);

        print('SMS processed successfully');
      } else {
        print('No reply from webhook');
      }
    } catch (e) {
      print('Error processing SMS: $e');
    }
  }

  // Platform channel for native SMS sending (fixes Android 8.1.0)
  static const platform = MethodChannel('sms_gateway/sms_sender');

  // Send SMS
  Future<void> sendSms({
    required String to,
    required String message,
    int? subscriptionId,
  }) async {
    try {
      print('📤 [sendSms] Starting SMS send to: $to');
      print('📤 [sendSms] Message: $message');
      print('📤 [sendSms] Message length: ${message.length}');

      // Try native platform channel first (works on Android 8.1.0)
      try {
        print('📤 [sendSms] Using native platform channel...');
        await platform.invokeMethod('sendSms', {
          'phoneNumber': to,
          'message': message,
        });
        print('✅ [sendSms] SMS sent successfully via platform channel');
        return;
      } catch (e) {
        print('⚠️ [sendSms] Platform channel failed: $e');
        print('📤 [sendSms] Falling back to telephony plugin...');
      }

      // Fallback to telephony plugin
      final hasPermission = await telephony.requestSmsPermissions;
      print('📤 [sendSms] SMS Permission granted: $hasPermission');

      if (!hasPermission!) {
        print('❌ [sendSms] SMS permission DENIED - cannot send');
        return;
      }

      print('📤 [sendSms] Calling telephony.sendSms()...');
      await telephony.sendSms(
        to: to,
        message: message,
        isMultipart: message.length > 160,
      );
      print('✅ [sendSms] telephony.sendSms() returned successfully');
    } catch (e, stackTrace) {
      print('❌❌❌ Error sending SMS: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Background message received: ${message.body}');
  final service = SmsService();
  await service.onMessageReceived(message);
}
