import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String activityIndicatorDemoTitle = 'Liquid Glass Activity Indicator';

Widget buildActivityIndicatorDemo() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Indicator', style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LiquidGlassActivityIndicator(size: 24),
            LiquidGlassActivityIndicator(size: 36, tint: Color(0xFF6C63FF)),
            LiquidGlassActivityIndicator(size: 48, tint: Color(0xFF00C853)),
          ],
        ),
      ],
    ),
  );
}
