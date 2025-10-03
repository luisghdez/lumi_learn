// whats_new_detail_data.dart
// This file contains all the detailed content for each version's What's New page

import 'package:flutter/material.dart';

class FeatureData {
  final String emoji;
  final String? text; // For simple features (v1.0.0)
  final String? title; // For detailed features (v2.0.0)
  final String? description; // For detailed features (v2.0.0)
  final Color color;

  const FeatureData({
    required this.emoji,
    this.text,
    this.title,
    this.description,
    required this.color,
  });
}

class VersionContent {
  final String welcomeEmoji;
  final String welcomeTitle;
  final String welcomeDescription;
  final List<Color> welcomeGradient;
  final String headerTitle;
  final IconData headerIcon;
  final List<FeatureData> features;
  final String closingEmoji;
  final String closingTitle;
  final String closingSubtitle;

  const VersionContent({
    required this.welcomeEmoji,
    required this.welcomeTitle,
    required this.welcomeDescription,
    required this.welcomeGradient,
    required this.headerTitle,
    required this.headerIcon,
    required this.features,
    required this.closingEmoji,
    required this.closingTitle,
    required this.closingSubtitle,
  });
}

// Version 2.0.0 Content
final version200Content = VersionContent(
  welcomeEmoji: '🚀',
  welcomeTitle: 'Lumi 2.0 is Here!',
  welcomeDescription:
      'We\'ve completely reimagined your learning experience with powerful new AI features, a stunning redesigned interface, and game-changing tools to help you master any subject faster than ever before.',
  welcomeGradient: [
    const Color(0xFF0004FF).withOpacity(0.2),
    const Color(0xFFA28BFF).withOpacity(0.15),
  ],
  headerTitle: 'What\'s New in 2.0',
  headerIcon: Icons.new_releases,
  features: [
    const FeatureData(
      emoji: '🎓',
      title: 'Lumi Tutor - Your AI Professor',
      description:
          'Meet your personal AI professor! Create custom courses, ask questions anytime, and get expert explanations tailored to your learning style. Available 24/7 for all your courses.',
      color: Color(0xFF0004FF),
    ),
    const FeatureData(
      emoji: '📸',
      title: 'AI Scanner',
      description:
          'Snap a photo of any document, textbook page, or handwritten notes and let our advanced AI instantly transform it into interactive lessons and study materials.',
      color: Color(0xFFA28BFF),
    ),
    const FeatureData(
      emoji: '🎨',
      title: 'Completely Redesigned UI',
      description:
          'Experience a mega-clean, modern interface that\'s faster, smoother, and more intuitive. Every screen has been reimagined for the ultimate learning experience.',
      color: Color(0xFF00C9FF),
    ),
    const FeatureData(
      emoji: '⚡',
      title: 'Enhanced Course Creation',
      description:
          'Build courses faster with improved PDF processing, image recognition, and key term extraction. More formats supported, better accuracy.',
      color: Color(0xFFFF006E),
    ),
    const FeatureData(
      emoji: '🧠',
      title: 'Smarter AI Engine',
      description:
          'Our learning AI is now 3x more accurate with better context understanding, personalized recommendations, and adaptive difficulty.',
      color: Color(0xFF8338EC),
    ),
    const FeatureData(
      emoji: '💬',
      title: 'Interactive Learning Assistant',
      description:
          'Chat naturally with Lumi Tutor about any topic. Get instant clarification, examples, practice problems, and study tips tailored to your needs.',
      color: Color(0xFFFB5607),
    ),
    const FeatureData(
      emoji: '🎯',
      title: 'Performance Optimization',
      description:
          'Everything is faster! Improved loading times, smoother animations, and better responsiveness across all features.',
      color: Color(0xFF06FFA5),
    ),
  ],
  closingEmoji: '✨',
  closingTitle: 'The Future of Learning',
  closingSubtitle:
      'Experience the most advanced version of Lumi yet. Your journey to mastery starts now!',
);

// Version 1.0.0 Content
final version100Content = VersionContent(
  welcomeEmoji: '👋',
  welcomeTitle: 'Welcome to Lumi Learn!',
  welcomeDescription:
      'We\'re your new study partner — helping you learn faster, easier, and wherever you go. Whether it\'s mastering a subject, prepping for a test, or organizing lessons your way, Lumi\'s got your back.',
  welcomeGradient: [
    const Color(0xFFA28BFF).withOpacity(0.15),
    const Color(0xFF0004FF).withOpacity(0.1),
  ],
  headerTitle: 'Version 1.0.0',
  headerIcon: Icons.auto_awesome,
  features: [
    const FeatureData(
      emoji: '🧠',
      text: 'Smarter AI-powered learner engine',
      color: Color(0xFF0004FF),
    ),
    const FeatureData(
      emoji: '📱',
      text: 'Intuitive UI that feels smooth',
      color: Color(0xFFA28BFF),
    ),
    const FeatureData(
      emoji: '📚',
      text: 'Build lessons with PDFs, images, or key terms',
      color: Color(0xFF00C9FF),
    ),
  ],
  closingEmoji: '💡',
  closingTitle: 'Thanks for being here.',
  closingSubtitle: 'Let\'s master your world, one lesson at a time',
);

// Map to get content by version
final Map<String, VersionContent> versionContents = {
  '2.0.0': version200Content,
  '1.0.0': version100Content,
};