import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

/// General demo for the cross-platform shader-based [LiquidGlass] lens.
///
/// Drag the glass pill around to see it refract the colourful backdrop, tap the
/// button to feel the press ripple, and use the sliders to tune the look.
class ShaderGlassDemo extends StatefulWidget {
  const ShaderGlassDemo({super.key});

  @override
  State<ShaderGlassDemo> createState() => _ShaderGlassDemoState();
}

class _ShaderGlassDemoState extends State<ShaderGlassDemo> {
  Offset _lens = const Offset(40, 120);
  double _refraction = 22;
  double _chroma = 4;
  double _radius = 32;
  int _taps = 0;

  LiquidGlassStyle get _style => LiquidGlassStyle(
        borderRadius: _radius,
        refraction: _refraction,
        chromaticAberration: _chroma,
        tintOpacity: 0.08,
        highlight: 0.3,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassView(
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _Backdrop()),

            // Draggable glass pill — the star of the demo.
            Positioned(
              left: _lens.dx,
              top: _lens.dy,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _lens += d.delta),
                child: LiquidGlass(
                  width: 200,
                  height: 120,
                  style: _style,
                  child: const Center(
                    child: Text(
                      'Drag me',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // A tappable circular glass icon button.
            Positioned(
              right: 28,
              top: 120,
              child: LiquidGlass(
                width: 72,
                height: 72,
                style: _style.copyWith(borderRadius: 36),
                onTap: () => setState(() => _taps++),
                child: const Icon(Icons.favorite, color: Colors.white, size: 30),
              ),
            ),

            // Tap counter badge.
            Positioned(
              right: 28,
              top: 200,
              child: Text(
                'Taps: $_taps',
                style: const TextStyle(color: Colors.white70),
              ),
            ),

            // Controls.
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: LiquidGlass(
                style: _style.copyWith(borderRadius: 24, tintOpacity: 0.12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _slider('Refraction', _refraction, 0, 60,
                          (v) => setState(() => _refraction = v)),
                      _slider('Chromatic', _chroma, 0, 12,
                          (v) => setState(() => _chroma = v)),
                      _slider('Corner radius', _radius, 0, 60,
                          (v) => setState(() => _radius = v)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(
      String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

/// A colourful, high-contrast backdrop so the refraction is easy to see.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFF6FD8),
            Color(0xFF3813C2),
            Color(0xFF00C2FF),
            Color(0xFF00FFA3),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 60,
            left: 24,
            child: _blob(160, Colors.yellowAccent.withValues(alpha: 0.6)),
          ),
          Positioned(
            bottom: 160,
            right: 10,
            child: _blob(220, Colors.orangeAccent.withValues(alpha: 0.5)),
          ),
          const Center(
            child: Text(
              'LIQUID\nGLASS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                height: 1.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
