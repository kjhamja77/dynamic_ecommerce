import '../entities/terms_conditions.dart';

abstract class TermsConditionsRepository {
  Future<TermsConditionsResponse> getTermsConditions();
}
