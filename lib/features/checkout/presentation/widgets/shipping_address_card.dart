import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/shipping_address.dart';
import '../../../../core/theme/app_fonts.dart';
import '../constants/checkout_constants.dart';
import '../../../../l10n/app_localizations.dart';

class ShippingAddressCard extends StatelessWidget {
  final ShippingAddress address;
  final bool isSelected;
  final bool isOnlyAddress; // If true, this is the only address and should always be selected
  final VoidCallback? onTap; // For selecting address (when complete)
  final VoidCallback? onEdit; // For editing address

  const ShippingAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    this.isOnlyAddress = false,
    this.onTap,
    this.onEdit,
  });

  bool get _isIncomplete {
    // Only check main required fields: street name, province, and phone number
    return address.streetAddress.trim().isEmpty ||
        address.provinceId == null ||
        address.phone.trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasName = address.fullName.trim().isNotEmpty;
    final displayTitle = hasName
        ? address.fullName
        : (address.city.isNotEmpty
            ? address.city
            : (address.state.isNotEmpty ? address.state : AppLocalizations.of(context)!.address));
    final hasAddressDetails = address.fullAddress.trim().isNotEmpty;

    final VoidCallback? cardTapHandler = isOnlyAddress ? null : (_isIncomplete ? onEdit : onTap);
    final effectiveIsSelected = isOnlyAddress ? true : isSelected;
    final shadowAlpha = theme.brightness == Brightness.dark ? 0.2 : 0.06;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cardTapHandler,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: effectiveIsSelected
                ? CheckoutConstants.primaryColor
                : (_isIncomplete ? Colors.orange.shade300 : colorScheme.outline.withValues(alpha: 0.5)),
            width: effectiveIsSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: shadowAlpha),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveIsSelected ? CheckoutConstants.primaryColor : colorScheme.outline,
                  width: 2,
                ),
                color: effectiveIsSelected ? CheckoutConstants.primaryColor : Colors.transparent,
              ),
              child: effectiveIsSelected
                  ? Icon(
                      Icons.check,
                      color: colorScheme.onPrimary,
                      size: 12.w,
                    )
                  : null,
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.mdFontSize,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Incomplete warning badge
                      if (_isIncomplete) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12.w,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                AppLocalizations.of(context)!.incomplete,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.xsFontSize,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      // Edit button - bigger when complete, smaller when incomplete
                      if (onEdit != null)
                        GestureDetector(
                          onTap: () {
                            // Stop propagation to prevent card tap
                            onEdit?.call();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _isIncomplete ? 6.w : 10.w,
                              vertical: _isIncomplete ? 3.h : 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: _isIncomplete ? 12.w : 16.w,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  AppLocalizations.of(context)!.edit,
                                  style: AppFonts.getTextStyle(
                                    fontSize: _isIncomplete 
                                        ? ResponsiveConstants.xsFontSize 
                                        : ResponsiveConstants.smFontSize,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Show address details or incomplete message
                  if (hasAddressDetails)
                  Text(
                    address.fullAddress,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.tapToCompleteAddressDetails,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                  ),
                  SizedBox(height: 4.h),
                  // Force phone number to display left-to-right even in RTL mode
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      address.phone,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // Default badge - below address details
                  if (address.isDefault) ...[
                    SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: CheckoutConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'افتراضي',
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.xsFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                      ),
                    ),
                  ],
                ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
