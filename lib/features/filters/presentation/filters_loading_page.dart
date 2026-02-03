import 'package:flutter/material.dart';
// import '../../../core/constants/responsive_constants.dart';
import 'widgets/filters_shimmer.dart';
import '../domain/entities/filter_criteria.dart';
import '../domain/entities/filter_options.dart';
import 'filters_page.dart';
import '../../../core/di/injection_container.dart' as di;
import '../domain/usecases/get_available_filters.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class FiltersLoaderPage extends StatefulWidget {
  final FilterCriteria initial;
  final String? category;
  final String? brand;
  final String? query;

  const FiltersLoaderPage({
    super.key,
    required this.initial,
    this.category,
    this.brand,
    this.query,
  });

  @override
  State<FiltersLoaderPage> createState() => _FiltersLoaderPageState();
}

class _FiltersLoaderPageState extends State<FiltersLoaderPage> {
  FilterOptions? _options;

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    final getFilters = di.sl<GetAvailableFilters>();
    try {
      // Extract categoryId from initial criteria if available (first selected category ID)
      // This ensures filters are loaded with category-specific attributes when navigating from a category catalog
      final int? categoryId = widget.initial.categoryIds.isNotEmpty 
          ? widget.initial.categoryIds.first 
          : null;
      
      print('🔍 FiltersLoaderPage: Loading filters with categoryId: $categoryId (from initial.categoryIds: ${widget.initial.categoryIds})');
      
      final result = await getFilters(
        category: (widget.category == 'All') ? null : widget.category,
        brand: (widget.brand == 'All') ? null : widget.brand,
        query: widget.query,
        categoryId: categoryId, // Pass categoryId to fetch category-specific attributes
      );

      if (!mounted) return;
      
      result.fold(
        (failure) {
          AppSnackBar.error(context, '${AppLocalizations.of(context)!.error}: ${failure.message}');
          Navigator.of(context).pop();
        },
        (options) {
          setState(() {
            _options = options;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, AppLocalizations.of(context)!.errorLoadingCountriesStates);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Once options loaded, render the real FiltersPage in-place (no extra navigation)
    if (_options != null) {
      return FiltersPage(
        initial: widget.initial,
        options: _options!,
        onApply: (criteria) => Navigator.of(context).pop(criteria),
      );
    }
    // While loading, show lightweight shimmer with its own app scaffold
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.filters, style: AppFonts.getTextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const FiltersShimmer(),
    );
  }
}


