import 'package:flutter/material.dart';

class _OverlayAnimationWrapper extends StatefulWidget {
  final Function(AnimationController) onInit;
  final Widget Function(BuildContext, double) builder;

  const _OverlayAnimationWrapper({required this.onInit, required this.builder});

  @override
  State<_OverlayAnimationWrapper> createState() =>
      _OverlayAnimationWrapperState();
}

class _OverlayAnimationWrapperState extends State<_OverlayAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    widget.onInit(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.builder(context, _controller.value),
    );
  }
}

class HighlightOverlay {
  static OverlayEntry show(BuildContext context, GlobalKey targetKey, String screentext) {
    final renderBox = targetKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
  final String string = screentext;
    late AnimationController controller;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        // We use a StatefullWidget or a simple TickerProvider for the animation
        return _OverlayAnimationWrapper(
          onInit: (c) => controller = c,
          // ... inside your _OverlayAnimationWrapper builder ...
          builder: (context, pulse) {
            final RRect hole = RRect.fromRectAndRadius(
              Rect.fromLTWH(
                position.dx - 4,
                position.dy - 4,
                size.width + 8,
                size.height + 8,
              ),
              const Radius.circular(12),
            );

            return Stack(
              children: [
                // 1. THE BLOCKER
                GestureDetector(
                  onTap: () => {},
                  child: ClipPath(
                    clipper: HoleClipper(hole: hole),
                    child: Container(
                      color: Colors.transparent
                    ),
                  ),
                ),

                // 2. THE GLOW
                IgnorePointer(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _HighlightPainter(hole: hole, pulse: pulse),
                  ),
                ),

                // 3. THE TEXT/BUTTON BELOW THE HOLE
                Positioned(
                  top: hole.bottom + 10, // 20px space below the hole
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                      
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child:  Text(
                          string,
                          style: TextStyle(color: Color(0xFF2d5d5d)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(entry);
    return entry;
  }
}

/// Creates a "hole" in the overlay interaction area
class HoleClipper extends CustomClipper<Path> {
  final RRect hole;
  HoleClipper({required this.hole});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd; // This subtraction creates the hole
  }

  @override
  bool shouldReclip(HoleClipper oldClipper) => oldClipper.hole != hole;
}

/// Optimized Painter for the moving stroke
class _HighlightPainter extends CustomPainter {
  final RRect hole;
  final double pulse;

  _HighlightPainter({required this.hole, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = pulse * 2 * 3.1415926;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    // Create a shader that rotates around the center of the hole
    glowPaint.shader = SweepGradient(
      center: Alignment.center,
      transform: GradientRotation(angle),
      colors: [
        const Color.fromARGB(0, 33, 149, 243),
        const Color.fromARGB(0, 33, 149, 243),
        Colors.blue,
        const Color.fromARGB(0, 33, 149, 243),
        const Color.fromARGB(0, 33, 149, 243),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(hole.outerRect);

    // Draw the glow slightly inflated to sit on the edge
    canvas.drawRRect(hole.inflate(2), glowPaint);
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// Helper to handle the AnimationController lifecycle within an Overlay
