import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/onboarding_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingPage page;
  final bool isLastPage;

  const OnboardingContent({
    super.key,
    required this.page,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Section – flexible so it shrinks when text grows
          Flexible(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                child: _buildCachedImage(page.image ?? ''),
              ),
            ),
          ),

          SizedBox(height: ResponsiveConstants.xlSpacing),

          // Text Content Section – no ellipsis on title, text takes the space it needs
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                page.name,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.headlineFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),
              Text(
                page.description ?? '',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.lgFontSize,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCachedImage(String rawUrl) {
    // Accept assets, absolute URLs, and relative server paths like "/web/image/..."
    if (rawUrl.startsWith('assets/')) {
      return Image.asset(
        rawUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final String resolvedUrl = rawUrl.startsWith('http')
        ? rawUrl
        : (rawUrl.startsWith('/')
            ? (AppConstants.baseUrl.endsWith('/')
                ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1) + rawUrl
                : AppConstants.baseUrl + rawUrl)
            : AppConstants.baseUrl + '/' + rawUrl);

    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: ResponsiveConstants.mdIconSize,
                height: ResponsiveConstants.mdIconSize,
                child: CircularProgressIndicator(
                  strokeWidth: ResponsiveConstants.loadingIndicatorStrokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                ),
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(context)!.loading,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: ResponsiveConstants.smFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveConstants.xlIconSize,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              Text(
                AppLocalizations.of(context)!.failedToLoadImage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: ResponsiveConstants.smFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveConstants.xsSpacing),
              Text(
                'URL: ${url.length > 50 ? '${url.substring(0, 50)}...' : url}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: ResponsiveConstants.xsFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}
