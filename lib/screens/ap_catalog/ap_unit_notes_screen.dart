import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/screens/courses/lessons/note_screen.dart';

/// Lists all units of an AP course. Tapping "View" on a row lazily fetches
/// that unit's markdown note via [GET /courses/:courseId/notes/:unitNumber]
/// and opens the existing [NoteScreen].
///
/// Reuses the same dark glass-morphism look as [ApCatalogScreen].
class ApUnitNotesScreen extends StatefulWidget {
  final String courseId;

  /// Map from unit number (1-based) to unit name.
  final Map<int, String> units;

  const ApUnitNotesScreen({
    Key? key,
    required this.courseId,
    required this.units,
  }) : super(key: key);

  @override
  State<ApUnitNotesScreen> createState() => _ApUnitNotesScreenState();
}

class _ApUnitNotesScreenState extends State<ApUnitNotesScreen> {
  /// Tracks which unit rows are currently fetching.
  final Set<int> _loading = {};

  Future<void> _onViewTap(int unitNumber) async {
    if (_loading.contains(unitNumber)) return;

    setState(() => _loading.add(unitNumber));

    try {
      final auth = Get.find<AuthController>();
      final token = await auth.getIdToken();
      if (token == null) {
        _showSnackbar('Not signed in', isError: true);
        return;
      }

      final response = await ApiService().getAPUnitNote(
        token: token,
        courseId: widget.courseId,
        unitNumber: unitNumber,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final note = data['note'] as Map<String, dynamic>?;
        final content = note?['content'] as String? ?? '';
        Get.to(
          () => NoteScreen(markdownText: content),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else if (response.statusCode == 404) {
        _showSnackbar('No note available for this unit yet');
      } else {
        _showSnackbar('Failed to load note (${response.statusCode})',
            isError: true);
      }
    } catch (_) {
      _showSnackbar('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading.remove(unitNumber));
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Note',
      message,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedUnits = widget.units.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                if (sortedUnits.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No units found.',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SliverList.separated(
                      itemCount: sortedUnits.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = sortedUnits[index];
                        return _UnitNoteRow(
                          unitNumber: entry.key,
                          unitName: entry.value,
                          isLoading: _loading.contains(entry.key),
                          onView: () => _onViewTap(entry.key),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15), width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Tap a unit to read its note',
                  style: TextStyle(
                    color: Color.fromARGB(153, 255, 255, 255),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitNoteRow extends StatelessWidget {
  final int unitNumber;
  final String unitName;
  final bool isLoading;
  final VoidCallback onView;

  const _UnitNoteRow({
    required this.unitNumber,
    required this.unitName,
    required this.isLoading,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12), width: 0.5),
          ),
          child: Row(
            children: [
              // Unit number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Center(
                  child: Text(
                    '$unitNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  unitName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // View button
              GestureDetector(
                onTap: isLoading ? null : onView,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.5),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
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
