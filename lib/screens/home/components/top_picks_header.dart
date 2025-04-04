import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class TopPicksHeader extends StatelessWidget {
  final VoidCallback onAddTap;
  final int slotsUsed;
  final int maxSlots;
  final bool isPremium;

  const TopPicksHeader({
    Key? key,
    required this.onAddTap,
    required this.slotsUsed,
    required this.maxSlots,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'My Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onAddTap,
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
