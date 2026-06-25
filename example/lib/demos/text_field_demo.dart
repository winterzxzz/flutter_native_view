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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Text Field',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Native glass text input with placeholder and secure entry.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          LiquidGlassTextField(
            text: _name,
            placeholder: 'Full name',
            tint: const Color(0xFF0A84FF),
            onChanged: (String v) => setState(() => _name = v),
            onSubmitted: (String v) => setState(() => _submitted = v),
          ),
          const SizedBox(height: 16),

          LiquidGlassTextField(
            text: _password,
            placeholder: 'Password',
            obscureText: true,
            onChanged: (String v) => setState(() => _password = v),
          ),
          const SizedBox(height: 20),

          Text(
            'Name: $_name\nPassword length: ${_password.length}\nSubmitted: $_submitted',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
