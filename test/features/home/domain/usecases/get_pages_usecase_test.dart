import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/home/domain/entities/page.dart';
import 'package:zalando_clone_app/features/home/domain/repositories/home_repository.dart';
import 'package:zalando_clone_app/features/home/domain/usecases/get_pages_usecase.dart';

import 'get_pages_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late GetPagesUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetPagesUseCase(mockRepository);
  });

  const tUserId = 1;
  final tPages = [
    Page(
      id: 1,
      name: 'home',
      title: 'Home',
      description: 'Main home page',
      icon: 'home_icon',
      order: 1,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Page(
      id: 2,
      name: 'catalog',
      title: 'Catalog',
      description: 'Product catalog page',
      icon: 'catalog_icon',
      order: 2,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetPagesUseCase', () {
    test('should get pages from the repository', () async {
      // arrange
      when(mockRepository.getPages(tUserId))
          .thenAnswer((_) async => Right(tPages));

      // act
      final result = await useCase(GetPagesParams(userId: tUserId));

      // assert
      expect(result, Right(tPages));
      verify(mockRepository.getPages(tUserId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(mockRepository.getPages(tUserId))
          .thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await useCase(GetPagesParams(userId: tUserId));

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getPages(tUserId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
