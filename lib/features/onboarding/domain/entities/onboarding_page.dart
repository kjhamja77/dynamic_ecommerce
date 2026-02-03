import 'package:equatable/equatable.dart';

class OnboardingPage extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int sequence;

  const OnboardingPage({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.sequence = 0,
  });

  @override
  List<Object?> get props => [id, name, description, image, sequence];
}
