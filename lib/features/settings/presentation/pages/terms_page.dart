import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/html_content_widget.dart';
import '../../../terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import '../../../terms_conditions/presentation/bloc/terms_conditions_event.dart';
import '../../../terms_conditions/presentation/bloc/terms_conditions_state.dart';
import '../../../../core/services/haptic_service.dart';
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TermsConditionsBloc>().add(LoadTermsConditions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.termsOfService,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.background,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onBackground, size: 20),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await HapticService.buttonClick();
            if (mounted) {
              navigator.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TermsConditionsBloc, TermsConditionsState>(
          builder: (context, state) {
            if (state is TermsConditionsLoading) {
              return _buildLoadingState();
            } else if (state is TermsConditionsLoaded) {
              return _buildLoadedState(state);
            } else if (state is TermsConditionsError) {
              return _buildErrorState(state);
            }
            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          Text(
            AppLocalizations.of(context)!.loading,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(TermsConditionsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    final termsConditions = state.termsConditions.termsConditions.isNotEmpty
        ? state.termsConditions.termsConditions.first
        : null;

    if (termsConditions == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            child: Text(
              termsConditions.name,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.xlFontSize,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // HTML Content
          HtmlContentWidget(
            htmlContent: termsConditions.termsCondition,
          ),
          
          // Footer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            child: Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.smFontSize,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TermsConditionsError state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              AppLocalizations.of(context)!.error,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Text(
              state.message,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveConstants.xlSpacing),
            ElevatedButton.icon(
              onPressed: () async {
                await HapticService.buttonClick();
                if (mounted) {
                  context.read<TermsConditionsBloc>().add(LoadTermsConditions());
                }
              },
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(
                alpha: isDark ? 0.7 : 0.5,
              ),
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              AppLocalizations.of(context)!.noTermsAvailable,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Text(
              AppLocalizations.of(context)!.noTermsAvailableDescription,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


