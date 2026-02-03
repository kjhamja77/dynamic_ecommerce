import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../constants/auth_color_constants.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ForgotPasswordRequested(_emailController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () async {
            await HapticService.buttonClick();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordEmailSent) {
            AppSnackBar.success(context, '${AppLocalizations.of(context)!.resetLinkSentTo} ${state.email}');
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            AppSnackBar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: ResponsiveConstants.xlSpacing),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AuthColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.lock_reset, color: Colors.white, size: 40),
                          ),
                          SizedBox(height: ResponsiveConstants.mdSpacing),
                          Text(
                            AppLocalizations.of(context)!.resetYourPassword,
                            style: AppFonts.getTextStyle(fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            AppLocalizations.of(context)!.enterEmailForResetInstructions,
                            textAlign: TextAlign.center,
                            style: AppFonts.getTextStyle(fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.xlSpacing),
                    AuthTextField(
                      controller: _emailController,
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.enterYourEmail,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
                          return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveConstants.lgSpacing),
                    AuthButton(
                      onPressed: isLoading ? null : _submit,
                      text: isLoading ? AppLocalizations.of(context)!.sendingResetLink : AppLocalizations.of(context)!.sendResetLink,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
