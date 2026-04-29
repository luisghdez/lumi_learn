import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Step 1 of onboarding: Username and avatar selection
class OnboardingStep1 extends StatefulWidget {
  final Function(String username, int avatarIndex) onContinue;

  const OnboardingStep1({
    super.key,
    required this.onContinue,
  });

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  bool _isUsernameFocused = false;
  int _selectedAvatarIndex = 0;

  // Auto-scroll functionality
  final ScrollController _scrollController = ScrollController();
  bool _userHasScrolled = false;
  AnimationController? _autoScrollController;
  Animation<double>? _autoScrollAnimation;

  // List of all available avatars (same as PfpGalleryScreen)
  final List<String> avatars = [
    'assets/pfp/pfp48.png',
    'assets/pfp/pfp19.png',
    'assets/pfp/pfp17.png',
    'assets/pfp/pfp47.png',
    'assets/pfp/pfp33.png',
    'assets/pfp/pfp30.png',
    'assets/pfp/pfp46.png',
    'assets/pfp/pfp1.png',
    'assets/pfp/pfp2.png',
    'assets/pfp/pfp3.png',
    'assets/pfp/pfp4.png',
    'assets/pfp/pfp5.png',
    'assets/pfp/pfp6.png',
    'assets/pfp/pfp7.png',
    'assets/pfp/pfp8.png',
    'assets/pfp/pfp9.png',
    'assets/pfp/pfp10.png',
    'assets/pfp/pfp11.png',
    'assets/pfp/pfp12.png',
    'assets/pfp/pfp13.png',
    'assets/pfp/pfp14.png',
    'assets/pfp/pfp15.png',
    'assets/pfp/pfp16.png',
    'assets/pfp/pfp18.png',
    'assets/pfp/pfp20.png',
    'assets/pfp/pfp21.png',
    'assets/pfp/pfp22.png',
    'assets/pfp/pfp23.png',
    'assets/pfp/pfp24.png',
    'assets/pfp/pfp25.png',
    'assets/pfp/pfp26.png',
    'assets/pfp/pfp27.png',
    'assets/pfp/pfp28.png',
    'assets/pfp/pfp29.png',
    'assets/pfp/pfp31.png',
    'assets/pfp/pfp32.png',
    'assets/pfp/pfp34.png',
    'assets/pfp/pfp35.png',
    'assets/pfp/pfp36.png',
    'assets/pfp/pfp37.png',
    'assets/pfp/pfp38.png',
    'assets/pfp/pfp39.png',
    'assets/pfp/pfp40.png',
    'assets/pfp/pfp41.png',
    'assets/pfp/pfp42.png',
    'assets/pfp/pfp43.png',
    'assets/pfp/pfp44.png',
    'assets/pfp/pfp45.png',
  ];

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isUsernameFocused = _usernameFocusNode.hasFocus;
        });
      }
    });

    // Start auto-scrolling after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (_userHasScrolled || !mounted || !_scrollController.hasClients) return;

    // Calculate the total scrollable distance
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    // Create an animation that slowly scrolls through all avatars
    // Duration: slower scroll for better showcase (180 seconds for full scroll)
    const duration = Duration(seconds: 180);

    _autoScrollController = AnimationController(
      vsync: this,
      duration: duration,
    );

    _autoScrollAnimation = Tween<double>(
      begin: 0.0,
      end: maxScroll,
    ).animate(CurvedAnimation(
      parent: _autoScrollController!,
      curve: Curves.linear,
    ));

    _autoScrollAnimation!.addListener(() {
      if (!_userHasScrolled && _scrollController.hasClients && mounted) {
        _scrollController.jumpTo(_autoScrollAnimation!.value);
      }
    });

    _autoScrollController!.forward();
  }

  void _stopAutoScroll() {
    _autoScrollController?.stop();
    _autoScrollController?.dispose();
    _autoScrollController = null;
    _autoScrollAnimation = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.dispose();
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final username = _usernameController.text.trim();
    widget.onContinue(username, _selectedAvatarIndex);
  }

  Widget _buildAvatarGrid(double availableHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    // Calculate avatar size based on available height
    // We want the avatar to be large but fit within the available space
    double avatarSize = availableHeight * 0.85; // Leave some room for padding

    // Clamp avatar size to reasonable limits
    if (isTablet) {
      avatarSize = avatarSize.clamp(240.0, 580.0);
    } else {
      avatarSize = avatarSize.clamp(180.0, 350.0);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Detect when user starts scrolling
        if (notification is ScrollStartNotification) {
          if (notification.dragDetails != null && !_userHasScrolled) {
            // User initiated scroll with drag
            setState(() {
              _userHasScrolled = true;
            });
            _stopAutoScroll();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: avatars.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Center(child: _buildAvatarCard(index, avatarSize));
        },
      ),
    );
  }

  Widget _buildAvatarCard(int index, double size) {
    final isSelected = _selectedAvatarIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarIndex = index;
        });
      },
      child: SizedBox(
        width: size * 0.95,
        height: size,
        child: Stack(
          children: [
            // Avatar image
            Center(
              child: Image.asset(
                avatars[index],
                fit: BoxFit.contain,
                width: size,
                height: size,
              ),
            ),

            // Selected indicator
            if (isSelected)
              Positioned(
                top: size * 0.02,
                right: size * 0.02,
                child: Container(
                  padding: EdgeInsets.all(size * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade200.withOpacity(0.95),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: isTablet ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: size * 0.05,
                        spreadRadius: size * 0.005,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.grey.shade900,
                    size: size * 0.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return SafeArea(
      child: Column(
        children: [
          // Top 30% - Title and Input
          Expanded(
            flex: 30,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenWidth * 0.15 : 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Header
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isTablet ? 60 : 44,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Make it '),
                          TextSpan(
                            text: 'yours',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isTablet ? 60 : 44,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 16 : 8),

                  Text(
                    "Choose a username and avatar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: isTablet ? 20 : 16,
                      letterSpacing: 0.8,
                    ),
                  ),

                  SizedBox(height: isTablet ? 24 : 16),

                  // Username text field
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600 : double.infinity,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.85),
                          blurRadius: 18,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: (!_isUsernameFocused &&
                                    _usernameController.text.isEmpty)
                                ? 'Username'
                                : null,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: isTablet ? 20 : 16,
                              letterSpacing: 0.6,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                        Positioned(
                          left: isTablet ? 12 : 1,
                          child: Container(
                            width: isTablet ? 36 : 36,
                            height: isTablet ? 36 : 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: isTablet ? 3.2 : 1.6,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatars[_selectedAvatarIndex],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Middle 50% - Avatar Selection
          Expanded(
            flex: 50,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _buildAvatarGrid(constraints.maxHeight),
                );
              },
            ),
          ),

          // Bottom 20% - Continue Button
          Expanded(
            flex: 20,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenWidth * 0.15 : 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                        maxWidth: isTablet ? 500 : double.infinity),
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
