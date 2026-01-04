import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_transaction.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _keyFilterNumbers = 'filter_numbers';
  static const String _keyPrefixFilter = 'prefix_filter';
  static const String _keyWebhookUrl = 'webhook_url';
  static const String _keySmsCounter = 'sms_counter';
  static const String _keySubscriptionId = 'subscription_id';
  static const String _keyTransactions = 'transactions';
  static const String _keyLastResetDate = 'last_reset_date';
  static const String _keyServiceRunning = 'service_running';

  // Save filter numbers
  Future<void> saveFilterNumbers(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFilterNumbers, numbers);
  }

  // Get filter numbers
  Future<List<String>> getFilterNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFilterNumbers) ?? [];
  }

  // Save prefix filter
  Future<void> savePrefixFilter(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrefixFilter, prefix);
  }

  // Get prefix filter
  Future<String> getPrefixFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrefixFilter) ?? '';
  }

  // Save webhook URL
  Future<void> saveWebhookUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWebhookUrl, url);
  }

  // Get webhook URL
  Future<String> getWebhookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWebhookUrl) ?? '';
  }

  static const String _keyTotalReceived = 'total_received';

  // ... (existing keys)

  // Save SMS counter
  Future<void> saveSmsCounter(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySmsCounter, count);
  }

  // Get SMS counter
  Future<int> getSmsCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySmsCounter) ?? 0;
  }

  // Increment SMS counter
  Future<int> incrementSmsCounter() async {
    final currentCount = await getSmsCounter();
    final newCount = currentCount + 1;
    await saveSmsCounter(newCount);
    return newCount;
  }

  // Save Total Received counter
  Future<void> saveTotalReceived(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalReceived, count);
  }

  // Get Total Received counter
  Future<int> getTotalReceived() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalReceived) ?? 0;
  }

  // Increment Total Received counter
  Future<int> incrementTotalReceived() async {
    final currentCount = await getTotalReceived();
    final newCount = currentCount + 1;
    await saveTotalReceived(newCount);
    return newCount;
  }

  // Reset SMS counter
  Future<void> resetSmsCounter() async {
    await saveSmsCounter(0);
    await saveTotalReceived(0); // Reset both checks
  }

  // Save subscription ID
  Future<void> saveSubscriptionId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySubscriptionId, id);
  }

  // Get subscription ID
  Future<int?> getSubscriptionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySubscriptionId);
  }

  // Save transaction
  Future<void> saveTransaction(SmsTransaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();

    // Add new transaction at the beginning
    transactions.insert(0, transaction);

    // Keep only last 5 transactions
    if (transactions.length > 5) {
      transactions.removeRange(5, transactions.length);
    }

    // Convert to JSON and save
    final jsonList = transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_keyTransactions, jsonList);
  }

  // Get transactions
  Future<List<SmsTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyTransactions) ?? [];

    return jsonList.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      return SmsTransaction.fromJson(json);
    }).toList();
  }

  // Clear all transactions
  Future<void> clearTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTransactions);
  }

  // Save last reset date
  Future<void> saveLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastResetDate, date.toIso8601String());
  }

  // Get last reset date
  Future<DateTime?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastResetDate);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  // Save service running state
  Future<void> saveServiceRunning(bool isRunning) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyServiceRunning, isRunning);
  }

  // Get service running state
  Future<bool> getServiceRunning() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyServiceRunning) ?? false;
  }

  // Get all settings
  Future<AppSettings> getSettings() async {
    final filterNumbers = await getFilterNumbers();
    final prefixFilter = await getPrefixFilter();
    final webhookUrl = await getWebhookUrl();
    final subscriptionId = await getSubscriptionId();

    return AppSettings(
      filterNumbers: filterNumbers,
      prefixFilter: prefixFilter,
      webhookUrl: webhookUrl,
      subscriptionId: subscriptionId,
    );
  }

  // Save all settings
  Future<void> saveSettings(AppSettings settings) async {
    await saveFilterNumbers(settings.filterNumbers);
    await savePrefixFilter(settings.prefixFilter);
    await saveWebhookUrl(settings.webhookUrl);
    if (settings.subscriptionId != null) {
      await saveSubscriptionId(settings.subscriptionId!);
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
