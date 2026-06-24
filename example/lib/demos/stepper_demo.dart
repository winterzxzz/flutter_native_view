import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String stepperDemoTitle = 'Liquid Glass Stepper';

Widget buildStepperDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stepper', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassStepper(
          value: 0,
          onChanged: (int v) {},
          min: 0,
          max: 10,
        ),
        const SizedBox(height: 16),
        LiquidGlassStepper(
          value: 5,
          onChanged: (int v) {},
          step: 2,
          min: 0,
          max: 20,
        ),
      ],
    ),
  );
}
