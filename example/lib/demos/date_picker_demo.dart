import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String datePickerDemoTitle = 'Liquid Glass Date Picker';

Widget buildDatePickerDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date Picker', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassDatePicker(
          value: DateTime.now(),
          onChanged: (DateTime v) {},
          mode: 'date',
        ),
      ],
    ),
  );
}
