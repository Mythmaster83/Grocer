import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Database of units for grocery items
class ItemUnits {
  static const String _keyCustomUnits = 'custom_item_units';
  static Map<String, String> _customUnits = {};
  
  // Default units for common items
  static final Map<String, String> _defaultUnits = {
    // Fruits
    'Apples': '1 lb',
    'Bananas': '1 lb',
    'Oranges': '1 lb',
    'Grapes': '1 lb',
    'Strawberries': '1 lb',
    'Blueberries': '1 lb',
    'Raspberries': '1 lb',
    'Blackberries': '1 lb',
    'Mangoes': '1 lb',
    'Pineapple': '1 unit',
    'Watermelon': '1 unit',
    'Cantaloupe': '1 unit',
    'Honeydew': '1 unit',
    'Peaches': '1 lb',
    'Plums': '1 lb',
    'Cherries': '1 lb',
    'Pears': '1 lb',
    'Kiwi': '1 lb',
    'Avocado': '1 unit',
    'Lemons': '1 lb',
    'Limes': '1 lb',
    'Coconut': '1 unit',
    'Papaya': '1 unit',
    
    // Vegetables
    'Lettuce': '1 head',
    'Spinach': '1 bag',
    'Kale': '1 bunch',
    'Arugula': '1 bag',
    'Cabbage': '1 head',
    'Broccoli': '1 lb',
    'Cauliflower': '1 head',
    'Carrots': '1 lb',
    'Celery': '1 bunch',
    'Cucumber': '1 unit',
    'Tomatoes': '1 lb',
    'Peppers': '1 lb',
    'Bell Peppers': '1 unit',
    'Onions': '1 lb',
    'Garlic': '1 bulb',
    'Potatoes': '1 lb',
    'Sweet Potatoes': '1 lb',
    'Mushrooms': '1 lb',
    'Zucchini': '1 lb',
    'Squash': '1 unit',
    'Eggplant': '1 unit',
    'Corn': '1 ear',
    'Peas': '1 lb',
    'Green Beans': '1 lb',
    'Asparagus': '1 bunch',
    'Brussels Sprouts': '1 lb',
    'Radishes': '1 bunch',
    'Beets': '1 lb',
    
    // Dairy
    'Milk': '1 gallon',
    'Cheese': '1 lb',
    'Butter': '1 lb',
    'Yogurt': '1 container',
    'Sour Cream': '1 container',
    'Cream Cheese': '1 package',
    'Cottage Cheese': '1 container',
    'Mozzarella': '1 lb',
    'Cheddar': '1 lb',
    'Swiss Cheese': '1 lb',
    'Parmesan': '1 container',
    'Greek Yogurt': '1 container',
    'Heavy Cream': '1 pint',
    'Half and Half': '1 pint',
    'Eggs': '1 dozen',
    
    // Meat & Seafood
    'Chicken': '1 lb',
    'Beef': '1 lb',
    'Pork': '1 lb',
    'Turkey': '1 lb',
    'Salmon': '1 lb',
    'Tuna': '1 lb',
    'Shrimp': '1 lb',
    'Crab': '1 lb',
    'Lobster': '1 lb',
    'Cod': '1 lb',
    'Tilapia': '1 lb',
    'Ground Beef': '1 lb',
    'Ground Turkey': '1 lb',
    'Bacon': '1 package',
    'Sausage': '1 lb',
    'Ham': '1 lb',
    'Hot Dogs': '1 package',
    'Deli Meat': '1 lb',
    
    // Bread & Bakery
    'Bread': '1 loaf',
    'Bagels': '1 package',
    'English Muffins': '1 package',
    'Croissants': '1 package',
    'Tortillas': '1 package',
    'Pita Bread': '1 package',
    'Hamburger Buns': '1 package',
    'Hot Dog Buns': '1 package',
    'Dinner Rolls': '1 package',
    
    // Pantry Staples
    'Rice': '1 lb',
    'Pasta': '1 lb',
    'Spaghetti': '1 lb',
    'Macaroni': '1 lb',
    'Flour': '1 lb',
    'Sugar': '1 lb',
    'Salt': '1 container',
    'Pepper': '1 container',
    'Olive Oil': '1 bottle',
    'Vegetable Oil': '1 bottle',
    'Canola Oil': '1 bottle',
    'Vinegar': '1 bottle',
    'Soy Sauce': '1 bottle',
    'Worcestershire Sauce': '1 bottle',
    'Ketchup': '1 bottle',
    'Mustard': '1 bottle',
    'Mayonnaise': '1 jar',
    'BBQ Sauce': '1 bottle',
    'Hot Sauce': '1 bottle',
    'Honey': '1 jar',
    'Maple Syrup': '1 bottle',
    'Vanilla Extract': '1 bottle',
    
    // Canned Goods
    'Canned Tomatoes': '1 can',
    'Tomato Sauce': '1 can',
    'Tomato Paste': '1 can',
    'Beans': '1 can',
    'Black Beans': '1 can',
    'Kidney Beans': '1 can',
    'Chickpeas': '1 can',
    'Canned Corn': '1 can',
    'Canned Tuna': '1 can',
    'Canned Salmon': '1 can',
    'Soup': '1 can',
    'Broth': '1 can',
    'Chicken Broth': '1 can',
    'Beef Broth': '1 can',
    'Vegetable Broth': '1 can',
    
    // Snacks
    'Chips': '1 bag',
    'Crackers': '1 box',
    'Cookies': '1 package',
    'Nuts': '1 bag',
    'Almonds': '1 bag',
    'Peanuts': '1 bag',
    'Cashews': '1 bag',
    'Walnuts': '1 bag',
    'Pistachios': '1 bag',
    'Popcorn': '1 bag',
    'Pretzels': '1 bag',
    'Granola Bars': '1 box',
    'Trail Mix': '1 bag',
    'Chocolate': '1 bar',
    'Candy': '1 package',
    
    // Beverages
    'Water': '1 bottle',
    'Juice': '1 bottle',
    'Orange Juice': '1 bottle',
    'Apple Juice': '1 bottle',
    'Coffee': '1 bag',
    'Tea': '1 box',
    'Soda': '1 bottle',
    'Beer': '1 pack',
    'Wine': '1 bottle',
    'Sports Drinks': '1 bottle',
    'Energy Drinks': '1 can',
    
    // Frozen
    'Frozen Vegetables': '1 bag',
    'Frozen Fruit': '1 bag',
    'Ice Cream': '1 container',
    'Frozen Pizza': '1 unit',
    'Frozen Meals': '1 package',
    'Frozen Chicken': '1 bag',
    'Frozen Fish': '1 bag',
    
    // Condiments & Spices
    'Cumin': '1 container',
    'Paprika': '1 container',
    'Oregano': '1 container',
    'Basil': '1 container',
    'Thyme': '1 container',
    'Rosemary': '1 container',
    'Cinnamon': '1 container',
    'Nutmeg': '1 container',
    'Ginger': '1 container',
    'Turmeric': '1 container',
    'Curry Powder': '1 container',
    'Chili Powder': '1 container',
    'Red Pepper Flakes': '1 container',
    'Bay Leaves': '1 container',
    'Parsley': '1 container',
    
    // Other
    'Toilet Paper': '1 package',
    'Paper Towels': '1 package',
    'Napkins': '1 package',
    'Dish Soap': '1 bottle',
    'Laundry Detergent': '1 bottle',
    'Shampoo': '1 bottle',
    'Conditioner': '1 bottle',
    'Soap': '1 bar',
    'Toothpaste': '1 tube',
    'Deodorant': '1 container',
  };

