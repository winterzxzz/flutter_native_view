import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildDatePickerDemo() => const DatePickerDemo();

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});
  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 3));

  String _format(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  int _nights(DateTime a, DateTime b) => b.difference(a).inDays;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Your Stay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select check-in and check-out dates.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Check-in
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF0A84FF),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LiquidGlassDatePicker(
                      value: _checkIn,
                      onChanged: (DateTime v) =>
                          setState(() => _checkIn = v),
                      mode: 'date',
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _format(_checkIn),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Check-out
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF30D158),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LiquidGlassDatePicker(
                      value: _checkOut,
                      onChanged: (DateTime v) =>
                          setState(() => _checkOut = v),
                      mode: 'date',
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _format(_checkOut),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFFFF9F0A),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total nights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${_nights(_checkIn, _checkOut)} nights',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
