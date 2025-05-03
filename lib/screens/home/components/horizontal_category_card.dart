import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class HorizontalCategoryCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onConfirm;
  final double height;
  final List<String> tags;

  const HorizontalCategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onConfirm,
    required this.height,
    required this.tags,
  }) : super(key: key);

  @override
  State<HorizontalCategoryCard> createState() => _HorizontalCategoryCardState();
}

class _HorizontalCategoryCardState extends State<HorizontalCategoryCard> {
  bool _overlayVisible = false;
  late FocusNode _focusNode;

  static const double _aspectRatio = 200 / 140;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _overlayVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleCardTap() {
    _focusNode.requestFocus();
    setState(() {
      _overlayVisible = true;
    });
  }

  void _handleCancel() {
    setState(() {
      _overlayVisible = false;
    });
    _focusNode.unfocus();
  }

  void _handleConfirm() {
    setState(() {
      _overlayVisible = false;
    });
    _focusNode.unfocus();
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = widget.height;
    final double cardWidth = cardHeight * _aspectRatio;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final List<String> displayTags =
        widget.tags.isEmpty ? ['LumiOG', 'Classic'] : widget.tags;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Focus(
        focusNode: _focusNode,
        child: GestureDetector(
          onTap: _handleCardTap,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: greyBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: displayTags
                                  .map((tag) => _TagChip(label: tag))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: !_overlayVisible,
                child: AnimatedOpacity(
                  opacity: _overlayVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.75),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Do you want to \nsave and start\nthis course?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _handleConfirm,
                              child: const Text(
                                'Yes!',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: TextButton(
                            onPressed: _handleCancel,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}
