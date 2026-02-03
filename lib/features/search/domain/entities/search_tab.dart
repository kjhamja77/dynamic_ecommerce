import 'package:equatable/equatable.dart';

class SearchTab extends Equatable {
  final String id;
  final String title;
  final bool isSelected;
  final int sortOrder;

  const SearchTab({
    required this.id,
    required this.title,
    this.isSelected = false,
    required this.sortOrder,
  });

  SearchTab copyWith({
    String? id,
    String? title,
    bool? isSelected,
    int? sortOrder,
  }) {
    return SearchTab(
      id: id ?? this.id,
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, title, isSelected, sortOrder];
}
