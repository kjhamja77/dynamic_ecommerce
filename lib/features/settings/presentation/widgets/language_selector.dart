import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../core/services/first_launch_service.dart';
import '../../../../core/services/language_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/language.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../orders/core/constants/order_constants.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/welcome_bloc.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../search/presentation/bloc/search_event.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/widgets/app_loading_widget.dart';

class LanguageSelector extends StatelessWidget {
  final Language currentLanguage;
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService = AppLocalizationService();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListenableBuilder(
      listenable: localizationService,
      builder: (context, child) {
        // Get current language from localization service (this is the source of truth)
        final currentLocale = localizationService.currentLocale;
        
        final content = Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              for (final language in Language.supportedLanguages)
                _LanguageOption(
                  language: language,
                  isSelected: language.code.code == currentLocale.languageCode,
                  onTap: () async {
                    final isSelected = language.code.code == currentLocale.languageCode;
                    if (!isSelected) {
                      // Start global language-change loader so ALL pages can
                      // show a consistent skeleton while translations + data
                      // are being refreshed.
                      localizationService.beginLanguageChange();
                      try {
                        // Get success message in the target language before switching
                        final successMessage = language.code.code == 'ar' 
                            ? 'تم تغيير اللغة بنجاح!'
                            : 'Language changed successfully!';

                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.changingLanguage),
                            duration: const Duration(milliseconds: 800),
                            backgroundColor: OrderConstants.infoColor,
                          ),
                        );

                        // Update the localization service (primary source of truth).
                        // AppLocalizationService internally:
                        // - Persists the language
                        // - Marks language as selected
                        // - Syncs LanguageService / Accept-Language header.
                        await localizationService.setLanguage(language.code.code);
                        
                        // Update SettingsBloc for consistency
                        if (context.mounted) {
                          context.read<SettingsBloc>().add(UpdateLanguage(language));
                        }

                        // Proactively refresh ALL data-dependent BLoCs in the new language
                        // This ensures all API-driven content is reloaded with the updated Accept-Language header
                        if (context.mounted) {
                          // Reload home pages and featured products
                          try {
                            final homeBloc = context.read<HomeBloc>();
                            homeBloc.add(const LoadPages(1, forceRefresh: true)); // userId 1 (same as DynamicHomeTabWidget)
                            homeBloc.add(LoadFeaturedProducts());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading HomeBloc: $e');
                          }

                          // Reload rotating welcome texts
                          try {
                            context.read<WelcomeBloc>().add(LoadWelcomeTexts());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading WelcomeBloc: $e');
                          }

                          // Reload search data (categories and tabs)
                          try {
                            context.read<SearchBloc>().add(const LoadSearchData());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading SearchBloc: $e');
                          }

                          // Reload favorites
                          try {
                            context.read<FavoritesBloc>().add(LoadFavorites());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading FavoritesBloc: $e');
                          }

                          // Reload user profile (may contain localized data)
                          try {
                            context.read<ProfileBloc>().add(LoadUserProfile());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading ProfileBloc: $e');
                          }

                          // Reload cart (product names/descriptions may be localized)
                          try {
                            context.read<CartBloc>().add(const LoadCart());
                          } catch (e) {
                            debugPrint('⚠️ LanguageSelector: Error reloading CartBloc: $e');
                          }
                        }

                        // Call optional callback for any extra side-effects
                        onLanguageChanged?.call();
                      } catch (e) {
                        // Show error message in current language (before change)
                        final errorMessage = currentLocale.languageCode == 'ar'
                            ? 'خطأ في تغيير اللغة. يرجى المحاولة مرة أخرى.'
                            : 'Error changing language. Please try again.';
                            
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              duration: const Duration(seconds: 3),
                              backgroundColor: OrderConstants.errorColor,
                            ),
                          );
                        }
                      } finally {
                        // Keep the loader a bit longer so that home, search,
                        // etc. have time to reload their API data in the new language.
                        await localizationService.endLanguageChange();
                      }
                    }
                  },
                ),
            ],
          ),
        );

        // When language is changing, show a loader overlay on top of the
        // language selector section so the user clearly sees that the
        // change is in progress.
        if (localizationService.isChangingLanguage) {
          return Stack(
            children: [
              content,
              Positioned.fill(
                child: Container(
                  color: theme.colorScheme.background.withValues(alpha: 0.6),
                  child: Center(
                    child: const AppLoadingWidget.small(
                      showMessage: false,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(ResponsiveConstants.mdSpacing),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? OrderConstants.primaryColor.withValues(alpha: 0.2)
                    : OrderConstants.primaryColor.withValues(alpha: 0.1))
                : (isDark
                    ? colorScheme.surface
                    : Colors.white),
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(
              color: isSelected
                  ? OrderConstants.primaryColor
                  : (isDark
                      ? colorScheme.outline.withValues(alpha: 0.4)
                      : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                language.flag,
                style: TextStyle(fontSize: ResponsiveConstants.xlFontSize),
              ),
              SizedBox(width: ResponsiveConstants.mdSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    if (language.nativeName != language.name)
                      Text(
                        language.nativeName,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: OrderConstants.primaryColor,
                        size: ResponsiveConstants.mdIconSize,
                        key: const ValueKey('selected'),
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: isDark
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : Colors.grey.shade400,
                        size: ResponsiveConstants.mdIconSize,
                        key: const ValueKey('unselected'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}