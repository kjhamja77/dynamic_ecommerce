import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {}

class UpdateUserProfile extends ProfileEvent {
  final UserProfile profile;

  const UpdateUserProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class LoadUserOrders extends ProfileEvent {}

class LoadOrderDetails extends ProfileEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class Logout extends ProfileEvent {}

class DeleteAccount extends ProfileEvent {}

class NavigateToSettings extends ProfileEvent {}

class NavigateToOrders extends ProfileEvent {}
