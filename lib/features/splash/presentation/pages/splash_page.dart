import 'package:flutter/material.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../widgets/splash_content.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start app initialization when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashBloc>().add(InitializeApp());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashInitialized) {
            debugPrint('🚀 SplashPage: SplashInitialized');
            debugPrint('   📋 shouldShowOnboarding: ${state.shouldShowOnboarding}');
            debugPrint('   🌐 shouldShowLanguageSelection: ${state.shouldShowLanguageSelection}');
            
            if (state.shouldShowLanguageSelection) {
              debugPrint('   ➡️ Navigating to /language-selection');
              // Navigate to language selection
              Navigator.of(context).pushReplacementNamed('/language-selection');
            } else {
              // Language already selected - check authentication status
              debugPrint('   ➡️ Navigating to /main (AuthWrapper)');
              // Navigate to main app (AuthWrapper will decide between login or home)
              Navigator.of(context).pushReplacementNamed('/main');
            }
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            if (state is SplashError) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
          await HapticService.buttonClick();
          context.read<SplashBloc>().add(InitializeApp());
        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show splash content for all other states
            return const SplashContent();
          },
        ),
      ),
    );
  }
}
