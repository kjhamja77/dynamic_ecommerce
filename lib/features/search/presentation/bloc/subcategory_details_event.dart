import 'package:equatable/equatable.dart';

abstract class SubcategoryDetailsEvent extends Equatable {
  const SubcategoryDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubcategoryDetails extends SubcategoryDetailsEvent {
  final String subcategoryId;

  const LoadSubcategoryDetails(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

class NavigateToSubcategory extends SubcategoryDetailsEvent {
  final String subcategoryId;
  final String title;

  const NavigateToSubcategory({
    required this.subcategoryId,
    required this.title,
  });

  @override
  List<Object?> get props => [subcategoryId, title];
}
