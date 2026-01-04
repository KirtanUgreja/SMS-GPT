class AppSettings {
  final List<String> filterNumbers;
  final String prefixFilter;
  final String webhookUrl;
  final int? subscriptionId;

  AppSettings({
    this.filterNumbers = const [],
    this.prefixFilter = '',
    required this.webhookUrl,
    this.subscriptionId,
  });

  // Validate webhook URL
  bool isWebhookValid() {
    if (webhookUrl.isEmpty) return false;
    try {
      final uri = Uri.parse(webhookUrl);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Check if number should be processed
  bool shouldProcessNumber(String number) {
    if (filterNumbers.isEmpty) return true;
    return filterNumbers.any((filter) => number.contains(filter));
  }

  // Check if message should be processed based on prefix
  bool shouldProcessMessage(String message) {
    if (prefixFilter.isEmpty) return true;
    return message.trim().startsWith(prefixFilter);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'filterNumbers': filterNumbers,
      'prefixFilter': prefixFilter,
      'webhookUrl': webhookUrl,
      'subscriptionId': subscriptionId,
    };
  }

  // Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      filterNumbers: List<String>.from(json['filterNumbers'] ?? []),
      prefixFilter: json['prefixFilter'] ?? '',
      webhookUrl: json['webhookUrl'] ?? '',
      subscriptionId: json['subscriptionId'],
    );
  }

  // Create a copy with updated values
  AppSettings copyWith({
    List<String>? filterNumbers,
    String? prefixFilter,
    String? webhookUrl,
    int? subscriptionId,
  }) {
    return AppSettings(
      filterNumbers: filterNumbers ?? this.filterNumbers,
      prefixFilter: prefixFilter ?? this.prefixFilter,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}
