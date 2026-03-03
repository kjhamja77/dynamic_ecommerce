import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:zalando_clone_app/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:zalando_clone_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:zalando_clone_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:zalando_clone_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:zalando_clone_app/features/checkout/domain/usecases/get_checkout_items.dart';
import 'package:zalando_clone_app/features/checkout/domain/usecases/get_checkout_summary.dart';
import 'package:zalando_clone_app/features/checkout/domain/usecases/place_order.dart';
import 'package:zalando_clone_app/features/checkout/presentation/bloc/order_bloc.dart';
import 'package:zalando_clone_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/terms_conditions/data/datasources/terms_conditions_remote_data_source.dart';
import '../../features/terms_conditions/data/repositories/terms_conditions_repository_impl.dart';
import '../../features/terms_conditions/domain/repositories/terms_conditions_repository.dart';
import '../../features/terms_conditions/domain/usecases/get_terms_conditions.dart';
import '../../features/terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import 'package:zalando_clone_app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:zalando_clone_app/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:zalando_clone_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:zalando_clone_app/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/clear_user_caches_on_logout_service.dart';
import '../services/device_service.dart';
import '../services/brand_mapping_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_mobile_code_usecase.dart';
import '../../features/auth/domain/usecases/google_login_usecase.dart';
import '../../features/auth/domain/usecases/resend_mobile_verification_usecase.dart';
import '../../features/auth/domain/usecases/resend_email_verification_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/usecases/guest_login_usecase.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_featured_products_usecase.dart';
import '../../features/home/domain/usecases/get_pages_usecase.dart';
import '../../features/home/domain/usecases/get_page_components_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/welcome_bloc.dart';
import '../../features/home/domain/usecases/get_welcome_texts_usecase.dart';
import '../../features/product_details/di/product_details_di.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/data/services/category_service_impl.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/datasources/search_local_data_source.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/services/category_service.dart';
import '../../features/search/domain/usecases/get_search_categories.dart';
import '../../features/search/domain/usecases/get_search_tabs.dart';
import '../../features/search/domain/usecases/get_subcategories.dart';
import '../../features/search/domain/usecases/get_subcategory_details.dart';
import '../../features/search/domain/usecases/search_products_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/presentation/bloc/subcategory_details_bloc.dart';
import '../../features/catalog/presentation/bloc/catalog_bloc.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/usecases/fetch_catalog_page.dart';
import '../../features/filters/domain/usecases/get_available_filters.dart';
import '../../features/filters/domain/usecases/clear_available_filters_cache.dart';
import '../../features/filters/domain/repositories/filter_repository.dart';
import '../../features/filters/data/filter_repository_impl.dart';
import '../../features/filters/data/datasources/filter_remote_data_source.dart';
import '../../features/filters/presentation/bloc/filter_bloc.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source_impl.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/add_to_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/remove_from_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/check_favorite_status_usecase.dart';
import '../../features/favorites/domain/usecases/clear_favorites_usecase.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/domain/usecases/get_user_orders.dart';
import '../../features/profile/domain/usecases/get_order_details.dart';
import '../../features/profile/domain/usecases/logout.dart';
import '../../features/profile/domain/usecases/delete_account.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../features/splash/splash.dart';
import '../../features/settings/settings.dart';
import '../../features/cart/cart.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/datasources/cart_remote_data_source_impl.dart';
import '../../features/payment_method/payment_method.dart';
import '../../features/orders/orders.dart';
import '../../features/orders/presentation/bloc/refund_requests_bloc.dart';
import '../../features/orders/domain/usecases/get_delivery_status.dart';
import '../../features/addresses/addresses.dart' as Addresses;
import '../../features/addresses/data/datasources/address_remote_data_source.dart' as Addr;
import '../../features/addresses/data/datasources/address_remote_data_source_impl.dart' as Addr;
import '../../features/addresses/domain/usecases/get_countries.dart' as Addresses;
import '../../features/addresses/domain/usecases/get_states.dart' as Addresses;
import '../../features/auth/data/datasources/biometric_local_data_source.dart';
import '../../features/auth/data/repositories/biometric_repository_impl.dart';
import '../../features/auth/domain/repositories/biometric_repository.dart';
import '../../features/auth/domain/usecases/authenticate_with_biometric.dart';
import '../../features/auth/domain/usecases/check_biometric_availability.dart';
import '../../features/auth/domain/usecases/get_biometric_settings.dart';
import '../../features/auth/domain/usecases/update_biometric_settings.dart';
import '../../features/auth/presentation/bloc/biometric_bloc.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/datasources/product_remote_data_source_impl.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_by_id.dart';
import '../../features/product/domain/usecases/get_product_list.dart';
import '../../features/product/domain/usecases/get_products_by_category.dart';
import '../../features/product/domain/usecases/search_products.dart' as ProductSearch;
import '../../features/product/domain/usecases/get_root_categories.dart';
import '../../features/product/domain/usecases/get_categories_by_parent_id.dart';
import '../../features/product/domain/usecases/get_all_categories.dart';
import '../../features/product/domain/usecases/get_category_hierarchy.dart';
import '../../features/product/domain/usecases/get_products_by_category_name.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/language_selection/data/datasources/language_remote_data_source.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Initialize SharedPreferences first
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
      deviceService: sl(),
      verifyMobileCodeUseCase: sl(),
      resendMobileVerificationUseCase: sl(),
      resendEmailVerificationUseCase: sl(),
      googleLoginUseCase: sl(),
      guestLoginUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => HomeBloc(
      getFeaturedProductsUseCase: sl(),
      getPagesUseCase: sl(),
      getPageComponentsUseCase: sl(),
      getRootCategoriesUseCase: sl(),
    ),
  );

  // Welcome Text Use Case
  sl.registerLazySingleton(() => GetWelcomeTextsUseCase(sl()));
  // Guest Login Use Case
  sl.registerLazySingleton(() => GuestLoginUseCase(sl()));

  // Welcome Bloc
  sl.registerFactory(
    () => WelcomeBloc(
      getWelcomeTextsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => SearchBloc(
      getSearchCategories: sl(),
      getSearchTabs: sl(),
      getSubcategories: sl(),
      searchProductsUseCase: sl(),
      searchRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => SubcategoryDetailsBloc(
      getSubcategoryDetails: sl(),
    ),
  );

  sl.registerFactory(
    () => CatalogBloc(
      fetchCatalogPage: sl(),
      filterDataSource: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => FavoritesBloc(
      getFavorites: sl(),
      addToFavorites: sl(),
      removeFromFavorites: sl(),
      checkFavoriteStatus: sl(),
      clearFavorites: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      getUserOrders: sl(),
      getOrderDetails: sl(),
      logout: sl(),
      deleteAccount: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => CartBloc(
      addToCart: sl(),
      getCart: sl(),
      removeFromCart: sl(),
      removeFromCartByQuantity: sl(),
      updateCartItemQuantity: sl(),
      clearCart: sl(),
    ),
  );

  sl.registerFactory(
    () => OnboardingBloc(
      checkOnboardingStatus: sl(),
      completeOnboarding: sl(),
      onboardingRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => SplashBloc(
      checkAppInitialization: sl(),
      splashRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsBloc(
      getSettings: sl(),
      updateLanguage: sl(),
      updateTheme: sl(),
      updateNotifications: sl(),
      updateSettings: sl(),
    ),
  );

  // Core (register early so downstream deps can resolve)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton<DeviceService>(() => DeviceService());

  // External
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Use cases
  sl.registerLazySingleton(() => UpdateSettings(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => VerifyMobileCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResendMobileVerificationUseCase(sl()));
  sl.registerLazySingleton(() => ResendEmailVerificationUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetPagesUseCase(sl()));
  sl.registerLazySingleton(() => GetPageComponentsUseCase(sl()));
  sl.registerLazySingleton(() => GetSearchCategories(sl()));
  sl.registerLazySingleton(() => GetSearchTabs(sl()));
  sl.registerLazySingleton(() => GetSubcategories(sl()));
  sl.registerLazySingleton(() => GetSubcategoryDetails(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => FetchCatalogPage(sl()));
  sl.registerLazySingleton(() => GetAvailableFilters(sl()));
  sl.registerLazySingleton(() => ClearAvailableFiltersCache(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => AddToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => CheckFavoriteStatusUseCase(sl()));
  sl.registerLazySingleton(() => ClearFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserOrders(sl()));
  sl.registerLazySingleton(() => GetOrderDetails(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => CheckOnboardingStatus(sl()));
  sl.registerLazySingleton(() => CompleteOnboarding(sl()));
  sl.registerLazySingleton(() => CheckAppInitialization(sl()));
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateLanguage(sl()));
  sl.registerLazySingleton(() => UpdateTheme(sl()));
  sl.registerLazySingleton(() => UpdateNotifications(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCartByQuantity(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));

  // Logout cache clear (used by AuthRepositoryImpl on logout)
  sl.registerLazySingleton<ClearUserCachesOnLogoutService>(
    () => ClearUserCachesOnLogoutService(
      cartLocal: sl<CartLocalDataSource>(),
      orderLocal: sl<OrderLocalDataSource>(),
      homeLocal: sl<HomeLocalDataSource>(),
      addressLocal: sl<Addresses.AddressLocalDataSource>(),
      paymentMethodLocal: sl<PaymentMethodLocalDataSource>(),
      filterRemote: sl<FilterRemoteDataSource>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storage: sl(),
      sharedPreferences: sl(),
      logoutCacheClearService: sl<ClearUserCachesOnLogoutService>(),
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      productRepository: sl(),
      localDataSource: sl<HomeLocalDataSource>(),
    ),
  );

  // Register CategoryService
  sl.registerLazySingleton<CategoryService>(
    () => CategoryServiceImpl(productRepository: sl()),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      categoryService: sl(),
      searchRemoteDataSource: sl(),
      searchLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      homeRepository: sl<HomeRepository>(),
      productRepository: sl<ProductRepository>(),
      filterRemoteDataSource: sl<FilterRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<FilterRepository>(
    () => FilterRepositoryImpl(
      remoteDataSource: sl<FilterRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      authRepository: sl<AuthRepository>(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSource(sharedPreferences: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<LanguageRemoteDataSource>(
    () => LanguageRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<FilterRemoteDataSource>(
    () => FilterRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  
  // Initialize BrandMappingService with the filter data source
  BrandMappingService().initialize(sl<FilterRemoteDataSource>());
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(sl(), sl()),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Payment Method Feature
  sl.registerLazySingleton<PaymentMethodLocalDataSource>(
    () => PaymentMethodLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PaymentMethodRemoteDataSource>(
    () => PaymentMethodRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<PaymentMethodRepository>(
    () => PaymentMethodRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<GetPaymentMethodsUseCase>(
    () => GetPaymentMethodsUseCase(sl()),
  );

  sl.registerLazySingleton<AddPaymentMethodUseCase>(
    () => AddPaymentMethodUseCase(sl()),
  );

  sl.registerLazySingleton<DeletePaymentMethodUseCase>(
    () => DeletePaymentMethodUseCase(sl()),
  );

  sl.registerLazySingleton<SetDefaultPaymentMethodUseCase>(
    () => SetDefaultPaymentMethodUseCase(sl()),
  );

  sl.registerFactory<PaymentMethodBloc>(
    () => PaymentMethodBloc(
      getPaymentMethodsUseCase: sl(),
      addPaymentMethodUseCase: sl(),
      deletePaymentMethodUseCase: sl(),
      setDefaultPaymentMethodUseCase: sl(),
    ),
  );

  // Orders Feature
  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl<OrderRemoteDataSource>(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<GetOrders>(() => GetOrders(sl()));
  sl.registerLazySingleton<GetOrderById>(() => GetOrderById(sl()));
  sl.registerLazySingleton<CreateOrder>(() => CreateOrder(sl()));
  sl.registerLazySingleton<CancelOrder>(() => CancelOrder(sl()));
  sl.registerLazySingleton<GetDeliveryStatus>(() => GetDeliveryStatus(sl()));
  sl.registerLazySingleton<CreateRefundRequest>(() => CreateRefundRequest(sl()));
  sl.registerLazySingleton<GetRefundRequests>(() => GetRefundRequests(sl()));
  sl.registerLazySingleton<GetRefundRequestDetails>(
    () => GetRefundRequestDetails(sl()),
  );
  sl.registerLazySingleton<CancelRefundRequest>(
    () => CancelRefundRequest(sl()),
  );

  sl.registerFactory<OrdersBloc>(
    () => OrdersBloc(
      getOrders: sl(),
      getOrderById: sl(),
      createOrder: sl(),
      cancelOrder: sl(),
      getDeliveryStatus: sl(),
    ),
  );

  sl.registerFactory<RefundRequestsBloc>(
    () => RefundRequestsBloc(
      getRefundRequests: sl<GetRefundRequests>(),
    ),
  );

  // Addresses Feature
  sl.registerLazySingleton<Addresses.AddressLocalDataSource>(
    () => Addresses.AddressLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<Addresses.AddressRepository>(
    () => Addresses.AddressRepositoryImpl(
      local: sl<Addresses.AddressLocalDataSource>(),
      remote: sl<Addr.AddressRemoteDataSource>(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => Addresses.GetAddresses(sl()));
  sl.registerLazySingleton(() => Addresses.AddAddress(sl()));
  sl.registerLazySingleton(() => Addresses.UpdateAddress(sl()));
  sl.registerLazySingleton(() => Addresses.DeleteAddress(sl()));
  sl.registerLazySingleton(() => Addresses.SetDefaultAddress(sl()));
  sl.registerFactory(() => Addresses.AddressBloc(
        getAddresses: sl(),
        addAddress: sl(),
        updateAddress: sl(),
        deleteAddress: sl(),
        setDefaultAddress: sl(),
        getCountries: sl(),
        getStates: sl(),
      ));

  // Addresses remote data source
  sl.registerLazySingleton<Addr.AddressRemoteDataSource>(
    () => Addr.AddressRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Master data usecases
  sl.registerLazySingleton(() => Addresses.GetCountries(sl()));
  sl.registerLazySingleton(() => Addresses.GetStates(sl()));

  // Biometric Feature
  sl.registerLazySingleton<BiometricLocalDataSource>(
    () => BiometricLocalDataSourceImpl(),
  );
  
  sl.registerLazySingleton<BiometricRepository>(
    () => BiometricRepositoryImpl(localDataSource: sl()),
  );
  
  sl.registerLazySingleton<CheckBiometricAvailability>(
    () => CheckBiometricAvailability(sl()),
  );
  
  sl.registerLazySingleton<AuthenticateWithBiometric>(
    () => AuthenticateWithBiometric(sl()),
  );
  
  sl.registerLazySingleton<GetBiometricSettings>(
    () => GetBiometricSettings(sl()),
  );
  
  sl.registerLazySingleton<UpdateBiometricSettings>(
    () => UpdateBiometricSettings(sl()),
  );
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => GetProductList(sl()));
  sl.registerLazySingleton(() => GetProductsByCategory(sl()));
  sl.registerLazySingleton(() => ProductSearch.SearchProducts(sl()));
  sl.registerLazySingleton(() => GetRootCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesByParentIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryHierarchy(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryName(sl()));
  
  sl.registerFactory<BiometricBloc>(
    () => BiometricBloc(
      checkBiometricAvailability: sl(),
      authenticateWithBiometric: sl(),
      getBiometricSettings: sl(),
      updateBiometricSettings: sl(),
    ),
  );

  // Product Feature
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductById: sl(),
      getProductList: sl(),
      getProductsByCategory: sl(),
      searchProducts: sl<ProductSearch.SearchProducts>(),
      getRootCategories: sl<GetRootCategoriesUseCase>(),
      getCategoriesByParentId: sl<GetCategoriesByParentIdUseCase>(),
      getAllCategories: sl<GetAllCategoriesUseCase>(),
    ),
  );

  // Filter Feature
  sl.registerFactory<FilterBloc>(
    () => FilterBloc(repository: sl<FilterRepository>()),
  );

  // Core & External already registered above

  // Product Details Feature
  ProductDetailsDI.setup(sl);

  // Checkout Feature - Commented out due to import conflicts
  // sl.registerLazySingleton<CheckoutLocalDataSource>(
  //   () => CheckoutLocalDataSourceImpl(sl()),
  // );

  // Checkout – remote shipping methods wiring
  // Local DS required by repository
  sl.registerLazySingleton<CheckoutLocalDataSource>(
    () => CheckoutLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      localDataSource: sl<CheckoutLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      remoteDataSource: sl<CheckoutRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetCheckoutItems>(
    () => GetCheckoutItems(sl<CheckoutRepository>()),
  );

  sl.registerLazySingleton<GetCheckoutSummary>(
    () => GetCheckoutSummary(sl<CheckoutRepository>()),
  );

  sl.registerLazySingleton<PlaceOrder>(
    () => PlaceOrder(sl<CheckoutRepository>()),
  );

  sl.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(
      checkoutRepository: sl<CheckoutRepository>(),
    ),
  );

  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      placeOrder: sl<PlaceOrder>(),
      clearCart: sl<ClearCart>(),
      checkoutRepository: sl<CheckoutRepository>(),
    ),
  );

  // Terms and Conditions
  sl.registerLazySingleton<TermsConditionsRemoteDataSource>(
    () => TermsConditionsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<TermsConditionsRepository>(
    () => TermsConditionsRepositoryImpl(
      remoteDataSource: sl<TermsConditionsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => GetTermsConditions(sl<TermsConditionsRepository>()));

  sl.registerFactory(
    () => TermsConditionsBloc(
      getTermsConditions: sl<GetTermsConditions>(),
    ),
  );
}
