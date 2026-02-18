import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/email_verification_dialog.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/auth_button.dart';
import '../constants/auth_color_constants.dart';
import '../pages/number_verification_page.dart';
import '../pages/login_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/biometric_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _phoneFieldKey = GlobalKey<PhoneInputFieldState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final rawPhone = _phoneController.text.trim();
      final phoneWithCode = rawPhone.isEmpty ? null : (_phoneFieldKey.currentState?.fullPhoneNumber ?? rawPhone);
      final selectedCountry = _phoneFieldKey.currentState?.selectedCountry;
      final countryCode = selectedCountry?.countryCode; // ISO code like 'US', 'AE'
      context.read<AuthBloc>().add(RegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone : phoneWithCode,
            countryCode: countryCode,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Unfocus all text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is EmailVerificationRequired) {
            _showEmailVerificationDialog(context, state, navigateToLogin: true);
            // Show success snackbar after dialog is shown so it appears above
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.accountCreatedSuccessfully),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            });
          } else if (state is EmailVerificationResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.verificationEmailSent),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is Authenticated) {
            // AuthWrapper will automatically handle the navigation to HomePage
            // No need to manually navigate here
          } else if (state is MobileVerificationRequired) {
            Navigator.of(context).pushNamed(
              '/verify-mobile',
              arguments: NumberVerificationArgs(
                userId: state.userId,
                phoneMasked: state.phoneMasked,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        // App icon
                        Image.asset(
                          'assets/images/logo.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.createAccount,
                          style: AppFonts.getTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.joinUsAndStartShopping,
                          style: AppFonts.getTextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // First Name Field
                  AuthTextField(
                    controller: _firstNameController,
                    labelText: AppLocalizations.of(context)!.firstName,
                    hintText: AppLocalizations.of(context)!.enterYourFirstName,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourFirstName;
                      }
                      if (value.length < 2) {
                        return AppLocalizations.of(context)!.firstNameMustBeAtLeastTwoCharacters;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Last Name Field
                  AuthTextField(
                    controller: _lastNameController,
                    labelText: AppLocalizations.of(context)!.lastName,
                    hintText: AppLocalizations.of(context)!.enterYourLastName,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourLastName;
                      }
                      if (value.length < 2) {
                        return AppLocalizations.of(context)!.lastNameMustBeAtLeastTwoCharacters;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.enterYourEmailAddress,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Phone Number Field
                  PhoneInputField(
                    key: _phoneFieldKey,
                    controller: _phoneController,
                    labelText: AppLocalizations.of(context)!.phoneNumber,
                    hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
                      }
                      // Basic phone validation - allows digits, spaces, dashes, parentheses, and +
                      if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                        return AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Password Field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.createStrongPassword,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterPassword;
                      }
                      if (value.length < 8) {
                        return AppLocalizations.of(context)!.passwordMustBeAtLeastEightCharacters;
                      }
                      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                        return AppLocalizations.of(context)!.passwordMustContainUppercaseLowercaseAndNumber;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Confirm Password Field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    labelText: AppLocalizations.of(context)!.confirmPassword,
                    hintText: AppLocalizations.of(context)!.confirmYourPassword,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseConfirmYourPassword;
                      }
                      if (value != _passwordController.text) {
                        return AppLocalizations.of(context)!.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: true, // For demo purposes, always checked
                        onChanged: (value) {
                          // Handle terms acceptance
                        },
                        activeColor: AuthColorConstants.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Handle terms tap
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppFonts.getTextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              children: [
                                TextSpan(text: AppLocalizations.of(context)!.iAgreeToThe),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.termsOfService,
                                  style: TextStyle(
                                    color: AuthColorConstants.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: AppLocalizations.of(context)!.and),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.privacyPolicy,
                                  style: TextStyle(
                                    color: AuthColorConstants.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Register Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        onPressed: state is AuthLoading ? null : _handleRegister,
                        text: state is AuthLoading ? AppLocalizations.of(context)!.creatingAccount : AppLocalizations.of(context)!.createAccount,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Social sign-up options removed by request
                  const SizedBox(height: 20),
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAnAccount,
                        style: AppFonts.getTextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                                                  child: Text(
                            AppLocalizations.of(context)!.signIn,
                            style: AppFonts.getTextStyle(
                              color: AuthColorConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _showEmailVerificationDialog(
    BuildContext context,
    EmailVerificationRequired state, {
    bool navigateToLogin = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) => EmailVerificationDialog(
        email: state.email,
        userId: state.userId,
        apiToken: state.apiToken,
        onOkPressed: () {
          if (navigateToLogin) {
            // Close dialog first
            Navigator.of(dialogContext).pop();
            // Navigate to login page using navigation service with BiometricBloc provider
            NavigationService.pushReplacementSlideFromRight(
              BlocProvider(
                create: (context) => di.sl<BiometricBloc>(),
                child: const LoginPage(),
              ),
            );
          } else {
            // Just close dialog if not navigating to login
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }
}
