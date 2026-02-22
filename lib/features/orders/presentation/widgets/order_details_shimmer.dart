import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class OrderDetailsShimmer extends StatelessWidget {
  const OrderDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade200;
    final highlightColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey.shade100;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            _buildCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.lgIconSize),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _line(height: 12, width: 80),
                            SizedBox(height: ResponsiveConstants.xsSpacing),
                            _line(height: 18, width: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.mdIconSize),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _line(height: 12, width: 100),
                            SizedBox(height: ResponsiveConstants.xsSpacing),
                            _line(height: 16, width: 140),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  _line(height: 12, width: 150),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Summary Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(height: 18, width: 120),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ...List.generate(4, (index) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _line(height: 14, width: 100),
                        _line(height: 14, width: 80),
                      ],
                    ),
                  )),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  Builder(
                    builder: (context) => Divider(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _line(height: 18, width: 100),
                      _line(height: 20, width: 120),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Order Items Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.mdIconSize),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      _line(height: 18, width: 120),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  _line(height: 12, width: 150),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ...List.generate(2, (index) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                    child: Row(
                      children: [
                        _square(dimension: 60),
                        SizedBox(width: ResponsiveConstants.mdSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(height: 14, width: double.infinity),
                              SizedBox(height: ResponsiveConstants.xsSpacing),
                              _line(height: 12, width: 100),
                              SizedBox(height: ResponsiveConstants.xsSpacing),
                              _line(height: 12, width: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Delivery Status Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.lgIconSize),
                      SizedBox(width: ResponsiveConstants.mdSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _line(height: 12, width: 100),
                            SizedBox(height: ResponsiveConstants.xsSpacing),
                            _line(height: 18, width: 140),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _line(height: 14, width: double.infinity),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  _line(height: 14, width: 200),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Shipping Info Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.mdIconSize),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      _line(height: 18, width: 140),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ...List.generate(3, (index) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 120),
                        Expanded(child: _line(height: 14, width: double.infinity)),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Payment Details Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _circle(dimension: ResponsiveConstants.mdIconSize),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      _line(height: 18, width: 120),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ...List.generate(2, (index) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _line(height: 14, width: 100),
                        _line(height: 14, width: 80),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Timeline Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(height: 18, width: 100),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ...List.generate(3, (index) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _circle(dimension: 24),
                        SizedBox(width: ResponsiveConstants.mdSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(height: 16, width: 120),
                              SizedBox(height: ResponsiveConstants.xsSpacing),
                              _line(height: 12, width: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              child: Column(
                children: [
                  _button(height: 48),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _button(height: 48),
                ],
              ),
            ),

            SizedBox(height: ResponsiveConstants.xlSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          margin: EdgeInsets.all(ResponsiveConstants.mdPadding),
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _line({required double height, required double width}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
          ),
        );
      },
    );
  }

  Widget _circle({required double dimension}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          height: dimension,
          width: dimension,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _square({required double dimension}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          height: dimension,
          width: dimension,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          ),
        );
      },
    );
  }

  Widget _button({required double height}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          ),
        );
      },
    );
  }
}

