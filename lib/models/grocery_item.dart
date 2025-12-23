import 'package:isar/isar.dart';

part 'grocery_item.g.dart';

@collection
class GroceryItem {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount; // allow fractional amounts (e.g. 1.5 kg)
  late String unit; // 'cans', 'packets', 'kg', etc.
  late bool isPurchased;
  
  DateTime? expiry; // optional expiry for stock items

  GroceryItem({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.amount,
    required this.unit,
    this.isPurchased = false,
    this.expiry,
  });

  @override
  String toString() => '$name: $amount $unit${expiry != null ? " (exp ${expiry!.toIso8601String()})" : ""}';
}
