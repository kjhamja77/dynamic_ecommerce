import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:card_scanner/card_scanner.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/payment_method_bloc.dart';
import '../bloc/payment_method_event.dart';
import '../../domain/entities/payment_method.dart';
import '../widgets/credit_card_preview.dart';
import '../widgets/payment_method_type_grid.dart';
import '../widgets/payment_form_fields.dart';
import 'scan_card_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';

  PaymentMethodType _selectedType = PaymentMethodType.alQaseh;
  late final int _previewColorIndex;

  @override
  void initState() {
    super.initState();
    _previewColorIndex = Random().nextInt(10);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();
    _cvvCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: ResponsiveConstants.mdIconSize,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.addPaymentMethod,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.scanCard,
            icon: Icon(Icons.document_scanner_outlined, color: Colors.black87, size: ResponsiveConstants.mdIconSize),
            onPressed: () async {
              await HapticService.buttonClick();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScanCardPage(),
                ),
              );
              if (result == null) return;
              try {
                final number = result.cardNumber ?? '';
                final expiry = result.expiryDate ?? '';
                final holder = result.cardHolderName ?? '';
                setState(() {
                  _cardNumberController.text = number.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} ").trim();
                  _expiryDateController.text = expiry;
                  _cardHolderNameController.text = holder;
                  _cardNumber = _cardNumberController.text;
                  _expiryDate = _expiryDateController.text;
                  _cardHolderName = _cardHolderNameController.text;
                });
                context.read<PaymentMethodBloc>().add(UpdateCardPreview(
                  cardNumber: _cardNumber,
                  expiryDate: _expiryDate,
                  cardHolderName: _cardHolderName,
                  cvv: _cvvCode,
                  type: _selectedType,
                ));
              } catch (_) {
                // Ignore malformed scan result
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          children: [
            CreditCardPreview(
              cardNumber: _cardNumber,
              expiryDate: _expiryDate,
              cardHolderName: _cardHolderName,
              cvv: _cvvCode,
              colorIndex: _previewColorIndex,
            ),

            // Enhanced Payment Method Type Selection
            PaymentMethodTypeGrid(
              selected: _selectedType,
              onChanged: (t) async {
                await HapticService.selectionClick();
                setState(() => _selectedType = t);
              },
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),

            // Coming Soon Message
            if (_selectedType == PaymentMethodType.zainCash || _selectedType == PaymentMethodType.qiCard)
              Container(
                margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: ResponsiveConstants.mdIconSize,
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.comingSoon,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Form (extracted)
            Form(
              key: _formKey,
              child: Opacity(
                opacity: (_selectedType == PaymentMethodType.zainCash || _selectedType == PaymentMethodType.qiCard) ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: _selectedType == PaymentMethodType.zainCash || _selectedType == PaymentMethodType.qiCard,
                  child: PaymentFormFields(
                nameController: _nameController,
                cardHolderNameController: _cardHolderNameController,
                cardNumberController: _cardNumberController,
                expiryDateController: _expiryDateController,
                cvvController: _cvvCodeController,
                onCardNumberChanged: (v) {
                  setState(() => _cardNumber = v);
                  context.read<PaymentMethodBloc>().add(UpdateCardPreview(
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cardHolderName: _cardHolderName,
                    cvv: _cvvCode,
                    type: _selectedType,
                  ));
                },
                onExpiryChanged: (v) {
                  setState(() => _expiryDate = v);
                  context.read<PaymentMethodBloc>().add(UpdateCardPreview(
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cardHolderName: _cardHolderName,
                    cvv: _cvvCode,
                    type: _selectedType,
                  ));
                },
                onCvvChanged: (v) {
                  setState(() => _cvvCode = v);
                  context.read<PaymentMethodBloc>().add(UpdateCardPreview(
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cardHolderName: _cardHolderName,
                    cvv: _cvvCode,
                    type: _selectedType,
                  ));
                },
                onCardHolderNameChanged: (v) {
                  setState(() => _cardHolderName = v);
                  context.read<PaymentMethodBloc>().add(UpdateCardPreview(
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cardHolderName: _cardHolderName,
                    cvv: _cvvCode,
                    type: _selectedType,
                  ));
                },
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveConstants.xlSpacing),

            // Enhanced Add Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (_selectedType == PaymentMethodType.zainCash || _selectedType == PaymentMethodType.qiCard)
                    ? null
                    : () async {
                        await HapticService.buttonClick();
                        _addPaymentMethod();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.lgPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: ResponsiveConstants.mdIconSize,
                      color: Colors.white,
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Text(
                      AppLocalizations.of(context)!.addPaymentMethod,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: ResponsiveConstants.lgSpacing),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod() {
    if (_formKey.currentState!.validate()) {
      final paymentMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        cardNumber: _cardNumber.replaceAll(
          ' ',
          '',
        ),
        expiryDate: _expiryDate,
        cardHolderName: _cardHolderName,
        cvvCode: _cvvCode,
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      context.read<PaymentMethodBloc>().add(AddPaymentMethod(paymentMethod));
      Navigator.of(context).pop(true);
    }
  }
}
