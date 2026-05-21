import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryIcon extends StatelessWidget {
  final int index;
  final bool compact;
  final double size;

  const CategoryIcon({
    super.key,
    required this.index,
    this.compact = false,
    this.size = 14,
  });

  static const List<IconData> icons = [
    Icons.work_outline,
    Icons.person_outline,
    Icons.favorite_border,
    Icons.account_balance_wallet_outlined,
    Icons.warning_amber_outlined,
    Icons.shopping_bag_outlined,
    Icons.flight_takeoff,
    Icons.school_outlined,
    Icons.home_outlined,
    Icons.diversity_3_outlined,
    Icons.lightbulb_outline,
    Icons.more_horiz,
  ];

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[index % AppTheme.categoryColors.length];

    if (compact) {
      return Icon(icons[index % icons.length], color: color, size: size);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[index % icons.length], color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            AppTheme.categoryNames[index % AppTheme.categoryNames.length],
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
