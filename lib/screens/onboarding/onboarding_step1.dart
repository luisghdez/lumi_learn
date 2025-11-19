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

class _OnboardingStep1State extends State<OnboardingStep1> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  bool _isUsernameFocused = false;
  int _selectedAvatarIndex = 0;

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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final username = _usernameController.text.trim();
    widget.onContinue(username, _selectedAvatarIndex);
  }

  Widget _buildAvatarGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    // Calculate spacing
    final spacing = isTablet ? 6.0 : 0.0;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: _buildAvatarCard(index),
        );
      },
    );
  }

  Widget _buildAvatarCard(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isSelected = _selectedAvatarIndex == index;

    // Make avatars bigger - adjust size based on device
    final avatarSize = isTablet ? 240.0 : 220.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarIndex = index;
        });
      },
      child: SizedBox(
        width: avatarSize * 0.8,
        height: avatarSize,
        child: Stack(
          children: [
            // Avatar image - no padding, full size
            Center(
              child: Image.asset(
                avatars[index],
                fit: BoxFit.cover,
                width: avatarSize,
                height: avatarSize,
              ),
            ),

            // Selected indicator
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.grey.shade900,
                    size: 20,
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;

    return SafeArea(
      child: SizedBox(
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Padded content section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.15 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // Header
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isTablet ? 60 : 44,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                        children: [
                          TextSpan(text: 'Make it '),
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

                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      "Choose a username and avatar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: isTablet ? 20 : 16,
                        letterSpacing: 0.8,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Username text field inspired by the mockup
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
                            left: isTablet ? 6 : 1,
                            child: Container(
                              width: isTablet ? 52 : 36,
                              height: isTablet ? 52 : 36,
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
                                  width: 1.6,
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

                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Avatar horizontal scroll - full width, no padding
              SizedBox(
                height: isTablet ? 260.0 : 240.0,
                child: _buildAvatarGrid(),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Padded content section (continue button)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.15 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // Continue button
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

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
