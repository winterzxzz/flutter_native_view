import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlassGallery(),
    );
  }
}

class GlassGallery extends StatefulWidget {
  const GlassGallery({super.key});

  @override
  State<GlassGallery> createState() => _GlassGalleryState();
}

class _GlassGalleryState extends State<GlassGallery> {
  bool _switchOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // A colorful backdrop so the glass has something to refract.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF7F00FF), Color(0xFFE100FF), Color(0xFFFF8C00)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Heading-style button.
                LiquidGlassButton.heading(
                  onPressed: () {},
                  child: const Text(
                    'Liquid Glass',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Regular glass button.
                LiquidGlassButton(
                  onPressed: () {},
                  child: const Text(
                    'Tap me',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
                const SizedBox(height: 24),

                // Generic wrapper around arbitrary content.
                LiquidGlass(
                  style: const GlassStyle(cornerRadius: 24),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.bolt, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Any widget, wrapped',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Native glass switch.
                LiquidGlassSwitch(
                  value: _switchOn,
                  onChanged: (bool v) => setState(() => _switchOn = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
