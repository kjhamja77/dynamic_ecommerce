import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../services/app_localization_service.dart';
import '../../l10n/app_localizations.dart';
import '../services/app_restart.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocalizationService(),
      builder: (context, child) {
        final localizationService = AppLocalizationService();
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: AppFonts.getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context: context,
                  languageCode: 'en',
                  languageName: AppLocalizations.of(context)!.english,
                  nativeName: AppLocalizations.of(context)!.english,
                  flag: '🇺🇸',
                  isSelected: localizationService.currentLocale.languageCode == 'en',
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context: context,
                  languageCode: 'ar',
                  languageName: AppLocalizations.of(context)!.arabic,
                  nativeName: 'العربية',
                  flag: '🇸🇦',
                  isSelected: localizationService.currentLocale.languageCode == 'ar',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
  }) {
    final localizationService = AppLocalizationService();
    
    return InkWell(
      onTap: () async {
        await HapticService.buttonClick();
        
        // Only restart if language is actually changing
        if (!isSelected) {
          await localizationService.setLanguage(languageCode);
          
          // Show loading message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.changingLanguage),
              duration: const Duration(milliseconds: 800),
              backgroundColor: Colors.blue,
            ),
          );
          
          // Restart the app to fully apply the new locale
          if (context.mounted) {
            AppRestart.restart(context);
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: AppFonts.getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: AppFonts.getTextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
