class TermsConditions {
  final int id;
  final String name;
  final String termsCondition;
  final String state;

  const TermsConditions({
    required this.id,
    required this.name,
    required this.termsCondition,
    required this.state,
  });

  factory TermsConditions.fromJson(Map<String, dynamic> json) {
    return TermsConditions(
      id: json['id'] as int,
      name: json['name'] as String,
      termsCondition: json['terms_condition'] as String,
      state: json['state'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'terms_condition': termsCondition,
      'state': state,
    };
  }

  TermsConditions copyWith({
    int? id,
    String? name,
    String? termsCondition,
    String? state,
  }) {
    return TermsConditions(
      id: id ?? this.id,
      name: name ?? this.name,
      termsCondition: termsCondition ?? this.termsCondition,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TermsConditions &&
        other.id == id &&
        other.name == name &&
        other.termsCondition == termsCondition &&
        other.state == state;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        termsCondition.hashCode ^
        state.hashCode;
  }

  @override
  String toString() {
    return 'TermsConditions(id: $id, name: $name, termsCondition: $termsCondition, state: $state)';
  }
}

class TermsConditionsResponse {
  final int totalCount;
  final List<TermsConditions> termsConditions;

  const TermsConditionsResponse({
    required this.totalCount,
    required this.termsConditions,
  });

  factory TermsConditionsResponse.fromJson(Map<String, dynamic> json) {
    return TermsConditionsResponse(
      totalCount: json['total_count'] as int,
      termsConditions: (json['terms_conditions'] as List<dynamic>)
          .map((item) => TermsConditions.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'terms_conditions': termsConditions.map((x) => x.toJson()).toList(),
    };
  }

  TermsConditionsResponse copyWith({
    int? totalCount,
    List<TermsConditions>? termsConditions,
  }) {
    return TermsConditionsResponse(
      totalCount: totalCount ?? this.totalCount,
      termsConditions: termsConditions ?? this.termsConditions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TermsConditionsResponse &&
        other.totalCount == totalCount &&
        other.termsConditions == termsConditions;
  }

  @override
  int get hashCode {
    return totalCount.hashCode ^ termsConditions.hashCode;
  }

  @override
  String toString() {
    return 'TermsConditionsResponse(totalCount: $totalCount, termsConditions: $termsConditions)';
  }
}
