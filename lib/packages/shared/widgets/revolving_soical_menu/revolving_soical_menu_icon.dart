import 'dart:math';
import 'package:flutter/material.dart';

class CircularActionMenuItem {
  final Widget icon;
  final String tooltip;
  final Color? highlightColor;
  final VoidCallback onPressed;

  const CircularActionMenuItem({
    required this.icon,
    required this.tooltip,
    this.highlightColor,
    required this.onPressed,
  });
}

/// A Circular Action Menu that starts as a single central icon and expands
/// into a radial menu with revolving items.
///
/// **Example Usage:**
/// ```dart
/// Center(
///   child: CircularActionMenu(
///     enableRotation: false, // Set to true if you want the menu to continuously spin
///     centralIcon: Icon(Icons.share, size: 30.0),
///     centralIconColor: Colors.black87,
///     radius: 70.0,
///     itemSize: 48.0,
///     centralItemSize: 48.0,
///     items: [
///       CircularActionMenuItem(
///         icon: Icon(Icons.code),
///         tooltip: context.tr(LocaleKeys.autoGithub) ?? 'GitHub',
///         highlightColor: Colors.black,
///         onPressed: () => print('GitHub Tapped!'),
///       ),
///       CircularActionMenuItem(
///         icon: Icon(Icons.facebook),
///         tooltip: context.tr(LocaleKeys.autoFacebook) ?? 'Facebook',
///         highlightColor: const Color(0xFF1877F2),
///         onPressed: () => print('Facebook Tapped!'),
///       ),
///     ],
///   ),
/// )
/// ```
class CircularActionMenu extends StatefulWidget {
  final Widget centralIcon;
  final Color? centralIconColor;
  final List<CircularActionMenuItem> items;
  final double radius;
  final Duration revolutionDuration;
  final double itemSize;
  final double centralItemSize;
  final Color highlightColor;
  final bool enableRotation;

  const CircularActionMenu({
    super.key,
    required this.centralIcon,
    this.centralIconColor,
    required this.items,
    this.radius = 100.0,
    this.revolutionDuration = const Duration(seconds: 10),
    this.itemSize = 56.0,
    this.centralItemSize = 56.0,
    this.highlightColor = Colors.blueAccent,
    this.enableRotation = true,
  }) : assert(items.length <= 9, 'Max icon button cap is 9');

  @override
  State<CircularActionMenu> createState() => _CircularActionMenuState();
}

class _CircularActionMenuState extends State<CircularActionMenu>
    with TickerProviderStateMixin {
  late AnimationController _revolveController;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _hoveredIndexNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _revolveController = AnimationController(
      vsync: this,
      duration: widget.revolutionDuration,
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _revolveController.dispose();
    _expandController.dispose();
    _selectedIndexNotifier.dispose();
    _hoveredIndexNotifier.dispose();
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _selectedIndexNotifier.value = index;
    _revolveController.stop();

    // Trigger the callback
    widget.items[index].onPressed();

    // Auto-close after a short delay so the user can see the highlight/capsule effect
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _isExpandedNotifier.value = false;
        _revolveController.stop();
        _selectedIndexNotifier.value = null;
        _hoveredIndexNotifier.value = null;
        _expandController.reverse();
      }
    });
  }

  void _toggleRevolving() {
    if (!_isExpandedNotifier.value) {
      // 1. Expand out
      _isExpandedNotifier.value = true;
      _selectedIndexNotifier.value = null;
      _hoveredIndexNotifier.value = null;
      _expandController.forward().then((_) {
        if (mounted && _isExpandedNotifier.value && widget.enableRotation) {
          // 2. Start revolving once expanded
          _revolveController.repeat();
        }
      });
    } else {
      if (_selectedIndexNotifier.value != null) {
        // If an item was selected, tapping the center resumes revolving or just clears selection
        _selectedIndexNotifier.value = null;
        if (widget.enableRotation) {
          _revolveController.repeat();
        }
      } else {
        // If already expanded, collapse back in
        _isExpandedNotifier.value = false;
        _revolveController.stop();
        _expandController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius * 2 + max(widget.itemSize, widget.centralItemSize),
      height: widget.radius * 2 + max(widget.itemSize, widget.centralItemSize),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _revolveController,
          _expandController,
          _selectedIndexNotifier,
          _hoveredIndexNotifier,
          _isExpandedNotifier,
        ]),
        builder: (context, child) {
          final activeIndex =
              _hoveredIndexNotifier.value ?? _selectedIndexNotifier.value;
          final maxSize = max(widget.centralItemSize, widget.itemSize);
          final currentRadius = widget.radius * _expandAnimation.value;
          final currentOpacity = _expandController.value.clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. The Capsule Background (Hover / Selection effect)
              if (activeIndex != null && currentOpacity > 0) ...[
                Builder(
                  builder: (context) {
                    final item = widget.items[activeIndex];
                    final activeColor =
                        item.highlightColor ?? widget.highlightColor;
                    final angle =
                        -pi / 2 +
                        (2 * pi / widget.items.length) * activeIndex +
                        (_revolveController.value * 2 * pi);

                    final capsuleWidth =
                        currentRadius +
                        widget.centralItemSize / 2 +
                        widget.itemSize / 2;
                    final translateX =
                        capsuleWidth / 2 - widget.centralItemSize / 2;

                    return Transform.rotate(
                      angle: angle,
                      child: Transform.translate(
                        offset: Offset(translateX, 0),
                        child: Opacity(
                          opacity: currentOpacity,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: capsuleWidth,
                            height: maxSize,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(maxSize / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // 2. Revolving Icons
              if (currentOpacity > 0)
                ...List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final angle =
                      -pi / 2 +
                      (2 * pi / widget.items.length) * index +
                      (_revolveController.value * 2 * pi);

                  final isActive = activeIndex == index;
                  final activeColor =
                      item.highlightColor ?? widget.highlightColor;

                  return Transform.translate(
                    offset: Offset(
                      currentRadius * cos(angle),
                      currentRadius * sin(angle),
                    ),
                    child: Opacity(
                      opacity: currentOpacity,
                      child: MouseRegion(
                        onEnter: (_) {
                          if (_selectedIndexNotifier.value == null) {
                            _hoveredIndexNotifier.value = index;
                          }
                        },
                        onExit: (_) {
                          if (_hoveredIndexNotifier.value == index) {
                            _hoveredIndexNotifier.value = null;
                          }
                        },
                        child: Tooltip(
                          message: item.tooltip,
                          child: GestureDetector(
                            onTap: () => _onItemTapped(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: widget.itemSize,
                              height: widget.itemSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? activeColor
                                    : Theme.of(context).cardColor,
                                boxShadow: isActive
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: isActive
                                        ? Colors.white
                                        : Theme.of(context).iconTheme.color,
                                  ),
                                  child: item.icon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // 3. Central Icon
              MouseRegion(
                onEnter: (_) => _hoveredIndexNotifier.value = null,
                child: GestureDetector(
                  onTap: _toggleRevolving,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.centralItemSize,
                    height: widget.centralItemSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeIndex != null
                          ? (widget.items[activeIndex].highlightColor ??
                                widget.highlightColor)
                          : (widget.centralIconColor ??
                                Theme.of(context).primaryColor),
                      boxShadow: activeIndex != null
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: IconTheme(
                        data: const IconThemeData(color: Colors.white),
                        child: widget.centralIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
