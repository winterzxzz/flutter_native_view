import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String stepperDemoTitle = 'Liquid Glass Stepper';

Widget buildStepperDemo() => const StepperDemo();

class StepperDemo extends StatefulWidget {
  const StepperDemo({super.key});
  @override
  State<StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<StepperDemo> {
  int _a = 0;
  int _b = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stepper', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Text('Value: $_a', style: const TextStyle(color: Colors.white70)),
          LiquidGlassStepper(
            value: _a,
            onChanged: (int v) => setState(() => _a = v),
            min: 0,
            max: 10,
          ),
          const SizedBox(height: 16),
          Text('Value: $_b (step 2)', style: const TextStyle(color: Colors.white70)),
          LiquidGlassStepper(
            value: _b,
            onChanged: (int v) => setState(() => _b = v),
            step: 2,
            min: 0,
            max: 20,
          ),
        ],
      ),
    );
  }
}
