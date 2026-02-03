import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../constants/auth_color_constants.dart';
import '../../../../core/utils/country_code_detector.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  /// Optional initial country code (ISO 2-letter), e.g. 'AE', from backend/profile.
  final String? initialCountryCode;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.onChanged,
    this.initialCountryCode,
  });

  @override
  State<PhoneInputField> createState() => PhoneInputFieldState();
}

class PhoneInputFieldState extends State<PhoneInputField> {
  // Default to Iraq (IQ) instead of US
  late Country _selectedCountry;
  
  bool _isFocused = false;
  bool _hasError = false;
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize default country to Iraq (IQ)
    try {
      _selectedCountry = CountryCodeDetector.getCountryFromCode('IQ') ?? Country.parse('IQ');
    } catch (e) {
      // Fallback to Iraq with known values if parsing fails
      _selectedCountry = Country(
        phoneCode: '964',
        countryCode: 'IQ',
        e164Sc: 0,
        geographic: true,
        level: 1,
        name: 'Iraq',
        displayName: 'Iraq',
        displayNameNoCountryCode: 'Iraq',
        e164Key: '964',
        example: '7901234567',
      );
    }
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    
    // Initialize country from provided initialCountryCode if available
    if (widget.initialCountryCode != null &&
        widget.initialCountryCode!.trim().isNotEmpty) {
      // Use a post-frame callback to ensure widget is mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setCountryCode(widget.initialCountryCode!);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
      });
    }
  }

  void _detectAndUpdateCountryCode(String phoneNumber) {
    // Only auto-detect if the phone number has at least 3 digits
    if (phoneNumber.length >= 3) {
      final detectedCountry = CountryCodeDetector.detectCountry(phoneNumber);
      if (detectedCountry != null && detectedCountry.countryCode != _selectedCountry.countryCode) {
        setState(() {
          _selectedCountry = detectedCountry;
        });
        
        // Remove the country code from the phone number to avoid duplication
        final countryCode = detectedCountry.phoneCode;
        if (phoneNumber.startsWith(countryCode)) {
          final phoneWithoutCountryCode = phoneNumber.substring(countryCode.length);
          widget.controller.text = phoneWithoutCountryCode;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: phoneWithoutCountryCode.length),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: AppFonts.getTextStyle(fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surface.withValues(alpha: 0.9)
                : colorScheme.surface,
            border: Border.all(
              color: _hasError 
                  ? colorScheme.error
                  : _isFocused 
                      ? AuthColorConstants.primaryColor 
                      : colorScheme.outline.withValues(alpha: 0.3),
              width: _hasError || _isFocused ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AuthColorConstants.primaryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                // Country Code Selector
              GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    countryListTheme: CountryListThemeData(
                      flagSize: 25,
                      backgroundColor: colorScheme.surface,
                      textStyle: AppFonts.getTextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      bottomSheetHeight: 500,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      searchTextStyle: AppFonts.getTextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                      // Country code changed - user can manually adjust phone number if needed
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surface.withValues(alpha: 0.5)
                        : colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${_selectedCountry.phoneCode}',
                          style: AppFonts.getTextStyle(fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Divider
              Container(
                height: 32,
                width: 1,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              // Phone Number Input
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    keyboardType: TextInputType.phone,
                    validator: widget.validator,
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                      _validateField();
                      // Removed automatic country code detection on every keystroke
                      // Users can manually select country code using the dropdown
                    },
                    style: AppFonts.getTextStyle(fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
        // Error Text
        if (_hasError && widget.validator != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              widget.validator!(widget.controller.text) ?? '',
              style: AppFonts.getTextStyle(fontSize: 12,
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  // Getter for the full phone number with country code
  String get fullPhoneNumber => '+${_selectedCountry.phoneCode}${widget.controller.text}';
  
  // Getter for the selected country
  Country get selectedCountry => _selectedCountry;
  
  // Method to manually set country code from 2-letter ISO code (e.g. 'AE')
  void setCountryCode(String countryCode) {
    try {
      final normalized = countryCode.toUpperCase().trim();
      // Prefer our detector helper so it works even if Country.parse changes
      final country = CountryCodeDetector.getCountryFromCode(normalized) ?? Country.parse(normalized);
      setState(() {
        _selectedCountry = country;
      });
    } catch (e) {
      // Handle invalid country code silently
    }
  }
  
  // Method to detect and set country code from phone number
  void detectCountryFromPhoneNumber(String phoneNumber) {
    _detectAndUpdateCountryCode(phoneNumber);
  }
}
