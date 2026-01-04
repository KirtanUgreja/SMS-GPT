import 'package:xml/xml.dart' as xml;

class XmlParserService {
  // Parse TwiML XML response and extract message
  String? parseResponse(String xmlString) {
    try {
      // Parse XML
      final document = xml.XmlDocument.parse(xmlString);
      
      // Find <Response><Message> tag
      final responseElement = document.findElements('Response').firstOrNull;
      if (responseElement == null) {
        print('No <Response> element found in XML');
        return null;
      }
      
      final messageElement = responseElement.findElements('Message').firstOrNull;
      if (messageElement == null) {
        print('No <Message> element found in XML');
        return null;
      }
      
      // Extract text content
      final messageText = messageElement.innerText.trim();
      return messageText.isNotEmpty ? messageText : null;
      
    } catch (e) {
      print('Error parsing XML: $e');
      return null;
    }
  }

  // Validate XML structure
  bool isValidTwiML(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final responseElement = document.findElements('Response').firstOrNull;
      return responseElement != null;
    } catch (e) {
      return false;
    }
  }
}
