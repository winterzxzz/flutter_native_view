import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});
  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoSave = true;
  bool _location = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure your preferences using native toggles.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF6C63FF),
              borderRadius: 16,
              child: Column(
                children: [
                  _SwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts and updates',
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  _divider(),
                  _SwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark appearance system-wide',
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                    tint: const Color(0xFF0A84FF),
                  ),
                  _divider(),
                  _SwitchTile(
                    title: 'Auto Save',
                    subtitle: 'Save changes automatically',
                    value: _autoSave,
                    onChanged: (v) => setState(() => _autoSave = v),
                    tint: const Color(0xFF30D158),
                  ),
                  _divider(),
                  _SwitchTile(
                    title: 'Location Services',
                    subtitle: 'Allow access to device location',
                    value: _location,
                    onChanged: (v) => setState(() => _location = v),
                    tint: const Color(0xFFFF9F0A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: Colors.white12),
      );
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? tint;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          LiquidGlassSwitch(
            value: value,
            onChanged: onChanged,
            tint: tint,
          ),
        ],
      ),
    );
  }
}
