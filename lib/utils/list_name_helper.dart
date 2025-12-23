/// Helper class to manage list names with markers to distinguish
/// between grocery and stock lists with the same name
class ListNameHelper {
  static const String _groceryPrefix = 'GROCERY:';
  static const String _stockPrefix = 'STOCK:';

  /// Get the marked list name for internal storage
  static String getMarkedName(String name, bool isStockList) {
    return isStockList ? '$_stockPrefix$name' : '$_groceryPrefix$name';
  }

  /// Get the display name (without marker) from a marked name
  static String getDisplayName(String markedName) {
    if (markedName.startsWith(_groceryPrefix)) {
      return markedName.substring(_groceryPrefix.length);
    } else if (markedName.startsWith(_stockPrefix)) {
      return markedName.substring(_stockPrefix.length);
    }
    // If no marker, return as-is (for backward compatibility)
    return markedName;
  }

  /// Check if a marked name is a stock list
  static bool isStockListFromName(String markedName) {
    return markedName.startsWith(_stockPrefix);
  }

  /// Get the marked name for a list given its display name and type
  static String getMarkedNameForList(String displayName, bool isStockList) {
    return getMarkedName(displayName, isStockList);
  }
}

