import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../widgets/input_formatters.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController cardHolderNameController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;

  final void Function(String) onCardNumberChanged;
  final void Function(String) onExpiryChanged;
  final void Function(String) onCvvChanged;
  final void Function(String) onCardHolderNameChanged;

  const PaymentFormFields({
    super.key,
    required this.nameController,
    required this.cardHolderNameController,
    required this.cardNumberController,
    required this.expiryDateController,
    required this.cvvController,
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCvvChanged,
    required this.onCardHolderNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _elevatedField(
          context,
          TextFormField(
            controller: nameController,
            decoration: _decoration(
              label: AppLocalizations.of(context)!.paymentMethodName,
              hint: 'e.g., My Credit Card',
              icon: Icons.credit_card,
            ),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: Colors.black87,
            ),
            validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.pleaseEnterName : null,
          ),
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),
        _elevatedField(
          context,
          TextFormField(
            controller: cardHolderNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration(
              label: AppLocalizations.of(context)!.cardholderName,
              hint: 'e.g., John Doe',
              icon: Icons.person_outline,
            ),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: Colors.black87,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.pleaseEnterCardholderName : null,
            onChanged: onCardHolderNameChanged,
          ),
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),
        _elevatedField(
          context,
          TextFormField(
            controller: cardNumberController,
            decoration: _decoration(
              label: AppLocalizations.of(context)!.cardNumber,
              hint: '0000 0000 0000 0000',
              icon: Icons.credit_card,
            ),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: Colors.black87,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return AppLocalizations.of(context)!.pleaseEnterCardNumber;
              final digitsOnly = value.replaceAll(' ', '');
              if (digitsOnly.length < 13) return AppLocalizations.of(context)!.pleaseEnterValidCardNumber;
              return null;
            },
            onChanged: onCardNumberChanged,
          ),
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),
        Row(
          children: [
            Expanded(
              child: _elevatedField(
                context,
                TextFormField(
                  controller: expiryDateController,
                  decoration: _decoration(
                    label: AppLocalizations.of(context)!.expiryDate,
                    hint: '12/25',
                    icon: Icons.calendar_today,
                  ),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.black87,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.pleaseEnterExpiryDate;
                    if (value.length < 4) return 'Please enter MM/YY';
                    return null;
                  },
                  onChanged: onExpiryChanged,
                ),
              ),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),
            Expanded(
              child: _elevatedField(
                context,
                TextFormField(
                  controller: cvvController,
                  decoration: _decoration(
                    label: AppLocalizations.of(context)!.cvv,
                    hint: '123',
                    icon: Icons.security,
                  ),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.black87,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.pleaseEnterCvv;
                    if (value.length < 3) return AppLocalizations.of(context)!.pleaseEnterValidCvv;
                    return null;
                  },
                  onChanged: onCvvChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _decoration({required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        borderSide: const BorderSide(color: Colors.black87, width: 2),
      ),
      prefixIcon: Icon(icon, color: Colors.black87),
      labelStyle: AppFonts.getTextStyle(color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _elevatedField(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}


