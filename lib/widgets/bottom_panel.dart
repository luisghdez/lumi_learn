import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'dart:ui'; // For ImageFilter

class BottomPanel extends StatelessWidget {
  final int? selectedLessonIndex;
  final String? selectedLessonPlanetName;
  final String? selectedLessonDescription;
  final VoidCallback onStartPressed;
  final VoidCallback onClose;

  /// Optional unit label shown as a small pill below the planet name.
  /// Pass a value like "Unit 3 • Atomic Structure" for AP courses.
  /// When null (default) the pill is not rendered, preserving existing layout.
  final String? unitLabel;

  /// When provided, a "Notes" icon-button is shown beside the Start button.
  final VoidCallback? onViewUnitNotes;

  /// When provided, a "Cards" icon-button is shown beside the Start button.
  final VoidCallback? onViewUnitFlashcards;

  const BottomPanel({
    Key? key,
    required this.selectedLessonIndex,
    required this.selectedLessonPlanetName,
    required this.selectedLessonDescription,
    required this.onStartPressed,
    required this.onClose,
    this.unitLabel,
    this.onViewUnitNotes,
    this.onViewUnitFlashcards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final activePlanet = courseController.activePlanet.value;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(140, 0, 0, 0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: activePlanet == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No planet selected',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Large planet image, partially off-screen on bottom-left, with 50% opacity
                    Positioned(
                      left: activePlanet.hasRings ? -200 : -150,
                      bottom: activePlanet.hasRings ? -70 : -130,
                      child: Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          activePlanet.imagePath,
                          width: activePlanet.hasRings ? 480 : 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Foreground: text & button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.8, // 70% of the available width
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                selectedLessonPlanetName ?? '',
                                style: const TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              if (unitLabel != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    unitLabel!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color.fromARGB(200, 255, 255, 255),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                selectedLessonDescription ?? '',
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 213, 213, 213),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Secondary action row — Notes + Cards (AP only)
                              if (onViewUnitNotes != null || onViewUnitFlashcards != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (onViewUnitNotes != null)
                                      _PanelIconButton(
                                        icon: Icons.note_alt_outlined,
                                        label: 'Notes',
                                        onTap: onViewUnitNotes!,
                                      ),
                                    if (onViewUnitNotes != null && onViewUnitFlashcards != null)
                                      const SizedBox(width: 10),
                                    if (onViewUnitFlashcards != null)
                                      _PanelIconButton(
                                        icon: Icons.menu_book_outlined,
                                        label: 'Cards',
                                        onTap: onViewUnitFlashcards!,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              FractionallySizedBox(
                                widthFactor: 0.7,
                                child: ElevatedButton(
                                  onPressed: onStartPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 24, 24, 24),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PanelIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
