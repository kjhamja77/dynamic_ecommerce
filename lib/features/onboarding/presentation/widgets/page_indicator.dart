import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.xsSpacing),
          width: index == currentPage 
              ? ResponsiveConstants.mdDimension 
              : ResponsiveConstants.smDimension,
          height: ResponsiveConstants.smDimension,
          decoration: BoxDecoration(
            color: index == currentPage ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
          ),
        ),
      ),
    );
  }
}
