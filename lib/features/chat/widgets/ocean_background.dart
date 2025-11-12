import 'dart:math';
import 'package:flutter/material.dart';

/// Animated ocean background with floating bubbles
class OceanBackground extends StatefulWidget {
  final Widget child;

  const OceanBackground({super.key, required this.child});

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with TickerProviderStateMixin {
  late List<Bubble> bubbles;
  late AnimationController _waveController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    
    // Initialize bubbles
    bubbles = List.generate(15, (index) => Bubble.random());
    
    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    // Bubble animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _bubbleController.addListener(() {
      setState(() {
        for (var bubble in bubbles) {
          bubble.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0A1929),
                      const Color(0xFF1A237E),
                    ]
                  : [
                      const Color(0xFFE3F2FD),
                      const Color(0xFFBBDEFB),
                    ],
            ),
          ),
        ),
        
        // Animated waves
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                animation: _waveController,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Floating bubbles
        ...bubbles.map((bubble) => Positioned(
          left: bubble.x,
          top: bubble.y,
          child: Opacity(
            opacity: bubble.opacity,
            child: Container(
              width: bubble.size,
              height: bubble.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        )),
        
        // Content
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  WavePainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.blue.withOpacity(0.1)
          : Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;
    final phase = animation.value * 2 * pi;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 +
          waveHeight * sin((x / waveLength * 2 * pi) + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = isDark
          ? Colors.cyan.withOpacity(0.05)
          : Colors.lightBlue.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 +
          waveHeight * sin((x / waveLength * 2 * pi) - phase);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class Bubble {
  double x;
  double y;
  final double size;
  final double speed;
  double opacity;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory Bubble.random() {
    final random = Random();
    return Bubble(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      size: random.nextDouble() * 30 + 10,
      speed: random.nextDouble() * 0.5 + 0.2,
      opacity: random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update() {
    y -= speed;
    if (y < -size) {
      y = 800;
      x = Random().nextDouble() * 400;
    }
  }
}

