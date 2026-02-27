import 'package:flutter/foundation.dart';

import 'models/page_model.dart';
import 'models/component_model.dart';

/// Offloads heavy Home page API JSON parsing to a background isolate so that
/// the main isolate remains responsive while converting API responses into
/// strongly‑typed models.
Future<List<PageModel>> parseHomePagesInBackground(
  List<dynamic> apiPages,
) {
  final items = apiPages.cast<Map<String, dynamic>>();
  return compute<List<Map<String, dynamic>>, List<PageModel>>(
    _parseHomePages,
    items,
  );
}

List<PageModel> _parseHomePages(
  List<Map<String, dynamic>> items,
) {
  return items.map(PageModel.fromJson).toList();
}

Future<PageComponentsModel> parseHomePageComponentsInBackground(
  Map<String, dynamic> apiData,
) {
  return compute<Map<String, dynamic>, PageComponentsModel>(
    _parseHomePageComponents,
    apiData,
  );
}

PageComponentsModel _parseHomePageComponents(
  Map<String, dynamic> json,
) {
  return PageComponentsModel.fromJson(json);
}

