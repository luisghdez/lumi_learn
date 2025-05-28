import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumi_learn_app/constants.dart';

class NoteScreen extends StatelessWidget {
  final String markdownText;

  const NoteScreen({Key? key, required this.markdownText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;

    final markdownStyle = MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: isTablet ? 28 : 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        h2: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        h3: TextStyle(
          fontSize: isTablet ? 20 : 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        p: TextStyle(
          fontSize: isTablet ? 18 : 14,
          fontWeight: FontWeight.w300,
          color: Colors.white70,
          height: 1.5,
        ),
        blockquote: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white, // High contrast for readability
          fontSize: isTablet ? 16 : 14,
        ),
        blockquotePadding: const EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFF3A7BD5).withOpacity(0.2), // soft blue tint
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3A7BD5).withOpacity(0.4),
            width: 1,
          ),
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: isTablet ? 16 : 14,
          color: Colors.amberAccent,
          backgroundColor: Colors.black45,
        ),
        listBullet: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 16 : 14,
        ),
        checkbox: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 16 : 14,
        ),
        tableHead: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 16 : 14,
        ),
        tableBody: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 16 : 14,
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white24,
              width: 1,
            ),
          ),
        ),
        blockSpacing: 18);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
            child: Markdown(
          data: markdownText,
          styleSheet: markdownStyle,
          physics: const BouncingScrollPhysics(),
        )),
      ),
    );
  }
}
