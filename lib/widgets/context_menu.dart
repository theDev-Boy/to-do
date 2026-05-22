import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class ContextMenu extends StatefulWidget {
  final Offset position;
  final List<ContextMenuOption> options;
  final VoidCallback onDismiss;

  const ContextMenu({
    super.key,
    required this.position,
    required this.options,
    required this.onDismiss,
  });

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final menuHeight = widget.options.length * 52.0 + 16;
    final top = widget.position.dy > screenSize.height / 2
        ? widget.position.dy - menuHeight - 10
        : widget.position.dy + 10;
    final left = widget.position.dx > screenSize.width - 200
        ? widget.position.dx - 200
        : widget.position.dx - 20;

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Transparent background to catch taps
          Container(color: Colors.transparent),
          // Menu
          Positioned(
            top: top.clamp(20.0, screenSize.height - menuHeight - 20),
            left: left.clamp(10.0, screenSize.width - 210),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A12).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.options.length, (i) {
                        final option = widget.options[i];
                        return _MenuItem(
                          icon: option.icon,
                          label: option.label,
                          color: option.color,
                          onTap: () {
                            HapticService.light();
                            // Execute the option action first
                            option.onTap();
                            // Always dismiss the menu (it wraps the action)
                            _dismiss();
                          },
                          showDivider: i < widget.options.length - 1 &&
                              widget.options[i + 1].showDividerAbove,
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContextMenuOption {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool showDividerAbove;

  ContextMenuOption({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
    this.showDividerAbove = false,
  });
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Divider(
            height: 1,
            color: AppTheme.borderLight,
            indent: 16,
            endIndent: 16,
          ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: c),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: c,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper to show context menu as an OverlayEntry (not a dialog)
void showContextMenu(
  BuildContext context, {
  required Offset position,
  required List<ContextMenuOption> options,
}) {
  HapticService.medium();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => ContextMenu(
      position: position,
      options: options,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  Overlay.of(context).insert(entry);
}
