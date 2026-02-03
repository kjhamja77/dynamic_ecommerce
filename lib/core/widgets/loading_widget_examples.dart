import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';
import 'app_loading_widget.dart';
import '../../core/theme/app_fonts.dart';

/// Example usage of all available loading animations
/// This file demonstrates how to use the AppLoadingWidget with different configurations
class LoadingWidgetExamples {
  /// Get a list of all available loading animation examples
  static List<Widget> getAllExamples(BuildContext context) {
    return [
      _buildExampleCard(
        context,
        'Default Loading',
        'AppLoadingWidget.defaultLoading()',
        const AppLoadingWidget.defaultLoading(
          message: 'Loading products...',
          showMessage: true,
        ),
      ),
      _buildExampleCard(
        context,
        'Small Loading',
        'AppLoadingWidget.small()',
        const AppLoadingWidget.small(
          message: 'Loading...',
          showMessage: true,
        ),
      ),
      _buildExampleCard(
        context,
        'Large Loading',
        'AppLoadingWidget.large()',
        const AppLoadingWidget.large(
          message: 'Loading data...',
          showMessage: true,
        ),
      ),
      _buildExampleCard(
        context,
        'Staggered Dots Wave',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.staggeredDotsWave)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.staggeredDotsWave,
        ),
      ),
      _buildExampleCard(
        context,
        'Three Rotating Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.threeRotatingDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.threeRotatingDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Four Rotating Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.fourRotatingDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.fourRotatingDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Beat Animation',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.beat)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.beat,
        ),
      ),
      _buildExampleCard(
        context,
        'Wave Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.waveDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.waveDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Ink Drop',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.inkDrop)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.inkDrop,
        ),
      ),
      _buildExampleCard(
        context,
        'Twisting Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.twistingDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.twistingDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Three Arched Circle',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.threeArchedCircle)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.threeArchedCircle,
        ),
      ),
      _buildExampleCard(
        context,
        'Falling Dot',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.fallingDot)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.fallingDot,
        ),
      ),
      _buildExampleCard(
        context,
        'Bouncing Ball',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.bouncingBall)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.bouncingBall,
        ),
      ),
      _buildExampleCard(
        context,
        'Flickr',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.flickr)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.flickr,
        ),
      ),
      _buildExampleCard(
        context,
        'Two Rotating Arc',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.twoRotatingArc)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.twoRotatingArc,
        ),
      ),
      _buildExampleCard(
        context,
        'Horizontal Rotating Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.horizontalRotatingDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.horizontalRotatingDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Newton Cradle',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.newtonCradle)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.newtonCradle,
        ),
      ),
      _buildExampleCard(
        context,
        'Stretched Dots',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.stretchedDots)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.stretchedDots,
        ),
      ),
      _buildExampleCard(
        context,
        'Half Triangle Dot',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.halfTriangleDot)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.halfTriangleDot,
        ),
      ),
      _buildExampleCard(
        context,
        'Dots Triangle',
        'AppLoadingWidget.custom(animationType: LoadingAnimationType.dotsTriangle)',
        const AppLoadingWidget.custom(
          animationType: LoadingAnimationType.dotsTriangle,
        ),
      ),
    ];
  }

  /// Build an example card for a loading animation
  static Widget _buildExampleCard(
    BuildContext context,
    String title,
    String code,
    Widget loadingWidget,
  ) {
    return Card(
      margin: EdgeInsets.all(ResponsiveConstants.smSpacing),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            loadingWidget,
            SizedBox(height: ResponsiveConstants.smSpacing),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveConstants.smSpacing),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Text(
                code,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
