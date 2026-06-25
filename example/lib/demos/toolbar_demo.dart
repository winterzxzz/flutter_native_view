import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildToolbarDemo() {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Toolbar actions for a mail-like interface.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        SizedBox(height: 20),

        _ToolbarCard(
          title: 'Inbox',
          subtitle: '3 unread · swipe to action',
          tint: Color(0xFF0A84FF),
          actions: ['trash', 'folder', 'tag'],
        ),
        SizedBox(height: 16),

        _ToolbarCard(
          title: 'Archive',
          subtitle: 'Swipe to mark or move',
          tint: Color(0xFF30D158),
          actions: ['archivebox', 'envelope.open', 'bell'],
        ),
        SizedBox(height: 16),

        _ToolbarCard(
          title: 'Files',
          subtitle: 'Select items to reveal actions',
          tint: Color(0xFFFF9F0A),
          actions: ['trash', 'square.and.arrow.up', 'info.circle'],
        ),
      ],
    ),
  );
}

class _ToolbarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color tint;
  final List<String> actions;

  const _ToolbarCard({
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LiquidGlassContainer(
        tint: tint,
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              LiquidGlassToolbar(
                actions: actions
                    .map((s) => BarAction(
                          id: s,
                          sfSymbol: s,
                          onPressed: null,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
