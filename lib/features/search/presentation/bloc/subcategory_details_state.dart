import 'package:equatable/equatable.dart';
import '../../domain/entities/subcategory_details.dart';

abstract class SubcategoryDetailsState extends Equatable {
  const SubcategoryDetailsState();

  @override
  List<Object?> get props => [];
}

class SubcategoryDetailsInitial extends SubcategoryDetailsState {}

class SubcategoryDetailsLoading extends SubcategoryDetailsState {}

class SubcategoryDetailsLoaded extends SubcategoryDetailsState {
  final SubcategoryDetails subcategoryDetails;

  const SubcategoryDetailsLoaded({
    required this.subcategoryDetails,
  });

  @override
  List<Object?> get props => [subcategoryDetails];
}

class SubcategoryDetailsError extends SubcategoryDetailsState {
  final String message;

  const SubcategoryDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
