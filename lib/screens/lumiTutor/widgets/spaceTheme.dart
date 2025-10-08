import 'package:flutter/material.dart';

final Map<String, TextStyle> spaceTheme = {
  'root': const TextStyle(
    backgroundColor: Colors.transparent,
    color: Color(0xFFF0F4FF), // Brighter starlight white
  ),
  'keyword': const TextStyle(
    color: Color(0xFFBB86FC), // Brighter nebula purple
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Color(0xFFBB86FC),
        blurRadius: 4,
      ),
    ],
  ),
  'built_in': const TextStyle(
    color: Color(0xFF5FD3F3), // Brighter cosmic blue
    fontWeight: FontWeight.w500,
  ),
  'type': const TextStyle(
    color: Color(0xFF9D7FFF), // Brighter galaxy purple
    fontWeight: FontWeight.w600,
  ),
  'literal': const TextStyle(
    color: Color(0xFFE879F9), // Brighter magenta nebula
    fontWeight: FontWeight.w500,
  ),
  'number': const TextStyle(
    color: Color(0xFFD946EF), // Brighter purple star
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Color(0xFFD946EF),
        blurRadius: 3,
      ),
    ],
  ),
  'string': const TextStyle(
    color: Color(0xFF22D3EE), // Brighter ice blue (cyan)
    fontWeight: FontWeight.w500,
    shadows: [
      Shadow(
        color: Color(0xFF22D3EE),
        blurRadius: 2,
      ),
    ],
  ),
  'comment': const TextStyle(
    color: Color(0xFF94A3B8), // Brighter space gray
    fontStyle: FontStyle.italic,
  ),
  'function': const TextStyle(
    color: Color(0xFF38BDF8), // Brighter star blue
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Color(0xFF38BDF8),
        blurRadius: 4,
      ),
    ],
  ),
  'variable': const TextStyle(
    color: Color(0xFFF0ABFC), // Brighter light purple
    fontWeight: FontWeight.w500,
  ),
  'attr': const TextStyle(
    color: Color(0xFF7DD3FC), // Brighter sky blue
    fontWeight: FontWeight.w500,
  ),
  'tag': const TextStyle(
    color: Color(0xFFC084FC), // Brighter deep purple
    fontWeight: FontWeight.w600,
  ),
  'name': const TextStyle(
    color: Color(0xFF60A5FA), // Brighter azure
    fontWeight: FontWeight.w600,
  ),
  'selector-tag': const TextStyle(
    color: Color(0xFFA78BFA), // Brighter violet
    fontWeight: FontWeight.w600,
  ),
  'deletion': const TextStyle(
    color: Color(0xFFFB7185), // Brighter red giant
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.lineThrough,
  ),
  'addition': const TextStyle(
    color: Color(0xFF4ADE80), // Brighter green aurora
    fontWeight: FontWeight.w500,
  ),
  'link': const TextStyle(
    color: Color(0xFF38BDF8),
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    shadows: [
      Shadow(
        color: Color(0xFF38BDF8),
        blurRadius: 3,
      ),
    ],
  ),
  'operator': const TextStyle(
    color: Color(0xFFD946EF), // Brighter purple operator
    fontWeight: FontWeight.w600,
  ),
  'regexp': const TextStyle(
    color: Color(0xFFF0ABFC), // Brighter pink nebula
    fontWeight: FontWeight.w500,
  ),
  'title': const TextStyle(
    color: Color(0xFF60A5FA),
    fontWeight: FontWeight.bold,
    fontSize: 16,
    shadows: [
      Shadow(
        color: Color(0xFF60A5FA),
        blurRadius: 6,
      ),
    ],
  ),
  'section': const TextStyle(
    color: Color(0xFFA78BFA),
    fontWeight: FontWeight.bold,
    fontSize: 15,
  ),
  'quote': const TextStyle(
    color: Color(0xFF94A3B8),
    fontStyle: FontStyle.italic,
  ),
  'bullet': const TextStyle(
    color: Color(0xFF7DD3FC), // Brighter light blue
    fontWeight: FontWeight.w600,
  ),
  'emphasis': const TextStyle(
    color: Color(0xFFF0F4FF),
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
  ),
  'strong': const TextStyle(
    color: Color(0xFFFFFFFF), // Pure white for strong emphasis
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Color(0xFFBB86FC),
        blurRadius: 2,
      ),
    ],
  ),
  // Extra syntax elements with glow
  'class': const TextStyle(
    color: Color(0xFF818CF8), // Indigo
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(
        color: Color(0xFF818CF8),
        blurRadius: 4,
      ),
    ],
  ),
  'params': const TextStyle(
    color: Color(0xFFFBBF24), // Gold/yellow
    fontWeight: FontWeight.w500,
  ),
  'meta': const TextStyle(
    color: Color(0xFF94A3B8),
    fontWeight: FontWeight.w500,
  ),
  'doctag': const TextStyle(
    color: Color(0xFF4ADE80),
    fontWeight: FontWeight.w600,
  ),
};