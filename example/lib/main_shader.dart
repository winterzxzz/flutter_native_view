import 'package:flutter/material.dart';

import 'demos/shader_glass_demo.dart';

/// Standalone entry for the shader Liquid Glass demo.
/// Run with: `flutter run -t lib/main_shader.dart`
void main() => runApp(const ShaderGlassApp());

class ShaderGlassApp extends StatelessWidget {
  const ShaderGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const ShaderGlassDemo(),
    );
  }
}
