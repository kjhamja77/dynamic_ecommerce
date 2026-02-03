import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../constants/responsive_constants.dart';

class HtmlContentWidget extends StatelessWidget {
  final String htmlContent;
  final EdgeInsetsGeometry? padding;

  const HtmlContentWidget({
    super.key,
    required this.htmlContent,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onBackground;
    final headingColor = colorScheme.onBackground;
    final linkColor = colorScheme.primary;
    
    return Container(
      padding: padding ?? EdgeInsets.all(ResponsiveConstants.lgPadding),
      child: Html(
        data: htmlContent,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(ResponsiveConstants.mdFontSize),
            fontFamily: 'Poppins',
            color: textColor,
            lineHeight: LineHeight(1.6),
          ),
          "p": Style(
            margin: Margins.only(bottom: ResponsiveConstants.mdSpacing),
            fontSize: FontSize(ResponsiveConstants.mdFontSize),
            color: textColor,
            lineHeight: LineHeight(1.6),
          ),
          "h1, h2, h3, h4, h5, h6": Style(
            margin: Margins.only(
              top: ResponsiveConstants.lgSpacing,
              bottom: ResponsiveConstants.mdSpacing,
            ),
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
          "h1": Style(
            fontSize: FontSize(ResponsiveConstants.xlFontSize),
            margin: Margins.only(
              top: ResponsiveConstants.xlSpacing,
              bottom: ResponsiveConstants.lgSpacing,
            ),
          ),
          "h2": Style(
            fontSize: FontSize(ResponsiveConstants.lgFontSize),
          ),
          "h3": Style(
            fontSize: FontSize(ResponsiveConstants.mdFontSize + 2),
          ),
          "ul, ol": Style(
            margin: Margins.only(
              left: ResponsiveConstants.mdSpacing,
              bottom: ResponsiveConstants.mdSpacing,
            ),
          ),
          "li": Style(
            margin: Margins.only(bottom: ResponsiveConstants.xsSpacing),
            fontSize: FontSize(ResponsiveConstants.mdFontSize),
            color: textColor,
            lineHeight: LineHeight(1.6),
          ),
          "strong, b": Style(
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
          "em, i": Style(
            fontStyle: FontStyle.italic,
          ),
          "a": Style(
            color: linkColor,
            textDecoration: TextDecoration.underline,
          ),
        },
      ),
    );
  }
}
