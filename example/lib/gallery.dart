import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import 'weather/injection.dart';
import 'weather/weather_app.dart';

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Glass Native v1')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Text(
            'Real SwiftUI controls on iOS, stable Material fallbacks elsewhere.',
          ),
          const SizedBox(height: 20),
          _GalleryTile(
            title: 'V1 control gallery',
            subtitle: 'Typed styles, live theme changes, and diagnostics',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const _ControlGallery()),
            ),
          ),
          const SizedBox(height: 12),
          _GalleryTile(
            title: 'Weather example',
            subtitle: 'Existing domain example migrated to the v1 controls',
            onTap: () {
              configureWeatherDependencies();
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WeatherApp()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

enum _ForecastPeriod { day, week, month }

class _ControlGallery extends StatefulWidget {
  const _ControlGallery();

  @override
  State<_ControlGallery> createState() => _ControlGalleryState();
}

class _ControlGalleryState extends State<_ControlGallery> {
  static const Color _purple = Color(0xFF6C63FF);
  static const Color _blue = Color(0xFF0A84FF);

  late final TextEditingController _searchController;
  late final LiquidGlassDiagnostics _diagnostics;
  bool _alternateTheme = false;
  bool _switchValue = true;
  bool _checkboxValue = false;
  double _sliderValue = 0.4;
  int _stepperValue = 2;
  _ForecastPeriod _period = _ForecastPeriod.day;
  DateTime _date = DateTime.now();
  Color _color = _purple;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _diagnostics = LiquidGlassDiagnostics(
      onEvent: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color tint = _alternateTheme ? _blue : _color;
    final LiquidGlassDiagnosticsSnapshot metrics = _diagnostics.snapshot;
    return LiquidGlassTheme(
      diagnostics: _diagnostics,
      data: LiquidGlassThemeData(
        style: LiquidGlassStyle(
          tint: tint,
          shape: const LiquidGlassShape.roundedRectangle(cornerRadius: 16),
        ),
        controlStyle: LiquidGlassControlStyle(
          tintColor: tint,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('V1 controls'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Change live theme',
              onPressed: () =>
                  setState(() => _alternateTheme = !_alternateTheme),
              icon: const Icon(Icons.palette_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'Bridge counts: ${metrics.viewsCreated} views · '
              '${metrics.configUpdates} updates · '
              '${metrics.nativeEvents} events · '
              '${metrics.intrinsicMeasurements} measurements',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Buttons'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                LiquidGlassButton(
                  label: 'Continue',
                  leadingSymbol: const LiquidGlassSymbol(
                    'arrow.right',
                    fallbackIcon: Icons.arrow_forward,
                  ),
                  onPressed: () {},
                ),
                LiquidGlassButton.prominent(label: 'Primary', onPressed: () {}),
                LiquidGlassButton.icon(
                  symbol: const LiquidGlassSymbol(
                    'heart.fill',
                    fallbackIcon: Icons.favorite,
                  ),
                  semanticLabel: 'Favorite',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            LiquidGlassButtonGroup(
              items: <LiquidGlassButtonItem>[
                LiquidGlassButtonItem(
                  id: 'back',
                  symbol: const LiquidGlassSymbol(
                    'chevron.left',
                    fallbackIcon: Icons.chevron_left,
                  ),
                  semanticLabel: 'Back',
                  onPressed: () {},
                ),
                LiquidGlassButtonItem(
                  id: 'share',
                  label: 'Share',
                  symbol: const LiquidGlassSymbol(
                    'square.and.arrow.up',
                    fallbackIcon: Icons.ios_share,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionTitle('Controls'),
            Row(
              children: <Widget>[
                LiquidGlassSwitch(
                  value: _switchValue,
                  semanticLabel: 'Notifications',
                  onChanged: (bool value) =>
                      setState(() => _switchValue = value),
                ),
                const SizedBox(width: 20),
                LiquidGlassCheckbox(
                  value: _checkboxValue,
                  semanticLabel: 'Agree to terms',
                  onChanged: (bool value) =>
                      setState(() => _checkboxValue = value),
                ),
              ],
            ),
            LiquidGlassSlider(
              value: _sliderValue,
              semanticLabel: 'Volume',
              onChanged: (double value) => setState(() => _sliderValue = value),
            ),
            LiquidGlassStepper(
              value: _stepperValue,
              min: 0,
              max: 10,
              semanticLabel: 'Guests',
              onChanged: (int value) => setState(() => _stepperValue = value),
            ),
            LiquidGlassSegmentedControl<_ForecastPeriod>(
              segments: const <LiquidGlassSegment<_ForecastPeriod>>[
                LiquidGlassSegment(value: _ForecastPeriod.day, label: 'Day'),
                LiquidGlassSegment(value: _ForecastPeriod.week, label: 'Week'),
                LiquidGlassSegment(
                  value: _ForecastPeriod.month,
                  label: 'Month',
                ),
              ],
              value: _period,
              onChanged: (_ForecastPeriod value) =>
                  setState(() => _period = value),
            ),
            const SizedBox(height: 28),
            const _SectionTitle('Input and pickers'),
            LiquidGlassTextField.search(
              controller: _searchController,
              placeholder: 'Search places',
              onSubmitted: (String value) {},
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                LiquidGlassMenu<_ForecastPeriod>(
                  label: 'Period',
                  items: const <LiquidGlassMenuItem<_ForecastPeriod>>[
                    LiquidGlassMenuItem(
                      value: _ForecastPeriod.day,
                      label: 'Day',
                    ),
                    LiquidGlassMenuItem(
                      value: _ForecastPeriod.week,
                      label: 'Week',
                    ),
                    LiquidGlassMenuItem(
                      value: _ForecastPeriod.month,
                      label: 'Month',
                    ),
                  ],
                  onSelected: (_ForecastPeriod value) =>
                      setState(() => _period = value),
                ),
                LiquidGlassDatePicker(
                  value: _date,
                  onChanged: (DateTime value) => setState(() => _date = value),
                ),
                LiquidGlassColorPicker(
                  value: _color,
                  onChanged: (Color value) => setState(() => _color = value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
