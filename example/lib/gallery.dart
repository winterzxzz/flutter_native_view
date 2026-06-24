import 'package:flutter/material.dart';

import 'demos/activity_indicator_demo.dart';
import 'demos/button_demo.dart';
import 'demos/button_group_demo.dart';
import 'demos/color_picker_demo.dart';
import 'demos/container_demo.dart';
import 'demos/date_picker_demo.dart';
import 'demos/icon_button_demo.dart';
import 'demos/menu_demo.dart';
import 'demos/navigation_bar_demo.dart';
import 'demos/progress_view_demo.dart';
import 'demos/search_bar_demo.dart';
import 'demos/segmented_demo.dart';
import 'demos/slider_demo.dart';
import 'demos/stepper_demo.dart';
import 'demos/switch_demo.dart';
import 'demos/tab_bar_demo.dart';
import 'demos/toolbar_demo.dart';

typedef DemoBuilder = Widget Function();

class DemoEntry {
  const DemoEntry(this.title, this.builder);
  final String title;
  final DemoBuilder builder;
}

final List<DemoEntry> demos = <DemoEntry>[
  DemoEntry('ActivityIndicator', () => buildActivityIndicatorDemo()),
  DemoEntry('Button', () => const ButtonDemo()),
  DemoEntry('ButtonGroup', () => buildButtonGroupDemo()),
  DemoEntry('ColorPicker', () => buildColorPickerDemo()),
  DemoEntry('Container', () => buildContainerDemo()),
  DemoEntry('DatePicker', () => buildDatePickerDemo()),
  DemoEntry('IconButton', () => const IconButtonDemo()),
  DemoEntry('Menu', () => const MenuDemo()),
  DemoEntry('NavigationBar', () => buildNavigationBarDemo()),
  DemoEntry('ProgressView', () => buildProgressViewDemo()),
  DemoEntry('SearchBar', () => const SearchBarDemo()),
  DemoEntry('SegmentedControl', () => const SegmentedDemo()),
  DemoEntry('Slider', () => buildSliderDemo()),
  DemoEntry('Stepper', () => buildStepperDemo()),
  DemoEntry('Switch', () => const SwitchDemo()),
  DemoEntry('TabBar', () => buildTabBarDemo()),
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
                    appBar: AppBar(title: Text(entry.title)),
                    body: Center(child: entry.builder()),
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
