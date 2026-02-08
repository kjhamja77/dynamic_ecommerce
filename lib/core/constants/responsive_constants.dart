import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive constants for the entire app
/// Uses flutter_screenutil for consistent scaling across different screen sizes
class ResponsiveConstants {
  // Private constructor to prevent instantiation
  ResponsiveConstants._();

  // Screen breakpoints for responsive design
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  // Responsive spacing
  static double get xsSpacing => 4.w;
  static double get smSpacing => 8.w;
  static double get mdSpacing => 16.w;
  static double get lgSpacing => 24.w;
  static double get xlSpacing => 32.w;
  static double get xxlSpacing => 48.w;

  // Responsive padding
  static double get xsPadding => 4.w;
  static double get smPadding => 8.w;
  static double get mdPadding => 16.w; // Standardized to 16 for consistent component padding
  static double get lgPadding => 24.w;
  static double get xlPadding => 32.w;
  static double get xxlPadding => 48.w;

  // Responsive margins
  static double get xsMargin => 4.w;
  static double get smMargin => 8.w;
  static double get mdMargin => 16.w;
  static double get lgMargin => 24.w;
  static double get xlMargin => 32.w;
  static double get xxlMargin => 48.w;

  // Responsive font sizes
  static double get xsFontSize => 10.sp;
  static double get smFontSize => 12.sp;
  static double get mdFontSize => 14.sp;
  static double get lgFontSize => 15.sp; // slightly smaller for app bar titles
  static double get xlFontSize => 18.sp;
  static double get xxlFontSize => 20.sp;
  static double get titleFontSize => 20.sp;
  static double get headlineFontSize => 28.sp;
  static double get displayFontSize => 32.sp;

  // Responsive icon sizes
  static double get xsIconSize => 16.w;
  static double get smIconSize => 20.w;
  static double get mdIconSize => 24.w;
  static double get lgIconSize => 32.w;
  static double get xlIconSize => 40.w;
  static double get xxlIconSize => 48.w;

  // Responsive border radius
  static double get xsRadius => 4.r;
  static double get smRadius => 8.r;
  static double get mdRadius => 12.r;
  static double get lgRadius => 16.r;
  static double get xlRadius => 24.r;
  static double get xxlRadius => 32.r;

  // Responsive elevations
  static double get xsElevation => 1.h;
  static double get smElevation => 2.h;
  static double get mdElevation => 4.h;
  static double get lgElevation => 8.h;
  static double get xlElevation => 16.h;

  // Responsive dimensions
  static double get xsDimension => 8.w;
  static double get smDimension => 16.w;
  static double get mdDimension => 24.w;
  static double get lgDimension => 32.w;
  static double get xlDimension => 48.w;
  static double get xxlDimension => 64.w;

  // Responsive button heights
  static double get smButtonHeight => 36.h;
  static double get mdButtonHeight => 48.h;
  static double get lgButtonHeight => 56.h;
  static double get xlButtonHeight => 70.h;

  // Responsive input field heights
  static double get smInputHeight => 40.h;
  static double get mdInputHeight => 48.h;
  static double get lgInputHeight => 56.h;

  // Responsive card dimensions
  static double get cardMinHeight => 200.h;
  static double get cardMaxHeight => 400.h;
  static double get cardImageHeight => 200.h;

  // Responsive grid spacing
  static double get gridSpacing => 16.w;
  static double get gridCrossAxisSpacing => 10.w;
  static double get gridMainAxisSpacing => 16.h;

  // Responsive tab dimensions
  static double get tabHeight => 48.h;
  static double get tabIndicatorWeight => 2.h;

  // Responsive app bar dimensions
  static double get appBarHeight => 56.h;
  static double get appBarElevation => 0.h;

  // Responsive bottom navigation dimensions
  static double get bottomNavHeight => 56.h;
  static double get bottomNavIconSize => 24.w;

  // Responsive drawer dimensions
  static double get drawerWidth => 280.w;
  static double get drawerHeaderHeight => 120.h;

  // Responsive modal dimensions
  static double get modalMaxWidth => 400.w;
  static double get modalMaxHeight => 600.h;

  // Responsive list tile dimensions
  static double get listTileHeight => 56.h;
  static double get listTileMinLeadingWidth => 40.w;

  // Responsive chip dimensions
  static double get chipHeight => 32.h;
  static double get chipLabelPadding => 8.w;

