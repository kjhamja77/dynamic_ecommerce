import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

class OrderDateUtils {
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMd(locale.toLanguageTag());
    final timeFormatter = DateFormat.Hm(locale.toLanguageTag());
    final formattedDate = dateFormatter.format(date);
    final formattedTime = timeFormatter.format(date);
    return AppLocalizations.of(context)!.dateAtTime(formattedDate, formattedTime);
  }

  static String formatTimelineDate(BuildContext context, DateTime date) {
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return loc.justNow;
    }

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return loc.minutesAgo(difference.inMinutes);
      }
      return loc.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      final locale = Localizations.localeOf(context);
      final timeFormatter = DateFormat.Hm(locale.toLanguageTag());
      return loc.yesterdayAt(timeFormatter.format(date));
    } else if (difference.inDays < 7) {
      return loc.daysAgo(difference.inDays);
    } else {
      return formatDate(context, date);
    }
  }

  static String formatDateTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMd(locale.toLanguageTag());
    final timeFormatter = DateFormat.Hm(locale.toLanguageTag());
    return '${dateFormatter.format(date)} ${timeFormatter.format(date)}';
  }
}
