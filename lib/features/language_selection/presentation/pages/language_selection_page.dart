import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../core/services/first_launch_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/datasources/language_remote_data_source.dart';
import '../../../../core/services/language_service.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with TickerProviderStateMixin {
  String? _selectedLanguage;
  List<LanguageDto> _languages = const [];
  bool _loading = true;
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _fetchLanguages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchLanguages() async {
    try {
      final ds = di.sl<LanguageRemoteDataSource>();
      final items = await ds.getLanguageList();
      if (mounted) {
        setState(() {
          _languages = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onLanguageSelected(String languageCode) {
    setState(() => _selectedLanguage = languageCode);
  }

  Future<void> _confirmSelection() async {
    if (_selectedLanguage == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await HapticService.buttonClick();
      await AppLocalizationService().setLanguage(_selectedLanguage!);
      await LanguageService().setFromAppLanguageCode(_selectedLanguage!);
      await FirstLaunchService().markFirstLaunchCompleted();
      await FirstLaunchService().markLanguageSelected();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  // Compact header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Icon(
                            Icons.language,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        Text(
                          'Choose language',
                          style: AppFonts.getTextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'You can change it later in Settings',
                          style: AppFonts.getTextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveConstants.xlSpacing),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    for (final lang in _languages) ...[
                      _LanguageOption(
                        languageCode: lang.isoCode,
                        languageName: lang.name,
                        subtitle: lang.isoCode.toUpperCase(),
                        flag: lang.isoCode == 'ar' ? '🇸🇦' : '🇺🇸',
                        isSelected: _selectedLanguage == lang.isoCode,
                        onTap: () async {
                          await HapticService.selectionClick();
                          _onLanguageSelected(lang.isoCode);
                        },
                      ),
                      SizedBox(height: ResponsiveConstants.mdSpacing),
                    ]
                  ],

                  const Spacer(),
                  // Bottom confirm button (enabled when selected)
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _selectedLanguage == null || _isSaving
                          ? null
                          : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _selectedLanguage == 'ar'
                                  ? 'استمرار'
                                  : 'Continue',
                              style: AppFonts.getTextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final String subtitle;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.subtitle,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LanguageOption> createState() => _LanguageOptionState();
}

class _LanguageOptionState extends State<_LanguageOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () async {
        await HapticService.selectionClick();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade50,
                border: Border.all(
                  color: widget.isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: widget.isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
              ),
              child: Row(
                children: [
                  // Flag
                  Text(
                    widget.flag,
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  SizedBox(width: ResponsiveConstants.lgSpacing),
                  
                  // Language info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.languageName,
                          style: AppFonts.getTextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.subtitle,
                          style: AppFonts.getTextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(
                            Icons.check,
                            size: 16.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
