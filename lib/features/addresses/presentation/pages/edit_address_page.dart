import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/unified_section_header.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../widgets/loading_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/datasources/address_remote_data_source.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../profile/domain/usecases/get_user_profile.dart';

class EditAddressPage extends StatefulWidget {
  final Address? address; // For editing existing address

  const EditAddressPage({super.key, this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _street = TextEditingController();
  final _phone = TextEditingController();
  final _streetNumber = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _district = TextEditingController();
  final _zipCode = TextEditingController();
  final _additionalInfo = TextEditingController();

  String? _selectedCountryId; // numeric id as string
  String _selectedCountryName = 'Iraq';
  String? _selectedStateId; // numeric id as string
  String _selectedStateName = '';
  bool _isDefault = false;

  // New: quick label chips - will be initialized in build method
  List<String> _labelOptions = [];
  String _selectedLabel = '';

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _provinces = [];
  // These flags are kept for compatibility with existing listener logic
  // (Countries/States loading), even though country is fixed to Iraq.
  bool _isCountriesLoading = false;
  bool _isStatesLoading = false;
  bool _isProvincesLoading = false;
  bool _isSaving = false;

  int? _selectedProvinceId;
  String _selectedProvinceName = '';

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
    // Countries API not needed; country is fixed to Iraq and cities are local
    _loadProvinces();
    // For new addresses, prefill phone field from user profile if available
    if (widget.address == null) {
      _prefillPhoneFromProfile();
    }
  }

  String _tr(BuildContext context, {required String en, required String ar}) {
    return Directionality.of(context) == TextDirection.rtl ? ar : en;
  }

  void _loadExistingAddress() {
    if (widget.address != null) {
      final address = widget.address!;
      
      // Debug: Print all address data to see what we're working with
      debugPrint('EditAddressPage: Loading address data:');
      debugPrint('  - ID: ${address.id}');
      debugPrint('  - Street: "${address.street}"');
      debugPrint('  - Street Number: "${address.streetNumber}"');
      debugPrint('  - Building: "${address.building}"');
      debugPrint('  - Floor: "${address.floor}"');
      debugPrint('  - Apartment: "${address.apartment}"');
      debugPrint('  - District: "${address.district}"');
      debugPrint('  - Zip Code: "${address.zipCode}"');
      debugPrint('  - City: "${address.city}"');
      debugPrint('  - Country: "${address.country}"');
      debugPrint('  - Additional Info: "${address.additionalInfo}"');
      debugPrint('  - Label: "${address.label}"');
      debugPrint('  - Country ID: ${address.countryId}');
      debugPrint('  - State ID: ${address.stateId}');
      debugPrint('  - Province ID: ${address.provinceId}');
      
      _street.text = address.street;
      _phone.text = address.phone;
      _streetNumber.text = address.streetNumber;
      _building.text = address.building;
      _floor.text = address.floor;
      _apartment.text = address.apartment;
      _district.text = address.district;
      _zipCode.text = address.zipCode;
      _additionalInfo.text = address.additionalInfo;
      _selectedCountryName = 'Iraq';
      _selectedStateName = address.city;
      _isDefault = address.isDefault;
      // Store the address label info for later processing in build method
      _selectedLabel = address.label.isNotEmpty ? address.label : address.additionalInfo;
      
      // Set country and state IDs if available
      if (address.countryId != null) {
        _selectedCountryId = address.countryId.toString();
        debugPrint('EditAddressPage: Set selectedCountryId to ${_selectedCountryId}');
      }
      if (address.stateId != null) {
        _selectedStateId = address.stateId.toString();
        debugPrint('EditAddressPage: Set selectedStateId to ${_selectedStateId}');
      }

      if (address.provinceId != null) {
        _selectedProvinceId = address.provinceId;
        debugPrint('EditAddressPage: Set selectedProvinceId to ${_selectedProvinceId}');
      }
      
      // Force a rebuild to update the UI with the loaded data
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _prefillPhoneFromProfile() async {
    try {
      final getUserProfile = di.sl<GetUserProfile>();
      final result = await getUserProfile(const NoParams());

      result.fold(
        (failure) {
          debugPrint('EditAddressPage: Failed to load user profile for phone prefill: $failure');
        },
        (profile) {
          final phone = profile.phoneNumber ?? '';
          if (!mounted) return;
          if (_phone.text.trim().isEmpty && phone.isNotEmpty) {
            setState(() {
              _phone.text = phone;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('EditAddressPage: Exception while prefilling phone from profile: $e');
    }
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isProvincesLoading = true;
    });
    try {
      final remote = di.sl<AddressRemoteDataSource>();
      final list = await remote.getProvinceList();
      setState(() {
        _provinces = list;
        _isProvincesLoading = false;

        // Try to match existing province selection if available
        if (_selectedProvinceId != null) {
          final match = _provinces.firstWhere(
            (e) => (e['id'] ?? e['province_id']).toString() == _selectedProvinceId.toString(),
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            _selectedProvinceName = (match['name'] ?? '').toString();
          }
        }
      });
    } catch (e) {
      setState(() {
        _isProvincesLoading = false;
      });
      debugPrint('EditAddressPage: Error loading provinces: $e');
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _street.dispose();
    _streetNumber.dispose();
    _building.dispose();
    _floor.dispose();
    _apartment.dispose();
    _district.dispose();
    _zipCode.dispose();
    _additionalInfo.dispose();
    super.dispose();
  }

  void _initializeLabelOptions(BuildContext context) {
    if (_labelOptions.isEmpty) {
      _labelOptions = [
        AppLocalizations.of(context)!.home,
        AppLocalizations.of(context)!.office,
        AppLocalizations.of(context)!.other,
      ];
      
      // Fix the selected label if we have an existing address
      if (widget.address != null && _selectedLabel.isNotEmpty) {
        final match = _labelOptions.firstWhere(
          (l) => l.toLowerCase() == _selectedLabel.toLowerCase(),
          orElse: () => AppLocalizations.of(context)!.other,
        );
        _selectedLabel = match;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize label options and fix selected label
    _initializeLabelOptions(context);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            color: colorScheme.onBackground, 
            size: 20
          ),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        title: Text(
          widget.address != null ? AppLocalizations.of(context)!.editAddress : AppLocalizations.of(context)!.addNewAddress,
          style: AppFonts.getTextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveConstants.lgFontSize,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is CountriesLoading) {
            setState(() {
              _isCountriesLoading = true;
            });
          } else if (state is CountriesLoaded) {
            setState(() {
              _isCountriesLoading = false;
              _countries = state.countries;
              debugPrint('EditAddressPage: Loaded ${_countries.length} countries');
              // Try to preselect matching country by ID first, then by name if editing
              if (_selectedCountryId != null) {
                // Try to find by ID first
                final c = _countries.firstWhere(
                  (e) => (e['id'] ?? e['country_id']).toString() == _selectedCountryId,
                  orElse: () => {},
                );
                if (c.isNotEmpty) {
                  _selectedCountryName = c['name'] as String;
                  debugPrint('EditAddressPage: Found country by ID: ${_selectedCountryName}');
                } else {
                  debugPrint('EditAddressPage: Country ID $_selectedCountryId not found, trying by name');
                  // Fallback to name matching
                  final cByName = _countries.firstWhere(
                    (e) => (e['name'] as String).toLowerCase() == _selectedCountryName.toLowerCase(),
                    orElse: () => {},
                  );
                  if (cByName.isNotEmpty) {
                    _selectedCountryId = (cByName['id'] ?? cByName['country_id']).toString();
                  }
                }
              } else if (_selectedCountryName.isNotEmpty) {
                // Try to find by name if no ID is set
                final c = _countries.firstWhere(
                  (e) => (e['name'] as String).toLowerCase() == _selectedCountryName.toLowerCase(),
                  orElse: () => {},
                );
                if (c.isNotEmpty) {
                  _selectedCountryId = (c['id'] ?? c['country_id']).toString();
                  debugPrint('EditAddressPage: Found country by name: ${_selectedCountryId}');
                }
              }
              if (_selectedCountryId != null) {
                debugPrint('EditAddressPage: Loading states for country $_selectedCountryId');
                context.read<AddressBloc>().add(LoadStates(int.parse(_selectedCountryId!)));
              }
            });
          } else if (state is StatesLoading) {
            setState(() {
              _isStatesLoading = true;
            });
          } else if (state is StatesLoaded) {
            setState(() {
              _isStatesLoading = false;
              _states = state.states;
              debugPrint('EditAddressPage: Loaded ${_states.length} states for country ${state.countryId}');
              debugPrint('EditAddressPage: States data: $_states');
              // Preselect state if editing - try by ID first, then by name
              if (_selectedStateId != null) {
                // Try to find by ID first
                final s = _states.firstWhere(
                  (e) => (e['id'] ?? e['state_id']).toString() == _selectedStateId,
                  orElse: () => {},
                );
                if (s.isNotEmpty) {
                  _selectedStateName = s['name'] as String;
                  debugPrint('EditAddressPage: Found state by ID: ${_selectedStateName}');
                } else {
                  debugPrint('EditAddressPage: State ID $_selectedStateId not found, trying by name');
                  // Fallback to name matching
                  final sByName = _states.firstWhere(
                    (e) => (e['name'] as String).toLowerCase() == _selectedStateName.toLowerCase(),
                    orElse: () => {},
                  );
                  if (sByName.isNotEmpty) {
                    _selectedStateId = (sByName['id'] ?? sByName['state_id']).toString();
                  }
                }
              } else if (_selectedStateName.isNotEmpty) {
                // Try to find by name if no ID is set
                final s = _states.firstWhere(
                  (e) => (e['name'] as String).toLowerCase() == _selectedStateName.toLowerCase(),
                  orElse: () => {},
                );
                if (s.isNotEmpty) {
                  _selectedStateId = (s['id'] ?? s['state_id']).toString();
                  debugPrint('EditAddressPage: Found state by name: ${_selectedStateId}');
                }
              }
            });
          } else if (state is AddressError) {
            setState(() {
              _isCountriesLoading = false;
              _isStatesLoading = false;
              _isSaving = false; // Reset saving state on error
            });
            // Show error message
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)!.errorLoadingCountriesStates}: ${state.message}',
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onError,
                  ),
                ),
                backgroundColor: colorScheme.error,
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.retry,
                  textColor: colorScheme.onError,
                  onPressed: () async {
          await HapticService.buttonClick();
          context.read<AddressBloc>().add(const LoadCountries());
        },
                ),
              ),
            );
          } else if (state is AddressSuccess) {
            // Reset saving state on success
            setState(() {
              _isSaving = false;
            });
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  children: [
                UnifiedSectionHeader(title: AppLocalizations.of(context)!.locationDetails, icon: Icons.location_on_outlined),
                SizedBox(height: ResponsiveConstants.mdSpacing),

                // Province dropdown (from API, single source of truth for region)
                if (_isProvincesLoading)
                  LoadingField(
                    label: _tr(context, en: 'Province', ar: 'المحافظة'),
                    icon: Icons.map_outlined,
                  )
                else
                  _buildDropdownField(
                    label: _tr(context, en: 'Province', ar: 'المحافظة'),
                    value: _selectedProvinceName.isEmpty ? '' : _selectedProvinceName,
                    items: _provinces.map((p) => (p['name'] ?? '').toString()).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvinceName = value ?? '';
                        final match = _provinces.firstWhere(
                          (p) => (p['name'] ?? '').toString() == _selectedProvinceName,
                          orElse: () => {},
                        );
                        if (match.isNotEmpty) {
                          _selectedProvinceId = match['id'] as int?;
                        }
                      });
                    },
                    icon: Icons.map_outlined,
                  ),
                SizedBox(height: ResponsiveConstants.mdSpacing),

                _buildTextField(
                  controller: _street,
                  label: AppLocalizations.of(context)!.streetName,
                  hint: AppLocalizations.of(context)!.enterStreetName,
                  icon: Icons.straighten,
                  validator: (value) => value?.trim().isEmpty == true ? AppLocalizations.of(context)!.streetNameIsRequired : null,
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),

                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildTextField(
                    controller: _phone,
                    label: AppLocalizations.of(context)!.phoneNumber,
                    hint: AppLocalizations.of(context)!.phoneNumber,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.trim().isEmpty == true
                        ? AppLocalizations.of(context)!.phoneNumber
                        : null,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),

                // Removed fields: Street Number, Building, Floor, Apartment, ZIP
                SizedBox(height: ResponsiveConstants.mdSpacing),

                UnifiedSectionHeader(title: _tr(context, en: 'Additional Notes', ar: 'ملاحظات إضافية'), icon: Icons.notes_outlined),
                SizedBox(height: ResponsiveConstants.smSpacing),
                _buildTextField(
                  controller: _additionalInfo,
                  label: _tr(context, en: 'Notes', ar: 'ملاحظات'),
                  hint: _tr(context, en: 'Enter any delivery notes (optional)', ar: 'أدخل أي ملاحظات للتوصيل (اختياري)'),
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),

                UnifiedSectionHeader(title: AppLocalizations.of(context)!.addressSettings, icon: Icons.settings),
                SizedBox(height: ResponsiveConstants.mdSpacing),

                _buildSwitchTile(
                  title: AppLocalizations.of(context)!.setAsDefaultAddress,
                  subtitle: AppLocalizations.of(context)!.defaultAddressDescription,
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                  icon: Icons.star,
                ),
                SizedBox(height: ResponsiveConstants.xlSpacing),

                _buildSaveButton(),
                SizedBox(height: ResponsiveConstants.lgSpacing),
              ],
            ),
          ),
        ),
            // Loading overlay
            if (_isSaving)
              Container(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.4 : 0.1,
                          ),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.saving,
                          style: AppFonts.getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon, 
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary, 
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error, 
            width: 2,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppFonts.getTextStyle(
          color: isDark 
              ? colorScheme.onSurface 
              : Colors.grey.shade600,
        ),
        hintStyle: AppFonts.getTextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      style: AppFonts.getTextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : (items.contains(value) ? value : null),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              item,
              style: AppFonts.getTextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon, 
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary, 
            width: 2,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppFonts.getTextStyle(
          color: isDark 
              ? colorScheme.onSurface 
              : Colors.grey.shade600,
        ),
      ),
      style: AppFonts.getTextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
      dropdownColor: colorScheme.surface,
      icon: Icon(
        Icons.keyboard_arrow_down, 
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppFonts.getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppFonts.getTextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        value: value,
        onChanged: (value) async {
          await HapticService.selectionClick();
          onChanged(value);
        },
        secondary: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            icon, 
            color: Colors.amber.shade600,
          ),
        ),
        activeColor: colorScheme.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSaveButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () async {
          await HapticService.buttonClick();
          _save();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSaving 
              ? colorScheme.surface.withValues(alpha: 0.5)
              : colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.saving,
                    style: AppFonts.getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                widget.address != null 
                    ? AppLocalizations.of(context)!.updateAddress 
                    : AppLocalizations.of(context)!.saveAddress,
                style: AppFonts.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final colorScheme = Theme.of(context).colorScheme;
    
    if (_selectedCountryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseSelectACountry,
            style: AppFonts.getTextStyle(
              color: colorScheme.onError,
            ),
          ),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    // Province is required so that backend receives a valid province_id
    if (_selectedProvinceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              en: 'Please select a province',
              ar: 'يرجى اختيار المحافظة',
            ),
            style: AppFonts.getTextStyle(
              color: colorScheme.onError,
            ),
          ),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (_isSaving) return; // Prevent multiple saves

    setState(() {
      _isSaving = true;
    });

    try {
      // Use phone number entered in the form
      final resolvedPhone = _phone.text.trim();
      final address = Address(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: AppLocalizations.of(context)!.user,
        phone: resolvedPhone,
        country: _selectedCountryName,
        // Use selected province as city in backend, district remains separate text field
        city: _selectedProvinceName.isNotEmpty ? _selectedProvinceName : _district.text.trim(),
        district: _district.text.trim(),
        street: _street.text.trim(),
        streetNumber: '',
        building: '',
        floor: '',
        apartment: '',
        zipCode: '',
        additionalInfo: _additionalInfo.text.trim(),
        label: _selectedLabel == AppLocalizations.of(context)!.other ? '' : _selectedLabel,
        isDefault: _isDefault,
        createdAt: widget.address?.createdAt ?? DateTime.now(),
        countryId: _selectedCountryId != null ? int.tryParse(_selectedCountryId!) : null,
        stateId: _selectedStateId != null ? int.tryParse(_selectedStateId!) : null,
        provinceId: _selectedProvinceId,
        type: 'delivery', // Default to delivery
      );

      if (widget.address != null) {
        context.read<AddressBloc>().add(UpdateAddressEvent(address));
      } else {
        context.read<AddressBloc>().add(AddNewAddress(address));
      }

      // Wait a bit for the operation to complete before closing
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorSavingAddress}: ${e.toString()}',
              style: AppFonts.getTextStyle(
                color: colorScheme.onError,
              ),
            ),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }


  Widget _buildInfoField({
    required String label,
    required String message,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppFonts.getTextStyle(color: Colors.blue.shade600),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppFonts.getTextStyle(color: Colors.blue.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorField({
    required String label,
    required String message,
    required IconData icon,
    required VoidCallback onRetry,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red.shade600),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: Colors.red.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppFonts.getTextStyle(color: Colors.red.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.getTextStyle(color: Colors.red.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await HapticService.buttonClick();
              onRetry();
            },
            icon: Icon(Icons.refresh, size: 16),
            label: Text(AppLocalizations.of(context)!.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
