import 'package:flutter/widgets.dart';
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

      // Send to webhook
      final reply = await _webhook.sendToWebhook(
        webhookUrl: settings.webhookUrl,
        from: from,
        body: body,
      );

      if (reply != null && reply.isNotEmpty) {
        // Send reply SMS
        await sendSms(
          to: from,
          message: reply,
          subscriptionId: settings.subscriptionId,
        );

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

  // Send SMS
  Future<void> sendSms({
    required String to,
    required String message,
    int? subscriptionId,
  }) async {
    try {
      // Send SMS using specific SIM or default
      if (subscriptionId != null) {
        await telephony.sendSmsByDefaultApp(
          to: to,
          message: message,
        );
      } else {
        await telephony.sendSms(
          to: to,
          message: message,
        );
      }
      print('SMS sent to $to: $message');
    } catch (e) {
      print('Error sending SMS: $e');
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
