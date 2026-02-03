import 'package:equatable/equatable.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_category.dart';

/// Base class for filter states
abstract class FiltersState extends Equatable {
  const FiltersState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FiltersInitial extends FiltersState {
  const FiltersInitial();
}

/// Filters loaded and ready
class FiltersLoaded extends FiltersState {
  final FilterCriteria criteria;
  final Map<int, List<FilterCategory>> subcategories;

  const FiltersLoaded({
    required this.criteria,
    this.subcategories = const {},
  });

  FiltersLoaded copyWith({
    FilterCriteria? criteria,
    Map<int, List<FilterCategory>>? subcategories,
  }) {
    return FiltersLoaded(
      criteria: criteria ?? this.criteria,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  List<Object?> get props => [criteria, subcategories];
}

/// Filters loading
class FiltersLoading extends FiltersState {
  const FiltersLoading();
}

/// Filters error
class FiltersError extends FiltersState {
  final String message;

  const FiltersError(this.message);

  @override
  List<Object?> get props => [message];
}

