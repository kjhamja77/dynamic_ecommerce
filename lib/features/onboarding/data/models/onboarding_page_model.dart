import '../../domain/entities/onboarding_page.dart';

class OnboardingPageModel extends OnboardingPage {
  const OnboardingPageModel({
    required super.id,
    required super.name,
    super.description,
    super.image,
    super.sequence,
  });

  factory OnboardingPageModel.fromJson(Map<String, dynamic> json) {
    return OnboardingPageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: _parseDescription(json['description']),
      image: json['image'] as String?,
      sequence: json['sequence'] as int? ?? json['id'] as int, // Fallback to id if sequence not provided
    );
  }

  static String? _parseDescription(dynamic description) {
    if (description == null) return null;
    if (description is String) return description;
    if (description is bool) return description ? 'Description available' : null;
    return description.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sequence': sequence,
    };
  }

  // Static method to get default onboarding pages (fallback)
  static List<OnboardingPageModel> getDefaultPages() {
    return [
      const OnboardingPageModel(
        id: 1,
        name: 'Welcome to Bazar',
        description: 'Discover the latest fashion trends and shop your favorite brands with ease.',
        image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=1000&fit=crop&crop=center',
        sequence: 1,
      ),
      const OnboardingPageModel(
        id: 2,
        name: 'Shop Smart',
        description: 'Get personalized recommendations and find exactly what you\'re looking for.',
        image: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800&h=1000&fit=crop&crop=center',
        sequence: 2,
      ),
      const OnboardingPageModel(
        id: 3,
        name: 'Fast Delivery',
        description: 'Enjoy quick delivery and easy returns. Your fashion journey starts here!',
        image: 'https://images.pexels.com/photos/4391477/pexels-photo-4391477.jpeg?auto=compress&cs=tinysrgb&w=800&h=1000&fit=crop',
        sequence: 3,
      ),
    ];
  }
}
