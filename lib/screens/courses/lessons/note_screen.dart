import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:get/get.dart';

class NoteScreen extends StatefulWidget {
  final String markdownText;

  const NoteScreen({Key? key, required this.markdownText}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool _isCopied = false;

  void _copyAllText() {
    Clipboard.setData(ClipboardData(text: widget.markdownText));
    setState(() {
      _isCopied = true;
    });

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 20.0;
    final appBarPad = isTablet ? 32.0 : 0.0;

    final markdownStyle = MarkdownStyleSheet(
      // Links with purple accent
      a: TextStyle(
        color: const Color(0xFFB388FF),
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFFB388FF).withOpacity(0.6),
      ),

      // Headers with consistent hierarchy
      h1: TextStyle(
        fontSize: isTablet ? 28 : 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.25,
      ),
      h2: TextStyle(
        fontSize: isTablet ? 24 : 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFEDE7F6),
        height: 1.3,
      ),
      h3: TextStyle(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFD1C4E9),
        height: 1.35,
      ),
      h4: TextStyle(
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFB388FF),
        height: 1.4,
      ),

      // Body text
      p: TextStyle(
        fontSize: isTablet ? 18 : 14,
        fontWeight: FontWeight.w300,
        color: Colors.white,
        height: 1.55,
      ),

      // Tables with glass morphism
      tableBorder: TableBorder.all(
        color: Colors.white.withOpacity(0.08),
        width: 1,
        borderRadius: BorderRadius.circular(16),
      ),

      // Blockquotes with glass morphism effect
      blockquote: TextStyle(
        fontStyle: FontStyle.italic,
        color: const Color(0xFFEDE7F6),
        fontSize: isTablet ? 16 : 14,
        height: 1.45,
      ),
      blockquotePadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),

      // Code blocks with glass morphism
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: isTablet ? 16 : 14,
        color: const Color(0xFFF3E5F5),
        backgroundColor: Colors.transparent,
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),

      // Lists with consistent styling
      listBullet: TextStyle(
        color: const Color(0xFFD1C4E9),
        fontSize: isTablet ? 16 : 14,
      ),
      checkbox: TextStyle(
        color: const Color(0xFFD1C4E9),
        fontSize: isTablet ? 16 : 14,
      ),

      // Tables with glass morphism
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
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),

      // Horizontal rule with purple accent
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF7C4DFF),
            width: 0.8,
          ),
        ),
      ),

      // Spacing for readability
      blockSpacing: 16,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/black_moons_lighter.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              iconSize: iconSize,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              onPressed: Get.back,
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: isTablet ? 32.0 : 8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: TextButton.icon(
                    key: ValueKey(_isCopied),
                    onPressed: _isCopied ? null : _copyAllText,
                    icon: Icon(
                      _isCopied ? Icons.check : Icons.copy_all,
                      size: iconSize,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isCopied ? 'Copied' : 'Copy All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 12 : 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Markdown(
                    data: widget.markdownText,
                    styleSheet: markdownStyle,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(padding),
                    selectable: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}