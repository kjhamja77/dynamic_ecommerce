import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.onDelete,
    required this.onSetDefault,
  });

  // Professional color schemes for credit cards (same as CreditCardPreview)
  static const List<List<Color>> _professionalColors = [
    [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Deep Blue to Blue
    [Color(0xFF7C3AED), Color(0xFF8B5CF6)], // Purple to Light Purple
    [Color(0xFF059669), Color(0xFF10B981)], // Dark Green to Green
    [Color(0xFFDC2626), Color(0xFFEF4444)], // Dark Red to Red
    [Color(0xFF92400E), Color(0xFFF59E0B)], // Brown to Amber
    [Color(0xFF1F2937), Color(0xFF4B5563)], // Dark Gray to Gray
    [Color(0xFF7C2D12), Color(0xFFEA580C)], // Dark Orange to Orange
    [Color(0xFF581C87), Color(0xFF9333EA)], // Dark Purple to Purple
    [Color(0xFF0F766E), Color(0xFF14B8A6)], // Dark Teal to Teal
    [Color(0xFF991B1B), Color(0xFFDC2626)], // Dark Red to Red
  ];

  Color _getRandomColor() {
    // Use payment method ID to ensure consistent colors for the same card
    final hash = paymentMethod.id.hashCode;
    final index = hash.abs() % _professionalColors.length;
    return _professionalColors[index][0];
  }

  Color _getRandomSecondaryColor() {
    // Use payment method ID to ensure consistent colors for the same card
    final hash = paymentMethod.id.hashCode;
    final index = hash.abs() % _professionalColors.length;
    return _professionalColors[index][1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ResponsiveConstants.smSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Payment Method Display (responsive via slightly taller aspect ratio)
          AspectRatio(
            aspectRatio: 3 / 2, // Taller to comfortably fit layouts like Cash on Delivery
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveConstants.xlRadius),
                topRight: Radius.circular(ResponsiveConstants.xlRadius),
              ),
                image: paymentMethod.type == PaymentMethodType.zainCash
                  ? const DecorationImage(
                      image: AssetImage('assets/images/zain-cash.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    )
                  : paymentMethod.type == PaymentMethodType.qiCard
                      ? const DecorationImage(
                          image: AssetImage('assets/images/qi-card.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        )
                      : paymentMethod.type == PaymentMethodType.alQaseh
                          ? const DecorationImage(
                              image: AssetImage('assets/images/alqaseh.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            )
                          : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveConstants.xlRadius),
                  topRight: Radius.circular(ResponsiveConstants.xlRadius),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildPaymentMethodDisplay(context),
                    Positioned(
                      top: ResponsiveConstants.mdPadding,
                      right: ResponsiveConstants.mdPadding,
                      child: GestureDetector(
                        onTap: onSetDefault,
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            paymentMethod.isDefault ? Icons.star : Icons.star_border,
                            color: Colors.white,
                            size: ResponsiveConstants.mdIconSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Enhanced Payment Method Info
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ResponsiveConstants.xlRadius),
                bottomRight: Radius.circular(ResponsiveConstants.xlRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  paymentMethod.name,
                                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (paymentMethod.isDefault)
                                Container(
                                  margin: EdgeInsets.only(left: ResponsiveConstants.xsSpacing),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveConstants.mdPadding,
                                    vertical: ResponsiveConstants.xsPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.defaultAddress,
                                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            _getPaymentMethodTypeText(paymentMethod.type),
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveConstants.lgSpacing),
                
                // Enhanced Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            size: ResponsiveConstants.smIconSize,
                            color: Colors.white,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.delete,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveConstants.mdPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDisplay(BuildContext context) {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        return _buildCreditCardDisplay(context);
      case PaymentMethodType.debitCard:
        return _buildCreditCardDisplay(context);
      case PaymentMethodType.paypal:
        return _buildPayPalDisplay(context);
      case PaymentMethodType.applePay:
        return _buildApplePayDisplay(context);
      case PaymentMethodType.googlePay:
        return _buildGooglePayDisplay(context);
      case PaymentMethodType.bankTransfer:
        return _buildBankTransferDisplay(context);
      case PaymentMethodType.cashOnDelivery:
        return _buildCashOnDeliveryDisplay(context);
      case PaymentMethodType.cash:
        return _buildCashDisplay(context);
      case PaymentMethodType.zainCash:
        return _buildZainCashDisplay(context);
      case PaymentMethodType.qiCard:
        return _buildQiCardDisplay(context);
      case PaymentMethodType.alQaseh:
        return _buildAlQasehDisplay(context);
    }
  }

  Widget _buildCashDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade500,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Stack(
        children: [
          // subtle shapes
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: Colors.white,
                    size: ResponsiveConstants.xlIconSize,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.cash,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // bottom caption bar (prevents overflow)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.lgPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
              ),
              child: Text(
                AppLocalizations.of(context)!.payWithCashOnDelivery,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZainCashDisplay(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildQiCardDisplay(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildAlQasehDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
      ),
      child: Stack(
        children: [
          // subtle shapes
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/alqaseh.png',
                    width: ResponsiveConstants.xlIconSize,
                    height: ResponsiveConstants.xlIconSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: ResponsiveConstants.xlIconSize,
                      );
                    },
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  'Al Qaseh',
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // bottom caption bar (prevents overflow)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.lgPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
              ),
              child: Text(
                AppLocalizations.of(context)!.alQaseh,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardDisplay(BuildContext context) {
    // Fallback to generic display if data is invalid
    if (paymentMethod.cardNumber == null ||
        paymentMethod.cardNumber!.isEmpty ||
        paymentMethod.cardNumber == '**** **** **** ****') {
      return _buildGenericCardDisplay(context);
    }

    final sanitizedCardNumber =
        paymentMethod.cardNumber!.replaceAll(RegExp(r'\D'), '');
    if (sanitizedCardNumber.length < 13) {
      return _buildGenericCardDisplay(context);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Enhanced gradient background with darker professional colors
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getRandomColor().withValues(alpha: 0.8),
                _getRandomColor().withValues(alpha: 0.6),
                _getRandomSecondaryColor().withValues(alpha: 0.7),
                _getRandomSecondaryColor().withValues(alpha: 0.5),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        
        // Subtle background patterns
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        
        Padding(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CreditCardUi(
                cardHolderFullName: paymentMethod.cardHolderName ?? AppLocalizations.of(context)!.cardHolder,
                cardNumber: sanitizedCardNumber,
                validThru: paymentMethod.expiryDate ?? '12/25',
                cvvNumber: paymentMethod.cvvCode ?? '123',
                topLeftColor: _getRandomColor(),
                bottomRightColor: _getRandomSecondaryColor(),
                width: constraints.maxWidth * 0.9,
                shouldMaskCardNumber: false,
                enableFlipping: false,
              );
            },
          ),
        ),

        // Enhanced bottom overlay bar - moved down to prevent overlap
       
      ],
    );
  }

  Widget _buildGenericCardDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E2E2E),
            Color(0xFF3A3A3A),
            Color(0xFF2E2E2E),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          
          Center(
            child: Container(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.credit_card,
                color: Colors.white,
                size: ResponsiveConstants.xlIconSize,
              ),
            ),
          ),
          
          // Enhanced bottom overlay
          
        ],
      ),
    );
  }

  Widget _buildPayPalDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.blue.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.paypal,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Text(
                  AppLocalizations.of(context)!.paypal,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xxlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.onlinePaymentService,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black87,
            Colors.black,
            Colors.black87,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: ResponsiveConstants.xxlIconSize,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Text(
                  AppLocalizations.of(context)!.applePay,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xxlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.contactlessPayment,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGooglePayDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.blue.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.android,
                    color: Colors.white,
                    size: ResponsiveConstants.xxlIconSize,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Text(
                  AppLocalizations.of(context)!.googlePay,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xxlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.mobilePaymentService,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade400,
            Colors.indigo.shade600,
            Colors.indigo.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: ResponsiveConstants.xxlIconSize,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Text(
                  AppLocalizations.of(context)!.bankTransfer,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xxlFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.directBankTransfer,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnDeliveryDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade400,
            Colors.teal.shade600,
            Colors.teal.shade700,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          
          // Main content - centered in container
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.mdPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(ResponsiveConstants.xlRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: ResponsiveConstants.lgIconSize,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.of(context)!.cashOnDelivery.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.lgFontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Text(
                    AppLocalizations.of(context)!.payWhenYouReceive,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodTypeText(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethodType.cash:
        return 'Cash Payment';
      case PaymentMethodType.zainCash:
        return 'Zain Cash';
      case PaymentMethodType.qiCard:
        return 'Qi Card';
      case PaymentMethodType.alQaseh:
        return 'Al Qaseh';
    }
  }
}
