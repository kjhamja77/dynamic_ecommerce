import 'package:flutter/material.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';

class FavoritesContentWidget extends StatelessWidget {
  final Function(int)? onTabChanged;
  
  const FavoritesContentWidget({super.key, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return FavoritesPage(onTabChanged: onTabChanged);
  }
}
