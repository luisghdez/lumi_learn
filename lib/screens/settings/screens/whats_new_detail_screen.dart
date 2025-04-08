import 'dart:ui';
import 'package:flutter/material.dart';

class WhatsNewDetailScreen extends StatelessWidget {
  final String title;
  const WhatsNewDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _glassCard(
          child: ListView(
            children: const [
              SizedBox(height: 8),
              _SectionHeader(text: 'We’ve made big changes to help you learn faster:'),
              SizedBox(height: 12),
              BulletPoint(text: '🧠 Faster AI learner engine'),
              BulletPoint(text: '✨ Sleek, intuitive UI updates'),
              BulletPoint(text: '🐛 Bug fixes & performance boosts'),
              BulletPoint(text: '🌒 Dark mode refinements'),
              BulletPoint(text: '📚 New learning modules'),
              SizedBox(height: 24),
              Divider(
                thickness: 0.6,
                color: Colors.white24,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Thanks for evolving with Lumi Learn 💡',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
