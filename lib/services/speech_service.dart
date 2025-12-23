import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ParsedItem {
  final String name;
  final String? quantity; // Can be a number or "." for ambiguous

  ParsedItem({required this.name, this.quantity});
}

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  
  stt.SpeechToText get speech => _speech;

  bool _isInitialized = false;
  
  // Track if speech recognition is actively listening
  bool get isActivelyListening => _isListening && _speech.isListening;
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      final result = await _speech.initialize(
        onError: (error) {
          // Silently handle errors
        },
        onStatus: (status) {
          // Silently handle status updates
        },
      );
      _isInitialized = result;
      return result;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  bool get isListening => _isListening;

  Future<String?> listen() async {
    if (!await initialize()) {
      return null;
    }

    if (_isListening) {
      await stop();
    }

    String? result;
    _isListening = true;

    await _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          result = val.recognizedWords;
          _isListening = false;
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: false,
      ),
    );

    // Wait for result or timeout
    int attempts = 0;
    while (_isListening && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    return result;
  }

  Future<void> stop() async {
    if (_isListening) {
      try {
        await _speech.stop();
      } catch (e) {
        // Silently handle errors
      } finally {
        _isListening = false;
      }
    } else {
      // Ensure speech is stopped even if state is inconsistent
      try {
        await _speech.stop();
      } catch (e) {
        // Silently handle errors
      }
    }
  }

  Future<void> cancel() async {
    _isListening = false;
    try {
      await _speech.cancel();
    } catch (e) {
      // Silently handle errors
    }
  }
  
  /// Start listening with a callback for results
  /// Returns true if listening started successfully
  Future<bool> startListening({
    required Function(stt.SpeechRecognitionResult) onResult,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 5),
    String localeId = 'en_US',
    bool partialResults = true,
    bool cancelOnError = false,
  }) async {
    if (!await initialize()) {
      return false;
    }
    
    if (_isListening) {
      await stop();
    }
    
    try {
      _isListening = true;
      await _speech.listen(
        onResult: onResult,
        listenFor: listenFor,
        pauseFor: pauseFor,
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: cancelOnError,
          partialResults: partialResults,
        ),
      );
      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  /// Word bank for misunderstood words (speech recognition errors)
  /// Maps commonly misrecognized words to their correct forms
  static final Map<String, String> _wordBank = {
    // Number misunderstandings
    'for': 'four',
    'to': 'two',
    'too': 'two',
    'ate': 'eight',
    'won': 'one',
    'tree': 'three',
    'sicks': 'six',
    'sex': 'six',
    'fife': 'five',
    'nigh': 'nine',
    'twenny': 'twenty',
    'thirteen': 'thirteen',
    'fourteen': 'fourteen',
    'fifteen': 'fifteen',
    'sixteen': 'sixteen',
    'seventeen': 'seventeen',
    'eighteen': 'eighteen',
    'nineteen': 'nineteen',
    'thirty': 'thirty',
    'forty': 'forty',
    'fifty': 'fifty',
    'sixty': 'sixty',
    'seventy': 'seventy',
    'eighty': 'eighty',
    'ninety': 'ninety',
    
    // Common grocery item misunderstandings
    'bred': 'bread',
    'breds': 'bread',
    'cheeze': 'cheese',
    'chiken': 'chicken',
    'chikn': 'chicken',
    'tomatos': 'tomatoes',
    'potatos': 'potatoes',
    'onion': 'onion',
    'onions': 'onions',
  };

  /// Normalize text using word bank to correct misunderstood words
  /// Replaces misunderstood words with their correct forms
  String _normalizeWithWordBank(String text) {
    String result = text;
    
    // Apply word bank corrections using word boundaries to avoid partial matches
    for (final entry in _wordBank.entries) {
      final pattern = RegExp('\\b${RegExp.escape(entry.key)}\\b', caseSensitive: false);
      result = result.replaceAll(pattern, entry.value);
    }
    
    return result;
  }

  /// Parse speech text to extract items and quantities
  /// Handles patterns like "2 apples", "three bananas", "milk", "a dozen eggs", etc.
  /// 
  /// PARSING METHOD:
  /// 1. Normalize: lowercase, trim, replace multiple spaces with single space
  /// 2. Word Bank Correction: Replace misunderstood words (e.g., "for" -> "four", "to" -> "two")
  /// 3. Split by separators: ',', 'and', '&', 'then', 'also' (using word boundaries \b)
  /// 4. For each part:
  ///    - Extract quantity (digits, number words, or special quantities like "a", "dozen")
  ///    - Remaining text becomes item name
  ///    - Capitalize first letter of item name
  /// 5. Return list of ParsedItem objects
  List<ParsedItem> parseSpeechText(String text) {
    final List<ParsedItem> items = [];
    
    // Normalize text: lowercase, remove extra spaces
    String normalized = text.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    // Apply word bank corrections for misunderstood words
    normalized = _normalizeWithWordBank(normalized);
    
    // Split by common separators
    final separators = [',', 'and', '&', 'then', 'also'];
    List<String> parts = [normalized];
    
    for (final sep in separators) {
      List<String> newParts = [];
      for (final part in parts) {
        newParts.addAll(part.split(RegExp('\\b$sep\\b', caseSensitive: false)));
      }
      parts = newParts;
    }
    
    // Process each part
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      
      // Try to extract quantity and item name
      final quantityMatch = _extractQuantity(trimmed);
      String? quantity = quantityMatch['quantity'];
      String itemName = quantityMatch['remaining'] as String;
      
      // Clean up item name and capitalize first letter
      itemName = itemName.trim();
      if (itemName.isEmpty) continue;
      
      // Capitalize first letter
      if (itemName.isNotEmpty) {
        itemName = itemName[0].toUpperCase() + itemName.substring(1);
      }
      
      // If quantity is ambiguous or not found, use "."
      if (quantity == null || quantity.isEmpty) {
        quantity = '.';
      }
      
      items.add(ParsedItem(name: itemName, quantity: quantity));
    }
    
    return items;
  }
  
  /// Parse a single item from text (for incremental parsing)
  /// Returns a list of items found in the text (usually 1, but can be multiple if separators are present)
  /// 
  /// PARSING METHOD:
  /// 1. Normalize: lowercase, trim, replace multiple spaces with single space
  /// 2. Word Bank Correction: Replace misunderstood words (e.g., "for" -> "four", "to" -> "two")
  /// 3. Split by separators: ',', 'and', '&', 'then', 'also' (using word boundaries \b)
  /// 4. For each part:
  ///    - Extract quantity (digits, number words, or special quantities like "a", "dozen")
  ///    - Remaining text becomes item name
  ///    - Capitalize first letter of item name
  /// 5. Return list of ParsedItem objects
  List<ParsedItem> parseSingleItem(String text) {
    // Normalize text: lowercase, remove extra spaces
    String normalized = text.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    if (normalized.isEmpty) {
      return [];
    }
    
    // Apply word bank corrections for misunderstood words
    normalized = _normalizeWithWordBank(normalized);
    
    // Split by common separators to handle "2 apples and 3 bananas"
    final separators = [',', 'and', '&', 'then', 'also'];
    List<String> parts = [normalized];
    
    for (final sep in separators) {
      List<String> newParts = [];
      for (final part in parts) {
        newParts.addAll(part.split(RegExp('\\b$sep\\b', caseSensitive: false)));
      }
      parts = newParts;
    }
    
    final List<ParsedItem> items = [];
    
    // Process each part
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      
      // Try to extract quantity and item name
      final quantityMatch = _extractQuantity(trimmed);
      String? quantity = quantityMatch['quantity'];
      String itemName = quantityMatch['remaining'] as String;
      
      // Clean up item name and capitalize first letter
      itemName = itemName.trim();
      if (itemName.isEmpty) continue;
      
      // Capitalize first letter
      if (itemName.isNotEmpty) {
        itemName = itemName[0].toUpperCase() + itemName.substring(1);
      }
      
      // If quantity is ambiguous or not found, use "."
      if (quantity == null || quantity.isEmpty) {
        quantity = '.';
      }
      
      items.add(ParsedItem(name: itemName, quantity: quantity));
    }
    
    return items;
  }

  Map<String, String?> _extractQuantity(String text) {
    // Number words to digits mapping
    final numberWords = {
      'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
      'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9',
      'ten': '10', 'eleven': '11', 'twelve': '12', 'thirteen': '13',
      'fourteen': '14', 'fifteen': '15', 'sixteen': '16', 'seventeen': '17',
      'eighteen': '18', 'nineteen': '19', 'twenty': '20', 'thirty': '30',
      'forty': '40', 'fifty': '50', 'sixty': '60', 'seventy': '70',
      'eighty': '80', 'ninety': '90', 'hundred': '100',
    };
    
    // Special quantity words
    final specialQuantities = {
      'a': '1', 'an': '1', 'a couple': '2', 'a few': '.',
      'some': '.', 'several': '.', 'many': '.', 'lots': '.',
      'dozen': '12', 'half dozen': '6',
    };
    
    String remaining = text;
    String? quantity;
    
    // Check for special quantities first
    for (final entry in specialQuantities.entries) {
      if (text.toLowerCase().startsWith('${entry.key} ')) {
        quantity = entry.value;
        remaining = text.substring(entry.key.length).trim();
        break;
      }
    }
    
    // If not found, try to find numeric patterns
    if (quantity == null) {
      // Try to match digits at the start
      final digitMatch = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(text);
      if (digitMatch != null) {
        quantity = digitMatch.group(1) ?? '';
        remaining = text.substring(digitMatch.end).trim();
      } else {
        // Try to match number words
        for (final entry in numberWords.entries) {
          final pattern = RegExp('^${entry.key}\\s+', caseSensitive: false);
          if (pattern.hasMatch(text)) {
            quantity = entry.value;
            remaining = text.replaceFirst(pattern, '').trim();
            break;
          }
        }
      }
    }
    
    // If still no quantity found, check for "a" or "an" at the start
    if (quantity == null) {
      final aMatch = RegExp(r'^(a|an)\s+', caseSensitive: false).firstMatch(text);
      if (aMatch != null) {
        quantity = '1';
        remaining = text.substring(aMatch.end).trim();
      }
    }
    
    return {'quantity': quantity, 'remaining': remaining};
  }
}