  // Responsive badge dimensions
  static double get badgeSize => 20.w;
  static double get badgeOffset => 8.w;

  // Responsive avatar dimensions
  static double get xsAvatarSize => 24.w;
  static double get smAvatarSize => 32.w;
  static double get mdAvatarSize => 40.w;
  static double get lgAvatarSize => 56.w;
  static double get xlAvatarSize => 72.w;

  // Responsive divider dimensions
  static double get dividerThickness => 1.h;
  static double get dividerIndent => 16.w;
  static double get dividerEndIndent => 16.w;

  // Responsive progress indicator dimensions
  static double get progressIndicatorSize => 24.w;
  static double get linearProgressIndicatorHeight => 4.h;

  // Responsive switch dimensions
  static double get switchWidth => 40.w;
  static double get switchHeight => 24.h;

  // Responsive checkbox dimensions
  static double get checkboxSize => 18.w;

  // Responsive radio dimensions
  static double get radioSize => 18.w;

  // Responsive slider dimensions
  static double get sliderTrackHeight => 4.h;
  static double get sliderThumbRadius => 10.r;

  // Responsive stepper dimensions
  static double get stepperIconSize => 24.w;
  static double get stepperLineWidth => 2.w;

  // Responsive expansion tile dimensions
  static double get expansionTileHeaderHeight => 48.h;

  // Responsive data table dimensions
  static double get dataTableRowHeight => 52.h;
  static double get dataTableHeaderRowHeight => 56.h;

  // Responsive tooltip dimensions
  static double get tooltipMaxWidth => 200.w;
  static double get tooltipPadding => 8.w;

  // Responsive snackbar dimensions
  static double get snackbarMaxWidth => 400.w;
  static double get snackbarMinHeight => 48.h;

  // Responsive dialog dimensions
  static double get dialogMaxWidth => 400.w;
  static double get dialogMaxHeight => 600.h;

  // Responsive bottom sheet dimensions
  static double get bottomSheetMaxHeight => 0.8.sh;
  static double get bottomSheetMinHeight => 200.h;

  // Responsive navigation rail dimensions
  static double get navigationRailWidth => 72.w;
  static double get navigationRailExtendedWidth => 256.w;

  // Responsive floating action button dimensions
  static double get fabSize => 56.w;
  static double get smallFabSize => 40.w;
  static double get largeFabSize => 96.w;

  // Responsive speed dial dimensions
  static double get speedDialChildSize => 56.w;
  static double get speedDialChildPadding => 8.w;

  // Responsive refresh indicator dimensions
  static double get refreshIndicatorSize => 40.w;

  // Responsive scrollbar dimensions
  static double get scrollbarThickness => 8.w;
  static double get scrollbarRadius => 4.r;

  // Responsive shimmer dimensions
  static double get shimmerBaseWidth => 200.w;
  static double get shimmerBaseHeight => 100.h;

  // Responsive skeleton dimensions
  static double get skeletonHeight => 20.h;
  static double get skeletonRadius => 4.r;

  // Responsive loading indicator dimensions
  static double get loadingIndicatorSize => 24.w;
  static double get loadingIndicatorStrokeWidth => 2.w;

  // Responsive error state dimensions
  static double get errorIconSize => 60.w;
  static double get errorTextMaxWidth => 300.w;

  // Responsive empty state dimensions
  static double get emptyStateIconSize => 80.w;
  static double get emptyStateTextMaxWidth => 250.w;

  // Responsive search bar dimensions
  static double get searchBarHeight => 48.h;
  static double get searchBarIconSize => 20.w;

  // Responsive filter chip dimensions
  static double get filterChipHeight => 32.h;
  static double get filterChipLabelPadding => 12.w;

  // Responsive sort button dimensions
  static double get sortButtonHeight => 36.h;
  static double get sortButtonIconSize => 18.w;

  // Responsive view toggle dimensions
  static double get viewToggleHeight => 40.h;
  static double get viewToggleIconSize => 20.w;

  // Responsive pagination dimensions
  static double get paginationHeight => 48.h;
  static double get paginationButtonSize => 32.w;

  // Responsive rating dimensions
  static double get ratingSize => 20.w;
  static double get ratingSpacing => 4.w;

  // Responsive price dimensions
  static double get priceFontSize => 18.sp;
  static double get originalPriceFontSize => 14.sp;
  static double get discountFontSize => 12.sp;

  // Responsive brand dimensions
  static double get brandFontSize => 14.sp;
  static double get productNameFontSize => 14.sp;

