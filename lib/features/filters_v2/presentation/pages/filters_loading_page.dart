import 'package:flutter/material.dart';
import '../widgets/filters_shimmer.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_options.dart';
import 'filters_page.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../filters/domain/usecases/get_available_filters.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

/// Page that loads filter options and then displays FiltersPage
class FiltersLoadingPage extends StatefulWidget {
  final FilterCriteria initial;
  final String? category;
  final String? brand;
  final String? query;

  const FiltersLoadingPage({
    super.key,
    required this.initial,
    this.category,
    this.brand,
    this.query,
  });

  @override
  State<FiltersLoadingPage> createState() => _FiltersLoadingPageState();
}

class _FiltersLoadingPageState extends State<FiltersLoadingPage> {
  FilterOptions? _options;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    final getFilters = di.sl<GetAvailableFilters>();
    try {
      // Extract categoryId from initial criteria if available
      final int? categoryId = widget.initial.categoryIds.isNotEmpty 
          ? widget.initial.categoryIds.first 
          : null;
      
      print('🔍 FiltersLoadingPage: Loading filters with categoryId: $categoryId');

      final result = await getFilters(
        category: (widget.category == 'All') ? null : widget.category,
        brand: (widget.brand == 'All') ? null : widget.brand,
        query: widget.query,
        categoryId: categoryId,
      );

      if (!mounted) return;
      
      result.fold(
        (failure) {
          AppSnackBar.error(
            context,
            '${AppLocalizations.of(context)!.error}: ${failure.message}',
          );
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
      AppSnackBar.error(
        context,
        AppLocalizations.of(context)!.errorLoadingCountriesStates,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Once options loaded, render the real FiltersPage
    if (_options != null) {
      return FiltersPage(
        initial: widget.initial,
        options: _options!,
        onApply: (criteria) => Navigator.of(context).pop(criteria),
      );
    }
    
    // While loading, show shimmer
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.filters,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onBackground,
        ),
      ),
      body: const FiltersShimmer(),
    );
  }
}

