import 'dart:math' as math;
import 'package:flutter/material.dart';

class BaseScreenContainer extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context) builder;
  final String backgroundAsset;
  final bool includeSafeArea;
  final double tabletBreakpoint;
  final double bottomPadding;

  const BaseScreenContainer({
    Key? key,
    required this.builder,
    this.onRefresh,
    this.backgroundAsset = 'assets/images/black_moons_lighter.png',
    this.includeSafeArea = true,
    this.tabletBreakpoint = 800,
    this.bottomPadding = 40,
  }) : super(key: key);

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = _getHorizontalPadding(context);
    final double topPadding = MediaQuery.of(context).padding.top + horizontalPadding;

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
          ),
        ),

        // Foreground content with optional SafeArea
        if (includeSafeArea)
          SafeArea(
            top: false,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minHeight = math.max(
                  0.0,
                  screenHeight - topPadding - bottomPadding,
                );

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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: builder(context),
                      ),
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
