import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class OfflinePage extends StatefulWidget {
  final String? fromPage; // Track which page user came from
  final Map<String, dynamic>? pageData; // Data to restore when back online

  const OfflinePage({
    super.key,
    this.fromPage,
    this.pageData,
  });

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulsing animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Consumer<ConnectivityService>(
          builder: (context, connectivityService, child) {
            // Auto-navigate back when connection is restored
            if (connectivityService.isConnected) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateBackToOriginalPage(context);
              });
            }

            return Padding(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Offline Icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 80,
                            color: Colors.red.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: ResponsiveConstants.xlSpacing),
                  
                  // Offline Message
                  Text(
                    AppLocalizations.of(context)!.noInternetConnection,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.xlFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  
                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.checkInternetConnection,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveConstants.xlSpacing),
                  
                  // Retry Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRetrying ? null : _handleRetry,
                      icon: _isRetrying 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.refresh_rounded),
                      label: Text(
                        _isRetrying 
                          ? AppLocalizations.of(context)!.retrying
                          : AppLocalizations.of(context)!.retry,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.lgFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveConstants.lgPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  
                  // Connectivity Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.lgPadding,
                      vertical: ResponsiveConstants.mdPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: ResponsiveConstants.mdIconSize,
                        ),
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Expanded(
                          child: Text(
                            connectivityService.getStatusMessage(context),
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.smFontSize,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  
                  // Tips Section
                  _buildTipsSection(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade600,
                size: ResponsiveConstants.mdIconSize,
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(context)!.quickTips,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _buildTipItem('• ${AppLocalizations.of(context)!.checkWiFiConnection}'),
          _buildTipItem('• ${AppLocalizations.of(context)!.verifyMobileDataEnabled}'),
          _buildTipItem('• ${AppLocalizations.of(context)!.tryDifferentLocation}'),
          _buildTipItem('• ${AppLocalizations.of(context)!.restartInternetConnection}'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Text(
        tip,
        style: AppFonts.getTextStyle(
          fontSize: ResponsiveConstants.smFontSize,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() {
      _isRetrying = true;
    });

    await HapticService.buttonClick();

    try {
      // Check connectivity
      final connectivityService = context.read<ConnectivityService>();
      
      // Wait a bit to show the loading state
      await Future.delayed(Duration(seconds: 2));
      
      if (connectivityService.isConnected) {
        // Connection restored, navigate back
        _navigateBackToOriginalPage(context);
      } else {
        // Still no connection, show feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.stillNoInternetConnection),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void _navigateBackToOriginalPage(BuildContext context) {
    if (widget.fromPage != null) {
      // Navigate back to the original page
      Navigator.of(context).pushReplacementNamed(widget.fromPage!);
    } else {
      // Default to home page
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}
