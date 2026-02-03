import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/errors/failures.dart';
import 'package:zalando_clone_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:zalando_clone_app/features/favorites/domain/usecases/add_to_favorites_usecase.dart';
import 'package:zalando_clone_app/features/favorites/domain/usecases/check_favorite_status_usecase.dart';
import 'package:zalando_clone_app/features/favorites/domain/usecases/clear_favorites_usecase.dart';
import 'package:zalando_clone_app/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:zalando_clone_app/features/favorites/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:zalando_clone_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:zalando_clone_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:zalando_clone_app/features/favorites/presentation/bloc/favorites_state.dart';

import 'favorites_bloc_test.mocks.dart';

@GenerateMocks([
  GetFavoritesUseCase,
  AddToFavoritesUseCase,
  RemoveFromFavoritesUseCase,
  CheckFavoriteStatusUseCase,
  ClearFavoritesUseCase,
])
void main() {
  late FavoritesBloc favoritesBloc;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;
  late MockAddToFavoritesUseCase mockAddToFavoritesUseCase;
  late MockRemoveFromFavoritesUseCase mockRemoveFromFavoritesUseCase;
  late MockCheckFavoriteStatusUseCase mockCheckFavoriteStatusUseCase;
  late MockClearFavoritesUseCase mockClearFavoritesUseCase;

  final tFavorites = [
    FavoriteProduct(
      id: '1',
      name: 'Test Product 1',
      brand: 'Test Brand',
      price: 99.99,
      imageUrl: 'https://example.com/image1.jpg',
      category: 'Electronics',
      addedAt: DateTime(2024, 1, 1),
    ),
    FavoriteProduct(
      id: '2',
      name: 'Test Product 2',
      brand: 'Test Brand',
      price: 149.99,
      imageUrl: 'https://example.com/image2.jpg',
      category: 'Clothing',
      addedAt: DateTime(2024, 1, 2),
    ),
  ];

  final tFavoriteStatuses = {
    '1': true,
    '2': true,
    '3': false,
  };

  setUp(() {
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    mockAddToFavoritesUseCase = MockAddToFavoritesUseCase();
    mockRemoveFromFavoritesUseCase = MockRemoveFromFavoritesUseCase();
    mockCheckFavoriteStatusUseCase = MockCheckFavoriteStatusUseCase();
    mockClearFavoritesUseCase = MockClearFavoritesUseCase();

    favoritesBloc = FavoritesBloc(
      getFavorites: mockGetFavoritesUseCase,
      addToFavorites: mockAddToFavoritesUseCase,
      removeFromFavorites: mockRemoveFromFavoritesUseCase,
      checkFavoriteStatus: mockCheckFavoriteStatusUseCase,
      clearFavorites: mockClearFavoritesUseCase,
    );
  });

  tearDown(() {
    favoritesBloc.close();
  });

  test('initial state should be FavoritesInitial', () {
    expect(favoritesBloc.state, FavoritesInitial());
  });

  group('LoadFavorites', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoading, FavoritesLoaded] when getFavorites succeeds',
      build: () {
        when(mockGetFavoritesUseCase()).thenAnswer((_) async => Right(tFavorites));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded(
          favorites: tFavorites,
          favoriteStatuses: {'1': true, '2': true},
        ),
      ],
      verify: (_) {
        verify(mockGetFavoritesUseCase()).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoading, FavoritesError] when getFavorites fails',
      build: () {
        when(mockGetFavoritesUseCase()).thenAnswer(
          (_) async => Left(ServerFailure('Server error')),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () => [
        FavoritesLoading(),
        FavoritesError('Server error'),
      ],
      verify: (_) {
        verify(mockGetFavoritesUseCase()).called(1);
      },
    );
  });

  group('AddToFavorites', () {
    final tNewFavorite = FavoriteProduct(
      id: '3',
      name: 'New Product',
      brand: 'New Brand',
      price: 199.99,
      imageUrl: 'https://example.com/image3.jpg',
      category: 'Accessories',
      addedAt: DateTime(2024, 1, 3),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit optimistic update then success when addToFavorites succeeds',
      build: () {
        when(mockAddToFavoritesUseCase(any)).thenAnswer((_) async => const Right(null));
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: tFavorites,
        favoriteStatuses: tFavoriteStatuses,
      ),
      act: (bloc) => bloc.add(AddToFavorites(tNewFavorite)),
      expect: () => [
        FavoritesLoaded(
          favorites: [...tFavorites, tNewFavorite],
          favoriteStatuses: {...tFavoriteStatuses, '3': true},
        ),
      ],
      verify: (_) {
        verify(mockAddToFavoritesUseCase(tNewFavorite)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit optimistic update then revert and error when addToFavorites fails',
      build: () {
        when(mockAddToFavoritesUseCase(any)).thenAnswer(
          (_) async => Left(CacheFailure('Cache error')),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: tFavorites,
        favoriteStatuses: tFavoriteStatuses,
      ),
      act: (bloc) => bloc.add(AddToFavorites(tNewFavorite)),
      expect: () => [
        FavoritesLoaded(
          favorites: [...tFavorites, tNewFavorite],
          favoriteStatuses: {...tFavoriteStatuses, '3': true},
        ),
        FavoritesLoaded(
          favorites: tFavorites,
          favoriteStatuses: tFavoriteStatuses,
        ),
        FavoritesError('Cache error'),
      ],
      verify: (_) {
        verify(mockAddToFavoritesUseCase(tNewFavorite)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesError] when not in loaded state and addToFavorites fails',
      build: () {
        when(mockAddToFavoritesUseCase(any)).thenAnswer(
          (_) async => Left(CacheFailure('Cache error')),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(AddToFavorites(tNewFavorite)),
      expect: () => [
        FavoritesError('Cache error'),
      ],
      verify: (_) {
        verify(mockAddToFavoritesUseCase(tNewFavorite)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoading] when not in loaded state and addToFavorites succeeds',
      build: () {
        when(mockAddToFavoritesUseCase(any)).thenAnswer((_) async => const Right(null));
        when(mockGetFavoritesUseCase()).thenAnswer((_) async => Right(tFavorites));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(AddToFavorites(tNewFavorite)),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded(
          favorites: tFavorites,
          favoriteStatuses: {'1': true, '2': true},
        ),
      ],
      verify: (_) {
        verify(mockAddToFavoritesUseCase(tNewFavorite)).called(1);
        verify(mockGetFavoritesUseCase()).called(1);
      },
    );
  });

  group('RemoveFromFavorites', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should emit optimistic update then success when removeFromFavorites succeeds',
      build: () {
        when(mockRemoveFromFavoritesUseCase(any)).thenAnswer((_) async => const Right(null));
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: tFavorites,
        favoriteStatuses: tFavoriteStatuses,
      ),
      act: (bloc) => bloc.add(RemoveFromFavorites('1')),
      expect: () => [
        FavoritesLoaded(
          favorites: [tFavorites[1]], // Remove first item
          favoriteStatuses: {...tFavoriteStatuses, '1': false},
        ),
      ],
      verify: (_) {
        verify(mockRemoveFromFavoritesUseCase('1')).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit optimistic update then revert and error when removeFromFavorites fails',
      build: () {
        when(mockRemoveFromFavoritesUseCase(any)).thenAnswer(
          (_) async => Left(CacheFailure('Cache error')),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: tFavorites,
        favoriteStatuses: tFavoriteStatuses,
      ),
      act: (bloc) => bloc.add(RemoveFromFavorites('1')),
      expect: () => [
        FavoritesLoaded(
          favorites: [tFavorites[1]], // Remove first item
          favoriteStatuses: {...tFavoriteStatuses, '1': false},
        ),
        FavoritesLoaded(
          favorites: tFavorites,
          favoriteStatuses: tFavoriteStatuses,
        ),
        FavoritesError('Cache error'),
      ],
      verify: (_) {
        verify(mockRemoveFromFavoritesUseCase('1')).called(1);
      },
    );
  });

  group('CheckFavoriteStatus', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoriteStatusUpdated] when checkFavoriteStatus succeeds',
      build: () {
        when(mockCheckFavoriteStatusUseCase(any)).thenAnswer((_) async => const Right(true));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(CheckFavoriteStatus('1')),
      expect: () => [
        FavoriteStatusUpdated('1', true),
      ],
      verify: (_) {
        verify(mockCheckFavoriteStatusUseCase('1')).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesError] when checkFavoriteStatus fails',
      build: () {
        when(mockCheckFavoriteStatusUseCase(any)).thenAnswer(
          (_) async => Left(CacheFailure('Cache error')),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(CheckFavoriteStatus('1')),
      expect: () => [
        FavoritesError('Cache error'),
      ],
      verify: (_) {
        verify(mockCheckFavoriteStatusUseCase('1')).called(1);
      },
    );
  });

  group('ClearFavorites', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoaded] with empty lists when clearFavorites succeeds',
      build: () {
        when(mockClearFavoritesUseCase()).thenAnswer((_) async => const Right(null));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(ClearFavorites()),
      expect: () => [
        FavoritesLoaded(favorites: [], favoriteStatuses: {}),
      ],
      verify: (_) {
        verify(mockClearFavoritesUseCase()).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesError] when clearFavorites fails',
      build: () {
        when(mockClearFavoritesUseCase()).thenAnswer(
          (_) async => Left(CacheFailure('Cache error')),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(ClearFavorites()),
      expect: () => [
        FavoritesError('Cache error'),
      ],
      verify: (_) {
        verify(mockClearFavoritesUseCase()).called(1);
      },
    );
  });

  group('ToggleFavorite', () {
    final tProduct = FavoriteProduct(
      id: '3',
      name: 'Toggle Product',
      brand: 'Toggle Brand',
      price: 299.99,
      imageUrl: 'https://example.com/toggle.jpg',
      category: 'Shoes',
      addedAt: DateTime(2024, 1, 3),
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should call RemoveFromFavorites when product is already favorite',
      build: () {
        when(mockRemoveFromFavoritesUseCase(any)).thenAnswer((_) async => const Right(null));
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: [...tFavorites, tProduct],
        favoriteStatuses: {...tFavoriteStatuses, '3': true},
      ),
      act: (bloc) => bloc.add(ToggleFavorite(tProduct, true)),
      verify: (_) {
        verify(mockRemoveFromFavoritesUseCase('3')).called(1);
        verifyNever(mockAddToFavoritesUseCase(any));
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should call AddToFavorites when product is not favorite',
      build: () {
        when(mockAddToFavoritesUseCase(any)).thenAnswer((_) async => const Right(null));
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favorites: tFavorites,
        favoriteStatuses: tFavoriteStatuses,
      ),
      act: (bloc) => bloc.add(ToggleFavorite(tProduct, false)),
      verify: (_) {
        verify(mockAddToFavoritesUseCase(tProduct)).called(1);
        verifyNever(mockRemoveFromFavoritesUseCase(any));
      },
    );
  });
}
