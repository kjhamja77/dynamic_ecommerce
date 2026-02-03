import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class OnboardingEmptyState extends StatelessWidget {
  const OnboardingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),

              SizedBox(height: ResponsiveConstants.xlSpacing),

              // Title
              Text(
                'No Onboarding Content',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.headlineFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: ResponsiveConstants.mdSpacing),

              // Description
              Text(
                'Add onboarding content from the dashboard to provide users with a great first experience.',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: ResponsiveConstants.xlSpacing),

              // Skip to login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          _skipToLogin(context);
        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveConstants.mdPadding,
                      horizontal: ResponsiveConstants.lgPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Skip to Login',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: ResponsiveConstants.mdSpacing),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          _retryOnboarding(context);
        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveConstants.mdPadding,
                      horizontal: ResponsiveConstants.lgPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipToLogin(BuildContext context) {
    // Complete onboarding and navigate to login
    context.read<OnboardingBloc>().add(SkipOnboarding());
  }

  void _retryOnboarding(BuildContext context) {
    // Retry loading onboarding pages
    context.read<OnboardingBloc>().add(LoadOnboardingPages());
  }
}
