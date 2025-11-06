import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/auth/signup_screen.dart';
import 'dart:ui';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late PageController _pageController;
  late AnimationController _parallaxController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  
  int _currentPage = 0;
  bool _isTransitioning = false;

  final List<String> onboardingImages = [
    "assets/onboarding/onboard01.png",
    "assets/onboarding/onboard02.png",
    "assets/onboarding/onboard03.png",
    "assets/onboarding/onboard04.png",
    "assets/onboarding/onboard05.png",
    "assets/onboarding/onboard06.png",
    "assets/onboarding/onboard07.png",
    "assets/onboarding/onboard08.png",
  ];

  // Gradient combinations for each page
  final List<List<Color>> pageGradients = [
    [Color(0xFF000029), Color(0xFF1a1a3e).withOpacity(0.7)],
    [Color(0xFF0f0c29), Color(0xFF302b63).withOpacity(0.7)],
    [Color(0xFF1a1a2e), Color(0xFF16213e).withOpacity(0.7)],
    [Color(0xFF000428), Color(0xFF004e92).withOpacity(0.7)],
    [Color(0xFF1e3c72), Color(0xFF2a5298).withOpacity(0.7)],
    [Color(0xFF141e30), Color(0xFF243b55).withOpacity(0.7)],
    [Color(0xFF0f2027), Color(0xFF203a43).withOpacity(0.7)],
    [Color(0xFF000029), Color(0xFF1a1a3e).withOpacity(0.7)],
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pageController = PageController();

    _parallaxController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _pageController.dispose();
    _parallaxController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < onboardingImages.length - 1) {
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    authController.hasCompletedOnboarding.value = true;
    Get.to(
      () => SignupScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
    );
  }

  Widget _buildFloatingParticles() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _parallaxController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(
              animation: _parallaxController.value,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildImagePage(int index, double pageOffset) {
    final parallax = (index - pageOffset).clamp(-1.0, 1.0);
    final scale = 1.0 + (parallax.abs() * 0.2);
    final opacity = 1.0 - (parallax.abs() * 0.2);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax image effect - clean, no overlays
            Transform.translate(
              offset: Offset(parallax * -50, 0),
              child: Image.asset(
                onboardingImages[index],
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),

            // Very subtle vignette effect only at edges
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Fully transparent container, no border, no shadow
            Positioned(
              left: 24,
              right: 24,
              bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    // No border, no boxShadow
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button with better styling
                        if (_currentPage < onboardingImages.length - 1)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _finishOnboarding,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(width: 70),

                        // Page indicators
                        Expanded(
                          child: Center(
                            child: _buildPageIndicators(),
                          ),
                        ),

                        // Redesigned next button - smaller and more elegant
                        _buildMainActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingImages.length,
        (index) {
          final isActive = index == _currentPage;
          final distance = (_currentPage - index).abs();
          final scale = 1.0 - (distance * 0.15).clamp(0.0, 0.5);
          
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: isActive ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isActive
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.25),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainActionButton() {
    final isLastPage = _currentPage == onboardingImages.length - 1;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.03),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _goToNextPage,
              borderRadius: BorderRadius.circular(25),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      key: ValueKey(isLastPage),
                      color: Colors.white.withOpacity(0.95),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000029),
      body: Stack(
        children: [
          // Full-screen page view with parallax
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, _) {
              final pageOffset = _pageController.hasClients ? _pageController.page ?? 0.0 : 0.0;
              return PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: onboardingImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) => _buildImagePage(index, pageOffset),
              );
            },
          ),

          // Floating particles overlay
          _buildFloatingParticles(),

          // Glassy bottom controls
          _buildGlassyBottomControls(),
        ],
      ),
    );
  }
}

// Custom painter for floating particles
class ParticlesPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  ParticlesPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 73) % size.width;
      final y = (animation * size.height + i * 47) % size.height;
      final radius = (i % 3 + 1) * 2.0;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

// Custom painter for ripple effect
class RipplePainter extends CustomPainter {
  final double animation;
  final Color color;
  
  RipplePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * animation;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - animation))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}