import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart' as dartz;
import '../../domain/entities/user_order.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/get_user_orders.dart';
import '../../domain/usecases/get_order_details.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/delete_account.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/auth_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;
  final GetUserOrders getUserOrders;
  final GetOrderDetails getOrderDetails;
  final LogoutUseCase logout;
  final DeleteAccountUseCase deleteAccount;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.getUserOrders,
    required this.getOrderDetails,
    required this.logout,
    required this.deleteAccount,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserOrders>(_onLoadUserOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<Logout>(_onLogout);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Only show loading if we don't already have profile data
    if (state is! ProfileLoaded) {
      emit(ProfileLoading());
    }
    
    final result = await getUserProfile(NoParams());

    if (result.isLeft()) {
      final failure = (result as dartz.Left).value;
      {
        final failureMessage = failure.toString().toLowerCase();
        
        // Check for token expiration errors
        if (failureMessage.contains('token') && 
            (failureMessage.contains('expired') || 
             failureMessage.contains('invalid') || 
             failureMessage.contains('unauthorized'))) {
          
          debugPrint('ProfileBloc:_onLoadUserProfile → Token expiration detected: $failureMessage');
          
          // Clear the token and let AuthWrapper handle navigation
          AuthService().handleTokenExpiration();
          
          // Emit a specific error state that the UI can handle
          emit(ProfileError('Session expired. Please log in again.'));
        } else {
          emit(ProfileError(failure.toString()));
        }
      }
    } else {
      final profile = (result as dartz.Right).value;

      // Also load orders so count is correct when profile screen first appears
      List<UserOrder> orders = const [];
      try {
        final ordersResult = await getUserOrders(const NoParams());
        if (ordersResult.isRight()) {
          orders = (ordersResult as dartz.Right).value;
        }
      } catch (_) {
        // Ignore orders loading errors here; profile will still load
      }

      emit(ProfileLoaded(profile: profile, orders: orders));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Allow updates from any state except ProfileLoading
    // If we're in ProfileInitial or ProfileError, we can still update
    if (state is ProfileLoading) {
      debugPrint('ProfileBloc: Cannot update profile - currently loading');
      return;
    }

    emit(ProfileUpdating(event.profile));

    debugPrint('ProfileBloc: Updating profile from state: ${state.runtimeType}');
    debugPrint('ProfileBloc: Profile data - Name: ${event.profile.name}, Email: ${event.profile.email}');
    debugPrint('ProfileBloc: Profile data - Phone: ${event.profile.phoneNumber}, Country: ${event.profile.countryCode}');
    debugPrint('ProfileBloc: Profile data - Avatar: ${event.profile.avatarUrl}');
    
    final result = await updateUserProfile(event.profile);
    debugPrint('ProfileBloc: Update result: $result');

    await result.fold(
      (failure) async {
        debugPrint('ProfileBloc: Update failed: ${failure.toString()}');
        emit(ProfileError(failure.toString()));
      },
      (updatedProfile) async {
        debugPrint('ProfileBloc: Update successful');
        debugPrint('ProfileBloc: Updated profile - Name: ${updatedProfile.name}, Email: ${updatedProfile.email}');
        debugPrint('ProfileBloc: Updated profile - Phone: ${updatedProfile.phoneNumber}, Country: ${updatedProfile.countryCode}');
        debugPrint('ProfileBloc: Updated profile - Avatar: ${updatedProfile.avatarUrl}');

        // Emit ProfileUpdated first, then transition to ProfileLoaded to maintain orders
        emit(ProfileUpdated(updatedProfile));

        // Await orders so all emit() calls happen before the event handler completes
        final ordersResult = await getUserOrders(NoParams());
        ordersResult.fold(
          (_) {
            if (!emit.isDone) {
              emit(ProfileLoaded(profile: updatedProfile, orders: const []));
            }
          },
          (orders) {
            if (!emit.isDone) {
              emit(ProfileLoaded(profile: updatedProfile, orders: orders));
              debugPrint('ProfileBloc: Transitioned to ProfileLoaded with ${orders.length} orders');
            }
          },
        );
      },
    );
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrders event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isLoadingOrders: true));
      
      final result = await getUserOrders(NoParams());
      
      result.fold(
        (failure) => emit(ProfileError(failure.toString())),
        (orders) => emit(currentState.copyWith(
          orders: orders,
          isLoadingOrders: false,
        )),
      );
    }
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<ProfileState> emit,
  ) async {
    emit(OrdersLoading());
    
    final result = await getOrderDetails(event.orderId);
    
    result.fold(
      (failure) => emit(OrdersError(failure.toString())),
      (order) => emit(OrdersLoaded([order])),
    );
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<ProfileState> emit,
  ) async {
    emit(LoggingOut());
    
    final result = await logout(NoParams());
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (_) => emit(LoggedOut()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(DeletingAccount());
    
    final result = await deleteAccount(NoParams());
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (_) => emit(AccountDeleted()),
    );
  }
}
