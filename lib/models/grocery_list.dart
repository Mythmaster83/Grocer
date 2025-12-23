import 'package:isar/isar.dart';

part 'grocery_list.g.dart';

enum ScheduleFrequency {
  once,      // Single date
  weekly,    // Weekly
  biweekly,  // Every 2 weeks
  monthly,   // Monthly
}

@collection
class GroceryList {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late bool isStockList; // true for stock lists, false for shopping lists

  // Image path for list cover (set once on creation)
  String? imagePath;

  // Scheduling fields (only for shopping lists)
  DateTime? scheduledDate; // For single date or next occurrence
  @Enumerated(EnumType.name)
  ScheduleFrequency? frequency; // null = no schedule, once/weekly/biweekly/monthly
  int? dayOfWeek; // 1-7 (Monday-Sunday) for recurring schedules
  bool isCompleted = false; // Whether shopping is completed
  DateTime? lastCompletedDate; // When the list was last marked as completed

  GroceryList({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.isStockList,
    this.imagePath,
    this.scheduledDate,
    this.frequency,
    this.dayOfWeek,
    this.isCompleted = false,
    this.lastCompletedDate,
  });

  // Calculate next shopping date based on schedule
  DateTime? getNextShoppingDate() {
    if (isStockList || frequency == null) return scheduledDate;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (scheduledDate == null) return null;
    
    DateTime nextDate = scheduledDate!;
    
    // If it's a recurring schedule and we've passed the date, calculate next occurrence
    if (frequency != null && frequency != ScheduleFrequency.once && nextDate.isBefore(today)) {
      switch (frequency!) {
        case ScheduleFrequency.weekly:
          while (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
            nextDate = nextDate.add(const Duration(days: 7));
          }
          break;
        case ScheduleFrequency.biweekly:
          while (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
            nextDate = nextDate.add(const Duration(days: 14));
          }
          break;
        case ScheduleFrequency.monthly:
          while (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          }
          break;
        case ScheduleFrequency.once:
          break;
      }
    }
    
    return nextDate;
  }
}

