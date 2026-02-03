import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

class AppPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppPullToRefresh({super.key, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await HapticService.lightImpact();
        return onRefresh();
      },
      trigger: IndicatorTrigger.leadingEdge,
      leadingScrollIndicatorVisible: false,
      builder: (context, child, controller) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final progress = controller.value.clamp(0.0, 1.0);
                final opacity = controller.isLoading ? 1.0 : progress;
                final dy = (1 - progress) * -36.0;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Opacity(
                    opacity: opacity,
                    child: _CheckMark(progress: progress, isLoading: controller.isLoading),
                  ),
                );
              },
            ),
            Transform.translate(
              offset: Offset(0, controller.value * 24.0),
              child: child,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class _CheckMark extends StatelessWidget {
  final double progress;
  final bool isLoading;

  const _CheckMark({required this.progress, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final size = 24.0;
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: _CheckPainter(progress: progress, isLoading: isLoading),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final bool isLoading;

  _CheckPainter({required this.progress, required this.isLoading});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;

    // Draw circular background progress
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.2);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final sweep = (isLoading ? 1.0 : progress) * 3.1415 * 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415 / 2, sweep, false, paint);
    canvas.drawCircle(center, radius, circlePaint);

    // Draw check mark when nearly ready
    if (progress >= 0.8 || isLoading) {
      final p1 = Offset(size.width * 0.25, size.height * 0.55);
      final p2 = Offset(size.width * 0.45, size.height * 0.75);
      final p3 = Offset(size.width * 0.75, size.height * 0.35);
      canvas.drawLine(p1, p2, paint);
      canvas.drawLine(p2, p3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isLoading != isLoading;
  }
}


