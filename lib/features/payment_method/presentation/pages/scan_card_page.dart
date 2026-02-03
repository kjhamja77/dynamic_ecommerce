import 'package:flutter/material.dart';
// import 'package:card_scanner/card_scanner.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

// TODO(scanner): Re-enable when card_scanner is compatible with Firebase/GoogleSignIn pods
class ScanCardPage extends StatefulWidget {
  const ScanCardPage({super.key});

  @override
  State<ScanCardPage> createState() => _ScanCardPageState();
}

class _ScanCardPageState extends State<ScanCardPage> {
  // CardDetails? _lastResult;
  bool _scanning = false;
  String? _error;

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      // final result = await CardScanner.scanCard(
      //   scanOptions: const CardScanOptions(
      //     scanCardHolderName: true,
      //   ),
      // );
      if (!mounted) return;
      // Temporarily disabled
      if (true) {
        setState(() => _error = AppLocalizations.of(context)!.scanCancelled);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        title: Text(
          AppLocalizations.of(context)!.scanCard,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        children: [
          // Hero header
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.grey.shade900,
                  Colors.black.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.white, size: 26),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.positionYourCardWithinFrame,
                        style: AppFonts.getTextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveConstants.xlFontSize,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        AppLocalizations.of(context)!.scanCardPrivacyNote,
                        style: AppFonts.getTextStyle(color: Colors.white70,
                          fontSize: ResponsiveConstants.smFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveConstants.xlSpacing),

          // Scan guide frame with card aspect ratio
          AspectRatio(
            aspectRatio: 1.586, // standard credit card ratio
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle gradient overlay to hint camera area
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(0.04),
                          Colors.black.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Corner guides
                  Padding(
                    padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                    child: _CornerGuides(color: Colors.black87.withOpacity(0.85)),
                  ),
                  // Center icon & hint
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.document_scanner, size: 36, color: Colors.black87),
                        ),
                        SizedBox(height: ResponsiveConstants.smSpacing),
                        Text(
                          AppLocalizations.of(context)!.alignCardEdgesWithGuides,
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: ResponsiveConstants.xlSpacing),

          // Tips
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Colors.black87, size: 20),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Text(
                      AppLocalizations.of(context)!.quickTips,
                      style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                        fontSize: ResponsiveConstants.mdFontSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                _Tip(text: AppLocalizations.of(context)!.scanCardTipLighting),
                _Tip(text: AppLocalizations.of(context)!.scanCardTipSurface),
                _Tip(text: AppLocalizations.of(context)!.makeSureNumbersAreClearlyVisible),
                if (_error != null) ...[
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Text(
                    _error!,
                    style: AppFonts.getTextStyle(color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: ResponsiveConstants.xlSpacing),

          // Action button
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _scanning ? null : _startScan,
              icon: const Icon(Icons.document_scanner, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              label: Text(
                _scanning ? AppLocalizations.of(context)!.scanning : AppLocalizations.of(context)!.startScan,
                style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                  fontSize: ResponsiveConstants.mdFontSize,
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveConstants.lgSpacing),
          Center(
            child: Text(
              AppLocalizations.of(context)!.youCanEditDetailsBeforeSaving,
              style: AppFonts.getTextStyle(color: Colors.grey.shade600,
                fontSize: ResponsiveConstants.smFontSize,
              ),
            ),
          ),

          // if (_lastResult != null) ...[ ... ],
        ],
      ),
    );
  }
}

class _CornerGuides extends StatelessWidget {
  const _CornerGuides({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final double guideLen = 24;
    final double stroke = 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Top-left
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: guideLen,
                height: guideLen,
                child: CustomPaint(painter: _CornerPainter(color: color, stroke: stroke)),
              ),
            ),
            // Top-right
            Positioned(
              right: 0,
              top: 0,
              child: Transform.rotate(
                angle: 1.5708, // 90deg
                child: SizedBox(
                  width: guideLen,
                  height: guideLen,
                  child: CustomPaint(painter: _CornerPainter(color: color, stroke: stroke)),
                ),
              ),
            ),
            // Bottom-left
            Positioned(
              left: 0,
              bottom: 0,
              child: Transform.rotate(
                angle: -1.5708, // -90deg
                child: SizedBox(
                  width: guideLen,
                  height: guideLen,
                  child: CustomPaint(painter: _CornerPainter(color: color, stroke: stroke)),
                ),
              ),
            ),
            // Bottom-right
            Positioned(
              right: 0,
              bottom: 0,
              child: Transform.rotate(
                angle: 3.14159, // 180deg
                child: SizedBox(
                  width: guideLen,
                  height: guideLen,
                  child: CustomPaint(painter: _CornerPainter(color: color, stroke: stroke)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color, required this.stroke});

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ResponsiveConstants.smSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.black87, size: 16),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Text(
              text,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
