import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../constants/auth_color_constants.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:provider/provider.dart';

class NumberVerificationArgs {
  final int? userId;
  final String? phoneMasked;

  const NumberVerificationArgs({this.userId, this.phoneMasked});
}

class NumberVerificationPage extends StatefulWidget {
  final NumberVerificationArgs args;

  const NumberVerificationPage({super.key, required this.args});

  @override
  State<NumberVerificationPage> createState() => _NumberVerificationPageState();
}

class _NumberVerificationPageState extends State<NumberVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'يرجى إدخال رمز تحقق صالح من 4 أرقام'
                : 'Please enter a valid 4-digit verification code',
          ),
        ),
      );
      return;
    }
    if (widget.args.userId == null) return;
    context.read<AuthBloc>().add(VerifyMobileCodeRequested(userId: widget.args.userId!, verificationCode: code));
  }

  void _onResend() {
    if (widget.args.userId == null) return;
    context.read<AuthBloc>().add(ResendMobileVerificationRequested(userId: widget.args.userId!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final phoneHint = widget.args.phoneMasked != null
        ? (isArabic
            ? 'تم إرسال رمز التحقق إلى رقمك ${widget.args.phoneMasked}'
            : 'We sent a verification code to ${widget.args.phoneMasked}')
        : (isArabic
            ? 'أدخل رمز التحقق المكون من 4 أرقام'
            : 'Enter the 4-digit verification code');

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
          onPressed: () async {
            await HapticService.buttonClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          isArabic ? 'التحقق من رقم الجوال مطلوب' : 'Mobile Verification Required',
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _submitting = true);
          } else {
            setState(() => _submitting = false);
          }

          if (state is MobileVerificationSuccess) {
            // Update currency provider with user's currency data
            final currencyProvider = context.read<CurrencyProvider>();
            if (state.user.currency != null && state.user.currencyId != null) {
              currencyProvider.updateCurrency(state.user.currency!, state.user.currencyId!);
            }
            
            // Navigate to main app (user is now logged in automatically)
            NavigationService.pushNamedAndRemoveUntil('/main', arguments: null);
          }

          if (state is MobileVerificationResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'تم إعادة إرسال رمز التحقق إلى رقمك.'
                      : 'Verification code resent to your phone.',
                ),
              ),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${AppLocalizations.of(context)!.error}: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  isArabic ? 'أدخل رمز التحقق' : 'Enter verification code',
                  style: AppFonts.getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                Text(
                  phoneHint,
                  style: AppFonts.getTextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 4,
                      controller: _codeController,
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: AppFonts.getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: AppFonts.getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AuthColorConstants.primaryColor, width: 2),
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: AppFonts.getTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onCompleted: (_) => _onVerify(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitting || widget.args.userId == null ? null : _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuthColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          AppLocalizations.of(context)!.confirm,
                          style: AppFonts.getTextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting || widget.args.userId == null ? null : _onResend,
                  child: Text(
                    isArabic ? 'إعادة إرسال الرمز' : 'Resend code',
                    style: AppFonts.getTextStyle(
                      color: AuthColorConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


