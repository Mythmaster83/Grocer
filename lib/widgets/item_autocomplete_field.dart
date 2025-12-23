import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/grocery_items.dart';
import '../utils/text_style_helper.dart';
import '../services/preferences_service.dart';

class ItemAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSubmitted;

  const ItemAutocompleteField({
    super.key,
    required this.controller,
    this.hintText = 'Item name',
    this.onSubmitted,
  });

  @override
  State<ItemAutocompleteField> createState() => _ItemAutocompleteFieldState();
}

class _ItemAutocompleteFieldState extends State<ItemAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<String> _hintNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> _showSuggestionsNotifier = ValueNotifier<bool>(false);
  List<String> _allCurrentSuggestions = []; // Track all suggestions including best match

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hintNotifier.dispose();
    _suggestionsNotifier.dispose();
    _showSuggestionsNotifier.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      _hintNotifier.value = '';
      _suggestionsNotifier.value = [];
      _showSuggestionsNotifier.value = false;
      return;
    }

    final allSuggestions = GroceryItems.getSuggestions(text);
    _allCurrentSuggestions = allSuggestions; // Store all suggestions for later checking
    
    if (allSuggestions.isEmpty) {
      _hintNotifier.value = '';
      _suggestionsNotifier.value = [];
      _showSuggestionsNotifier.value = false;
      return;
    }

    // Best match is the first suggestion (most similar)
    final bestMatch = allSuggestions.first;
    // Remove the matching part from hint to show only the completion
    final hintText = text.length < bestMatch.length
        ? bestMatch.substring(text.length)
        : '';
    
    _hintNotifier.value = hintText;

    // Other suggestions (excluding the best match)
    final otherSuggestions = allSuggestions.skip(1).toList();
    
    _suggestionsNotifier.value = otherSuggestions;
    _showSuggestionsNotifier.value = _focusNode.hasFocus && otherSuggestions.isNotEmpty;
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _showSuggestionsNotifier.value = false;
    } else if (widget.controller.text.isNotEmpty) {
      // Re-evaluate suggestions when focus is regained
      _onTextChanged();
    }
  }

  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.collapsed(offset: suggestion.length);
    _focusNode.unfocus();
    _showSuggestionsNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Full-screen barrier when suggestions are shown
        ValueListenableBuilder<bool>(
          valueListenable: _showSuggestionsNotifier,
          builder: (context, showSuggestions, _) {
            if (!showSuggestions) return const SizedBox.shrink();
            return Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                  _showSuggestionsNotifier.value = false;
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            );
          },
        ),
        // TextField with inline completion hint overlay
        ValueListenableBuilder<String>(
          valueListenable: _hintNotifier,
          builder: (context, hintText, _) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: TextStyleHelper.body(),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyleHelper.body(color: Colors.grey),
                  ),
                  onSubmitted: (String value) async {
                    final trimmedValue = value.trim();
                    if (trimmedValue.isNotEmpty) {
                      // Check if the submitted value is not in the current suggestions
                      final lowerValue = trimmedValue.toLowerCase();
                      final isInSuggestions = _allCurrentSuggestions.any(
                        (suggestion) => suggestion.toLowerCase() == lowerValue,
                      );
                      
                      // If not in suggestions, add it to the list
                      if (!isInSuggestions) {
                        await GroceryItems.addItemIfNew(trimmedValue);
                      }
                    }
                    widget.onSubmitted?.call(value);
                  },
                ),
                // Inline completion hint overlay
                if (hintText.isNotEmpty && widget.controller.text.isNotEmpty && _focusNode.hasFocus)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16,
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            text: widget.controller.text,
                            style: TextStyleHelper.body().copyWith(
                              color: Colors.transparent,
                            ),
                            children: [
                              TextSpan(
                                text: hintText,
                                style: TextStyleHelper.body().copyWith(
                                  color: PreferencesService.isDarkMode.value
                                      ? Colors.white38
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Suggestions list - separate widget with independent state
        SuggestionsColumn(
          suggestionsNotifier: _suggestionsNotifier,
          showNotifier: _showSuggestionsNotifier,
          onSelect: _selectSuggestion,
        ),
      ],
    );
  }
}

/// Separate widget for suggestions column that manages its own state
class SuggestionsColumn extends StatelessWidget {
  final ValueNotifier<List<String>> suggestionsNotifier;
  final ValueNotifier<bool> showNotifier;
  final Function(String) onSelect;

  const SuggestionsColumn({
    super.key,
    required this.suggestionsNotifier,
    required this.showNotifier,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    // Completely opaque background
    final backgroundColor = isDarkMode 
        ? Colors.grey[900]!
        : Colors.grey[200]!;

    return ValueListenableBuilder<bool>(
      valueListenable: showNotifier,
      builder: (context, showSuggestions, _) {
        if (!showSuggestions) return const SizedBox.shrink();
        
        return ValueListenableBuilder<List<String>>(
          valueListenable: suggestionsNotifier,
          builder: (context, suggestions, _) {
            if (suggestions.isEmpty) return const SizedBox.shrink();
            
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Barrier to prevent clicks behind suggestions
                Positioned.fill(
                  top: 56 + 200, // Start barrier below the suggestions box
                  child: GestureDetector(
                    onTap: () {
                      // This will be handled by the parent widget
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                // Suggestions box
                Positioned(
                  top: 56, // Position below TextField
                  left: 0,
                  right: 0,
                  child: Material(
                    color: backgroundColor, // Ensure Material is fully opaque
                    elevation: 8, // Higher elevation to ensure it's above other elements
                    borderRadius: BorderRadius.circular(8),
                    type: MaterialType.card, // Explicit material type
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 200.0,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor, // Fully opaque background
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  debugPrint('[ItemAutocompleteField] Suggestion tapped: "$suggestion"');
                                  onSelect(suggestion);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  child: Text(
                                    suggestion,
                                    style: TextStyleHelper.small(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
