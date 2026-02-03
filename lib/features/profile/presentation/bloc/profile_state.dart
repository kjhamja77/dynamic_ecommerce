import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_order.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<UserOrder> orders;
  final bool isLoadingOrders;

  const ProfileLoaded({
    required this.profile,
    this.orders = const [],
    this.isLoadingOrders = false,
  });

  @override
  List<Object?> get props => [profile, orders, isLoadingOrders];

  ProfileLoaded copyWith({
    UserProfile? profile,
    List<UserOrder>? orders,
    bool? isLoadingOrders,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      orders: orders ?? this.orders,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OrdersLoading extends ProfileState {}

class OrdersLoaded extends ProfileState {
  final List<UserOrder> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrdersError extends ProfileState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class LoggingOut extends ProfileState {}

class LoggedOut extends ProfileState {}

class DeletingAccount extends ProfileState {}

class AccountDeleted extends ProfileState {}
