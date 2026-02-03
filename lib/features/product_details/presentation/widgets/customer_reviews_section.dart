import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerReviewsSection extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final List<ReviewSummary> reviews;

  const CustomerReviewsSection({
    super.key,
    this.averageRating = 4.5,
    this.totalReviews = 247,
    this.reviews = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.customerReviews,
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () async {
          await HapticService.buttonClick();
          _showAllReviews(context);
        },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Rating summary
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Overall rating
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.headlineFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade600,
                          size: ResponsiveConstants.smIconSize,
                        );
                      }),
                    ),
                    SizedBox(height: ResponsiveConstants.xsSpacing),
                    Text(
                      '$totalReviews reviews',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: ResponsiveConstants.lgSpacing),
                
                // Rating breakdown
                Expanded(
                  child: Column(
                    children: [
                      _ratingBar(5, 156, totalReviews),
                      _ratingBar(4, 72, totalReviews),
                      _ratingBar(3, 15, totalReviews),
                      _ratingBar(2, 3, totalReviews),
                      _ratingBar(1, 1, totalReviews),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.lgSpacing),
          
          // Review highlights
          Text(
            AppLocalizations.of(context)!.whatCustomersAreSaying,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // Sample reviews
          ...(_getSampleReviews().take(3).map((review) => _reviewCard(review, context))),
          
          SizedBox(height: ResponsiveConstants.mdSpacing),
          
          // View all reviews button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
          await HapticService.buttonClick();
          _showAllReviews(context);
        },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
              ),
              child: Text(
                'Read All $totalReviews Reviews',
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBar(int stars, int count, int total) {
    final percentage = (count / total);
    
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.xsSpacing),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: ResponsiveConstants.xsSpacing),
          Icon(
            Icons.star,
            size: ResponsiveConstants.xsIconSize,
            color: Colors.amber.shade600,
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Text(
            '$count',
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(ReviewSummary review, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  review.reviewerName[0].toUpperCase(),
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.smSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 12,
                          );
                        }),
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                        Text(
                          review.timeAgo,
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Review content
          Text(
            review.comment,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          
          if (review.isVerifiedPurchase) ...[
            SizedBox(height: ResponsiveConstants.smSpacing),
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green.shade600,
                  size: ResponsiveConstants.xsIconSize,
                ),
                SizedBox(width: ResponsiveConstants.xsSpacing),
                Text(
                  AppLocalizations.of(context)!.verifiedPurchase,
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<ReviewSummary> _getSampleReviews() {
    return [
      ReviewSummary(
        reviewerName: 'Sarah M.',
        rating: 5,
        comment: 'Amazing quality! The fit is perfect and the material feels premium. Definitely worth the price.',
        timeAgo: '2 days ago',
        isVerifiedPurchase: true,
      ),
      ReviewSummary(
        reviewerName: 'Michael K.',
        rating: 4,
        comment: 'Good product overall. Fast delivery and exactly as described. Would recommend to others.',
        timeAgo: '1 week ago',
        isVerifiedPurchase: true,
      ),
      ReviewSummary(
        reviewerName: 'Emma L.',
        rating: 5,
        comment: 'Love this! Received so many compliments. The color is exactly as shown in the pictures.',
        timeAgo: '2 weeks ago',
        isVerifiedPurchase: false,
      ),
    ];
  }

  void _showAllReviews(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.customerReviews,
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            itemCount: _getSampleReviews().length,
            itemBuilder: (context, index) {
              return _reviewCard(_getSampleReviews()[index], context);
            },
          ),
        ),
      ),
    );
  }
}

class ReviewSummary {
  final String reviewerName;
  final int rating;
  final String comment;
  final String timeAgo;
  final bool isVerifiedPurchase;

  ReviewSummary({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.isVerifiedPurchase,
  });
}