  // Responsive favorite button dimensions
  static double get favoriteButtonSize => 36.w;
  static double get favoriteButtonIconSize => 20.w;

  // Responsive badge dimensions
  static double get newBadgeHeight => 24.h;
  static double get dealBadgeHeight => 24.h;
  static double get badgeFontSize => 12.sp;

  // Responsive image dimensions
  static double get productImageHeight => 200.h;
  static double get productImageWidth => 200.w;
  static double get productImageRadius => 12.r;
  
  // Product details specific responsive dimensions
  static double get productDetailsImageHeight => _getProductDetailsImageHeight();
  static double get productDetailsImageWidth => 1.sw;
  static double get productDetailsAppBarHeight => 0.8.sh;
  static double get productDetailsColorThumbnailSize => _getColorThumbnailSize();
  static double get productDetailsColorThumbnailSpacing => _getColorThumbnailSpacing();
  static double get productDetailsPageIndicatorBottom => _getPageIndicatorBottom();
  static double get productDetailsBottomSheetMaxHeight => _getBottomSheetMaxHeight();
  static double get productDetailsCardWidth => _getProductCardWidth();
  static double get productDetailsGridSpacing => _getGridSpacing();
  static double get productDetailsCompactListHeight => _getProductDetailsCompactListHeight();

  // Responsive grid dimensions
  static int get gridCrossAxisCount => _getGridCrossAxisCount();
  static double get gridChildAspectRatio => _getGridChildAspectRatio();

  // Helper methods for responsive calculations
  static int _getGridCrossAxisCount() {
    if (1.sw >= _desktopBreakpoint) return 6;
    if (1.sw >= _tabletBreakpoint) return 4;
    if (1.sw >= _mobileBreakpoint) return 3;
    return 2;
  }

  static double _getGridChildAspectRatio() {
    if (1.sw >= _desktopBreakpoint) return 0.75; // better proportions on desktop
    if (1.sw >= _tabletBreakpoint) return 0.70;  // better proportions on tablet
    if (1.sw >= _mobileBreakpoint) return 0.65;  // better proportions on large phones
    return 0.60;                                  // better proportions on small phones
  }

  // Responsive edge insets
  static EdgeInsets get xsEdgeInsets => EdgeInsets.all(xsPadding);
  static EdgeInsets get smEdgeInsets => EdgeInsets.all(smPadding);
  static EdgeInsets get mdEdgeInsets => EdgeInsets.all(mdPadding);
  static EdgeInsets get lgEdgeInsets => EdgeInsets.all(lgPadding);
  static EdgeInsets get xlEdgeInsets => EdgeInsets.all(xlPadding);

  static EdgeInsets get horizontalMdEdgeInsets => EdgeInsets.symmetric(horizontal: mdPadding);
  static EdgeInsets get verticalMdEdgeInsets => EdgeInsets.symmetric(vertical: mdPadding);
  static EdgeInsets get horizontalLgEdgeInsets => EdgeInsets.symmetric(horizontal: lgPadding);
  static EdgeInsets get verticalLgEdgeInsets => EdgeInsets.symmetric(vertical: lgPadding);

