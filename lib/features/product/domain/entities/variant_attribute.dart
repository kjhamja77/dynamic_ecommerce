import 'package:equatable/equatable.dart';

class VariantAttribute extends Equatable {
  final int attributeId;
  final String attributeName;
  final int valueId;
  final String valueName;

  const VariantAttribute({
    required this.attributeId,
    required this.attributeName,
    required this.valueId,
    required this.valueName,
  });

  @override
  List<Object> get props => [attributeId, attributeName, valueId, valueName];
}


