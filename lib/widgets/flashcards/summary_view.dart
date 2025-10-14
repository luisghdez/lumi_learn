import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/flashcards/summary_pie_chart.dart';

class SummaryView extends StatefulWidget {
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
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = widget.total == 0 ? 0 : ((widget.known / widget.total) * 100).round();

    final isTablet = MediaQuery.of(context).size.width >= 768;
    final buttonFont = isTablet ? 20.0 : 16.0;
    final buttonPad = isTablet ? 24.0 : 16.0;

    // Purple theme color
    const primaryPurple = Color(0xFF8B5CF6);
    
    // Enhanced feedback with titles
    String title;
    String comment;
    Color accentColor;
    
    if (widget.total == 0) {
      title = 'No Cards';
      comment = 'No flashcards to review!';
      accentColor = primaryPurple;
    } else if (widget.known == widget.total) {
      title = 'Perfect Score!';
      comment = 'Amazing! You mastered the topic.';
      accentColor = Colors.amber.shade600;
    } else if (widget.known >= (0.8 * widget.total).ceil()) {
      title = 'Almost There!';
      comment = 'So close to perfection! Keep it up!';
      accentColor = primaryPurple;
    } else if (widget.known >= (0.5 * widget.total).ceil()) {
      title = 'Good Progress';
      comment = 'You\'re getting there! Practice makes perfect.';
      accentColor = primaryPurple;
    } else if (widget.known > 0) {
      title = 'Keep Trying';
      comment = 'Keep pushing! Every attempt counts!';
      accentColor = Colors.red.shade400;
    } else {
      title = 'Fresh Start';
      comment = 'Don\'t give up! Try again and you\'ll improve.';
      accentColor = Colors.red.shade400;
    }

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glassy container with chart and info
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 48 : 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Title
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: isTablet ? 36 : 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: accentColor.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Pie chart with glow
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: isTablet ? 250 : 200,
                            height: isTablet ? 250 : 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedPieChart(
                                  knownFraction: widget.total == 0 ? 0 : widget.known / widget.total,
                                  knownColor: accentColor,
                                  unknownColor: Colors.grey.withOpacity(0.3),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${widget.known}/${widget.total}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 40 : 32,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$percent%',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: isTablet ? 24 : 18,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: accentColor.withOpacity(0.5),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Comment text
                        Text(
                          comment,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Glassy button with matching accent color
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withOpacity(0.3),
                          accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: accentColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          _controller.reverse().then((_) {
                            widget.onResetDeck();
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonPad * 2.5,
                            vertical: buttonPad,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: isTablet ? 28 : 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFont,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}