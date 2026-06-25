import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

class MenuDemo extends StatefulWidget {
  const MenuDemo({super.key});
  @override
  State<MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<MenuDemo> {
  String _status = 'Tap a menu to perform an action.';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Context menus for common operations.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF6C63FF),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MenuButton(
                          label: 'Edit',
                          symbol: 'pencil',
                          onSelected: () => setState(() => _status = '✏️  Edit selected'),
                        ),
                        _MenuButton(
                          label: 'Share',
                          symbol: 'square.and.arrow.up',
                          onSelected: () => setState(() => _status = '📤  Share opened'),
                        ),
                        _MenuButton(
                          label: 'More',
                          symbol: 'ellipsis.circle',
                          onSelected: () => setState(() => _status = '⋯  More options'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Inline menu trigger
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFFFF375F),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dropdown Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap the button to open a native context menu.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: LiquidGlassMenu(
                        label: 'Options',
                        sfSymbol: 'gearshape',
                        iconColor: Colors.white,
                        items: const [
                          MenuItem(
                            id: 'edit',
                            title: 'Edit',
                            sfSymbol: 'pencil',
                          ),
                          MenuItem(
                            id: 'share',
                            title: 'Share',
                            sfSymbol: 'square.and.arrow.up',
                          ),
                          MenuItem(
                            id: 'delete',
                            title: 'Delete',
                            sfSymbol: 'trash',
                          ),
                        ],
                        onSelected: (String id) {
                          final actions = {
                            'edit': '✏️  Editing document',
                            'share': '📤  Sharing document',
                            'delete': '🗑️  Document deleted',
                          };
                          setState(() => _status = actions[id] ?? id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final String symbol;
  final VoidCallback onSelected;

  const _MenuButton({
    required this.label,
    required this.symbol,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LiquidGlassIconButton(
          sfSymbol: symbol,
          onPressed: onSelected,
          tint: const Color(0xFF0A84FF),
          iconColor: Colors.white,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}
