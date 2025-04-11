import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class TopPicksHeader extends StatelessWidget {
  final VoidCallback onAddTap;
  final int slotsUsed;
  final int maxSlots;
  final bool isPremium;
  final TextStyle titleStyle;

  const TopPicksHeader({
    Key? key,
    required this.onAddTap,
    required this.slotsUsed,
    required this.maxSlots,
    required this.isPremium,
    required this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the text theme once for cleaner access
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'My Courses',
              style: titleStyle,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: greyBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isPremium ? '$slotsUsed/∞' : '$slotsUsed/$maxSlots',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onAddTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
