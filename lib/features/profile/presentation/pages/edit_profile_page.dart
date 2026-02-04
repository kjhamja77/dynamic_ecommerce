import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/widgets/authenticated_cached_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/unified_section_header.dart';
import '../../../../core/utils/country_code_detector.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({
    super.key, 
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFieldKey = GlobalKey<PhoneInputFieldState>();
  // Address removed from edit profile UI

  /// Bytes of the image picked from camera/gallery; used to send base64 to update API.
  Uint8List? _pickedImageBytes;

  String? _avatarUrl;
  bool _isLoading = false;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Get the latest profile from bloc state or use widget.profile
  UserProfile _getCurrentProfile() {
    final blocState = context.read<ProfileBloc>().state;
    if (blocState is ProfileLoaded) {
      return blocState.profile;
    } else if (blocState is ProfileUpdated) {
      return blocState.profile;
    }
    return widget.profile;
  }

  void _loadProfileData() {
    final profile = _getCurrentProfile();
    _currentProfile = profile;
    
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    
    // Handle phone number from API (strip +country code; country code handled by PhoneInputField.initialCountryCode)
    final phoneNumber = profile.phoneNumber ?? '';
    if (phoneNumber.isNotEmpty) {
      String cleanPhoneNumber = phoneNumber;
      if (phoneNumber.startsWith('+')) {
        final detected = CountryCodeDetector.detectCountry(phoneNumber);
        if (detected != null &&
            phoneNumber.startsWith('+${detected.phoneCode}')) {
          cleanPhoneNumber =
              phoneNumber.substring('+${detected.phoneCode}'.length);
        }
      }
      _phoneController.text = cleanPhoneNumber;
    }
    
    _avatarUrl = profile.avatarUrl;
    _pickedImageBytes = null;

    debugPrint('EditProfilePage: Loaded profile data');
    debugPrint('EditProfilePage: Name: ${profile.name}');
    debugPrint('EditProfilePage: Email: ${profile.email}');
    debugPrint('EditProfilePage: Phone: ${profile.phoneNumber}');
    debugPrint('EditProfilePage: Country Code: ${profile.countryCode}');
    debugPrint('EditProfilePage: Avatar URL: ${profile.avatarUrl}');
  }
  
  void _updateFormFields(UserProfile profile) {
    if (_currentProfile?.id == profile.id && 
        _currentProfile?.updatedAt == profile.updatedAt) {
      return; // Already up to date
    }
    
    _currentProfile = profile;
    _pickedImageBytes = null;
    _nameController.text = profile.name;
    _emailController.text = profile.email;

    // Handle phone number
    final phoneNumber = profile.phoneNumber ?? '';
    if (phoneNumber.isNotEmpty) {
      String cleanPhoneNumber = phoneNumber;
      if (phoneNumber.startsWith('+')) {
        final detected = CountryCodeDetector.detectCountry(phoneNumber);
        if (detected != null &&
            phoneNumber.startsWith('+${detected.phoneCode}')) {
          cleanPhoneNumber =
              phoneNumber.substring('+${detected.phoneCode}'.length);
        }
      }
      _phoneController.text = cleanPhoneNumber;
    } else {
      _phoneController.clear();
    }
    
    // Update avatar URL if it changed
    if (_avatarUrl != profile.avatarUrl) {
      setState(() {
        _avatarUrl = profile.avatarUrl;
      });
    }
    
    // Update country code in phone field
    if (profile.countryCode != null && _phoneFieldKey.currentState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _phoneFieldKey.currentState?.setCountryCode(profile.countryCode!);
      });
    }
    
    debugPrint('EditProfilePage: Updated form fields from profile');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Watch bloc state to get latest profile and update form fields
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        // Only listen to state changes that matter for this page
        return current is ProfileUpdated || 
               current is ProfileError || 
               current is ProfileUpdating;
      },
      listener: (context, state) {
        if (state is ProfileUpdated) {
          if (!mounted) return;
          
          debugPrint('EditProfilePage: Profile updated successfully');
          
          // Update loading state
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
          
          // Show success message first
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate back with the updated profile after a short delay to ensure UI updates
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pop(state.profile);
            }
          });
        } else if (state is ProfileError) {
          if (!mounted) return;
          
          debugPrint('EditProfilePage: Profile update error: ${state.message}');
          
          // Update loading state
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is ProfileUpdating) {
          if (!mounted) return;
          
          debugPrint('EditProfilePage: Profile updating...');
          
          // Update loading state
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        }
      },
      buildWhen: (previous, current) {
        // Rebuild when profile changes
        return current is ProfileLoaded || current is ProfileUpdated;
      },
      builder: (context, blocState) {
        // Get the latest profile from bloc state
        final latestProfile = blocState is ProfileLoaded 
            ? blocState.profile 
            : (blocState is ProfileUpdated 
                ? blocState.profile 
                : widget.profile);
        
        // Update form fields if profile changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateFormFields(latestProfile);
          }
        });
        
        return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () async {
            await HapticService.buttonClick();
            Navigator.of(context).pop();
          },
          ),
          title: Text(
            AppLocalizations.of(context)!.editProfile,
            style: AppFonts.getTextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveConstants.lgFontSize,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                AppLocalizations.of(context)!.save,
                style: AppFonts.getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              children: [
                _buildAvatarSection(),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                
                UnifiedSectionHeader(title: AppLocalizations.of(context)!.personalInformation, icon: Icons.person_outline),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                
                _buildTextField(
                  controller: _nameController,
                  label: AppLocalizations.of(context)!.fullName,
                  hint: AppLocalizations.of(context)!.enterYourFullName,
                  icon: Icons.person,
                  validator: (value) => value?.trim().isEmpty == true ? AppLocalizations.of(context)!.nameIsRequired : null,
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                
                _buildTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.email,
                  hint: AppLocalizations.of(context)!.enterYourEmailAddress,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.trim().isEmpty == true) return AppLocalizations.of(context)!.emailIsRequired;
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                
                PhoneInputField(
                  key: _phoneFieldKey,
                  controller: _phoneController,
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                  validator: (_) => null,
                  onChanged: (_) {},
                  initialCountryCode: _currentProfile?.countryCode ?? widget.profile.countryCode,
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                
                // Address section removed
                SizedBox(height: ResponsiveConstants.lgSpacing),
                
                _buildSaveButton(),
                SizedBox(height: ResponsiveConstants.lgSpacing),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildAvatarSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outline.withValues(alpha: 0.4)
                        : colorScheme.outline.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatarImage(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 3),
                  ),
                  child: IconButton(
                    onPressed: _showImagePickerOptions,
                    icon: Icon(
                      Icons.camera_alt,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            AppLocalizations.of(context)!.tapToChangePhoto,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (_avatarUrl != null && _avatarUrl!.isNotEmpty) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: ResponsiveConstants.smSpacing,
              runSpacing: ResponsiveConstants.xsSpacing,
              children: [
                TextButton.icon(
                  onPressed: _removeImage,
                  icon: Icon(Icons.remove_circle_outline, size: 18),
                  label: Text(AppLocalizations.of(context)!.remove),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size(0, 40),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showImageDetails,
                  icon: Icon(Icons.info_outline, size: 18),
                  label: Text(AppLocalizations.of(context)!.details),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size(0, 40),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    debugPrint('EditProfilePage: _buildAvatarImage - avatarUrl: $_avatarUrl');

    if (_avatarUrl == null || _avatarUrl!.isEmpty) {
      return _buildDefaultAvatar();
    }

    final avatarString = _avatarUrl!;
    final colorScheme = Theme.of(context).colorScheme;

    // 🚀 1️⃣ NETWORK URL
    if (avatarString.startsWith('http://') || avatarString.startsWith('https://')) {
      return AuthenticatedCachedImage(
        imageUrl: avatarString,
        fit: BoxFit.cover,
        placeholder: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: _buildDefaultAvatar(),
      );
    }

    // 🚀 2️⃣ FIXED FILE PATH CHECK — NO LONGER TREATS BASE64 AS FILE
    bool isFilePath = false;
    if (avatarString.length < 150 && (avatarString.contains('/') || avatarString.contains('\\'))) {
      try {
        final file = File(avatarString);
        if (file.existsSync()) {
          isFilePath = true;
        }
      } catch (_) {}
    }

    if (isFilePath) {
      try {
        return Image.file(
          File(avatarString),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) {
            debugPrint('File load failed → trying base64');
            return _tryBase64Image(avatarString, colorScheme);
          },
        );
      } catch (e) {
        return _tryBase64Image(avatarString, colorScheme);
      }
    }

    // 🚀 3️⃣ TREAT AS BASE64 ALWAYS IF NOT FILE / NOT URL
    return _tryBase64Image(avatarString, colorScheme);
  }

  /// Try to display image as base64, fallback to default avatar if it fails
  Widget _tryBase64Image(String imageString, ColorScheme colorScheme) {
    final bytes = _base64ToBytes(imageString);
    if (bytes != null && bytes.isNotEmpty) {
      debugPrint('EditProfilePage: ✅ Base64 conversion successful, displaying with Image.memory');
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('EditProfilePage: Error displaying base64 image: $error');
          return _buildDefaultAvatar();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: child,
          );
        },
      );
    }
    
    debugPrint('EditProfilePage: ❌ Base64 conversion failed, showing default avatar');
    return _buildDefaultAvatar();
  }

  /// Convert base64 string to Uint8List bytes
  Uint8List? _base64ToBytes(String base64String) {
    try {
      if (base64String.isEmpty) return null;

      String clean = base64String.trim();

      // Remove possible prefix
      if (clean.contains(',')) {
        clean = clean.split(',').last;
      }

      // Remove invalid whitespace
      clean = clean.replaceAll(RegExp(r"\s+"), "");

      // Pad if needed
      int mod = clean.length % 4;
      if (mod != 0) clean += "=" * (4 - mod);

      return base64Decode(clean);
    } catch (e) {
      debugPrint("Base64 decode failed: $e");
      return null;
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.person,
        size: 60,
        color:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
          color: colorScheme.onSurface.withValues(alpha: 0.7),
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
            color: isDark
                ? colorScheme.outline.withValues(alpha: 0.3)
                : Colors.grey.shade300,
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
        fillColor: isDark
            ? colorScheme.surface.withValues(alpha: 0.9)
            : Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppFonts.getTextStyle(
          color: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : Colors.grey.shade600,
        ),
        hintStyle: AppFonts.getTextStyle(
          color: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.4)
              : Colors.grey.shade400,
        ),
      ),
      style: AppFonts.getTextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
    );
  }


  Widget _buildSaveButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.save,
                style: AppFonts.getTextStyle(fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showImagePickerOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true, // keep sheet above system nav buttons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.choosePhoto,
              style: AppFonts.getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt,
                    title: AppLocalizations.of(context)!.camera,
                    onTap: () async {
          await HapticService.buttonClick();
          Navigator.pop(context);
                      // Add small delay to ensure modal is closed
                      Future.delayed(Duration(milliseconds: 100), () {
                        _pickImage(ImageSource.camera);
        });
                    },
                  ),
                ),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library,
                    title: AppLocalizations.of(context)!.gallery,
                    onTap: () async {
          await HapticService.buttonClick();
          Navigator.pop(context);
                      // Add small delay to ensure modal is closed
                      Future.delayed(Duration(milliseconds: 100), () {
                        _pickImage(ImageSource.gallery);
        });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
          await HapticService.buttonClick();
          Navigator.pop(context);
        },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: AppFonts.getTextStyle(
                    fontSize: 16,
                    color: isDark
                        ? colorScheme.onSurface.withValues(alpha: 0.7)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : null,
          border: Border.all(
            color: isDark
                ? colorScheme.outline.withValues(alpha: 0.4)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark
                  ? colorScheme.onSurface.withValues(alpha: 0.9)
                  : Colors.black87,
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              title,
              style: AppFonts.getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? colorScheme.onSurface.withValues(alpha: 0.9)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkPermission(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.status;
        if (status.isDenied) {
          final result = await Permission.camera.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // For gallery, check photos permission (Android 13+) or storage (older versions)
        if (defaultTargetPlatform == TargetPlatform.android) {
          // Try photos permission first (Android 13+)
          try {
            final photosStatus = await Permission.photos.status;
            if (photosStatus.isDenied) {
              final result = await Permission.photos.request();
              if (result.isGranted) {
                return true;
              }
            } else if (photosStatus.isGranted) {
              return true;
            }
          } catch (e) {
            debugPrint('Photos permission check failed (might be Android < 13): $e');
          }
          
          // Fallback to storage permission for Android 12 and below
          try {
            final storageStatus = await Permission.storage.status;
            if (storageStatus.isDenied) {
              final result = await Permission.storage.request();
              return result.isGranted;
            }
            return storageStatus.isGranted;
          } catch (e) {
            debugPrint('Storage permission check failed: $e');
            // If both fail, return true to let image picker handle it
            return true;
          }
        } else {
          // iOS
          final permission = Permission.photos;
          final status = await permission.status;
          if (status.isDenied) {
            final result = await permission.request();
            return result.isGranted;
          }
          return status.isGranted;
        }
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
      // Return true to let image picker handle permission requests
      return true;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check permission first
      final hasPermission = await _checkPermission(source);
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera 
                  ? AppLocalizations.of(context)!.cameraPermissionRequired
                  : AppLocalizations.of(context)!.photoLibraryPermissionRequired
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.settings,
                textColor: Colors.white,
                onPressed: () async {
          await HapticService.buttonClick();
          openAppSettings();
        },
              ),
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      
      // Add timeout to prevent hanging
      final XFile? image = await Future.any([
        picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.front,
        ),
        Future.delayed(Duration(seconds: 30), () => throw TimeoutException('Image picker timed out', Duration(seconds: 30))),
      ]);

      if (image != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.processingImage),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Simulate image processing delay
        await Future.delayed(Duration(milliseconds: 1500));

        if (mounted) {
          final bytes = await image.readAsBytes();
          setState(() {
            _avatarUrl = image.path;
            _pickedImageBytes = bytes;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.photoSelectedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image picker timed out. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String errorMessage = AppLocalizations.of(context)!.errorPickingImage;
      
      if (e.toString().contains('permission')) {
        errorMessage = AppLocalizations.of(context)!.permissionDenied;
      } else if (e.toString().contains('cancel') || e.toString().contains('User cancelled')) {
        // User cancelled, don't show error - this is normal behavior
        debugPrint('User cancelled image selection');
        return;
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Image picker timed out. Please try again.';
      } else {
        errorMessage = 'Error picking image: ${e.toString().split(':').last.trim()}';
      }
      
      debugPrint('Image picker error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _avatarUrl = null;
      _pickedImageBytes = null;
    });
    
    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.photoRemoved),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showImageDetails() {
    if (_avatarUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.imageDetails,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_avatarUrl!.startsWith('http')) ...[
              Text('Type: Network Image', style: AppFonts.getTextStyle()),
              Text('URL: ${_avatarUrl!}', style: AppFonts.getTextStyle(fontSize: 12)),
            ] else ...[
              Text('Type: Local Image', style: AppFonts.getTextStyle()),
              Text('Path: ${_avatarUrl!.split('/').last}', style: AppFonts.getTextStyle(fontSize: 12)),
            ],
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text('Status: Ready for upload', style: AppFonts.getTextStyle()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
            child: Text(AppLocalizations.of(context)!.close, style: AppFonts.getTextStyle()),
          ),
        ],
      ),
    );
  }


  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Prevent multiple simultaneous saves
    if (_isLoading) {
      debugPrint('EditProfilePage: Save already in progress, ignoring duplicate call');
      return;
    }

    // Set loading state immediately
    setState(() {
      _isLoading = true;
    });

    // Show image processing message if there's a new local image
    if (_avatarUrl != null && 
        _avatarUrl != widget.profile.avatarUrl && 
        !_avatarUrl!.startsWith('http')) {
      
      // Show image processing message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Processing image...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    try {
      // Phone: send national digits only (no country code prefix).
      // Country code: send dial code (e.g. "971") so backend stores it correctly.
      // Profile header and PhoneInputField accept both ISO and dial code for display/init.
      final String rawPhone = _phoneController.text.trim();
      final String? phoneNumberToSave = rawPhone.isEmpty ? null : rawPhone;
      final String? countryCodeToSave =
          _phoneFieldKey.currentState?.selectedCountry.countryCode;

      // Image to send: prefer picked bytes as base64 so update API always gets the image
      String? avatarUrlToSave;
      if (_pickedImageBytes != null && _pickedImageBytes!.isNotEmpty) {
        avatarUrlToSave = base64Encode(_pickedImageBytes!);
        debugPrint('EditProfilePage: Sending picked image as base64, length=${avatarUrlToSave.length}');
      } else {
        avatarUrlToSave = _avatarUrl;
      }

      final currentProfile = _currentProfile ?? widget.profile;
      final updatedProfile = UserProfile(
        id: currentProfile.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: avatarUrlToSave,
        phoneNumber: phoneNumberToSave,
        countryCode: countryCodeToSave,
        address: currentProfile.address,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );
      
      debugPrint('EditProfilePage: Saving profile - ID: ${updatedProfile.id}');
      debugPrint('EditProfilePage: Name: ${updatedProfile.name}');
      debugPrint('EditProfilePage: Email: ${updatedProfile.email}');
      debugPrint('EditProfilePage: Avatar URL: ${updatedProfile.avatarUrl}');
      debugPrint('EditProfilePage: Phone: ${updatedProfile.phoneNumber}');
      debugPrint('EditProfilePage: Country Code: ${updatedProfile.countryCode}');

      // Dispatch UpdateUserProfile event to trigger _onUpdateUserProfile in the bloc
      context.read<ProfileBloc>().add(UpdateUserProfile(updatedProfile));
    } catch (e) {
      debugPrint('EditProfilePage: Error preparing profile update: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
