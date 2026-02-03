import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/responsive_constants.dart';

/// A constant loading widget that can be used throughout the app
/// Uses the loading_animation_widget package for beautiful animations
class AppLoadingWidget extends StatelessWidget {
  final LoadingAnimationType animationType;
  final Color? color;
  final double? size;
  final String? message;
  final bool showMessage;

  const AppLoadingWidget({
    super.key,
    this.animationType = LoadingAnimationType.staggeredDotsWave,
    this.color,
    this.size,
    this.message,
    this.showMessage = false,
  });

  /// Default loading widget with staggered dots wave animation
  const AppLoadingWidget.defaultLoading({
    super.key,
    this.message,
    this.showMessage = false,
  }) : animationType = LoadingAnimationType.staggeredDotsWave,
       color = null,
       size = null;

  /// Small loading widget for buttons and small areas
  const AppLoadingWidget.small({
    super.key,
    this.message,
    this.showMessage = false,
  }) : animationType = LoadingAnimationType.threeRotatingDots,
       color = null,
       size = null;

  /// Large loading widget for full screen loading
  const AppLoadingWidget.large({
    super.key,
    this.message,
    this.showMessage = false,
  }) : animationType = LoadingAnimationType.staggeredDotsWave,
       color = null,
       size = null;

  /// Custom loading widget with specific animation and color
  const AppLoadingWidget.custom({
    super.key,
    required this.animationType,
    this.color,
    this.size,
    this.message,
    this.showMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = color ?? theme.primaryColor;
    final defaultSize = size ?? _getDefaultSize();

    Widget loadingAnimation = _buildLoadingAnimation(defaultColor, defaultSize);

    if (showMessage && message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingAnimation,
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            message!,
            style: TextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingAnimation;
  }

  Widget _buildLoadingAnimation(Color color, double size) {
    switch (animationType) {
      case LoadingAnimationType.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );
      case LoadingAnimationType.threeRotatingDots:
        return LoadingAnimationWidget.threeRotatingDots(
          color: color,
          size: size,
        );
      case LoadingAnimationType.fourRotatingDots:
        return LoadingAnimationWidget.fourRotatingDots(
          color: color,
          size: size,
        );
      case LoadingAnimationType.beat:
        return LoadingAnimationWidget.beat(
          color: color,
          size: size,
        );
      case LoadingAnimationType.waveDots:
        return LoadingAnimationWidget.waveDots(
          color: color,
          size: size,
        );
      case LoadingAnimationType.inkDrop:
        return LoadingAnimationWidget.inkDrop(
          color: color,
          size: size,
        );
      case LoadingAnimationType.twistingDots:
        return LoadingAnimationWidget.twistingDots(
          leftDotColor: color,
          rightDotColor: color.withValues(alpha: 0.6),
          size: size,
        );
      case LoadingAnimationType.threeArchedCircle:
        return LoadingAnimationWidget.threeArchedCircle(
          color: color,
          size: size,
        );
      case LoadingAnimationType.fallingDot:
        return LoadingAnimationWidget.fallingDot(
          color: color,
          size: size,
        );
      case LoadingAnimationType.bouncingBall:
        return LoadingAnimationWidget.bouncingBall(
          color: color,
          size: size,
        );
      case LoadingAnimationType.flickr:
        return LoadingAnimationWidget.flickr(
          leftDotColor: color,
          rightDotColor: color.withValues(alpha: 0.6),
          size: size,
        );
      case LoadingAnimationType.twoRotatingArc:
        return LoadingAnimationWidget.twoRotatingArc(
          color: color,
          size: size,
        );
      case LoadingAnimationType.horizontalRotatingDots:
        return LoadingAnimationWidget.horizontalRotatingDots(
          color: color,
          size: size,
        );
      case LoadingAnimationType.newtonCradle:
        return LoadingAnimationWidget.newtonCradle(
          color: color,
          size: size,
        );
      case LoadingAnimationType.stretchedDots:
        return LoadingAnimationWidget.stretchedDots(
          color: color,
          size: size,
        );
      case LoadingAnimationType.halfTriangleDot:
        return LoadingAnimationWidget.halfTriangleDot(
          color: color,
          size: size,
        );
      case LoadingAnimationType.dotsTriangle:
        return LoadingAnimationWidget.dotsTriangle(
          color: color,
          size: size,
        );
      case LoadingAnimationType.discreteCircular:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );
      case LoadingAnimationType.progressiveDots:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );
      case LoadingAnimationType.hexagonDots:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );
    }
  }

  double _getDefaultSize() {
    switch (animationType) {
      case LoadingAnimationType.staggeredDotsWave:
      case LoadingAnimationType.waveDots:
      case LoadingAnimationType.inkDrop:
      case LoadingAnimationType.beat:
      case LoadingAnimationType.fallingDot:
      case LoadingAnimationType.bouncingBall:
      case LoadingAnimationType.flickr:
      case LoadingAnimationType.newtonCradle:
      case LoadingAnimationType.stretchedDots:
      case LoadingAnimationType.halfTriangleDot:
      case LoadingAnimationType.dotsTriangle:
      case LoadingAnimationType.discreteCircular:
      case LoadingAnimationType.progressiveDots:
      case LoadingAnimationType.hexagonDots:
        return ResponsiveConstants.mdIconSize;
      case LoadingAnimationType.threeRotatingDots:
      case LoadingAnimationType.fourRotatingDots:
      case LoadingAnimationType.twistingDots:
      case LoadingAnimationType.threeArchedCircle:
      case LoadingAnimationType.twoRotatingArc:
      case LoadingAnimationType.horizontalRotatingDots:
        return ResponsiveConstants.mdIconSize;
    }
  }
}

/// Enum for different loading animation types
enum LoadingAnimationType {
  staggeredDotsWave,
  threeRotatingDots,
  fourRotatingDots,
  beat,
  waveDots,
  inkDrop,
  twistingDots,
  threeArchedCircle,
  fallingDot,
  bouncingBall,
  flickr,
  twoRotatingArc,
  horizontalRotatingDots,
  newtonCradle,
  stretchedDots,
  halfTriangleDot,
  dotsTriangle,
  discreteCircular,
  progressiveDots,
  hexagonDots,
}
