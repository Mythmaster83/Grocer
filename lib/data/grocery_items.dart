import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive list of common grocery items for autocomplete suggestions
class GroceryItems {
  static const String _keyCustomItems = 'custom_grocery_items';
  static List<String> _customItems = [];
  
  static const List<String> _defaultItems = [
    // Fruits
    'Apples', 'Bananas', 'Oranges', 'Grapes', 'Strawberries', 'Blueberries',
    'Raspberries', 'Blackberries', 'Mangoes', 'Pineapple', 'Watermelon',
    'Cantaloupe', 'Honeydew', 'Peaches', 'Plums', 'Cherries', 'Pears',
    'Kiwi', 'Avocado', 'Lemons', 'Limes', 'Coconut', 'Papaya',
    
    // Vegetables
    'Lettuce', 'Spinach', 'Kale', 'Arugula', 'Cabbage', 'Broccoli',
    'Cauliflower', 'Carrots', 'Celery', 'Cucumber', 'Tomatoes', 'Peppers',
    'Bell Peppers', 'Onions', 'Garlic', 'Potatoes', 'Sweet Potatoes',
    'Mushrooms', 'Zucchini', 'Squash', 'Eggplant', 'Corn', 'Peas',
    'Green Beans', 'Asparagus', 'Brussels Sprouts', 'Radishes', 'Beets',
    
    // Dairy
    'Milk', 'Cheese', 'Butter', 'Yogurt', 'Sour Cream', 'Cream Cheese',
    'Cottage Cheese', 'Mozzarella', 'Cheddar', 'Swiss Cheese', 'Parmesan',
    'Greek Yogurt', 'Heavy Cream', 'Half and Half', 'Eggs',
    
    // Meat & Seafood
    'Chicken', 'Beef', 'Pork', 'Turkey', 'Salmon', 'Tuna', 'Shrimp',
    'Crab', 'Lobster', 'Cod', 'Tilapia', 'Ground Beef', 'Ground Turkey',
    'Bacon', 'Sausage', 'Ham', 'Hot Dogs', 'Deli Meat',
    
    // Bread & Bakery
    'Bread', 'Bagels', 'English Muffins', 'Croissants', 'Tortillas',
    'Pita Bread', 'Hamburger Buns', 'Hot Dog Buns', 'Dinner Rolls',
    
    // Pantry Staples
    'Rice', 'Pasta', 'Spaghetti', 'Macaroni', 'Flour', 'Sugar', 'Salt',
    'Pepper', 'Olive Oil', 'Vegetable Oil', 'Canola Oil', 'Vinegar',
    'Soy Sauce', 'Worcestershire Sauce', 'Ketchup', 'Mustard', 'Mayonnaise',
    'BBQ Sauce', 'Hot Sauce', 'Honey', 'Maple Syrup', 'Vanilla Extract',
    
    // Canned Goods
    'Canned Tomatoes', 'Tomato Sauce', 'Tomato Paste', 'Beans', 'Black Beans',
    'Kidney Beans', 'Chickpeas', 'Corn', 'Tuna', 'Salmon', 'Soup',
    'Broth', 'Chicken Broth', 'Beef Broth', 'Vegetable Broth',
    
    // Snacks
    'Chips', 'Crackers', 'Cookies', 'Nuts', 'Almonds', 'Peanuts',
    'Cashews', 'Walnuts', 'Pistachios', 'Popcorn', 'Pretzels',
    'Granola Bars', 'Trail Mix', 'Chocolate', 'Candy',
    
    // Beverages
    'Water', 'Juice', 'Orange Juice', 'Apple Juice', 'Coffee', 'Tea',
    'Soda', 'Beer', 'Wine', 'Sports Drinks', 'Energy Drinks',
    
    // Frozen
    'Frozen Vegetables', 'Frozen Fruit', 'Ice Cream', 'Frozen Pizza',
    'Frozen Meals', 'Frozen Chicken', 'Frozen Fish',
    
    // Condiments & Spices
    'Cumin', 'Paprika', 'Oregano', 'Basil', 'Thyme', 'Rosemary',
    'Cinnamon', 'Nutmeg', 'Ginger', 'Turmeric', 'Curry Powder',
    'Chili Powder', 'Red Pepper Flakes', 'Bay Leaves', 'Parsley',
    
    // Other
    'Toilet Paper', 'Paper Towels', 'Napkins', 'Dish Soap', 'Laundry Detergent',
    'Shampoo', 'Conditioner', 'Soap', 'Toothpaste', 'Deodorant',
  ];

  /// Get all items (default + custom)
  static List<String> get items {
    return [..._defaultItems, ..._customItems];
  }

  /// Load custom items from preferences
  static Future<void> loadCustomItems() async {
    final prefs = await SharedPreferences.getInstance();
    final customItemsList = prefs.getStringList(_keyCustomItems);
    if (customItemsList != null) {
      _customItems = customItemsList;
    }
  }

  /// Add a new item to custom items if it doesn't exist
  static Future<void> addItemIfNew(String itemName) async {
    final trimmedName = itemName.trim();
    if (trimmedName.isEmpty) return;
    
    // Check if item already exists (case-insensitive)
    final lowerName = trimmedName.toLowerCase();
    final exists = items.any((item) => item.toLowerCase() == lowerName);
    
    if (!exists) {
      _customItems.add(trimmedName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyCustomItems, _customItems);
    }
  }

  /// Get suggestions based on input text, sorted by relevance
  static List<String> getSuggestions(String input) {
    if (input.isEmpty) return [];
    
    final lowerInput = input.toLowerCase().trim();
    if (lowerInput.isEmpty) return [];
    
    // Score and sort suggestions by relevance
    final scored = items.map((item) {
      final lowerItem = item.toLowerCase();
      int score = 0;
      
      // Exact match gets highest score
      if (lowerItem == lowerInput) {
        score = 1000;
      }
      // Starts with input gets high score
      else if (lowerItem.startsWith(lowerInput)) {
        score = 500 - (lowerItem.length - lowerInput.length); // Shorter matches preferred
      }
      // Contains input gets lower score
      else if (lowerItem.contains(lowerInput)) {
        score = 100 - (lowerItem.length - lowerInput.length); // Shorter matches preferred
      } else {
        return null; // No match
      }
      
      return MapEntry(item, score);
    }).whereType<MapEntry<String, int>>().toList();
    
    // Sort by score (descending), then by length (ascending), then alphabetically
    scored.sort((a, b) {
      if (a.value != b.value) return b.value.compareTo(a.value);
      if (a.key.length != b.key.length) return a.key.length.compareTo(b.key.length);
      return a.key.compareTo(b.key);
    });
    
    return scored.map((e) => e.key).take(10).toList();
  }
}

