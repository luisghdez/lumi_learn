import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final void Function(int) onPageChanged;
  final VoidCallback onCapture;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onCapture,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.3,
      initialPage: widget.selectedIndex,
    );
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _controller.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.categories.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (context, index) {
            final item = widget.categories[index];
            final isSelected = index == widget.selectedIndex;

            return GestureDetector(
              onTap: isSelected ? widget.onCapture : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 80 : 60,
                    height: isSelected ? 80 : 60,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: item['color'].withOpacity(0.4),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      item['icon'],
                      color: Colors.white,
                      size: isSelected ? 32 : 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
