import '../../domain/entities/terms_conditions.dart';
import '../../domain/repositories/terms_conditions_repository.dart';
import '../datasources/terms_conditions_remote_data_source.dart';

class TermsConditionsRepositoryImpl implements TermsConditionsRepository {
  final TermsConditionsRemoteDataSource remoteDataSource;

  TermsConditionsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<TermsConditionsResponse> getTermsConditions() async {
    try {
      final response = await remoteDataSource.getTermsConditions();
      return response;
    } catch (e) {
      throw Exception('Failed to get terms and conditions: $e');
    }
  }
}
