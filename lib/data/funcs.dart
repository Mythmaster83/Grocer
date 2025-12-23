import '../services/database_service.dart';

Future<void> deleteList(String listType, String title, bool isStockList) async {
  // Delete the list and all its items
  await DatabaseService.deleteGroceryList(title, isStockList);
}