  // Responsive border radius
  static BorderRadius get xsBorderRadius => BorderRadius.circular(xsRadius);
  static BorderRadius get smBorderRadius => BorderRadius.circular(smRadius);
  static BorderRadius get mdBorderRadius => BorderRadius.circular(mdRadius);
  static BorderRadius get lgBorderRadius => BorderRadius.circular(lgRadius);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xlRadius);

  // Responsive box constraints
  static BoxConstraints get xsBoxConstraints => BoxConstraints(
    minWidth: xsDimension,
    minHeight: xsDimension,
  );
  static BoxConstraints get smBoxConstraints => BoxConstraints(
    minWidth: smDimension,
    minHeight: smDimension,
  );
  static BoxConstraints get mdBoxConstraints => BoxConstraints(
    minWidth: mdDimension,
    minHeight: mdDimension,
  );
  static BoxConstraints get lgBoxConstraints => BoxConstraints(
    minWidth: lgDimension,
    minHeight: lgDimension,
  );

  // Responsive size
  static Size get xsSize => Size(xsDimension, xsDimension);
  static Size get smSize => Size(smDimension, smDimension);
  static Size get mdSize => Size(mdDimension, mdDimension);
  static Size get lgSize => Size(lgDimension, lgDimension);
  static Size get xlSize => Size(xlDimension, xlDimension);

  // Responsive offset
  static Offset get xsOffset => Offset(xsDimension, xsDimension);
  static Offset get smOffset => Offset(smDimension, smDimension);
  static Offset get mdOffset => Offset(mdDimension, mdDimension);
  static Offset get lgOffset => Offset(lgDimension, lgDimension);

  // Responsive duration (for animations)
  static Duration get xsDuration => Duration(milliseconds: 150);
  static Duration get smDuration => Duration(milliseconds: 300);
  static Duration get mdDuration => Duration(milliseconds: 500);
  static Duration get lgDuration => Duration(milliseconds: 700);
  static Duration get xlDuration => Duration(milliseconds: 1000);

  // Responsive curve (for animations)
  static Curve get defaultCurve => Curves.easeInOut;
  static Curve get fastCurve => Curves.fastOutSlowIn;
  static Curve get slowCurve => Curves.slowMiddle;

  // Product details specific responsive helper methods
  static double _getProductDetailsImageHeight() {
    if (1.sw >= _desktopBreakpoint) return 0.7.sh; // Desktop: 70% of screen height
    if (1.sw >= _tabletBreakpoint) return 0.75.sh; // Tablet: 75% of screen height
    return 0.8.sh; // Mobile: 80% of screen height
  }

  static double _getColorThumbnailSize() {
    if (1.sw >= _desktopBreakpoint) return 80.w; // Desktop: larger thumbnails
    if (1.sw >= _tabletBreakpoint) return 70.w; // Tablet: medium thumbnails
    return 60.w; // Mobile: smaller thumbnails
  }

  static double _getColorThumbnailSpacing() {
    if (1.sw >= _desktopBreakpoint) return 12.w; // Desktop: more spacing
    if (1.sw >= _tabletBreakpoint) return 10.w; // Tablet: medium spacing
    return 8.w; // Mobile: less spacing
  }

  static double _getPageIndicatorBottom() {
    if (1.sw >= _desktopBreakpoint) return 140.h; // Desktop: more space
    if (1.sw >= _tabletBreakpoint) return 120.h; // Tablet: medium space
    return 100.h; // Mobile: less space
  }

  static double _getBottomSheetMaxHeight() {
    if (1.sw >= _desktopBreakpoint) return 0.6.sh; // Desktop: smaller bottom sheet
    if (1.sw >= _tabletBreakpoint) return 0.7.sh; // Tablet: medium bottom sheet
    return 0.8.sh; // Mobile: larger bottom sheet
  }

  static double _getProductCardWidth() {
    if (1.sw >= _desktopBreakpoint) return 1.sw * 0.22; // Desktop: 6 cards per row
    if (1.sw >= _tabletBreakpoint) return 1.sw * 0.28; // Tablet: 4 cards per row
    if (1.sw >= _mobileBreakpoint) return 1.sw * 0.4; // Large mobile: 3 cards per row
    return 1.sw * 0.56; // Small mobile: 2 cards per row
  }

  static double _getGridSpacing() {
    if (1.sw >= _desktopBreakpoint) return 20.w; // Desktop: more spacing
    if (1.sw >= _tabletBreakpoint) return 16.w; // Tablet: medium spacing
    return 12.w; // Mobile: less spacing
  }

  /// Compact card image aspect ratio (must match ProductCard compact ratio).
  static double _getProductDetailsCompactImageAspectRatio() {
    if (1.sw >= _desktopBreakpoint) return 1.45;
    if (1.sw >= _tabletBreakpoint) return 1.5;
    return 1.55;
  }

  /// Compact card info section height (must match ProductCard _getCardInfoHeight for compact).
  /// Sized for brand + 2-line title + price + padding; extra headroom to avoid bottom overflow.
  static double _getProductDetailsCompactInfoHeight() {
    if (1.sw >= _desktopBreakpoint) return 106.h;
    if (1.sw >= _tabletBreakpoint) return 102.h;
    return 98.h;
  }

  /// Total height for the compact product card (image + info). Use this for the list container.
  static double get productDetailsCompactCardHeight {
    final width = productDetailsCardWidth;
    final imageHeight = width / _getProductDetailsCompactImageAspectRatio();
    return imageHeight + _getProductDetailsCompactInfoHeight();
  }

  static double _getProductDetailsCompactListHeight() {
    return productDetailsCompactCardHeight;
  }
}
