import 'package:flutter/material.dart';
import 'dynamic_tab_widget.dart';

class HomeTabWidget extends StatelessWidget {
  final TabController innerTabController;
  final String outerTab;
  final int userId;

  const HomeTabWidget({
    super.key,
    required this.innerTabController,
    required this.outerTab,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicTabWidget(
      innerTabController: innerTabController,
      outerTab: outerTab,
      userId: userId,
    );
  }
}
