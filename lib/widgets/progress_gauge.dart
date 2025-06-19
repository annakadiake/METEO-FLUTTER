import 'package:flutter/material.dart';
import 'dart:math';

class ProgressGauge extends StatefulWidget {
  final double progress;
  final VoidCallback? onComplete;
  final bool isCompleted;

  const ProgressGauge({
    super.key,
    required this.progress,
    this.onComplete,
    this.isCompleted = false,
  });

  @override
  State<ProgressGauge> createState() => _ProgressGaugeState();
}

class _ProgressGaugeState extends State<ProgressGauge>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isCompleted ? widget.onComplete : null,
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: GaugePainter(
                progress: _animation.value,
                isCompleted: widget.isCompleted,
              ),
              child: Center(
                child:
                    widget.isCompleted
                        ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_animation.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Icon(
                              Icons.cloud_download,
                              size: 24,
                              color: Colors.blue,
                            ),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final bool isCompleted;

  GaugePainter({required this.progress, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint =
        Paint()
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    if (isCompleted) {
      progressPaint.color = Colors.green;
    } else {
      progressPaint.shader = LinearGradient(
        colors: [Colors.blue.shade400, Colors.purple.shade400],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
