import 'package:flutter/material.dart';

/// Home page cards often use light [BoxShadow]s. In dark mode those read as a harsh
/// white glow; omit shadows there and keep elevation only in light mode.
List<BoxShadow> homeCardBoxShadow(BuildContext context, List<BoxShadow> lightModeShadows) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return const <BoxShadow>[];
  }
  return lightModeShadows;
}
