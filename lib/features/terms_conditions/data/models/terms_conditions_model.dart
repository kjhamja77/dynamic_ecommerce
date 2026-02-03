import '../../domain/entities/terms_conditions.dart';

class TermsConditionsModel extends TermsConditions {
  const TermsConditionsModel({
    required super.id,
    required super.name,
    required super.termsCondition,
    required super.state,
  });

  factory TermsConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      termsCondition: json['terms_condition'] as String,
      state: json['state'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'terms_condition': termsCondition,
      'state': state,
    };
  }

  @override
  TermsConditionsModel copyWith({
    int? id,
    String? name,
    String? termsCondition,
    String? state,
  }) {
    return TermsConditionsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      termsCondition: termsCondition ?? this.termsCondition,
      state: state ?? this.state,
    );
  }
}

class TermsConditionsResponseModel extends TermsConditionsResponse {
  const TermsConditionsResponseModel({
    required super.totalCount,
    required super.termsConditions,
  });

  factory TermsConditionsResponseModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionsResponseModel(
      totalCount: json['total_count'] as int,
      termsConditions: (json['terms_conditions'] as List<dynamic>)
          .map((item) => TermsConditionsModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'terms_conditions': termsConditions.map((x) => x.toJson()).toList(),
    };
  }

  @override
  TermsConditionsResponseModel copyWith({
    int? totalCount,
    List<TermsConditions>? termsConditions,
  }) {
    return TermsConditionsResponseModel(
      totalCount: totalCount ?? this.totalCount,
      termsConditions: termsConditions ?? this.termsConditions,
    );
  }
}
