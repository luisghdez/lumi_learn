import 'dart:math' as math;
import 'package:flutter/material.dart';

class BaseScreenContainer extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context) builder;
  final String backgroundAsset;
  final bool includeSafeArea;
  final double tabletBreakpoint;
  final double bottomPadding;
  final bool enableScroll;

  const BaseScreenContainer({
    Key? key,
    required this.builder,
    this.onRefresh,
    this.backgroundAsset = 'assets/images/black_moons_lighter.png',
    this.includeSafeArea = true,
    this.tabletBreakpoint = 800,
    this.bottomPadding = 0,
    this.enableScroll = true,
  }) : super(key: key);

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = _getHorizontalPadding(context);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
          ),
        ),
        if (includeSafeArea)
          SafeArea(
            top: false,
            bottom: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minHeight = math.max(
                  0.0,
                  constraints.maxHeight - topPadding - bottomPadding,
                );

                // ✅ If scrolling is disabled (like in chat), skip wrapping
                if (!enableScroll) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: topPadding,
                      bottom: bottomPadding,
                    ),
                    child: builder(context),
                  );
                }

                // ✅ Default scrollable layout
                return RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onRefresh: onRefresh ?? () async {},
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topPadding,
                      bottom: bottomPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: builder(context),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
