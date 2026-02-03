import '../entities/terms_conditions.dart';
import '../repositories/terms_conditions_repository.dart';

class GetTermsConditions {
  final TermsConditionsRepository repository;

  GetTermsConditions(this.repository);

  Future<TermsConditionsResponse> call() async {
    return await repository.getTermsConditions();
  }
}
