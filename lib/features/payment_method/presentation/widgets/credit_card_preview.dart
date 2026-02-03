import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';

class CreditCardPreview extends StatelessWidget {
  final String cardNumber; // formatted or digits
  final String expiryDate; // MM/YY
  final String cardHolderName;
  final String cvv;
  final int? colorIndex; // stable color selection across rebuilds

  const CreditCardPreview({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvv,
    this.colorIndex,
  });

  // Professional color schemes for credit cards
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

  int _resolvedIndex() {
    if (colorIndex != null) return colorIndex!.abs() % _professionalColors.length;
    // Fallback: derive from first 4 digits if available, else 0
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.isNotEmpty) {
      final sample = digits.substring(0, digits.length.clamp(0, 4));
      final hash = sample.codeUnits.fold<int>(0, (p, c) => p * 31 + c);
      return hash.abs() % _professionalColors.length;
    }
    return 0;
  }

  Color _primaryColor() {
    final idx = _resolvedIndex();
    return _professionalColors[idx][0];
  }

  Color _secondaryColor() {
    final idx = _resolvedIndex();
    return _professionalColors[idx][1];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width) *
            0.98;

        return Container(
          height: cardWidth * 0.6,
          margin: EdgeInsets.only(bottom: ResponsiveConstants.lgSpacing),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
            child: Center(
              child: CreditCardUi(
                width: cardWidth.clamp(250, 350),
                cardHolderFullName:
                    cardHolderName.isEmpty ? AppLocalizations.of(context)!.cardHolder : cardHolderName,
                cardNumber: (cardNumber.isEmpty
                        ? '0000000000000000'
                        : cardNumber.replaceAll(' ', ''))
                    .padRight(16, '0')
                    .substring(0, 16),
                validThru: expiryDate.isEmpty ? '12/25' : expiryDate,
                cvvNumber: cvv.isEmpty ? '123' : cvv,
                topLeftColor: _primaryColor(),
                bottomRightColor: _secondaryColor(),
                shouldMaskCardNumber: false,
                enableFlipping: true,
              ),
            ),
          ),
        );
      },
    );
  }
}