  /// Load custom units from preferences
  static Future<void> loadCustomUnits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customUnitsJson = prefs.getString(_keyCustomUnits);
      if (customUnitsJson != null) {
        final decoded = json.decode(customUnitsJson) as Map<String, dynamic>;
        _customUnits = decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      // Ignore loading errors
    }
  }

  /// Capitalize first letter of string
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  /// Get unit for an item (case-insensitive)
  /// Returns just the unit name (e.g., "lb", "unit", "bottle") without quantity
  static String getUnit(String itemName) {
    // Capitalize first letter
    final capitalized = capitalizeFirst(itemName);
    
    String unitString;
    
    // Check custom units first
    if (_customUnits.containsKey(capitalized)) {
      unitString = _customUnits[capitalized]!;
    } else {
      // Check default units (case-insensitive)
      final lowerName = capitalized.toLowerCase();
      unitString = '1 unit'; // Default fallback
      for (final entry in _defaultUnits.entries) {
        if (entry.key.toLowerCase() == lowerName) {
          unitString = entry.value;
          break;
        }
      }
    }
    
    // Extract unit name (remove leading number and space)
    // e.g., "1 lb" -> "lb", "1 unit" -> "unit"
    final parts = unitString.trim().split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return unitString;
  }

  /// Get unit with proper singular/plural form based on quantity
  /// If quantity is 1, returns singular form with (s) if applicable (e.g., "lb(s)")
  /// If quantity > 1, returns plural form (e.g., "lbs")
  static String getUnitWithPlural(String itemName, int quantity) {
    final unit = getUnit(itemName);
    
    // Handle common pluralizations
    if (quantity == 1) {
      // For singular, add (s) if it's a unit that can be pluralized
      // Check if unit is a common pluralizable unit (ends with 's' or is a weight/measure unit)
      if (unit.endsWith('s') && unit.length > 1 && !unit.endsWith('(s)')) {
        // Remove trailing 's' and add '(s)'
        final singular = unit.substring(0, unit.length - 1);
        return '$singular(s)';
      }
      // For units that don't end with 's', check if they should have (s)
      // Common units that should pluralize: lb, oz, kg, g, etc.
      final pluralizableUnits = ['lb', 'oz', 'kg', 'g', 'cup', 'tbsp', 'tsp', 'piece', 'item'];
      if (pluralizableUnits.contains(unit.toLowerCase())) {
        return '$unit(s)';
      }
      return unit;
    } else {
      // For plural, ensure it ends with 's' if it doesn't already
      if (unit.endsWith('(s)')) {
        // Remove '(s)' and add 's'
        return '${unit.substring(0, unit.length - 3)}s';
      }
      if (!unit.endsWith('s')) {
        return '${unit}s';
      }
      return unit;
    }
  }

  /// Set unit for an item
  static Future<void> setUnit(String itemName, String unit) async {
    final capitalized = capitalizeFirst(itemName);
    _customUnits[capitalized] = unit;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCustomUnits, json.encode(_customUnits));
    } catch (e) {
      // Ignore saving errors
    }
  }

  /// Get pluralized unit for an item
  /// If item has designated unit (lbs, kg, gal, liters, cans): use that unit
  /// If no designated unit: return plural form of item name
  static String getPluralizedUnit(String itemName, int quantity) {
    final unit = getUnit(itemName);
    
    // Check if unit is a designated unit (not "unit")
    final designatedUnits = ['lb', 'lbs', 'kg', 'g', 'oz', 'gal', 'gallon', 'liter', 'liters', 'l', 'ml', 'can', 'cans', 'bottle', 'bottles', 'package', 'packages', 'container', 'containers', 'bag', 'bags', 'box', 'boxes', 'dozen', 'head', 'bunch', 'ear', 'bulb', 'loaf', 'pint', 'jar', 'tube', 'bar'];
    final unitLower = unit.toLowerCase();
    
    // If unit is a designated unit, use it with proper pluralization
    if (designatedUnits.contains(unitLower) || unitLower != 'unit') {
      return getUnitWithPlural(itemName, quantity);
    }
    
    // No designated unit - pluralize the item name
    return _pluralizeItemName(itemName, quantity);
  }

  /// Pluralize an item name based on quantity
  static String _pluralizeItemName(String itemName, int quantity) {
    if (quantity == 1) {
      return itemName; // Singular
    }
    
    final name = itemName.trim();
    if (name.isEmpty) return name;
    
    final lowerName = name.toLowerCase();
    
    // Handle items already ending in 's', 'x', 'z', 'ch', 'sh'
    if (lowerName.endsWith('s') || lowerName.endsWith('x') || 
        lowerName.endsWith('z') || lowerName.endsWith('ch') || 
        lowerName.endsWith('sh')) {
      return name; // Already plural
    }
    
    // Handle items ending in 'y' preceded by a consonant
    if (lowerName.endsWith('y') && lowerName.length > 1) {
      final secondLast = lowerName[lowerName.length - 2];
      if (!_isVowel(secondLast)) {
        // Change 'y' to 'ies'
        return '${name.substring(0, name.length - 1)}ies';
      }
    }
    
    // Handle items ending in 'f' or 'fe'
    if (lowerName.endsWith('fe')) {
      return '${name.substring(0, name.length - 2)}ves';
    }
    if (lowerName.endsWith('f') && !lowerName.endsWith('ff')) {
      return '${name.substring(0, name.length - 1)}ves';
    }
    
    // Default: add 's'
    return '${name}s';
  }

  /// Check if character is a vowel
  static bool _isVowel(String char) {
    return ['a', 'e', 'i', 'o', 'u'].contains(char.toLowerCase());
  }
}

