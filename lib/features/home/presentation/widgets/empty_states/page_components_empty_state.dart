import 'package:flutter/material.dart';
import '../../constants/home_constants.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/constants/responsive_constants.dart';
import '../../../../../l10n/app_localizations.dart';

class PageComponentsEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const PageComponentsEmptyState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 56,
              color: HomeConstants.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              localizations?.noComponentsYet ?? 'No components yet',
              style: AppFonts.getTextStyle(fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              localizations?.addComponentsFromDashboard ?? 
                  'Add components from dashboard to populate this page.',
              textAlign: TextAlign.center,
              style: AppFonts.getTextStyle(fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeConstants.primaryColor,
                foregroundColor: HomeConstants.backgroundColor,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.mdPadding,
                  vertical: ResponsiveConstants.smPadding + 2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(localizations?.refresh ?? 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

