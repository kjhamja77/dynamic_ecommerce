import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';
import '../services/app_localization_service.dart';
import '../../l10n/app_localizations.dart';

class LocalizedTextExample extends StatelessWidget {
  const LocalizedTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = AppLocalizationService();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.localizedTextExample,
              style: AppFonts.getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Example 1: Using AppLocalizations
            _buildExample(
              title: AppLocalizations.of(context)!.usingAppLocalizations,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.welcome),
                  Text(AppLocalizations.of(context)!.settings),
                  Text(AppLocalizations.of(context)!.addToCart),
                  Text(AppLocalizations.of(context)!.price),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example 2: Using localization service helper
            _buildExample(
              title: AppLocalizations.of(context)!.usingLocalizationService,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  localizationService.buildLocalizedText(
                    AppLocalizations.of(context)!.home,
                    style: AppFonts.getTextStyle(fontSize: 16),
                  ),
                  localizationService.buildLocalizedText(
                    AppLocalizations.of(context)!.search,
                    style: AppFonts.getTextStyle(fontSize: 16),
                  ),
                  localizationService.buildLocalizedText(
                    AppLocalizations.of(context)!.favorites,
                    style: AppFonts.getTextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example 3: RTL-aware layout
            _buildExample(
              title: AppLocalizations.of(context)!.rtlLayout,
              child: Row(
                children: [
                  Icon(Icons.home),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.home),
                  const Spacer(),
                  Icon(Icons.search),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.search),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: child,
        ),
      ],
    );
  }
}
