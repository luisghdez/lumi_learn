import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/flashcards/summary_pie_chart.dart';

class SummaryView extends StatelessWidget {
  final int known;
  final int total;
  final VoidCallback onResetDeck;

  const SummaryView({
    Key? key,
    required this.known,
    required this.total,
    required this.onResetDeck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((known / total) * 100).round();

    final isTablet = MediaQuery.of(context).size.width >= 768;
    final buttonFont = isTablet ? 20.0 : 16.0;
    final buttonPad = isTablet ? 24.0 : 16.0;

    String comment;
    if (total == 0) {
      comment = 'No flashcards to review!';
    } else if (known == total) {
      comment = 'Amazing! You mastered the topic.';
    } else if (known >= (0.8 * total).ceil()) {
      comment = 'Great job! Just a little more practice.';
    } else if (known >= (0.5 * total).ceil()) {
      comment = 'Good effort! Review the ones you missed.';
    } else if (known > 0) {
      comment = 'Keep practicing! You can do it!';
    } else {
      comment = 'Don\'t give up! Try again and you\'ll improve.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPieChart(
                  knownFraction: total == 0 ? 0 : known / total,
                  knownColor: Colors.green,
                  unknownColor: Colors.red,
                ),
                Text(
                  '$known/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onResetDeck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(
                  horizontal: buttonPad * 2, vertical: buttonPad / 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: buttonFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 