import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';

class AlQasehPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String orderReference;
  final Function(bool success, String? orderReference)? onPaymentComplete;

  const AlQasehPaymentPage({
    Key? key,
    required this.paymentUrl,
    required this.orderReference,
    this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<AlQasehPaymentPage> createState() => _AlQasehPaymentPageState();
}

class _AlQasehPaymentPageState extends State<AlQasehPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigatedAway = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isOnReturnUrl = false;
  bool _hasDetectedSuccess = false;

  String _getLocalizedString(String key, String fallback, [Map<String, String>? params]) {
    if (!mounted) return fallback;
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return fallback;
    
    switch (key) {
      case 'paymentUrlMissing':
        return localizations.paymentUrlMissing;
      case 'invalidPaymentUrl':
        return localizations.invalidPaymentUrl;
      case 'failedToLoadPaymentPage':
        return params != null 
            ? localizations.failedToLoadPaymentPage(params['error'] ?? '')
            : fallback;
      case 'loadingPaymentPage':
        return localizations.loadingPaymentPage;
      case 'paymentError':
        return localizations.paymentError;
      case 'failedToLoadPaymentPageGeneric':
        return localizations.failedToLoadPaymentPageGeneric;
      case 'cancelPayment':
        return localizations.cancelPayment;
      case 'cancelPaymentConfirmation':
        return localizations.cancelPaymentConfirmation;
      case 'yes':
        return localizations.yes;
      case 'no':
        return localizations.no;
      case 'payment':
        return localizations.payment;
      case 'close':
        return localizations.close;
      default:
        return fallback;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Validate payment URL
    if (widget.paymentUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = _getLocalizedString('paymentUrlMissing', 
            'Payment URL is missing. Please try again.');
        _isLoading = false;
      });
      return;
    }

    // Validate URL format
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null || !uri.hasScheme) {
      setState(() {
        _hasError = true;
        _errorMessage = _getLocalizedString('invalidPaymentUrl', 
            'Invalid payment URL. Please try again.');
        _isLoading = false;
      });
      debugPrint('❌ Invalid payment URL: ${widget.paymentUrl}');
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Check payment status after page loads
            _checkPaymentStatus(url);
            // Only check page content if it's the return URL AND we haven't already detected success/failure
            // This prevents false positives from intermediate pages
            if (url.contains('/payment/alqaseh/return') && !_hasNavigatedAway) {
              // Check if URL already has status parameter - if so, don't check page content
              final uri = Uri.tryParse(url);
              final hasStatusParam = uri != null && 
                  (uri.queryParameters.containsKey('status') || 
                   uri.queryParameters.containsKey('payment_status'));
              
              if (!hasStatusParam) {
                // Only check page content if status parameter is missing
                // Small delay to ensure page is fully rendered
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (!_hasNavigatedAway && _isOnReturnUrl) {
                    _checkPageContent();
                  }
                });
              } else {
                debugPrint('✅ Status parameter found in URL - skipping page content check');
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted && !_hasNavigatedAway) {
              setState(() {
                _hasError = true;
                _errorMessage = _getLocalizedString('failedToLoadPaymentPage', 
                    'Failed to load payment page: ${error.description}', 
                    {'error': error.description});
                _isLoading = false;
              });
            }
          },
          onUrlChange: (UrlChange change) {
            // Also check on URL changes (for redirects)
            if (change.url != null) {
              _checkPaymentStatus(change.url!);
            }
          },
        ),
      )
      ..loadRequest(uri);
  }

  void _checkPaymentStatus(String url) {
    // Check if URL contains success indicators
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('⚠️ Failed to parse URL: $url');
      return;
    }

    debugPrint('🔍 Checking payment status for URL: $url');
    debugPrint('   Parsed URI: ${uri.toString()}');
    debugPrint('   Query parameters: ${uri.queryParameters}');

    // Check for Al Qaseh return URL - this is the key indicator
    if (url.contains('/payment/alqaseh/return')) {
      debugPrint('✅ Found Al Qaseh return URL');
      _isOnReturnUrl = true;
      
      // Parse query parameters - check both 'status' and 'payment_status'
      final status = uri.queryParameters['status'] ?? 
                     uri.queryParameters['payment_status'] ?? '';
      
      debugPrint('   Extracted status parameter: "$status"');
      debugPrint('   Status parameter type: ${status.runtimeType}');
      
      // Check status value - prioritize exact matches, then contains
      final statusLower = status.toLowerCase().trim();
      debugPrint('   Normalized status (lowercase, trimmed): "$statusLower"');
      
      // Success statuses - check exact match first for common cases
      final isSuccess = statusLower == 'succeeded' ||
                        statusLower == 'success' ||
                        statusLower == 'paid' ||
                        statusLower == 'completed' ||
                        statusLower.contains('succeeded') || 
                        statusLower.contains('success');
      
      // Failure statuses
      final isFailure = statusLower == 'failed' ||
                        statusLower == 'declined' ||
                        statusLower == 'cancelled' ||
                        statusLower == 'error' ||
                        statusLower.contains('failed') || 
                        statusLower.contains('declined') ||
                        statusLower.contains('cancelled') ||
                        statusLower.contains('error');
      
      if (isSuccess) {
        debugPrint('✅✅✅ Payment SUCCEEDED - Status: "$statusLower" ✅✅✅');
        _hasDetectedSuccess = true;
        _handlePaymentSuccess();
        return;
      } else if (isFailure) {
        // Only treat as failure if we haven't detected success and haven't navigated away
        // Add a small delay to allow success status to be detected first (in case of race condition)
        if (!_hasDetectedSuccess && !_hasNavigatedAway) {
          // Delay failure handling to give success status a chance to be detected first
          Future.delayed(const Duration(milliseconds: 500), () {
            // Double-check that success wasn't detected during the delay
            if (!_hasDetectedSuccess && !_hasNavigatedAway && mounted) {
              debugPrint('❌❌❌ Payment FAILED - Status: "$statusLower" ❌❌❌');
              _handlePaymentFailure();
            } else {
              debugPrint('⚠️ Failure status detected but success was found during delay - ignoring failure');
            }
          });
        } else {
          debugPrint('⚠️ Found failure status but success was already detected or already navigated away');
        }
        return;
      } else if (status.isEmpty) {
        // If return URL but no status, check page content
        // The backend shows "Payment processed. You can close this window." on success
        debugPrint('⚠️ Return URL found but status parameter is empty - checking page content');
        // Wait a bit for page to fully load, then check content
        // Only check once after a delay to avoid multiple checks causing false positives
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!_hasNavigatedAway && _isOnReturnUrl) {
            _checkPageContent();
          }
        });
        // Fallback: if still no result after 3 seconds, assume success if we're on return URL
        // (backend shows success message by default)
        Future.delayed(const Duration(milliseconds: 3000), () {
          if (!_hasNavigatedAway && _isOnReturnUrl) {
            debugPrint('⚠️ No clear status after 3 seconds on return URL - assuming success');
            _handlePaymentSuccess();
          }
        });
        return;
      } else {
        debugPrint('⚠️ Unknown status value: "$statusLower" - treating as pending');
        // Don't handle as success or failure for unknown statuses
        return;
      }
    } else {
      _isOnReturnUrl = false;
    }
    
    // Also check for direct status indicators in URL string (fallback check)
    final urlLower = url.toLowerCase();
    if (urlLower.contains('status=succeeded') || 
        urlLower.contains('status=success') ||
        urlLower.contains('payment_status=succeeded') ||
        urlLower.contains('payment_status=success') ||
        urlLower.contains('status=paid') ||
        urlLower.contains('status=completed')) {
      debugPrint('✅ Payment succeeded based on URL string pattern');
      _handlePaymentSuccess();
      } else if (urlLower.contains('status=failed') || 
               urlLower.contains('status=declined') ||
               urlLower.contains('payment_status=failed') ||
               urlLower.contains('payment_status=declined') ||
               urlLower.contains('status=cancelled')) {
      // Delay failure handling to allow success status to be detected first
      if (!_hasDetectedSuccess && !_hasNavigatedAway) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_hasDetectedSuccess && !_hasNavigatedAway && mounted) {
            debugPrint('❌ Payment failed based on URL string pattern');
            _handlePaymentFailure();
          }
        });
      }
    }
  }

  void _checkPageContent() {
    // Only check page content if we're on the return URL and haven't navigated away
    if (!_isOnReturnUrl || _hasNavigatedAway) {
      debugPrint('⚠️ Skipping page content check - not on return URL or already navigated');
      return;
    }
    
    // Inject JavaScript to check page content for payment status
    _controller.runJavaScriptReturningResult('''
      (function() {
        var bodyText = document.body.innerText || document.body.textContent || '';
        var titleText = document.title || '';
        
        // Only check visible body text, not HTML source (to avoid matching JS code)
        var visibleText = (bodyText + ' ' + titleText).toLowerCase();
        
        // Check for success indicators FIRST (priority)
        // These are the actual messages shown to users
        if (visibleText.includes('payment processed') ||
            visibleText.includes('payment completed') ||
            visibleText.includes('you can close') ||
            visibleText.includes('you can close this window') ||
            visibleText.includes('payment successful') ||
            visibleText.includes('payment succeeded')) {
          return 'success';
        }
        
        // Check for failure indicators - be more specific to avoid false positives
        // Only check for explicit payment failure messages, not generic "error"
        if (visibleText.includes('payment failed') ||
            visibleText.includes('payment declined') ||
            visibleText.includes('payment cancelled') ||
            visibleText.includes('payment unsuccessful') ||
            visibleText.includes('transaction failed') ||
            visibleText.includes('transaction declined')) {
          return 'failed';
        }
        
        return 'unknown';
      })();
    ''').then((result) {
      if (_hasNavigatedAway) {
        debugPrint('⚠️ Page content check completed but already navigated away');
        return;
      }
      
      debugPrint('📄 Page content check result: $result');
      final resultStr = result.toString().toLowerCase();
      
      // Check success first - prioritize success over failure
      if (resultStr.contains('success')) {
        debugPrint('✅ Payment success detected from page content');
        _hasDetectedSuccess = true;
        _handlePaymentSuccess();
      } else if (resultStr.contains('failed')) {
        // Only treat as failure if we're still on return URL, haven't seen success, and haven't navigated away
        // Add delay to allow success to be detected first
        if (_isOnReturnUrl && !_hasDetectedSuccess && !_hasNavigatedAway) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_hasDetectedSuccess && !_hasNavigatedAway && mounted) {
              debugPrint('❌ Payment failure detected from page content');
              _handlePaymentFailure();
            } else {
              debugPrint('⚠️ Failure detected from page content but success was found during delay');
            }
          });
        } else {
          debugPrint('⚠️ Found failure indicator but success was already detected or already processed');
        }
      } else {
        debugPrint('⚠️ Payment status unknown from page content');
      }
    }).catchError((error) {
      debugPrint('❌ Error checking page content: $error');
      // Don't treat JavaScript errors as payment failures
    });
  }

  void _handlePaymentSuccess() {
    if (_hasNavigatedAway) {
      debugPrint('⚠️ Attempted to handle payment success but already navigated away');
      return;
    }
    
    // Mark success and prevent any failure handling
    _hasDetectedSuccess = true;
    _hasNavigatedAway = true;
    
    debugPrint('✅✅✅ Handling payment success - calling onPaymentComplete ✅✅✅');
    
    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!(true, widget.orderReference);
    }
    
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _handlePaymentFailure() {
    // Don't handle failure if success was already detected
    if (_hasDetectedSuccess) {
      debugPrint('⚠️ Attempted to handle payment failure but success was already detected - ignoring');
      return;
    }
    
    if (_hasNavigatedAway) {
      debugPrint('⚠️ Attempted to handle payment failure but already navigated away');
      return;
    }
    
    _hasNavigatedAway = true;
    
    debugPrint('❌❌❌ Handling payment failure - calling onPaymentComplete ❌❌❌');
    
    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!(false, null);
    }
    
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedString('payment', 'Payment'),
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_hasNavigatedAway) {
              _showCancelDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _hasError
          ? _buildErrorState()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: ResponsiveConstants.mdSpacing),
                          Text(
                            _getLocalizedString('loadingPaymentPage', 'Loading payment page...'),
                            style: AppFonts.getTextStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade600,
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              Text(
                _getLocalizedString('paymentError', 'Payment Error'),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                _errorMessage ?? _getLocalizedString('failedToLoadPaymentPageGeneric', 
                    'Failed to load payment page. Please try again.'),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.lgSpacing),
              ElevatedButton(
                onPressed: () {
                  // Close the page and notify failure
                  if (widget.onPaymentComplete != null) {
                    widget.onPaymentComplete!(false, null);
                  }
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.lgPadding,
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                ),
                child: Text(
                  _getLocalizedString('close', 'Close'),
                  style: AppFonts.getTextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('cancelPayment', 'Cancel Payment'),
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          _getLocalizedString('cancelPaymentConfirmation', 
              'Are you sure you want to cancel this payment?'),
          style: AppFonts.getTextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _getLocalizedString('no', 'No'),
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onPaymentComplete != null) {
                widget.onPaymentComplete!(false, null);
              }
              Navigator.of(context).pop(false);
            },
            child: Text(
              _getLocalizedString('yes', 'Yes'),
              style: AppFonts.getTextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

