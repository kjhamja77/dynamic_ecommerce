import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';
import '../../core/theme/app_fonts.dart';
import '../services/haptic_service.dart';
import '../../l10n/app_localizations.dart';

class SortOption {
  final String label;
  final IconData icon;
  final String subtitle;
  const SortOption({required this.label, required this.icon, this.subtitle = ''});
}

Future<String?> showSortBottomSheet({
  required BuildContext context,
  required List<SortOption> options,
  required String selected,
  String title = 'Sort by'
}) async {
  final theme = Theme.of(context);
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    isScrollControlled: true,
    builder: (ctx) {
      return _SortBottomSheetContent(
        options: options,
        selected: selected,
        title: title,
      );
    },
  );
}

class _SortBottomSheetContent extends StatefulWidget {
  final List<SortOption> options;
  final String selected;
  final String title;

  const _SortBottomSheetContent({
    required this.options,
    required this.selected,
    required this.title,
  });

  @override
  State<_SortBottomSheetContent> createState() => _SortBottomSheetContentState();
}

class _SortBottomSheetContentState extends State<_SortBottomSheetContent> {
  late String tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: false,
      child: SafeArea(
        top: false,
        bottom: true,
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Text(
                    widget.title,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.lgFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  Expanded(
                    child: ListView.separated(
                      itemCount: widget.options.length,
                      separatorBuilder: (_, __) => Divider(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      itemBuilder: (_, index) {
                        final opt = widget.options[index];
                        return ListTile(
                          onTap: () async {
                            await HapticService.selectionClick();
                            setState(() {
                              tempSelected = opt.label;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(opt.icon, color: colorScheme.onSurface),
                          ),
                          title: Text(
                            opt.label,
                            style: AppFonts.getTextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: opt.subtitle.isNotEmpty
                              ? Text(
                                  opt.subtitle,
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.smFontSize,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                )
                              : null,
                          trailing: Radio<String>(
                            value: opt.label,
                            groupValue: tempSelected,
                            activeColor: colorScheme.primary,
                            onChanged: (val) async {
                              await HapticService.selectionClick();
                              setState(() {
                                tempSelected = val!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await HapticService.buttonClick();
                        navigator.pop(tempSelected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

