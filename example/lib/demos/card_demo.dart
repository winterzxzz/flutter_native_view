import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

Widget buildCardDemo() => const CardDemo();

class CardDemo extends StatefulWidget {
  const CardDemo({super.key});
  @override
  State<CardDemo> createState() => _CardDemoState();
}

class _CardDemoState extends State<CardDemo> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _agree = false;
  bool _news = true;
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Cards',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'LiquidGlassCard frames content; LiquidGlassLabeledSwitch is a setting row.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          LiquidGlassCard(
            tint: const Color(0xFF0A84FF),
            onTap: () => setState(() => _taps++),
            child: Row(
              children: <Widget>[
                const Icon(Icons.touch_app, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tappable card · tapped $_taps',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          LiquidGlassCard(
            tint: const Color(0xFF30D158),
            child: Column(
              children: <Widget>[
                LiquidGlassLabeledSwitch(
                  label: 'Wi-Fi',
                  value: _wifi,
                  onChanged: (bool v) => setState(() => _wifi = v),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Divider(color: Colors.white24),
                LiquidGlassLabeledSwitch(
                  label: 'Bluetooth',
                  value: _bluetooth,
                  onChanged: (bool v) => setState(() => _bluetooth = v),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          LiquidGlassCard(
            tint: const Color(0xFFFF9F0A),
            child: Column(
              children: <Widget>[
                _checkRow('I agree to the terms', _agree,
                    (bool v) => setState(() => _agree = v)),
                const SizedBox(height: 12),
                _checkRow('Send me product news', _news,
                    (bool v) => setState(() => _news = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: <Widget>[
        LiquidGlassCheckbox(value: value, onChanged: onChanged),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    );
  }
}
