import 'package:flutter/material.dart';

/// Constants for search-related icon mappings
class SearchIconConstants {
  // Private constructor to prevent instantiation
  SearchIconConstants._();

  /// Icon mappings for main search categories
  static const Map<String, IconData> categoryIcons = {
    'new_releases': Icons.new_releases,
    'eco': Icons.eco,
    'auto_awesome': Icons.auto_awesome,
    'checkroom': Icons.checkroom,
    'sports_soccer': Icons.sports_soccer,
    'fitness_center': Icons.fitness_center,
    'style': Icons.style,
    'wallet': Icons.account_balance_wallet,
    'content_cut': Icons.content_cut,
    'star': Icons.star,
    'play_circle_outline': Icons.play_circle_outline,
  };

  /// Icon mappings for subcategory items
  static const Map<String, IconData> subcategoryIcons = {
    'grid_view': Icons.grid_view,
    'sports_soccer': Icons.sports_soccer,
    'fitness_center': Icons.fitness_center,
    'business_center': Icons.business_center,
    'terrain': Icons.terrain,
    'directions_run': Icons.directions_run,
    'home': Icons.home,
    'whatshot': Icons.whatshot,
    'checkroom': Icons.checkroom,
    'weekend': Icons.weekend,
    'work': Icons.work,
    'school': Icons.school,
    'crop_square': Icons.crop_square,
    'celebration': Icons.celebration,
    'wallet': Icons.account_balance_wallet,
    'content_cut': Icons.content_cut,
    'star': Icons.star,
    'play_circle_outline': Icons.play_circle_outline,
    'new_releases': Icons.new_releases,
    'eco': Icons.eco,
    'auto_awesome': Icons.auto_awesome,
    'style': Icons.style,
    'beach_access': Icons.beach_access,
    'trending_up': Icons.trending_up,
    'sports_basketball': Icons.sports_basketball,
    'groups': Icons.groups,
    'person': Icons.person,
  };

  /// Get icon data for a category
  static IconData getCategoryIcon(String iconName) {
    return categoryIcons[iconName] ?? Icons.category;
  }

  /// Get icon data for a subcategory item
  static IconData getSubcategoryIcon(String iconName) {
    return subcategoryIcons[iconName] ?? Icons.category;
  }
}
