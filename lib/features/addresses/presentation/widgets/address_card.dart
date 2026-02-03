import 'package:flutter/material.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault 
              ? colorScheme.primary 
              : colorScheme.outline.withOpacity(0.2),
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildAddressDetails(context),
              _buildContactInfo(context),
              _buildActions(context),
            ],
          ),
          // Star icon for setting as default (positioned based on text direction)
          if (!address.isDefault)
            Builder(
              builder: (context) {
                final isRtl = Directionality.of(context) == TextDirection.rtl;
                return Positioned(
                  top: ResponsiveConstants.smPadding,
                  left: isRtl ? ResponsiveConstants.smPadding : null,
                  right: isRtl ? null : ResponsiveConstants.smPadding,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSetDefault,
                      borderRadius: BorderRadius.circular(20),
                      child: Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;
                          final isDark = theme.brightness == Brightness.dark;
                          
                          return Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.star_outline,
                              color: colorScheme.onSurface.withOpacity(0.7),
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: address.isDefault 
            ? colorScheme.primary 
            : (isDark ? colorScheme.surface : Colors.grey.shade50),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.smPadding),
            decoration: BoxDecoration(
              color: address.isDefault 
                  ? Colors.white.withValues(alpha: 0.2)
                  : (isDark ? colorScheme.surface : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: address.isDefault 
                  ? Colors.white 
                  : colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Text(
              (address.label.isNotEmpty ? address.label : AppLocalizations.of(context)!.address),
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w500,
                color: address.isDefault 
                    ? Colors.white 
                    : colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (address.isDefault)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.smPadding,
                vertical: ResponsiveConstants.xsPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.defaultAddress,
                style: AppFonts.getTextStyle(color: Colors.white,
                  fontSize: ResponsiveConstants.xsFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.address,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          Text(
            address.fullAddress,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Row(
        children: [
          Icon(
            Icons.phone,
            color: colorScheme.onSurface.withOpacity(0.7),
            size: 16,
          ),
          SizedBox(width: ResponsiveConstants.xsSpacing),
          // Force phone number to display left-to-right even in RTL mode
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              address.phone,
              style: AppFonts.getTextStyle(color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: ResponsiveConstants.smFontSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 18),
              label: Text(
                AppLocalizations.of(context)!.edit,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, size: 18),
              label: Text(
                AppLocalizations.of(context)!.delete,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
