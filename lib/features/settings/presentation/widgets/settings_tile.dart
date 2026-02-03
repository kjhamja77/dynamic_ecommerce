import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: contentPadding ?? EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdSpacing,
            vertical: ResponsiveConstants.xsSpacing,
          ),
          leading: leading,
          title: Text(
            title,
            style: AppFonts.getTextStyle(fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          subtitle: subtitle != null ? Text(
            subtitle!,
            style: AppFonts.getTextStyle(fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ) : null,
          trailing: trailing,
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: ResponsiveConstants.mdSpacing,
            endIndent: ResponsiveConstants.mdSpacing,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}
