import 'package:flutter/material.dart';

import 'demos/activity_indicator_demo.dart';
import 'demos/button_demo.dart';
import 'demos/card_demo.dart';
import 'demos/color_picker_demo.dart';
import 'demos/container_demo.dart';
import 'demos/date_picker_demo.dart';
import 'demos/menu_demo.dart';
import 'demos/navigation_bar_demo.dart';
import 'demos/progress_view_demo.dart';
import 'demos/search_bar_demo.dart';
import 'demos/segmented_demo.dart';
import 'demos/slider_demo.dart';
import 'demos/stepper_demo.dart';
import 'demos/switch_demo.dart';
import 'demos/tab_bar_demo.dart';
import 'demos/text_field_demo.dart';
import 'demos/toolbar_demo.dart';

typedef DemoBuilder = Widget Function();

class DemoEntry {
  const DemoEntry(this.title, this.builder);
  final String title;
  final DemoBuilder builder;
}

final List<DemoEntry> demos = <DemoEntry>[
  DemoEntry('ActivityIndicator', () => buildActivityIndicatorDemo()),
  DemoEntry('Buttons', () => const ButtonDemo()),
  DemoEntry('Card', () => buildCardDemo()),
  DemoEntry('ColorPicker', () => buildColorPickerDemo()),
  DemoEntry('Container', () => buildContainerDemo()),
  DemoEntry('DatePicker', () => buildDatePickerDemo()),
  DemoEntry('Menu', () => const MenuDemo()),
  DemoEntry('NavigationBar', () => buildNavigationBarDemo()),
  DemoEntry('ProgressView', () => buildProgressViewDemo()),
  DemoEntry('SearchBar', () => const SearchBarDemo()),
  DemoEntry('SegmentedControl', () => const SegmentedDemo()),
  DemoEntry('Slider', () => buildSliderDemo()),
  DemoEntry('Stepper', () => buildStepperDemo()),
  DemoEntry('Switch', () => const SwitchDemo()),
  DemoEntry('TabBar', () => buildTabBarDemo()),
  DemoEntry('TextField', () => buildTextFieldDemo()),
  DemoEntry('Toolbar', () => buildToolbarDemo()),
];

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Glass Gallery')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (BuildContext context, int i) {
          final DemoEntry entry = demos[i];
          return ListTile(
            title: Text(entry.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      title: Text(entry.title),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    body: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1B1530),
                            Color(0xFF0E1426),
                            Color(0xFF06121A),
                          ],
                        ),
                      ),
                      child: SafeArea(child: Center(child: entry.builder())),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
