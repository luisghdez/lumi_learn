import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/ap_catalog_controller.dart';
import 'package:lumi_learn_app/screens/ap_catalog/components/ap_subject_card.dart';
import 'package:lumi_learn_app/screens/ap_catalog/components/ap_unit_flow_card.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';

class ApCatalogScreen extends StatelessWidget {
  const ApCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the controller lazily when the screen opens, dispose when it closes.
    final controller = Get.put(ApCatalogController());

    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth >= 800 ? 32 : 16;

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
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoading(horizontalPadding);
              }
              if (controller.error.value.isNotEmpty) {
                return _buildError(controller, horizontalPadding);
              }
              return _CatalogBody(
                controller: controller,
                horizontalPadding: horizontalPadding,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(double hp) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hp, 12, hp, 0),
            child: const _CatalogHeader(),
          ),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4FC3F7),
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(ApCatalogController controller, double hp) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hp, 12, hp, 0),
            child: const _CatalogHeader(),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.error.value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: controller.fetchCatalog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Text(
                      'Try again',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _CatalogBody extends StatefulWidget {
  final ApCatalogController controller;
  final double horizontalPadding;

  const _CatalogBody({
    required this.controller,
    required this.horizontalPadding,
  });

  @override
  State<_CatalogBody> createState() => _CatalogBodyState();
}

class _CatalogBodyState extends State<_CatalogBody> {
  ApCategory? _selectedCategory;

  List<ApSubject> get _filtered {
    final all = widget.controller.subjects;
    if (_selectedCategory == null) return all;
    return all.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hp = widget.horizontalPadding;

    return Obx(() {
      final subjects = _filtered;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hp, 12, hp, 0),
              child: const _CatalogHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hp, 20, hp, 0),
              child: const ApUnitFlowCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 16),
              child: _CategoryFilterBar(
                horizontalPadding: hp,
                selected: _selectedCategory,
                onSelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hp, 0, hp, 32),
            sliver: SliverList.separated(
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return ApSubjectCard(
                  subject: subjects[index],
                  onStart: () => widget.controller.startCourse(subjects[index]),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AP Catalog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a subject, then move through a guided exam-prep loop.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  final double horizontalPadding;
  final ApCategory? selected;
  final ValueChanged<ApCategory?> onSelected;

  const _CategoryFilterBar({
    required this.horizontalPadding,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in ApCategory.values) ...[
            const SizedBox(width: 10),
            _FilterChip(
              label: category.label,
              isSelected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF4FC3F7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
