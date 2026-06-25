import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

Widget buildTextFieldDemo() => const TextFieldDemo();

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});
  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  String _name = '';
  String _password = '';
  String _submitted = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Ambient glow orbs
        Positioned(
          top: 80,
          right: -40,
          child: _GlowOrb(
            color: const Color(0xFF0A84FF),
            size: 180,
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: _GlowOrb(
            color: const Color(0xFF6C63FF),
            size: 220,
          ),
        ),
        Positioned(
          top: 260,
          left: MediaQuery.of(context).size.width * 0.3,
          child: _GlowOrb(
            color: const Color(0xFF5E5CE6),
            size: 140,
          ),
        ),

        // Main content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A84FF).withValues(alpha: 0.3),
                        const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.text_fields_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Text Field',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Native glass text input with\nplaceholder and secure entry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Glass card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Full name field
                          _GlassFieldLabel(label: 'Full name'),
                          const SizedBox(height: 8),
                          LiquidGlassTextField(
                            text: _name,
                            placeholder: 'Full name',
                            tint: const Color(0xFF0A84FF),
                            onChanged: (String v) => setState(() => _name = v),
                            onSubmitted: (String v) => setState(() => _submitted = v),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          _GlassFieldLabel(label: 'Password'),
                          const SizedBox(height: 8),
                          LiquidGlassTextField(
                            text: _password,
                            placeholder: 'Password',
                            obscureText: true,
                            onChanged: (String v) => setState(() => _password = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status pills
                if (_name.isNotEmpty || _password.isNotEmpty || _submitted.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      if (_name.isNotEmpty)
                        _StatusPill(
                          icon: Icons.person_outline,
                          label: _name,
                        ),
                      if (_password.isNotEmpty)
                        _StatusPill(
                          icon: Icons.lock_outline,
                          label: '${_password.length} chars',
                        ),
                      if (_submitted.isNotEmpty)
                        _StatusPill(
                          icon: Icons.check_circle_outline,
                          label: 'Sent',
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _GlassFieldLabel extends StatelessWidget {
  final String label;

  const _GlassFieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
