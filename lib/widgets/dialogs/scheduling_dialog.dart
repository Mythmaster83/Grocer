import 'package:flutter/material.dart';
import 'package:grocer_app/models/grocery_list.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';

class SchedulingDialog extends StatefulWidget {
  final GroceryList? list;
  final Function(GroceryList) onSave;

  const SchedulingDialog({
    super.key,
    this.list,
    required this.onSave,
  });

  @override
  State<SchedulingDialog> createState() => _SchedulingDialogState();
}

class _SchedulingDialogState extends State<SchedulingDialog> {
  ScheduleFrequency? _frequency;
  DateTime? _selectedDate;
  int? _selectedDayOfWeek;

  @override
  void initState() {
    super.initState();
    if (widget.list != null) {
      _frequency = widget.list!.frequency;
      _selectedDate = widget.list!.scheduledDate;
      _selectedDayOfWeek = widget.list!.dayOfWeek;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_frequency == ScheduleFrequency.once || _frequency == null) {
          _selectedDayOfWeek = picked.weekday;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => Opacity(
          opacity: 1.0,
          child: AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('Schedule Shopping', style: TextStyleHelper.h4()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frequency:', style: TextStyleHelper.bodyBold()),
              const SizedBox(height: 8),
              ...ScheduleFrequency.values.map((freq) => RadioListTile<ScheduleFrequency>(
                title: Text(
                  _getFrequencyLabel(freq),
                  style: TextStyleHelper.body(),
                ),
                value: freq,
                groupValue: _frequency,
                onChanged: (value) {
                  setState(() {
                    _frequency = value;
                    if (value == ScheduleFrequency.once && _selectedDate == null) {
                      _selectedDate = DateTime.now();
                    }
                  });
                },
              )),
              const SizedBox(height: 16),
              if (_frequency != null) ...[
                if (_frequency == ScheduleFrequency.once) ...[
                  Text('Date:', style: TextStyleHelper.bodyBold()),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select date',
                      style: TextStyleHelper.body(),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                ] else ...[
                  Text('Day of Week:', style: TextStyleHelper.bodyBold()),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _selectedDayOfWeek,
                    isExpanded: true,
                    items: List.generate(7, (index) {
                      final day = index + 1;
                      return DropdownMenuItem(
                        value: day,
                        child: Text(_getDayName(day), style: TextStyleHelper.body()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedDayOfWeek = value;
                        // Calculate next occurrence of this day
                        final now = DateTime.now();
                        final today = now.weekday;
                        int daysUntil = (value! - today) % 7;
                        if (daysUntil == 0) daysUntil = 7;
                        _selectedDate = now.add(Duration(days: daysUntil));
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Start Date:', style: TextStyleHelper.bodyBold()),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select start date',
                      style: TextStyleHelper.body(),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyleHelper.body()),
          ),
          TextButton(
            onPressed: _frequency == null
                ? null
                : () {
                    final list = widget.list ?? GroceryList(
                      name: '',
                      isStockList: false,
                    );
                    list.frequency = _frequency;
                    list.scheduledDate = _selectedDate;
                    list.dayOfWeek = _selectedDayOfWeek;
                    widget.onSave(list);
                    Navigator.pop(context);
                  },
            child: Text('Save', style: TextStyleHelper.body()),
          ),
        ],
        ),
          ),
        ),
      );
  }

  String _getFrequencyLabel(ScheduleFrequency freq) {
    switch (freq) {
      case ScheduleFrequency.once:
        return 'Once (Single Date)';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.biweekly:
        return 'Biweekly (Every 2 weeks)';
      case ScheduleFrequency.monthly:
        return 'Monthly';
    }
  }

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }
}

