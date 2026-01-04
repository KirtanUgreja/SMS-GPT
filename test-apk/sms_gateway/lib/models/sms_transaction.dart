class SmsTransaction {
  final String timestamp;
  final String from;
  final String receivedBody;
  final String sentReply;

  SmsTransaction({
    required this.timestamp,
    required this.from,
    required this.receivedBody,
    required this.sentReply,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'from': from,
      'receivedBody': receivedBody,
      'sentReply': sentReply,
    };
  }

  // Create from JSON
  factory SmsTransaction.fromJson(Map<String, dynamic> json) {
    return SmsTransaction(
      timestamp: json['timestamp'] ?? '',
      from: json['from'] ?? '',
      receivedBody: json['receivedBody'] ?? '',
      sentReply: json['sentReply'] ?? '',
    );
  }

  @override
  String toString() {
    return 'SmsTransaction{timestamp: $timestamp, from: $from, receivedBody: $receivedBody, sentReply: $sentReply}';
  }
}
