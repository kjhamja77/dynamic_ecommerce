import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_mobile_code_usecase.dart';
import '../../domain/usecases/resend_mobile_verification_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/guest_login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/device_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email; // Can be either email address or phone number
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? countryCode;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.countryCode,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone, countryCode];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyMobileCodeRequested extends AuthEvent {
  final int userId;
  final String verificationCode;

  const VerifyMobileCodeRequested({required this.userId, required this.verificationCode});

  @override
  List<Object?> get props => [userId, verificationCode];
}

class ResendMobileVerificationRequested extends AuthEvent {
  final int userId;

  const ResendMobileVerificationRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class BiometricAuthenticated extends AuthEvent {
  final User user;
  const BiometricAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class GoogleLoginRequested extends AuthEvent {
  final String idToken;
  const GoogleLoginRequested({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}

class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordEmailSent extends AuthState {
  final String email;
  const ForgotPasswordEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

class EmailVerificationRequired extends AuthState {
  final String email;
  final String message;
  
  const EmailVerificationRequired({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

class MobileVerificationSuccess extends AuthState {
  final User user;

  const MobileVerificationSuccess(this.user);

  @override
  List<Object> get props => [user];
}
class MobileVerificationResent extends AuthState {}

class MobileVerificationRequired extends AuthState {
  final int? userId;
  final String? phoneMasked;
  final String message;

  const MobileVerificationRequired({this.userId, this.phoneMasked, this.message = ''});

  @override
  List<Object?> get props => [userId, phoneMasked, message];
}

class MobileNumberMissing extends AuthState {
  final String message;
  const MobileNumberMissing({this.message = ''});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  final DeviceService deviceService;
  final VerifyMobileCodeUseCase verifyMobileCodeUseCase;
  final ResendMobileVerificationUseCase resendMobileVerificationUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final GuestLoginUseCase guestLoginUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.deviceService,
    required this.verifyMobileCodeUseCase,
    required this.resendMobileVerificationUseCase,
    required this.googleLoginUseCase,
    required this.guestLoginUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<BiometricAuthenticated>(_onBiometricAuthenticated);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyMobileCodeRequested>(_onVerifyMobileCodeRequested);
    on<ResendMobileVerificationRequested>(_onResendMobileVerificationRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Get device information
      final deviceInfo = await deviceService.getDeviceInfo();
      final deviceId = deviceInfo['device_id']!;
      final deviceToken = deviceInfo['device_token'];

      final result = await loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
        deviceId: deviceId,
        deviceToken: deviceToken,
      ));

      result.fold(
        (failure) {
          // Check if this is an email verification error
          if (failure.message.contains('EMAIL_NOT_VERIFIED') || 
              failure.message.contains('Email not verified')) {
            emit(EmailVerificationRequired(
              email: event.email,
              message: failure.message,
            ));
          } else if (failure.message.contains('NO_MOBILE_NUMBER')) {
            emit(MobileNumberMissing(message: failure.message));
          } else if (failure.message.contains('MOBILE_VERIFICATION_REQUIRED') ||
                     failure.message.toLowerCase().contains('mobile') &&
                     failure.message.toLowerCase().contains('verif')) {
            // Extract user_id and mobile from the error message
            int? userId;
            String? mobile;
            
            if (failure.message.contains('|USER_ID:')) {
              final parts = failure.message.split('|');
              for (final part in parts) {
                if (part.startsWith('USER_ID:')) {
                  userId = int.tryParse(part.substring(8));
                } else if (part.startsWith('MOBILE:')) {
                  mobile = part.substring(7);
                }
              }
            }
            
            emit(MobileVerificationRequired(
              userId: userId,
              phoneMasked: mobile,
              message: failure.message.split('|')[0], // Get the original message without the extra data
            ));
          } else {
            emit(AuthError(failure.message));
          }
        },
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Failed to get device information: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      countryCode: event.countryCode,
    ));

    result.fold(
      (failure) {
        // Check if this is an email verification or mobile verification error
        if (failure.message.contains('EMAIL_NOT_VERIFIED') || 
            failure.message.contains('Email not verified')) {
          emit(EmailVerificationRequired(
            email: event.email,
            message: failure.message,
          ));
        } else if (failure.message.contains('MOBILE_VERIFICATION_REQUIRED') ||
                   (failure.message.toLowerCase().contains('mobile') &&
                    failure.message.toLowerCase().contains('verif'))) {
          // Extract user_id and mobile from the error message
          int? userId;
          String? mobile;

          if (failure.message.contains('|USER_ID:')) {
            final parts = failure.message.split('|');
            for (final part in parts) {
              if (part.startsWith('USER_ID:')) {
                userId = int.tryParse(part.substring(8));
              } else if (part.startsWith('MOBILE:')) {
                mobile = part.substring(7);
              }
            }
          }

          emit(MobileVerificationRequired(
            userId: userId,
            phoneMasked: mobile,
            message: failure.message.split('|')[0],
          ));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('AuthBloc:_onLogoutRequested → start');
    emit(AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) {
        debugPrint('AuthBloc:_onLogoutRequested → repo failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        debugPrint('AuthBloc:_onLogoutRequested → repo success, emitting Unauthenticated');
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔍 AuthBloc:_onCheckAuthStatus → start');
    
    final result = await authRepository.isAuthenticated();

    bool? isAuthed;
    result.fold(
      (failure) {
        debugPrint('🔍 AuthBloc:_onCheckAuthStatus → isAuthenticated failed: ${failure.message}');
        isAuthed = null;
      },
      (value) {
        debugPrint('🔍 AuthBloc:_onCheckAuthStatus → isAuthenticated result: $value');
        isAuthed = value;
      },
    );

    if (isAuthed != true) {
      debugPrint('🔍 AuthBloc:_onCheckAuthStatus → not authenticated, emitting Unauthenticated');
      emit(Unauthenticated());
      return;
    }

    debugPrint('🔍 AuthBloc:_onCheckAuthStatus → authenticated, getting current user');
    final userResult = await authRepository.getCurrentUser();
    userResult.fold(
      (failure) {
        debugPrint('🔍 AuthBloc:_onCheckAuthStatus → getCurrentUser failed: ${failure.message}');
        emit(Unauthenticated());
      },
      (user) {
        if (user != null) {
          debugPrint('🔍 AuthBloc:_onCheckAuthStatus → user found, emitting Authenticated');
          emit(Authenticated(user));
        } else {
          debugPrint('🔍 AuthBloc:_onCheckAuthStatus → user is null, emitting Unauthenticated');
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onBiometricAuthenticated(
    BiometricAuthenticated event,
    Emitter<AuthState> emit,
  ) async {
    emit(Authenticated(event.user));
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(ForgotPasswordEmailSent(event.email)),
    );
  }

  Future<void> _onVerifyMobileCodeRequested(
    VerifyMobileCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyMobileCodeUseCase(VerifyMobileCodeParams(
      userId: event.userId,
      verificationCode: event.verificationCode,
    ));
    result.fold(
      (failure) {
        // Check for specific error codes
        if (failure.message.contains('NO_VERIFICATION_CODE')) {
          emit(AuthError('No verification code found. Please request a new code.'));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) {
        emit(MobileVerificationSuccess(user));
        // Also emit Authenticated state so AuthWrapper can handle navigation
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onResendMobileVerificationRequested(
    ResendMobileVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resendMobileVerificationUseCase(ResendMobileVerificationParams(userId: event.userId));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(MobileVerificationResent()),
    );
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final deviceInfo = await deviceService.getDeviceInfo();
      final deviceId = deviceInfo['device_id']!;
      final deviceToken = deviceInfo['device_token'];

      final result = await googleLoginUseCase(GoogleLoginParams(
        idToken: event.idToken,
        deviceId: deviceId,
        deviceToken: deviceToken,
      ));

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Failed to get device information: ${e.toString()}'));
    }
  }

  Future<void> _onGuestLoginRequested(
    GuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final deviceInfo = await deviceService.getDeviceInfo();
      final deviceId = deviceInfo['device_id']!;
      final deviceToken = deviceInfo['device_token'];

      final result = await guestLoginUseCase(GuestLoginParams(
        deviceId: deviceId,
        deviceToken: deviceToken,
      ));

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Failed to get device information: ${e.toString()}'));
    }
  }
}
