import 'package:flutter/material.dart';

/// Service to map grocery items to relevant Material icons
class IconMappingService {
  /// Get icon for a grocery item based on its name
  static IconData getItemIcon(String itemName) {
    final name = itemName.toLowerCase().trim();
    
    // Fruits
    if (name.contains('apple')) return Icons.apple;
    if (name.contains('banana')) return Icons.eco;
    if (name.contains('orange') || name.contains('citrus')) return Icons.eco;
    if (name.contains('grape')) return Icons.eco;
    if (name.contains('berry')) return Icons.eco;
    if (name.contains('mango') || name.contains('pineapple') || name.contains('papaya')) return Icons.eco;
    if (name.contains('watermelon') || name.contains('cantaloupe') || name.contains('honeydew')) return Icons.eco;
    if (name.contains('peach') || name.contains('plum') || name.contains('cherry') || name.contains('pear')) return Icons.eco;
    if (name.contains('kiwi') || name.contains('avocado') || name.contains('coconut')) return Icons.eco;
    if (name.contains('lemon') || name.contains('lime')) return Icons.eco;
    
    // Vegetables
    if (name.contains('lettuce') || name.contains('spinach') || name.contains('kale') || name.contains('arugula')) return Icons.eco;
    if (name.contains('cabbage') || name.contains('broccoli') || name.contains('cauliflower')) return Icons.eco;
    if (name.contains('carrot') || name.contains('celery')) return Icons.eco;
    if (name.contains('cucumber') || name.contains('zucchini') || name.contains('squash')) return Icons.eco;
    if (name.contains('tomato') || name.contains('pepper')) return Icons.eco;
    if (name.contains('onion') || name.contains('garlic')) return Icons.eco;
    if (name.contains('potato')) return Icons.eco;
    if (name.contains('mushroom')) return Icons.eco;
    if (name.contains('corn') || name.contains('pea') || name.contains('bean') || name.contains('asparagus')) return Icons.eco;
    if (name.contains('brussels') || name.contains('radish') || name.contains('beet')) return Icons.eco;
    if (name.contains('eggplant')) return Icons.eco;
    
    // Dairy
    if (name.contains('milk')) return Icons.local_drink;
    if (name.contains('cheese')) return Icons.lunch_dining;
    if (name.contains('butter')) return Icons.lunch_dining;
    if (name.contains('yogurt') || name.contains('cream')) return Icons.lunch_dining;
    if (name.contains('egg')) return Icons.egg;
    
    // Meat & Seafood
    if (name.contains('chicken')) return Icons.set_meal;
    if (name.contains('beef') || name.contains('pork') || name.contains('turkey')) return Icons.set_meal;
    if (name.contains('bacon') || name.contains('sausage') || name.contains('ham') || name.contains('hot dog')) return Icons.set_meal;
    if (name.contains('salmon') || name.contains('tuna') || name.contains('fish')) return Icons.set_meal;
    if (name.contains('shrimp') || name.contains('crab') || name.contains('lobster')) return Icons.set_meal;
    if (name.contains('deli')) return Icons.set_meal;
    
    // Bread & Bakery
    if (name.contains('bread') || name.contains('bagel') || name.contains('muffin') || name.contains('croissant')) return Icons.bakery_dining;
    if (name.contains('tortilla') || name.contains('pita') || name.contains('bun') || name.contains('roll')) return Icons.bakery_dining;
    
    // Pantry Staples
    if (name.contains('rice') || name.contains('pasta') || name.contains('spaghetti') || name.contains('macaroni')) return Icons.lunch_dining;
    if (name.contains('flour') || name.contains('sugar') || name.contains('salt') || name.contains('pepper')) return Icons.kitchen;
    if (name.contains('oil') || name.contains('vinegar')) return Icons.local_bar;
    if (name.contains('sauce') || name.contains('ketchup') || name.contains('mustard') || name.contains('mayonnaise')) return Icons.restaurant;
    if (name.contains('honey') || name.contains('syrup') || name.contains('extract')) return Icons.eco;
    
    // Canned Goods
    if (name.contains('can') || name.contains('canned') || name.contains('tin') || name.contains('jar')) return Icons.inventory_2;
    if (name.contains('soup') || name.contains('broth')) return Icons.soup_kitchen;
    
    // Snacks
    if (name.contains('chip') || name.contains('cracker') || name.contains('cookie') || name.contains('pretzel')) return Icons.cookie;
    if (name.contains('nut') || name.contains('almond') || name.contains('peanut') || name.contains('cashew') || name.contains('walnut') || name.contains('pistachio')) return Icons.eco;
    if (name.contains('popcorn') || name.contains('granola') || name.contains('trail mix')) return Icons.eco;
    if (name.contains('chocolate') || name.contains('candy')) return Icons.cake;
    
    // Beverages
    if (name.contains('water')) return Icons.water_drop;
    if (name.contains('juice')) return Icons.local_drink;
    if (name.contains('coffee') || name.contains('tea')) return Icons.local_cafe;
    if (name.contains('soda') || name.contains('drink')) return Icons.local_drink;
    if (name.contains('beer') || name.contains('wine')) return Icons.local_bar;
    
    // Frozen
    if (name.contains('frozen') || name.contains('ice cream') || name.contains('pizza')) return Icons.ac_unit;
    
    // Condiments & Spices
    if (name.contains('spice') || name.contains('cumin') || name.contains('paprika') || name.contains('oregano') || 
        name.contains('basil') || name.contains('thyme') || name.contains('rosemary') || name.contains('cinnamon') ||
        name.contains('nutmeg') || name.contains('ginger') || name.contains('turmeric') || name.contains('curry') ||
        name.contains('chili') || name.contains('pepper flake') || name.contains('bay') || name.contains('parsley')) {
      return Icons.spa;
    }
    
    // Household items
    if (name.contains('toilet paper') || name.contains('paper towel') || name.contains('napkin')) return Icons.cleaning_services;
    if (name.contains('soap') || name.contains('detergent') || name.contains('shampoo') || name.contains('conditioner')) return Icons.cleaning_services;
    if (name.contains('toothpaste') || name.contains('deodorant')) return Icons.cleaning_services;
    
    // Default icon
    return Icons.shopping_bag;
  }
  
  /// Get category icon (for list displays)
  static IconData getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    switch (cat) {
      case 'fruits':
        return Icons.eco;
      case 'vegetables':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.set_meal;
      case 'bread':
      case 'bakery':
        return Icons.bakery_dining;
      case 'pantry':
        return Icons.kitchen;
      case 'canned goods':
        return Icons.inventory_2;
      case 'snacks':
        return Icons.cookie;
      case 'beverages':
        return Icons.local_drink;
      case 'frozen':
        return Icons.ac_unit;
      case 'spices':
        return Icons.spa;
      default:
        return Icons.shopping_bag;
    }
  }
}

