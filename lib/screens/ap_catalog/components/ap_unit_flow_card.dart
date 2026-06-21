import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ApUnitFlowCard extends StatelessWidget {
  const ApUnitFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How every AP unit works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quickly understand the idea, test it, then explain it out loud to lock it in.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _FlowStep(
                    icon: Symbols.menu_book,
                    title: 'Read',
                    subtitle: 'Short visual lesson',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FlowStep(
                    icon: Symbols.quiz,
                    title: 'Test',
                    subtitle: 'AP-style practice',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FlowStep(
                    icon: Symbols.record_voice_over,
                    title: 'Speak',
                    subtitle: 'Feynman review',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FlowStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
