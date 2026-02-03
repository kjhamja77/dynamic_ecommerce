import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../services/haptic_service.dart';
import '../../l10n/app_localizations.dart';
import '../constants/responsive_constants.dart';
import '../theme/app_fonts.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget? offlineChild;
  final bool showOfflineBanner;
  final bool showRetryButton;
  final VoidCallback? onRetry;
  final String? customOfflineMessage;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineChild,
    this.showOfflineBanner = true,
    this.showRetryButton = true,
    this.onRetry,
    this.customOfflineMessage,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        final isConnected = connectivityService.isConnected;
        
        // If connected, show the main content
        if (isConnected) {
          return widget.child;
        }

        // If custom offline child is provided, use it
        if (widget.offlineChild != null) {
          return widget.offlineChild!;
        }

        // Show offline state
        return _buildOfflineState(context, connectivityService);
      },
    );
  }

  Widget _buildOfflineState(BuildContext context, ConnectivityService connectivityService) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Offline Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.xlSpacing),
              
              // Offline Message
              Text(
                AppLocalizations.of(context)!.noInternetConnection,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveConstants.mdSpacing),
              
              // Subtitle
              Text(
                widget.customOfflineMessage ?? 
                AppLocalizations.of(context)!.checkInternetConnection,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveConstants.xlSpacing),
              
              // Retry Button
              if (widget.showRetryButton) ...[
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
                        fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveConstants.mdPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      ),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: ResponsiveConstants.mdSpacing),
              
              // Connectivity Status
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.mdPadding,
                  vertical: ResponsiveConstants.smPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      connectivityService.getStatusIcon(),
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Text(
                      connectivityService.getStatusMessage(context),
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      // Call custom retry callback if provided
      if (widget.onRetry != null) {
        await Future.delayed(Duration(milliseconds: 500)); // Small delay for UX
        widget.onRetry!();
      } else {
        // Default retry behavior - just wait a bit and let connectivity service update
        await Future.delayed(Duration(seconds: 2));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }
}

/// A simpler connectivity banner that shows at the top of the screen
class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  final bool showBanner;
  final VoidCallback? onRetry;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showBanner = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        final isConnected = connectivityService.isConnected;
        
        if (!showBanner || isConnected) {
          return child;
        }

        return Column(
          children: [
            // Offline Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              color: Colors.red.shade600,
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: ResponsiveConstants.smIconSize,
                  ),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.noInternetConnection,
                      style: AppFonts.getTextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    GestureDetector(
                      onTap: () async {
                        await HapticService.buttonClick();
                        onRetry!();
                      },
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: ResponsiveConstants.smIconSize,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Main content
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
