import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String datePickerDemoTitle = 'Liquid Glass Date Picker';

Widget buildDatePickerDemo() => const DatePickerDemo();

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});
  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date Picker', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          LiquidGlassDatePicker(
            value: _date,
            onChanged: (DateTime v) => setState(() => _date = v),
            mode: 'date',
          ),
          const SizedBox(height: 16),
          Text(
            'Selected: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
