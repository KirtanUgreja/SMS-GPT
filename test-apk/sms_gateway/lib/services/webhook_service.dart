import 'package:http/http.dart' as http;
import 'xml_parser_service.dart';

class WebhookService {
  final XmlParserService _xmlParser = XmlParserService();

  // Send SMS data to webhook and get TwiML response
  Future<String?> sendToWebhook({
    required String webhookUrl,
    required String from,
    required String body,
  }) async {
    try {
      // Prepare form data (Twilio-compatible format)
      final formData = {
        'From': from,
        'Body': body,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse TwiML XML response
        final xmlResponse = response.body;
        print('Webhook response: $xmlResponse');
        
        final message = _xmlParser.parseResponse(xmlResponse);
        return message;
      } else {
        print('Webhook error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending to webhook: $e');
      return null;
    }
  }

  // Validate webhook URL
  bool isValidWebhookUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
