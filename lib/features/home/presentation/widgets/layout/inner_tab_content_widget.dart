import 'package:flutter/material.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/fashion_products_widget.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/electronics_content_widget.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/home_living_content_widget.dart';
import 'home_content_widget.dart';

class InnerTabContentWidget extends StatelessWidget {
  final String outerTab;
  final String innerTab;
  final Widget mainContent;

  const InnerTabContentWidget({
    super.key,
    required this.outerTab,
    required this.innerTab,
    required this.mainContent,
  });

  @override
  Widget build(BuildContext context) {
    // Show products for Fashion tab in any outer tab
    if (innerTab == 'Fashion') {
      return const FashionProductsWidget();
    }

    // New Trends shows general home content
    if (innerTab == 'New Trends') {
      return const HomeContentWidget();
    }

    // Electronics tab content
    if (innerTab == 'Electronics') {
      return const ElectronicsContentWidget();
    }

    // Home & Living tab content
    if (innerTab == 'Home & Living') {
      return const HomeLivingContentWidget();
    }

    // Fallback
    return const HomeContentWidget();
  }
}
