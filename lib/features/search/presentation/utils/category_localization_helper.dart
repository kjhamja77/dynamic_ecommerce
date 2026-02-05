import 'package:flutter/widgets.dart';

/// Helper to provide localized labels for well‑known top‑level categories
/// when the backend only returns English names.
///
/// This is intentionally a very small mapping layer so we don't hard‑code
/// translations all over the UI widgets.
class CategoryLocalizationHelper {
  CategoryLocalizationHelper._();

  /// Returns a user‑facing label for a category name.
  ///
  /// - Keeps the original name for unknown categories.
  /// - For Arabic, maps a few well‑known English names to Arabic labels.
  static String localizeCategoryName(BuildContext context, String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return trimmed;

    final localeCode = Localizations.localeOf(context).languageCode;
    if (localeCode != 'ar') {
      return trimmed;
    }

    final normalized = trimmed.toLowerCase();

    switch (normalized) {
      case 'women':
        return 'النساء';
      case 'men':
        return 'الرجال';
      case 'kids':
      case 'children':
        return 'الأطفال';
      case 'shoes':
        return 'أحذية';
      case 'bags':
        return 'حقائب';
      default:
        return trimmed;
    }
  }
}

