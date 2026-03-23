import 'package:flutter/material.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/features/home/presentation/theme/home_decorations.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mdPadding,
          vertical: ResponsiveConstants.smPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.shade600
              : (isDark ? colorScheme.surfaceContainerHighest : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: homeCardBoxShadow(context, [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ]),
        ),
        child: Text(
          label,
          style: AppFonts.getTextStyle(fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
