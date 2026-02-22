import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/order.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../core/constants/order_constants.dart';

class OrderStatusFilter extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusChanged;

  const OrderStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.filterByStatus,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context: context,
                label: loc.all,
                isSelected: selectedStatus == null,
                onTap: () async {
                  await HapticService.buttonClick();
                  onStatusChanged(null);
                },
              ),
              ...OrderStatus.values.map((status) {
                final statusLabel = OrderConstants.localizedStatus(context, status);
                final statusKey = status.name;
                final isSelected = selectedStatus == statusKey;
                return _buildFilterChip(
                  context: context,
                  label: statusLabel,
                  isSelected: isSelected,
                  onTap: () async {
                    await HapticService.buttonClick();
                    onStatusChanged(statusKey);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: ResponsiveConstants.smSpacing),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
            vertical: ResponsiveConstants.smPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
