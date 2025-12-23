import 'package:flutter/foundation.dart';

/// Service to trigger homepage refresh when schedules change
class HomeRefreshService {
  static final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);
  
  static ValueNotifier<int> get refreshNotifier => _refreshNotifier;
  
  /// Trigger a homepage refresh
  static void refresh() {
    _refreshNotifier.value = _refreshNotifier.value + 1;
  }
}

