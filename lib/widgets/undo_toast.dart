import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UndoToast extends StatefulWidget {
  final String message;
  final String? description;
  final Duration duration;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  const UndoToast({
    super.key,
    required this.message,
    this.description,
    this.duration = const Duration(seconds: 8),
    required this.onUndo,
    required this.onDismiss,
  });

  @override
  State<UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<UndoToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
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
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Dismissible(
          key: const ValueKey('undo_toast'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDismiss(),
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A12).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentPrimary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.undo,
                        size: 20,
                        color: AppTheme.accentPrimary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.description!,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onUndo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Undo',
                            style: TextStyle(
                              color: AppTheme.accentPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown bar
                _CountdownBar(
                  duration: widget.duration,
                  onComplete: () => _dismiss(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownBar extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const _CountdownBar({
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          child: LinearProgressIndicator(
            value: 1.0 - _controller.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              AppTheme.accentPrimary.withValues(alpha: 0.3),
            ),
            minHeight: 3,
          ),
        );
      },
    );
  }
}

// Helper to show undo toast overlay
OverlayEntry showUndoToast(
  BuildContext context, {
  required String message,
  String? description,
  Duration duration = const Duration(seconds: 8),
  required VoidCallback onUndo,
}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => UndoToast(
      message: message,
      description: description,
      duration: duration,
      onUndo: () {
        entry.remove();
        onUndo();
      },
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  Overlay.of(context).insert(entry);
  return entry;
}
