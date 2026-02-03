import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class AddressShimmer extends StatelessWidget {
  const AddressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      itemCount: 3, // Show 3 shimmer items
      separatorBuilder: (_, __) => SizedBox(height: ResponsiveConstants.mdSpacing),
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        final baseColor = isDark 
            ? colorScheme.outline.withValues(alpha: 0.3)
            : Colors.grey.shade300;
        final highlightColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.5)
            : Colors.grey.shade100;
        
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerHeader(context),
            _buildShimmerAddressDetails(context),
            _buildShimmerContactInfo(context),
            _buildShimmerActions(context),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildShimmerHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAddressDetails(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: ResponsiveConstants.xsSpacing),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: ResponsiveConstants.xsSpacing),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: ResponsiveConstants.xsSpacing),
              Container(
                width: 150,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContactInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveConstants.xsSpacing),
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
