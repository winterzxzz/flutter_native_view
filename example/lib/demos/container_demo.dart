import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String containerDemoTitle = 'Liquid Glass Container';

Widget buildContainerDemo() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Glass Container', style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 120,
          child: Stack(
            children: [
              LiquidGlassContainer(tint: Color(0xFF6C63FF), borderRadius: 24),
              Center(
                child: Text(
                  'Content on top of glass',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
