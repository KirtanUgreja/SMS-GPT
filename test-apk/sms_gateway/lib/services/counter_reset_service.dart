import 'storage_service.dart';

class CounterResetService {
  final StorageService _storage = StorageService();

  // Check if counter should be reset (new day)
  Future<void> checkAndResetIfNeeded() async {
    final lastResetDate = await _storage.getLastResetDate();
    final now = DateTime.now();

    if (lastResetDate == null) {
      // First time - set today as last reset
      await _storage.saveLastResetDate(now);
      return;
    }

    // Check if we're on a different day
    if (!_isSameDay(lastResetDate, now)) {
      await resetCounter();
    }
  }

  // Reset counter to 0
  Future<void> resetCounter() async {
    await _storage.resetSmsCounter();
    await _storage.saveLastResetDate(DateTime.now());
    print('Counter reset to 0');
  }

  // Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
