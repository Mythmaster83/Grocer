/// Helper to determine average calories for one unit of an item
class ItemCaloriesHelper {
  /// Get average calories per unit based on item name
  /// Returns a range string like "50-70" or "100" for single values
  static String getAvgCalories(String itemName) {
    final name = itemName.toLowerCase();
    
    // Fruits (per piece/unit)
    if (name.contains('apple')) return '80-100';
    if (name.contains('banana')) return '90-110';
    if (name.contains('orange')) return '60-80';
    if (name.contains('grape')) return '60-80';
    if (name.contains('strawberr')) return '30-50';
    if (name.contains('blueberr')) return '40-60';
    if (name.contains('mango')) return '100-120';
    if (name.contains('pineapple')) return '80-100';
    if (name.contains('watermelon')) return '40-60';
    if (name.contains('peach')) return '60-80';
    if (name.contains('pear')) return '80-100';
    if (name.contains('kiwi')) return '40-60';
    if (name.contains('avocado')) return '240-280';
    if (name.contains('lemon') || name.contains('lime')) return '15-20';
    if (name.contains('fruit')) return '50-80';
    
    // Vegetables (per unit or per serving)
    if (name.contains('lettuce') || name.contains('spinach') || name.contains('kale')) return '5-10';
    if (name.contains('carrot')) return '25-30';
    if (name.contains('tomato')) return '20-25';
    if (name.contains('cucumber')) return '15-20';
    if (name.contains('pepper') || name.contains('bell pepper')) return '20-30';
    if (name.contains('onion')) return '40-50';
    if (name.contains('potato') || name.contains('sweet potato')) return '100-150';
    if (name.contains('broccoli') || name.contains('cauliflower')) return '30-40';
    if (name.contains('mushroom')) return '15-20';
    if (name.contains('corn')) return '60-80';
    if (name.contains('vegetable')) return '20-40';
    
    // Dairy (per unit)
    if (name.contains('milk')) return '120-150';
    if (name.contains('cheese')) return '70-100';
    if (name.contains('butter')) return '100-120';
    if (name.contains('yogurt')) return '100-150';
    if (name.contains('egg')) return '70-80';
    if (name.contains('cream')) return '50-60';
    if (name.contains('dairy')) return '100-150';
    
    // Meat & Seafood (per 100g or per unit)
    if (name.contains('chicken')) return '165-200';
    if (name.contains('beef')) return '250-300';
    if (name.contains('pork')) return '240-280';
    if (name.contains('turkey')) return '160-190';
    if (name.contains('salmon')) return '200-230';
    if (name.contains('tuna')) return '120-150';
    if (name.contains('shrimp')) return '85-100';
    if (name.contains('fish')) return '100-200';
    if (name.contains('meat')) return '200-250';
    
    // Bread & Bakery
    if (name.contains('bread')) return '70-90';
    if (name.contains('bagel')) return '250-300';
    if (name.contains('croissant')) return '230-280';
    if (name.contains('tortilla')) return '60-80';
    
    // Pantry Staples
    if (name.contains('rice')) return '130-150';
    if (name.contains('pasta')) return '130-150';
    if (name.contains('flour')) return '110-130';
    if (name.contains('sugar')) return '15-20';
    if (name.contains('oil')) return '120-130';
    
    // Canned Goods
    if (name.contains('can') || name.contains('canned')) return '50-100';
    if (name.contains('bean')) return '100-120';
    
    // Default
    return '50-100';
  }
  
  /// Get calories as a formatted string for display
  static String getCaloriesDisplay(String itemName) {
    final calories = getAvgCalories(itemName);
    return '$calories cal';
  }
}

