import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Returns the localized label for known product attribute names (e.g. HEIGHT, WIDTH, MEASUREMENT).
/// For unknown attributes, returns [attributeName] unchanged.
String localizedAttributeLabel(BuildContext context, String attributeName) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return attributeName;
  final key = attributeName.trim().toUpperCase();
  switch (key) {
    case 'HEIGHT':
      return l10n.attributeHeight;
    case 'WIDTH':
      return l10n.attributeWidth;
    case 'MEASUREMENT':
      return l10n.attributeMeasurement;
    default:
      return attributeName;
  }
}
