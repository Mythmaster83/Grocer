import 'package:flutter/material.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'permission_dialogs/mic_permission_dialog.dart';
import 'parsed_items_widget.dart';

class VoiceInputDialog extends StatefulWidget {
  final bool isStockList;
  final String? existingListName;

  const VoiceInputDialog({
    super.key,
    this.isStockList = false,
    this.existingListName,
  });

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final SpeechService _speechService = SpeechService();
  final ValueNotifier<List<ParsedItem>> _parsedItemsNotifier = ValueNotifier<List<ParsedItem>>([]);
  bool _isListening = false;
  String _statusText = 'Tap the microphone to start';
  bool _isProcessing = false;

  @override
  void dispose() {
    _speechService.cancel();
    _parsedItemsNotifier.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stop();
      
      if (mounted) {
        setState(() {
          _isListening = false;
          final currentItems = _parsedItemsNotifier.value;
          if (currentItems.isEmpty && !_isProcessing) {
            _statusText = 'No items recognized. Tap the microphone to try again.';
          } else if (!_isProcessing) {
            _statusText = 'Recording stopped. Review ${currentItems.length} item(s) below and confirm or record again.';
          }
        });
      }
    } else {
      if (!mounted) return;
      
      // Check if there are existing items
      final currentItems = _parsedItemsNotifier.value;
      bool shouldClearItems = currentItems.isEmpty;
      
      if (currentItems.isNotEmpty) {
        // Show dialog to choose: Start Over or Continue
        if (!mounted) return;
        final choice = await _showRestartDialog(context);
        if (choice == null || !mounted) return;
        
        if (choice == 'start_over') {
          // Clear all items
          _parsedItemsNotifier.value = [];
          shouldClearItems = true;
          if (mounted) {
            setState(() {
              _statusText = 'Tap the microphone to start';
            });
          }
        } else {
          // Continue - keep existing items
          shouldClearItems = false;
        }
      }
      
      final hasPermission = await MicPermissionDialog.checkAndRequestPermission(context);
      
      if (!hasPermission) {
        if (!mounted) return;
        await MicPermissionDialog.show(
          context,
          onGranted: () {
            if (mounted) {
              _startListening(clearItems: shouldClearItems);
            }
          },
          onDenied: () {
            if (mounted) {
              setState(() {
                _statusText = 'Microphone permission is required for voice input.';
              });
            }
          },
        );
        return;
      }

      _startListening(clearItems: shouldClearItems);
    }
  }
  
  Future<String?> _showRestartDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('Continue or Start Over?', style: TextStyleHelper.h4()),
          content: Text(
            'You already have items. Would you like to continue adding items or start over?',
            style: TextStyleHelper.body(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'start_over'),
              child: Text('Start Over', style: TextStyleHelper.body()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'continue'),
              child: Text('Continue', style: TextStyleHelper.body()),
            ),
          ],
        ),
      ),
    );
  }

  void _addParsedItems(List<ParsedItem> newItems) {
    if (newItems.isEmpty) return;
    
    // Get current items and add new ones (avoiding duplicates by name)
    final currentItems = List<ParsedItem>.from(_parsedItemsNotifier.value);
    final existingNames = currentItems.map((item) => item.name.toLowerCase()).toSet();
    
    // Only add items that don't already exist
    final itemsToAdd = newItems.where((item) => 
      !existingNames.contains(item.name.toLowerCase())
    ).toList();
    
    if (itemsToAdd.isNotEmpty) {
      final updatedItems = [...currentItems, ...itemsToAdd];
      _parsedItemsNotifier.value = updatedItems;
    }
  }

  Future<void> _restartListening() async {
    if (!_isListening || !mounted) return;
    
    try {
      final success = await _speechService.startListening(
        onResult: (val) {
          if (val.finalResult) {
            final result = val.recognizedWords.trim();
            if (result.isNotEmpty) {
              // Parse immediately and add items incrementally
              final newItems = _speechService.parseSingleItem(result);
              if (newItems.isNotEmpty) {
                _addParsedItems(newItems);
              }
              
              if (mounted) {
              setState(() {
                  final currentItems = _parsedItemsNotifier.value;
                  _statusText = 'Listening... ${currentItems.length} item(s) recognized. Continue speaking or tap stop when done.';
              });
              }
              
              // Restart listening after a short delay if still active
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_isListening && mounted && !_speechService.isActivelyListening) {
                  _restartListening();
                }
              });
            }
          } else if (val.recognizedWords.isNotEmpty && mounted) {
            setState(() {
              _statusText = 'Listening... "${val.recognizedWords}"';
            });
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
        partialResults: true,
          cancelOnError: false,
      );
      
      if (!success && mounted) {
        setState(() {
          _isListening = false;
          _statusText = 'Failed to restart listening. Tap the microphone to try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusText = 'Error restarting: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _startListening({bool clearItems = true}) async {
    if (!mounted) return;
    
    setState(() {
      _isListening = true;
      _statusText = 'Listening... Speak now';
    });
    
    // Clear previous items only if requested
    if (clearItems) {
      _parsedItemsNotifier.value = [];
    }

    try {
      final success = await _speechService.startListening(
          onResult: (val) {
            if (val.finalResult) {
              final result = val.recognizedWords.trim();
              if (result.isNotEmpty) {
              // Parse immediately and add items incrementally
              final newItems = _speechService.parseSingleItem(result);
              if (newItems.isNotEmpty) {
                _addParsedItems(newItems);
              }
              
              if (mounted) {
                setState(() {
                  final currentItems = _parsedItemsNotifier.value;
                  _statusText = 'Listening... ${currentItems.length} item(s) recognized. Continue speaking or tap stop when done.';
                });
              }
                
              // Restart listening after a short delay if still active
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_isListening && mounted && !_speechService.isActivelyListening) {
                    _restartListening();
                  }
                });
              }
          } else if (val.recognizedWords.isNotEmpty && mounted) {
              setState(() {
                _statusText = 'Listening... "${val.recognizedWords}"';
              });
            }
          },
          listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
          localeId: 'en_US',
        partialResults: true,
            cancelOnError: false,
        );
      
      if (!success && mounted) {
        setState(() {
          _isListening = false;
          _statusText = 'Speech recognition not available. Please check permissions.';
        });
      }
    } catch (e) {
      if (mounted) {
      setState(() {
        _isListening = false;
        _statusText = 'Error initializing speech recognition: ${e.toString()}';
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('Voice Input', style: TextStyleHelper.h4()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_statusText, style: TextStyleHelper.body()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _toggleListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isProcessing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(_isListening ? Icons.stop : Icons.mic),
                      const SizedBox(width: 8),
                      Text(
                        _isProcessing 
                            ? 'Processing...' 
                            : (_isListening ? 'Stop Recording' : 'Click to start listening'),
                        style: TextStyleHelper.body(),
                      ),
                    ],
                  ),
                ),
                // Separate widget that manages its own state
                ParsedItemsWidget(
                  itemsNotifier: _parsedItemsNotifier,
                                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyleHelper.body()),
            ),
            ValueListenableBuilder<List<ParsedItem>>(
              valueListenable: _parsedItemsNotifier,
              builder: (context, items, _) {
                return ElevatedButton(
                  onPressed: items.isEmpty || _isProcessing
                  ? null
                      : () => Navigator.pop(context, items),
              child: Text('Confirm', style: TextStyleHelper.body()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
