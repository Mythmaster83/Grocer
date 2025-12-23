import 'package:flutter/material.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';

class DuplicateListDialog {
  static Future<String?> show(
    BuildContext context,
    String listName,
    bool isStockList,
  ) async {
    String? result;
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => ValueListenableBuilder<double>(
        valueListenable: PreferencesService.textSize,
        builder: (context, textSize, _) => ValueListenableBuilder<bool>(
          valueListenable: PreferencesService.isDarkMode,
          builder: (context, isDarkMode, _) => Opacity(
            opacity: 1.0,
            child: AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
            title: Text('List Already Exists', style: TextStyleHelper.h4()),
            content: Text(
              'A ${isStockList ? 'stock' : 'shopping'} list named "$listName" already exists. What would you like to do?',
              style: TextStyleHelper.body(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  result = null; // Cancel
                },
                child: Text('Cancel', style: TextStyleHelper.body()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  result = 'rename'; // Rename
                },
                child: Text('Rename', style: TextStyleHelper.body()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  result = 'replace'; // Replace
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Replace', style: TextStyleHelper.body()),
              ),
            ],
            ),
          ),
        ),
      ),
    );
    return result;
  }
}

