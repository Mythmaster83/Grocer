import 'package:isar/isar.dart';

part 'list_item.g.dart';

@collection
class ListItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String listName; // Which list this item belongs to

  late String name;
  late bool bought;
  late int quantity;
  
  // Image path for item (downloaded from Pexels)
  String? imagePath;

  ListItem({
    this.id = Isar.autoIncrement,
    required this.listName,
    required this.name,
    this.bought = false,
    this.quantity = 1,
    this.imagePath,
  });
}

