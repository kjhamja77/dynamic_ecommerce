import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Status chips use backend [order_status] strings exactly as returned (any language).
class OrderStatusFilter extends StatelessWidget {
  final String? selectedStatus;
  final void Function(String?) onStatusChanged;
  final ScrollController? scrollController;
  /// Distinct non-empty `order_status` values from loaded orders (first-seen order).
  final List<String> apiOrderStatuses;
  final bool showRefundChip;

  const OrderStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.scrollController,
    this.apiOrderStatuses = const <String>[],
    this.showRefundChip = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
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
                  ...apiOrderStatuses.map((apiLabel) {
                    final isSelected = selectedStatus == apiLabel;
                    return _buildFilterChip(
                      context: context,
                      label: apiLabel,
                      isSelected: isSelected,
                      onTap: () async {
                        await HapticService.buttonClick();
                        onStatusChanged(apiLabel);
                      },
                    );
                  }),
                  if (showRefundChip)
                    _buildFilterChip(
                      context: context,
                      label: loc.returns,
                      isSelected: selectedStatus == 'refund',
                      onTap: () async {
                        await HapticService.buttonClick();
                        onStatusChanged('refund');
                      },
                    ),
                ],
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
