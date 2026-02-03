import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class ProductCareSection extends StatelessWidget {
  final List<String> careInstructions;
  final List<String> materials;
  final String countryOfOrigin;

  const ProductCareSection({
    super.key,
    this.careInstructions = const [],
    this.materials = const [],
    this.countryOfOrigin = 'Turkey',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Care Instructions
        _buildSection(
          title: AppLocalizations.of(context)!.careInstructions,
          icon: Icons.local_laundry_service,
          iconColor: Colors.blue.shade600,
          items: _getDefaultCareInstructions(context),
        ),

        SizedBox(height: ResponsiveConstants.lgSpacing),

        // Materials
        _buildSection(
          title: AppLocalizations.of(context)!.materialsAndComposition,
          icon: Icons.texture,
          iconColor: Colors.green.shade600,
          items: _getDefaultMaterials(),
        ),

        SizedBox(height: ResponsiveConstants.lgSpacing),

        // Origin & Sustainability
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(
                        ResponsiveConstants.smRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.public,
                      color: Colors.green.shade700,
                      size: ResponsiveConstants.mdIconSize,
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Text(
                    AppLocalizations.of(context)!.originAndSustainability,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.mdSpacing),

              _infoRow(Icons.location_on, AppLocalizations.of(context)!.madeIn, countryOfOrigin),
              _infoRow(Icons.eco, AppLocalizations.of(context)!.ecoFriendly, AppLocalizations.of(context)!.sustainableMaterialsUsed),
              _infoRow(
                Icons.recycling,
                AppLocalizations.of(context)!.recyclable,
                'Packaging is 100% recyclable',
              ),
              _infoRow(Icons.verified, AppLocalizations.of(context)!.certified, AppLocalizations.of(context)!.oekoTextStandard100),
            ],
          ),
        ),

        SizedBox(height: ResponsiveConstants.lgSpacing),

        // Size & Fit Guide
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(
                        ResponsiveConstants.smRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.straighten,
                      color: Colors.blue.shade700,
                      size: ResponsiveConstants.mdIconSize,
                    ),
                  ),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Text(
                    AppLocalizations.of(context)!.sizeAndFitInformation,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveConstants.mdSpacing),

              _infoRow(Icons.height, AppLocalizations.of(context)!.fit, AppLocalizations.of(context)!.regularFit),
              _infoRow(
                Icons.person,
                AppLocalizations.of(context)!.modelSize,
                'Model is 178cm and wears size M',
              ),

              SizedBox(height: ResponsiveConstants.smSpacing),

              GestureDetector(
                onTap: () async {
          await HapticService.buttonClick();
          _showSizeGuide(context);
        },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.smPadding,
                    vertical: ResponsiveConstants.xsPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(
                      ResponsiveConstants.smRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.straighten,
                        color: Colors.white,
                        size: ResponsiveConstants.smIconSize,
                      ),
                      SizedBox(width: ResponsiveConstants.xsSpacing),
                      Text(
                        AppLocalizations.of(context)!.viewSizeGuide,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.smRadius,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Text(
                title,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveConstants.mdSpacing),

          ...items.map((item) => _bulletPoint(item)),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Text(
              text,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveConstants.smIconSize,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Text(
            '$label: ',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getDefaultCareInstructions(BuildContext context) {
    if (careInstructions.isNotEmpty) return careInstructions;

    return [
      'Machine wash cold (30°C max)',
      AppLocalizations.of(context)!.doNotBleach,
      AppLocalizations.of(context)!.tumbleDryLowHeat,
      'Iron on low temperature',
      'Do not dry clean',
      'Wash with similar colors',
      'Turn inside out before washing',
    ];
  }

  List<String> _getDefaultMaterials() {
    if (materials.isNotEmpty) return materials;

    return [
      '100% Cotton',
      'Pre-shrunk fabric',
      'Soft and breathable',
      'Hypoallergenic materials',
      'Durable construction',
      'Color-fast dyes',
    ];
  }

  void _showSizeGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveConstants.lgRadius),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),

              Text(
                'Size Guide',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ResponsiveConstants.mdSpacing),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Size chart table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            ResponsiveConstants.smRadius,
                          ),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                              ),
                              children:
                                  [
                                        'Size',
                                        'Chest (cm)',
                                        'Waist (cm)',
                                        'Length (cm)',
                                      ]
                                      .map(
                                        (header) => Padding(
                                          padding: EdgeInsets.all(
                                            ResponsiveConstants.smPadding,
                                          ),
                                          child: Text(
                                            header,
                                            style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                                              fontSize: ResponsiveConstants
                                                  .smFontSize,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            ...List.generate(5, (index) {
                              final sizeLabels = ['XS', 'S', 'M', 'L', 'XL'];
                              final measurements = [
                                ['76-81', '66-71', '68'],
                                ['82-87', '72-77', '70'],
                                ['88-93', '78-83', '72'],
                                ['94-99', '84-89', '74'],
                                ['100-105', '90-95', '76'],
                              ];
                              return TableRow(
                                children:
                                    [sizeLabels[index], ...measurements[index]]
                                        .map(
                                          (cell) => Padding(
                                            padding: EdgeInsets.all(
                                              ResponsiveConstants.smPadding,
                                            ),
                                            child: Text(
                                              cell.toString(),
                                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants
                                                    .smFontSize,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              );
                            }),
                          ],
                        ),
                      ),

                      SizedBox(height: ResponsiveConstants.lgSpacing),

                      // Measuring tips
                      Container(
                        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(
                            ResponsiveConstants.smRadius,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to measure',
                              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                                fontSize: ResponsiveConstants.mdFontSize,
                              ),
                            ),
                            SizedBox(height: ResponsiveConstants.smSpacing),
                            Text(
                              '• Chest: Measure around the fullest part of your chest\n'
                              '• Waist: Measure around your natural waistline\n'
                              '• Length: Measure from shoulder to desired length',
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
