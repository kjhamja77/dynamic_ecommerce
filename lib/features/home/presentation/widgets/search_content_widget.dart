import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SearchContentWidget extends StatefulWidget {
  const SearchContentWidget({super.key});

  @override
  State<SearchContentWidget> createState() => _SearchContentWidgetState();
}

class _SearchContentWidgetState extends State<SearchContentWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 1; // Start with "Men" selected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.smPadding,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.smPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: ResponsiveConstants.mdIconSize,
                ),
                SizedBox(width: ResponsiveConstants.smSpacing),
                Expanded(
                  child: Text(
                    'What are you looking for?',
                    style: AppFonts.getTextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: ResponsiveConstants.mdFontSize,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: ResponsiveConstants.smIconSize,
                  ),
                ),
              ],
            ),
          ),

          // Category Tabs (Women, Men, Kids)
          Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
            child: Row(
              children: [
                _buildCategoryTab('Women', 0),
                SizedBox(width: ResponsiveConstants.lgSpacing),
                _buildCategoryTab('Men', 1),
                SizedBox(width: ResponsiveConstants.lgSpacing),
                _buildCategoryTab('Kids', 2),
              ],
            ),
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),

          // Category List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              children: [
                _buildCategoryItem('NEW IN', Icons.new_releases, Colors.orange),
                _buildCategoryItem('Summer 2025', Icons.eco, Colors.green),
                _buildCategoryItem('Trending', Icons.auto_awesome, Colors.purple),
                _buildCategoryItem('Clothing', Icons.checkroom, Colors.blue),
                _buildCategoryItem('Shoes', Icons.sports_soccer, Colors.brown),
                _buildCategoryItem('Sports', Icons.fitness_center, Colors.red),
                _buildCategoryItem('Streetwear', Icons.style, Colors.black),
                _buildCategoryItem('Accessories', Icons.wallet, Colors.amber),
                _buildCategoryItem('Care', Icons.content_cut, Colors.teal),
                _buildCategoryItem('Designer', Icons.star, Colors.pink),
                _buildCategoryItem('Livestreams', Icons.play_circle_outline, Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () async {
          await HapticService.buttonClick();
          setState(() {
          _selectedTabIndex = index;
        });
        _tabController.animateTo(index);
      },
      child: Column(
        children: [
          Text(
            title,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          Container(
            height: 2,
            width: ResponsiveConstants.mdSpacing,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveConstants.mdIconSize,
            ),
          ),
          SizedBox(width: ResponsiveConstants.mdSpacing),
          Expanded(
            child: Text(
              title,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: ResponsiveConstants.smIconSize,
          ),
        ],
      ),
    );
  }
}
