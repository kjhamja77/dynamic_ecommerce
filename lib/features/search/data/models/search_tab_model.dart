import '../../domain/entities/search_tab.dart';

class SearchTabModel extends SearchTab {
  const SearchTabModel({
    required super.id,
    required super.title,
    super.isSelected,
    required super.sortOrder,
  });

  factory SearchTabModel.fromJson(Map<String, dynamic> json) {
    return SearchTabModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isSelected': isSelected,
      'sortOrder': sortOrder,
    };
  }
}
