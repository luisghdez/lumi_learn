import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:get/get.dart';

class NoteScreen extends StatelessWidget {
  final String markdownText;

  const NoteScreen({Key? key, required this.markdownText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 20.0;
    final appBarPad = isTablet ? 32.0 : 0.0;

    final markdownStyle = MarkdownStyleSheet(
      // palette
      // Deep purple primary, softer lavender accents
      // (tuned for contrast on pure black)
      a: TextStyle(
        color: const Color(0xFFB388FF), // link lavender
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFFB388FF).withOpacity(0.6),
      ),
      h1: TextStyle(
        fontSize: isTablet ? 28 : 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.25,
      ),
      h2: TextStyle(
        fontSize: isTablet ? 24 : 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFEDE7F6), // very light purple
        height: 1.3,
      ),
      h3: TextStyle(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFD1C4E9),
        height: 1.35,
      ),
      h4: TextStyle(
        // NEW for subheaders
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFB388FF), // soft lavender
        height: 1.4,
      ),
      p: TextStyle(
        fontSize: isTablet ? 18 : 14,
        fontWeight: FontWeight.w300,
        color: Colors.white,
        height: 1.55,
      ),

      // Quotes: subtle purple tint + left border
      blockquote: TextStyle(
        fontStyle: FontStyle.italic,
        color: const Color(0xFFEDE7F6),
        fontSize: isTablet ? 16 : 14,
        height: 1.45,
      ),
      blockquotePadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFF5E35B1).withOpacity(0.12), // soft purple wash
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withOpacity(0.35),
          width: 1,
        ),
      ),

      // Inline code + fenced code blocks
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: isTablet ? 16 : 14,
        color: const Color(0xFFF3E5F5), // light lilac
        backgroundColor: const Color(0xFF1A1424), // near-black purple
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1A1424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withOpacity(0.35),
          width: 1,
        ),
      ),

      // Lists & checkboxes
      listBullet: TextStyle(
        color: const Color(0xFFD1C4E9),
        fontSize: isTablet ? 16 : 14,
      ),
      checkbox: TextStyle(
        color: const Color(0xFFD1C4E9),
        fontSize: isTablet ? 16 : 14,
      ),

      // Tables: light borders, purple header
      tableHead: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? 16 : 14,
      ),
      tableBody: TextStyle(
        color: Colors.white70,
        fontSize: isTablet ? 16 : 14,
      ),
      tableCellsDecoration: BoxDecoration(
        border: Border.all(color: Colors.white12, width: 1),
      ),

      // Horizontal rule
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF7C4DFF), // primary purple
            width: 0.8,
          ),
        ),
      ),

      // Spacing tuned for readability
      blockSpacing: 12,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          iconSize: iconSize,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: Get.back,
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Markdown(
          data: markdownText,
          styleSheet: markdownStyle,
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
