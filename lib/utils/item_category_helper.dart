/// Helper to determine item category (moved from ImageLookupService)
class ItemCategoryHelper {
  /// Food categories list
  static const List<String> foodCategories = [
    'Fruits',
    'Vegetables',
    'Meat',
    'Dairy',
    'Grains',
    'Snacks',
    'Beverages',
    'Frozen Foods',
    'Canned Goods',
    'Bread & Bakery',
    'Pantry Staples',
    'Condiments & Spices',
  ];

  /// Determine item category based on name
  static String getItemCategory(String itemName) {
    final name = itemName.toLowerCase();
    
    // Fruits
    if (name.contains('fruit') || name.contains('apple') || 
        name.contains('banana') || name.contains('orange') ||
        name.contains('grape') || name.contains('strawberr') ||
        name.contains('blueberr') || name.contains('mango') ||
        name.contains('pineapple') || name.contains('watermelon') ||
        name.contains('peach') || name.contains('pear') ||
        name.contains('kiwi') || name.contains('avocado') ||
        name.contains('lemon') || name.contains('lime') ||
        name.contains('cherry') || name.contains('plum') ||
        name.contains('coconut') || name.contains('papaya')) {
      return 'Fruits';
    }
    
    // Vegetables
    if (name.contains('vegetable') || name.contains('lettuce') ||
        name.contains('spinach') || name.contains('kale') ||
        name.contains('carrot') || name.contains('tomato') ||
        name.contains('cucumber') || name.contains('pepper') ||
        name.contains('onion') || name.contains('potato') ||
        name.contains('broccoli') || name.contains('cauliflower') ||
        name.contains('mushroom') || name.contains('corn') ||
        name.contains('celery') || name.contains('cabbage') ||
        name.contains('zucchini') || name.contains('squash') ||
        name.contains('eggplant') || name.contains('peas') ||
        name.contains('green bean') || name.contains('asparagus') ||
        name.contains('brussels sprout') || name.contains('radish') ||
        name.contains('beet') || name.contains('garlic')) {
      return 'Vegetables';
    }
    
    // Meat & Seafood
    if (name.contains('meat') || name.contains('chicken') ||
        name.contains('beef') || name.contains('pork') ||
        name.contains('turkey') || name.contains('salmon') ||
        name.contains('tuna') || name.contains('shrimp') ||
        name.contains('crab') || name.contains('lobster') ||
        name.contains('fish') || name.contains('cod') ||
        name.contains('tilapia') || name.contains('ground beef') ||
        name.contains('ground turkey') || name.contains('bacon') ||
        name.contains('sausage') || name.contains('ham') ||
        name.contains('hot dog') || name.contains('deli meat')) {
      return 'Meat';
    }
    
    // Dairy
    if (name.contains('dairy') || name.contains('milk') ||
        name.contains('cheese') || name.contains('butter') ||
        name.contains('yogurt') || name.contains('sour cream') ||
        name.contains('cream cheese') || name.contains('cottage cheese') ||
        name.contains('mozzarella') || name.contains('cheddar') ||
        name.contains('swiss cheese') || name.contains('parmesan') ||
        name.contains('greek yogurt') || name.contains('heavy cream') ||
        name.contains('half and half') || name.contains('egg')) {
      return 'Dairy';
    }
    
    // Bread & Bakery
    if (name.contains('bread') || name.contains('bagel') ||
        name.contains('croissant') || name.contains('tortilla') ||
        name.contains('pita') || name.contains('hamburger bun') ||
        name.contains('hot dog bun') || name.contains('dinner roll') ||
        name.contains('english muffin') || name.contains('muffin') ||
        name.contains('cake') || name.contains('cookie') ||
        name.contains('pastry') || name.contains('donut')) {
      return 'Bread & Bakery';
    }
    
    // Grains
    if (name.contains('rice') || name.contains('pasta') ||
        name.contains('spaghetti') || name.contains('macaroni') ||
        name.contains('quinoa') || name.contains('barley') ||
        name.contains('oats') || name.contains('cereal') ||
        name.contains('flour') || name.contains('wheat')) {
      return 'Grains';
    }
    
    // Snacks
    if (name.contains('chip') || name.contains('cracker') ||
        name.contains('cookie') || name.contains('nut') ||
        name.contains('almond') || name.contains('peanut') ||
        name.contains('cashew') || name.contains('walnut') ||
        name.contains('pistachio') || name.contains('popcorn') ||
        name.contains('pretzel') || name.contains('granola bar') ||
        name.contains('trail mix') || name.contains('chocolate') ||
        name.contains('candy')) {
      return 'Snacks';
    }
    
    // Beverages
    if (name.contains('water') || name.contains('juice') ||
        name.contains('coffee') || name.contains('tea') ||
        name.contains('soda') || name.contains('beer') ||
        name.contains('wine') || name.contains('sports drink') ||
        name.contains('energy drink') || name.contains('beverage')) {
      return 'Beverages';
    }
    
    // Frozen Foods
    if (name.contains('frozen') || name.contains('ice cream') ||
        name.contains('frozen pizza') || name.contains('frozen meal')) {
      return 'Frozen Foods';
    }
    
    // Canned Goods
    if (name.contains('can') || name.contains('canned') || 
        name.contains('tin') || name.contains('jar') ||
        name.contains('bean') || name.contains('soup') ||
        name.contains('broth')) {
      return 'Canned Goods';
    }
    
    // Pantry Staples
    if (name.contains('sugar') || name.contains('salt') ||
        name.contains('pepper') || name.contains('oil') ||
        name.contains('vinegar') || name.contains('soy sauce') ||
        name.contains('honey') || name.contains('maple syrup') ||
        name.contains('vanilla extract')) {
      return 'Pantry Staples';
    }
    
    // Condiments & Spices
    if (name.contains('ketchup') || name.contains('mustard') ||
        name.contains('mayonnaise') || name.contains('bbq sauce') ||
        name.contains('hot sauce') || name.contains('cumin') ||
        name.contains('paprika') || name.contains('oregano') ||
        name.contains('basil') || name.contains('thyme') ||
        name.contains('rosemary') || name.contains('cinnamon') ||
        name.contains('nutmeg') || name.contains('ginger') ||
        name.contains('turmeric') || name.contains('curry') ||
        name.contains('chili powder') || name.contains('red pepper flake') ||
        name.contains('bay leaf') || name.contains('parsley')) {
      return 'Condiments & Spices';
    }
    
    // Clothing
    if (name.contains('shoe') || name.contains('sock') ||
        name.contains('shirt') || name.contains('pant') ||
        name.contains('underwear') || name.contains('bra') ||
        name.contains('jacket') || name.contains('coat') ||
        name.contains('dress') || name.contains('skirt') ||
        name.contains('hat') || name.contains('cap') ||
        name.contains('glove') || name.contains('scarf') ||
        name.contains('belt') || name.contains('tie') ||
        name.contains('accessory') || name.contains('jewelry')) {
      return 'Clothing';
    }
    
    // Cleaning
    if (name.contains('detergent') || name.contains('soap') ||
        name.contains('cleaning') || name.contains('paper towel') ||
        name.contains('toilet paper') || name.contains('napkin') ||
        name.contains('dish soap') || name.contains('laundry') ||
        name.contains('bleach') || name.contains('disinfectant') ||
        name.contains('sponge') || name.contains('wipe') ||
        name.contains('trash bag') || name.contains('garbage bag')) {
      return 'Cleaning';
    }
    
    // Utility
    if (name.contains('tool') || name.contains('battery') ||
        name.contains('light bulb') || name.contains('bulb') ||
        name.contains('hardware') || name.contains('screw') ||
        name.contains('nail') || name.contains('tape') ||
        name.contains('rope') || name.contains('cord') ||
        name.contains('extension cord') || name.contains('adapter') ||
        name.contains('charger') || name.contains('cable')) {
      return 'Utility';
    }
    
    // Personal Care
    if (name.contains('shampoo') || name.contains('conditioner') ||
        name.contains('toothpaste') || name.contains('toothbrush') ||
        name.contains('deodorant') || name.contains('antiperspirant') ||
        name.contains('lotion') || name.contains('cream') ||
        name.contains('cosmetic') || name.contains('makeup') ||
        name.contains('razor') || name.contains('shaving') ||
        name.contains('tissue') || name.contains('cotton') ||
        name.contains('bandage') || name.contains('medicine') ||
        name.contains('vitamin') || name.contains('supplement') ||
        name.contains('health product')) {
      return 'Personal Care';
    }
    
    // Furniture
    if (name.contains('chair') || name.contains('table') || 
        name.contains('sofa') || name.contains('bed') ||
        name.contains('desk') || name.contains('cabinet') ||
        name.contains('shelf') || name.contains('drawer') ||
        name.contains('couch') || name.contains('ottoman')) {
      return 'Furniture';
    }
    
    // Default to Misc for unrecognized items
    return 'Misc';
  }
  
  /// Check if a category is a food category
  static bool isFoodItem(String category) {
    return foodCategories.contains(category);
  }
}
