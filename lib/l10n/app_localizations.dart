import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In ar, this message translates to:
  /// **'كردوسي'**
  String get appTitle;

  /// Welcome message
  ///
  /// In ar, this message translates to:
  /// **'مرحباً،'**
  String get welcome;

  /// Sign in prompt text
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول؟'**
  String get signInPrompt;

  /// Promotional message for sign in
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لفتح العروض'**
  String get signInToUnlockDeals;

  /// Free delivery promotion
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني لأكثر من 29.90 يورو'**
  String get freeDeliveryOver;

  /// New arrivals promotion
  ///
  /// In ar, this message translates to:
  /// **'وصلات جديدة يومياً'**
  String get newArrivalsDaily;

  /// Discount promotion
  ///
  /// In ar, this message translates to:
  /// **'خصم إضافي 20% على الأنماط المختارة'**
  String get extraOffSelectedStyles;

  /// General error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWentWrong;

  /// Message when no products are found
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات متاحة'**
  String get noProductsAvailable;

  /// Settings menu item
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// Language and region settings
  ///
  /// In ar, this message translates to:
  /// **'اللغة والمنطقة'**
  String get languageRegion;

  /// Appearance settings
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// Notifications page title
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// App settings section
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التطبيق'**
  String get appSettings;

  /// About section
  ///
  /// In ar, this message translates to:
  /// **'حول'**
  String get about;

  /// Language selection prompt
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// Message shown while changing language
  ///
  /// In ar, this message translates to:
  /// **'جاري تغيير اللغة...'**
  String get changingLanguage;

  /// Success message after language change
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة بنجاح!'**
  String get languageChanged;

  /// Error message when language change fails
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تغيير اللغة. يرجى المحاولة مرة أخرى.'**
  String get errorChangingLanguage;

  /// Special offers section title
  ///
  /// In ar, this message translates to:
  /// **'عروض خاصة'**
  String get specialOffers;

  /// Special offers section subtitle
  ///
  /// In ar, this message translates to:
  /// **'عروض محدودة الوقت'**
  String get limitedTimeDeals;

  /// Flash sale offer title
  ///
  /// In ar, this message translates to:
  /// **'بيع سريع'**
  String get flashSale;

  /// New customer offer title
  ///
  /// In ar, this message translates to:
  /// **'عميل جديد'**
  String get newCustomer;

  /// Weekend special offer title
  ///
  /// In ar, this message translates to:
  /// **'عرض نهاية الأسبوع'**
  String get weekendSpecial;

  /// Free price label
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get free;

  /// Limited time label
  ///
  /// In ar, this message translates to:
  /// **'وقت محدود'**
  String get limitedTime;

  /// Select options prompt
  ///
  /// In ar, this message translates to:
  /// **'اختر الخيارات'**
  String get selectOptions;

  /// Error message when page fails to load
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الصفحة'**
  String get errorLoadingPage;

  /// Retry button text
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// Error message when pages fail to load
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الصفحات'**
  String get errorLoadingPages;

  /// Message when no pages are available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صفحات متاحة'**
  String get noPagesAvailable;

  /// Message when price range is not available
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر غير متاح'**
  String get priceRangeNotAvailable;

  /// Sort by label
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sortBy;

  /// Apply button text
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// All option label
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// Guest login button text
  ///
  /// In ar, this message translates to:
  /// **'متابعة كضيف'**
  String get continueAsGuest;

  /// Guest user label
  ///
  /// In ar, this message translates to:
  /// **'ضيف'**
  String get guest;

  /// Guest user title
  ///
  /// In ar, this message translates to:
  /// **'مستخدم ضيف'**
  String get guestUser;

  /// Guest mode label
  ///
  /// In ar, this message translates to:
  /// **'وضع الضيف'**
  String get guestMode;

  /// Prompt to sign in for full features
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لفتح جميع الميزات'**
  String get signInToUnlockFeatures;

  /// Guest limitations notice
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون الضيوف لديهم وصول محدود لبعض الميزات'**
  String get guestLimitations;

  /// Register page title
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// Login prompt for existing users
  ///
  /// In ar, this message translates to:
  /// **'هل لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// Sign in link text
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول الآن'**
  String get signInNow;

  /// Guest checkout option
  ///
  /// In ar, this message translates to:
  /// **'الدفع كضيف'**
  String get guestCheckout;

  /// Promotional message for sign in
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لتجربة تسوق أفضل'**
  String get signInForBetterExperience;

  /// Guest favorites limitation
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لحفظ المفضلة'**
  String get guestFavorites;

  /// Guest cart limitation notice
  ///
  /// In ar, this message translates to:
  /// **'سيتم حفظ عربة التسوق محلياً'**
  String get guestCart;

  /// Guest profile limitation
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول للوصول إلى ملفك الشخصي'**
  String get guestProfile;

  /// Theme section title
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// Light theme option
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// Dark theme option
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// System theme option
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// Light theme description
  ///
  /// In ar, this message translates to:
  /// **'استخدام المظهر الفاتح'**
  String get useLightTheme;

  /// Dark theme description
  ///
  /// In ar, this message translates to:
  /// **'استخدام المظهر الداكن'**
  String get useDarkTheme;

  /// System theme description
  ///
  /// In ar, this message translates to:
  /// **'اتباع مظهر النظام'**
  String get followSystemTheme;

  /// Push notifications setting
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات الفورية'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In ar, this message translates to:
  /// **'استقبال الإشعارات الفورية'**
  String get receivePushNotifications;

  /// Email notifications setting
  ///
  /// In ar, this message translates to:
  /// **'إشعارات البريد الإلكتروني'**
  String get emailNotifications;

  /// Email notifications description
  ///
  /// In ar, this message translates to:
  /// **'استقبل إشعارات البريد الإلكتروني'**
  String get receiveEmailNotifications;

  /// Sound setting
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get sound;

  /// Sound setting description
  ///
  /// In ar, this message translates to:
  /// **'شغل الصوت للإشعارات'**
  String get playSoundForNotifications;

  /// Vibration setting
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get vibration;

  /// Vibration setting description
  ///
  /// In ar, this message translates to:
  /// **'اهتز للإشعارات'**
  String get vibrateForNotifications;

  /// Auto update setting
  ///
  /// In ar, this message translates to:
  /// **'التحديث التلقائي'**
  String get autoUpdate;

  /// Auto update description
  ///
  /// In ar, this message translates to:
  /// **'حدث التطبيق تلقائياً'**
  String get automaticallyUpdateTheApp;

  /// Location services setting
  ///
  /// In ar, this message translates to:
  /// **'خدمات الموقع'**
  String get locationServices;

  /// Location services description
  ///
  /// In ar, this message translates to:
  /// **'اسمح للتطبيق بالوصول للموقع'**
  String get allowAppToAccessLocation;

  /// Analytics setting
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get analytics;

  /// Analytics description
  ///
  /// In ar, this message translates to:
  /// **'ساعد في تحسين التطبيق بالتحليلات'**
  String get helpImproveTheAppWithAnalytics;

  /// App version label
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// Privacy policy link text
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// Privacy policy description
  ///
  /// In ar, this message translates to:
  /// **'اقرأ سياسة الخصوصية'**
  String get readOurPrivacyPolicy;

  /// Terms of service link text
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfService;

  /// Terms of service description
  ///
  /// In ar, this message translates to:
  /// **'اقرأ شروط الخدمة'**
  String get readOurTermsOfService;

  /// Home address label
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get home;

  /// Search button text
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// Favorites tab label
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// Cart tab label
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cart;

  /// Profile page title
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// Add to cart button text
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get addToCart;

  /// Remove from cart button text
  ///
  /// In ar, this message translates to:
  /// **'احذف من السلة'**
  String get removeFromCart;

  /// Add to favorites button text
  ///
  /// In ar, this message translates to:
  /// **'أضف للمفضلة'**
  String get addToFavorites;

  /// Remove from favorites button text
  ///
  /// In ar, this message translates to:
  /// **'احذف من المفضلة'**
  String get removeFromFavorites;

  /// Price label
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// Quantity field label
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// Size attribute label
  ///
  /// In ar, this message translates to:
  /// **'المقاس'**
  String get size;

  /// Color attribute label
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get color;

  /// Selected label for options
  ///
  /// In ar, this message translates to:
  /// **'المحدد'**
  String get selected;

  /// Brand filter section header
  ///
  /// In ar, this message translates to:
  /// **'العلامة التجارية'**
  String get brand;

  /// Category filter section header
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// Rating sort option
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get rating;

  /// Reviews label
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// Description label
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// Loading text
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// Error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// Cancel button text
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Confirm button text
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// Save button text
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// Edit button text
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// Delete button text
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// Back button text
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// Next button text
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// Previous button text
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// Skip button text for onboarding
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// Get started button text for onboarding
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// Error message when image fails to load
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الصورة'**
  String get failedToLoadImage;

  /// Error message for onboarding loading failure
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل التعريف'**
  String get onboardingError;

  /// Done button text
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// Search results page title
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث'**
  String get searchResults;

  /// Empty state message when no products found
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على منتجات'**
  String get noProductsFound;

  /// Suggestion when no search results found
  ///
  /// In ar, this message translates to:
  /// **'جرب مصطلحات بحث مختلفة أو فلتر'**
  String get tryDifferentSearchTerms;

  /// End of search results message
  ///
  /// In ar, this message translates to:
  /// **'لقد وصلت إلى النهاية'**
  String get endOfResults;

  /// Filters page title
  ///
  /// In ar, this message translates to:
  /// **'الفلتر'**
  String get filters;

  /// Message for upcoming advanced filters
  ///
  /// In ar, this message translates to:
  /// **'الفلتر المتقدمة قادمة قريباً!'**
  String get advancedFiltersComingSoon;

  /// Clear all button text
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAll;

  /// On sale filter option
  ///
  /// In ar, this message translates to:
  /// **'في التخفيض'**
  String get onSale;

  /// In stock filter option
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStock;

  /// New arrivals filter
  ///
  /// In ar, this message translates to:
  /// **'وصلات جديدة'**
  String get newArrivals;

  /// Trending filter
  ///
  /// In ar, this message translates to:
  /// **'رائج'**
  String get trending;

  /// Search input hint text
  ///
  /// In ar, this message translates to:
  /// **'البحث عن المنتجات...'**
  String get searchHint;

  /// Empty search state title
  ///
  /// In ar, this message translates to:
  /// **'ابدأ البحث'**
  String get startSearching;

  /// Empty search state description
  ///
  /// In ar, this message translates to:
  /// **'أدخل مصطلح البحث أعلاه للعثور على المنتجات'**
  String get enterSearchTerm;

  /// Popular searches section title
  ///
  /// In ar, this message translates to:
  /// **'البحث الشائع'**
  String get popularSearches;

  /// Recent searches section title
  ///
  /// In ar, this message translates to:
  /// **'البحث الأخير'**
  String get recentSearches;

  /// Close button text
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// Open button text
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get open;

  /// View button text
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get view;

  /// Share button text
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// Copy button text
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// Paste button text
  ///
  /// In ar, this message translates to:
  /// **'لصق'**
  String get paste;

  /// Select button text
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get select;

  /// Select all button text
  ///
  /// In ar, this message translates to:
  /// **'اختيار الكل'**
  String get selectAll;

  /// Clear button text
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// Reset button text
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// Refresh button text
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No search results message
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نتائج'**
  String get noResultsFound;

  /// Try again button text
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// Network error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الشبكة'**
  String get networkError;

  /// Server error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get serverError;

  /// Unknown error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير معروف'**
  String get unknownError;

  /// Success message
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get success;

  /// Item added to cart success message
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العنصر للسلة'**
  String get itemAddedToCart;

  /// Item removed from cart success message
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العنصر من السلة'**
  String get itemRemovedFromCart;

  /// Item added to favorites success message
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العنصر للمفضلة'**
  String get itemAddedToFavorites;

  /// Item removed from favorites success message
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العنصر من المفضلة'**
  String get itemRemovedFromFavorites;

  /// Empty cart message
  ///
  /// In ar, this message translates to:
  /// **'سلتك فارغة'**
  String get cartIsEmpty;

  /// Empty favorites message
  ///
  /// In ar, this message translates to:
  /// **'قائمة المفضلة فارغة'**
  String get favoritesIsEmpty;

  /// Empty favorites description message
  ///
  /// In ar, this message translates to:
  /// **'ابدأ ببناء قائمة أمنياتك بإضافة المنتجات التي تحبها إلى المفضلة.'**
  String get favoritesEmptyDescription;

  /// Total label in cart summary
  ///
  /// In ar, this message translates to:
  /// **'المجموع: '**
  String get total;

  /// Subtotal label in cart summary
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي: '**
  String get subtotal;

  /// Tax label
  ///
  /// In ar, this message translates to:
  /// **'الضريبة'**
  String get tax;

  /// Shipping label
  ///
  /// In ar, this message translates to:
  /// **'الشحن'**
  String get shipping;

  /// Discount label
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get discount;

  /// Number of search results
  ///
  /// In ar, this message translates to:
  /// **'نتيجة'**
  String get results;

  /// Sort button tooltip
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// Filter and sort button tooltip
  ///
  /// In ar, this message translates to:
  /// **'تصفية وترتيب'**
  String get filterAndSort;

  /// Price under 50 filter
  ///
  /// In ar, this message translates to:
  /// **'أقل من 50'**
  String get under50;

  /// Minimum price prefix
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get min;

  /// Maximum price prefix
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى'**
  String get max;

  /// On sale filter chip
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get onSaleFilter;

  /// In stock filter chip
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStockFilter;

  /// Message to scroll for more products
  ///
  /// In ar, this message translates to:
  /// **'مرر لتحميل المزيد'**
  String get scrollToLoadMore;

  /// End of products message
  ///
  /// In ar, this message translates to:
  /// **'لقد وصلت إلى النهاية'**
  String get youHaveReachedTheEnd;

  /// Featured sort option
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get featured;

  /// Price low to high sort option
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأقل للأعلى'**
  String get priceLowToHigh;

  /// Price high to low sort option
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأعلى للأقل'**
  String get priceHighToLow;

  /// Newest sort option
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// Recommendations section title
  ///
  /// In ar, this message translates to:
  /// **'موصى لك'**
  String get recommendedForYou;

  /// Price low to high sort subtitle
  ///
  /// In ar, this message translates to:
  /// **'أفضل العروض أولاً'**
  String get bestDealsFirst;

  /// Price high to low sort subtitle
  ///
  /// In ar, this message translates to:
  /// **'الاختيارات المميزة أولاً'**
  String get premiumPicksFirst;

  /// Newest sort subtitle
  ///
  /// In ar, this message translates to:
  /// **'أحدث الوصولات'**
  String get latestArrivals;

  /// Editor's picks subtitle for sort options
  ///
  /// In ar, this message translates to:
  /// **'اختيارات المحررين'**
  String get editorsPicks;

  /// Rating sort subtitle
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييماً'**
  String get topRated;

  /// عنوان قسم الفئات المميزة في الصفحة الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'فئات مميزة'**
  String get featuredCategories;

  /// Checkout page title
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get checkout;

  /// Continue shopping button text
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسوق'**
  String get continueShopping;

  /// View cart button text
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة'**
  String get viewCart;

  /// Proceed to checkout button text
  ///
  /// In ar, this message translates to:
  /// **'المتابعة للدفع'**
  String get proceedToCheckout;

  /// Order summary title
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get orderSummary;

  /// Payment method section header
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// Shipping address section header
  ///
  /// In ar, this message translates to:
  /// **'عنوان الشحن'**
  String get shippingAddress;

  /// Billing address label
  ///
  /// In ar, this message translates to:
  /// **'عنوان الفواتير'**
  String get billingAddress;

  /// Order confirmation title
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get orderConfirmation;

  /// Thank you message after order
  ///
  /// In ar, this message translates to:
  /// **'شكراً لك على طلبك!'**
  String get thankYouForYourOrder;

  /// Order number label
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumber;

  /// Estimated delivery label
  ///
  /// In ar, this message translates to:
  /// **'التسليم المتوقع'**
  String get estimatedDelivery;

  /// Track order button text
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب'**
  String get trackOrder;

  /// Order history title
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلبات'**
  String get orderHistory;

  /// My orders menu item
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// Title for the order items section
  ///
  /// In ar, this message translates to:
  /// **'عناصر الطلب'**
  String get orderItemsTitle;

  /// Subtitle showing how many items were ordered
  ///
  /// In ar, this message translates to:
  /// **'لقد طلبت {count, plural, zero {0 عنصر} one {عنصرًا واحدًا} two {عنصرين} few {# عناصر} many {# عنصرًا} other {# عنصر}}'**
  String orderItemsSubtitle(num count);

  /// Order timeline section title
  ///
  /// In ar, this message translates to:
  /// **'تقدم الطلب'**
  String get orderProgress;

  /// Timeline label when order is placed
  ///
  /// In ar, this message translates to:
  /// **'تم وضع الطلب'**
  String get orderPlaced;

  /// Timeline label when order is confirmed
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الطلب'**
  String get orderConfirmed;

  /// Label for when the order was placed
  ///
  /// In ar, this message translates to:
  /// **'تم وضع الطلب في {date}'**
  String orderPlacedOn(String date);

  /// Label for order date
  ///
  /// In ar, this message translates to:
  /// **'تم الطلب في {date}'**
  String orderedOn(String date);

  /// Formats a date and time string
  ///
  /// In ar, this message translates to:
  /// **'{date} في {time}'**
  String dateAtTime(String date, String time);

  /// Relative time string for yesterday
  ///
  /// In ar, this message translates to:
  /// **'أمس في {time}'**
  String yesterdayAt(String time);

  /// Relative time string for current moment
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// Relative time string for minutes ago
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero {منذ 0 دقيقة} one {منذ دقيقة واحدة} two {منذ دقيقتين} few {منذ # دقائق} many {منذ # دقيقة} other {منذ # دقيقة}}'**
  String minutesAgo(int count);

  /// Relative time string for hours ago
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero {منذ 0 ساعة} one {منذ ساعة واحدة} two {منذ ساعتين} few {منذ # ساعات} many {منذ # ساعة} other {منذ # ساعة}}'**
  String hoursAgo(int count);

  /// Relative time string for days ago
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero {منذ 0 يوم} one {منذ يوم واحد} two {منذ يومين} few {منذ # أيام} many {منذ # يوم} other {منذ # يوم}}'**
  String daysAgo(int count);

  /// Displays the number of items
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero {0 عنصر} one {# عنصر} two {# عنصران} few {# عناصر} many {# عنصر} other {# عنصر}}'**
  String itemsCount(int count);

  /// Label for total amount
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get totalAmount;

  /// Shipping and delivery section title
  ///
  /// In ar, this message translates to:
  /// **'الشحن والتسليم'**
  String get shippingAndDelivery;

  /// Delivery address label
  ///
  /// In ar, this message translates to:
  /// **'عنوان التسليم'**
  String get deliveryAddress;

  /// Tracking number label
  ///
  /// In ar, this message translates to:
  /// **'رقم التتبع'**
  String get trackingNumber;

  /// Delivered on label
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم في'**
  String get deliveredOn;

  /// Message shown when order is shipped
  ///
  /// In ar, this message translates to:
  /// **'طلبك في الطريق! تتبعه باستخدام رقم التتبع أعلاه.'**
  String get orderOnWayMessage;

  /// CTA for order help button
  ///
  /// In ar, this message translates to:
  /// **'تحتاج مساعدة؟'**
  String get needHelp;

  /// Help sheet header
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكننا مساعدتك؟'**
  String get howCanWeHelp;

  /// Displays the order number
  ///
  /// In ar, this message translates to:
  /// **'الطلب رقم {orderNumber}'**
  String orderNumberWithValue(String orderNumber);

  /// Call customer service option
  ///
  /// In ar, this message translates to:
  /// **'اتصل بخدمة العملاء'**
  String get callCustomerService;

  /// WhatsApp support option
  ///
  /// In ar, this message translates to:
  /// **'دعم واتساب'**
  String get whatsappSupport;

  /// Subtitle for chat option
  ///
  /// In ar, this message translates to:
  /// **'تحدث معنا فورًا'**
  String get chatWithUsInstantly;

  /// Request return option
  ///
  /// In ar, this message translates to:
  /// **'طلب إرجاع'**
  String get requestReturn;

  /// Subtitle for return option
  ///
  /// In ar, this message translates to:
  /// **'إرجاع هذا الطلب'**
  String get returnThisOrder;

  /// Phone error message
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح تطبيق الهاتف'**
  String get couldNotLaunchPhoneDialer;

  /// WhatsApp error message
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح واتساب'**
  String get couldNotOpenWhatsapp;

  /// Default WhatsApp help message
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، أحتاج مساعدة بخصوص الطلب رقم {orderNumber}'**
  String whatsappOrderHelpMessage(String orderNumber);

  /// WhatsApp return request message
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، أود طلب إرجاع للطلب رقم {orderNumber}'**
  String whatsappReturnMessage(String orderNumber);

  /// Filter by status label
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الحالة'**
  String get filterByStatus;

  /// Payment status label
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get paymentStatus;

  /// Payment details section title
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدفع'**
  String get paymentDetails;

  /// Payment success message
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح'**
  String get paymentCompletedSuccessfully;

  /// Back to orders button label
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الطلبات'**
  String get backToOrders;

  /// Cancel order confirmation question
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get cancelOrderQuestion;

  /// Keep order button label
  ///
  /// In ar, this message translates to:
  /// **'لا، احتفظ بالطلب'**
  String get keepOrder;

  /// Confirm cancel order button label
  ///
  /// In ar, this message translates to:
  /// **'نعم، إلغاء الطلب'**
  String get confirmCancelOrder;

  /// Order status label
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get orderStatus;

  /// Order status - pending
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get pending;

  /// Order status - processing
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get processing;

  /// Order status - shipped
  ///
  /// In ar, this message translates to:
  /// **'تم الشحن'**
  String get shipped;

  /// Order status - delivered
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get delivered;

  /// Order status - cancelled
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// Order status - returned
  ///
  /// In ar, this message translates to:
  /// **'مُرجع'**
  String get returned;

  /// Paid payment status
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get paid;

  /// Failed payment status
  ///
  /// In ar, this message translates to:
  /// **'فشل'**
  String get failed;

  /// Refunded payment status
  ///
  /// In ar, this message translates to:
  /// **'مسترد'**
  String get refunded;

  /// Cancel order button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelOrder;

  /// Loading image message
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الصورة...'**
  String get loadingImage;

  /// Loading recommendations message
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل التوصيات...'**
  String get loadingRecommendations;

  /// Loading category details message
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل تفاصيل الفئة...'**
  String get loadingCategoryDetails;

  /// OK button text
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// Remove button text
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// Details button text
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// Save items for later subtitle
  ///
  /// In ar, this message translates to:
  /// **'احفظ العناصر لاحقاً'**
  String get saveItemsForLater;

  /// Find great offers subtitle
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن العروض الرائعة'**
  String get findGreatOffers;

  /// Deals section title
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get deals;

  /// Search bar hint text
  ///
  /// In ar, this message translates to:
  /// **'ماذا تبحث عنه؟'**
  String get whatAreYouLookingFor;

  /// New badge text
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newBadge;

  /// No description provided for @optionalItems.
  ///
  /// In ar, this message translates to:
  /// **'عناصر اختيارية'**
  String get optionalItems;

  /// No description provided for @alternativeItems.
  ///
  /// In ar, this message translates to:
  /// **'عناصر بديلة'**
  String get alternativeItems;

  /// Out of stock label
  ///
  /// In ar, this message translates to:
  /// **'نفد من المخزون'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'كمية محدودة'**
  String get lowStock;

  /// No description provided for @availableCount.
  ///
  /// In ar, this message translates to:
  /// **'({count} متاح)'**
  String availableCount(Object count);

  /// Welcome back message on login page
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك!'**
  String get welcomeBack;

  /// Subtitle on login page
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لمتابعة التسوق'**
  String get signInToContinueShopping;

  /// Email label
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// Phone label
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// Email input hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get enterYourEmail;

  /// Phone number field hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك'**
  String get enterYourPhoneNumber;

  /// Phone number field label
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// Password label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// Password input hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterYourPassword;

  /// Email validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريدك الإلكتروني'**
  String get pleaseEnterYourEmail;

  /// Email format validation
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get pleaseEnterValidEmail;

  /// Phone number validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتفك'**
  String get pleaseEnterYourPhoneNumber;

  /// Phone number format validation
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح'**
  String get pleaseEnterValidPhoneNumber;

  /// Password validation error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get pleaseEnterYourPassword;

  /// Password length validation error
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون كلمة المرور 6 أحرف على الأقل'**
  String get passwordMustBeAtLeast6Characters;

  /// Forgot password link
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// Sign in loading state
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول...'**
  String get signingIn;

  /// Sign in link text
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// Divider text between registration options
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// Google sign up button text
  ///
  /// In ar, this message translates to:
  /// **'جوجل'**
  String get google;

  /// Apple sign up button text
  ///
  /// In ar, this message translates to:
  /// **'أبل'**
  String get apple;

  /// Phone login not supported message
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بالهاتف غير مدعوم بعد'**
  String get phoneLoginNotSupportedYet;

  /// Fingerprint authentication button
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بالبصمة'**
  String get signInWithFingerprint;

  /// Face ID authentication button
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بوجهك'**
  String get signInWithFaceId;

  /// Biometric authentication loading state
  ///
  /// In ar, this message translates to:
  /// **'جاري التحقق...'**
  String get authenticating;

  /// Biometric authentication error
  ///
  /// In ar, this message translates to:
  /// **'فشل التحقق البيومتري'**
  String get biometricAuthenticationFailed;

  /// Sign up prompt text
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ '**
  String get dontHaveAnAccount;

  /// Sign up button text
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// Sign up page subtitle
  ///
  /// In ar, this message translates to:
  /// **'انضم إلينا لبدء رحلة التسوق'**
  String get joinUsToStartShopping;

  /// First name field label
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get firstName;

  /// Last name field label
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get lastName;

  /// First name field hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الأول'**
  String get enterYourFirstName;

  /// Last name field hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الأخير'**
  String get enterYourLastName;

  /// Confirm password field label
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// Confirm password input hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل تأكيد كلمة المرور'**
  String get enterConfirmPassword;

  /// First name validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسمك الأول'**
  String get pleaseEnterYourFirstName;

  /// Last name validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسمك الأخير'**
  String get pleaseEnterYourLastName;

  /// Confirm password validation error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال تأكيد كلمة المرور'**
  String get pleaseEnterConfirmPassword;

  /// Password match validation
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// Account creation loading text
  ///
  /// In ar, this message translates to:
  /// **'جاري إنشاء الحساب...'**
  String get creatingAccount;

  /// Sign in link prefix text
  ///
  /// In ar, this message translates to:
  /// **'هل لديك حساب بالفعل؟ '**
  String get alreadyHaveAnAccount;

  /// Forgot password page title
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetYourPassword;

  /// Forgot password page subtitle
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك تعليمات إعادة التعيين.'**
  String get enterEmailForResetInstructions;

  /// Send reset link button
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط إعادة التعيين'**
  String get sendResetLink;

  /// Sending reset link loading state
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال رابط إعادة التعيين...'**
  String get sendingResetLink;

  /// Reset link sent success message
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة التعيين إلى'**
  String get resetLinkSentTo;

  /// Empty cart title message
  ///
  /// In ar, this message translates to:
  /// **'سلتك فارغة'**
  String get yourCartIsEmpty;

  /// Empty cart description message
  ///
  /// In ar, this message translates to:
  /// **'يبدو أنك لم تضف أي عناصر إلى سلتك بعد. ابدأ التسوق لتملأها!'**
  String get cartEmptyDescription;

  /// Start shopping button text
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق'**
  String get startShopping;

  /// Clear favorites button tooltip
  ///
  /// In ar, this message translates to:
  /// **'مسح المفضلة'**
  String get clearFavorites;

  /// Single item label
  ///
  /// In ar, this message translates to:
  /// **'عنصر'**
  String get item;

  /// Multiple items label
  ///
  /// In ar, this message translates to:
  /// **'عناصر'**
  String get items;

  /// Clear all favorites confirmation title
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع المفضلة؟'**
  String get clearAllFavorites;

  /// Clear all favorites confirmation description
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع العناصر المفضلة.'**
  String get clearAllFavoritesDescription;

  /// Featured products section title
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المميزة'**
  String get featuredProducts;

  /// View all button text
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// All featured products page title
  ///
  /// In ar, this message translates to:
  /// **'جميع المنتجات المميزة'**
  String get allFeaturedProducts;

  /// New season collection banner title
  ///
  /// In ar, this message translates to:
  /// **'مجموعة الموسم الجديد'**
  String get newSeasonCollection;

  /// New season collection banner description
  ///
  /// In ar, this message translates to:
  /// **'اكتشف أحدث صيحات الموضة لهذا الموسم'**
  String get discoverLatestFashionTrends;

  /// Shop now button text
  ///
  /// In ar, this message translates to:
  /// **'تسوق الآن'**
  String get shopNow;

  /// Trending styles banner title
  ///
  /// In ar, this message translates to:
  /// **'الأنماط الرائجة'**
  String get trendingStyles;

  /// Trending styles banner description
  ///
  /// In ar, this message translates to:
  /// **'ابق في المقدمة مع أكثر أنماط الموضة شعبية'**
  String get stayAheadWithPopularStyles;

  /// Explore trends button text
  ///
  /// In ar, this message translates to:
  /// **'استكشف الصيحات'**
  String get exploreTrends;

  /// Designer collection banner title
  ///
  /// In ar, this message translates to:
  /// **'مجموعة المصممين'**
  String get designerCollection;

  /// Designer collection banner description
  ///
  /// In ar, this message translates to:
  /// **'قطع حصرية من أفضل مصممي الأزياء'**
  String get exclusivePiecesFromDesigners;

  /// View collection button text
  ///
  /// In ar, this message translates to:
  /// **'عرض المجموعة'**
  String get viewCollection;

  /// Street style banner title
  ///
  /// In ar, this message translates to:
  /// **'أسلوب الشارع'**
  String get streetStyle;

  /// Street style banner description
  ///
  /// In ar, this message translates to:
  /// **'موضة حضرية تحدد الأسلوب العصري'**
  String get urbanFashionDefinesModernStyle;

  /// Get the look button text
  ///
  /// In ar, this message translates to:
  /// **'احصل على الإطلالة'**
  String get getTheLook;

  /// Summer fashion trends story title
  ///
  /// In ar, this message translates to:
  /// **'صيحات موضة الصيف 2025'**
  String get summerFashionTrends2025;

  /// Fashion Weekly author name
  ///
  /// In ar, this message translates to:
  /// **'أسبوع الموضة'**
  String get fashionWeekly;

  /// Sustainable fashion guide story title
  ///
  /// In ar, this message translates to:
  /// **'دليل الموضة المستدامة'**
  String get sustainableFashionGuide;

  /// Eco Style author name
  ///
  /// In ar, this message translates to:
  /// **'إيكو ستايل'**
  String get ecoStyle;

  /// Street style inspiration story title
  ///
  /// In ar, this message translates to:
  /// **'إلهام أسلوب الشارع'**
  String get streetStyleInspiration;

  /// Urban Fashion author name
  ///
  /// In ar, this message translates to:
  /// **'الموضة الحضرية'**
  String get urbanFashion;

  /// Luxury brand spotlight story title
  ///
  /// In ar, this message translates to:
  /// **'تسليط الضوء على العلامات التجارية الفاخرة'**
  String get luxuryBrandSpotlight;

  /// Premium Guide author name
  ///
  /// In ar, this message translates to:
  /// **'الدليل المميز'**
  String get premiumGuide;

  /// Athleisure revolution story title
  ///
  /// In ar, this message translates to:
  /// **'ثورة الأزياء الرياضية'**
  String get athleisureRevolution;

  /// Sport & Style author name
  ///
  /// In ar, this message translates to:
  /// **'الرياضة والأناقة'**
  String get sportAndStyle;

  /// Women category tab
  ///
  /// In ar, this message translates to:
  /// **'النساء'**
  String get women;

  /// Men category tab
  ///
  /// In ar, this message translates to:
  /// **'الرجال'**
  String get men;

  /// Kids category tab
  ///
  /// In ar, this message translates to:
  /// **'الأطفال'**
  String get kids;

  /// No search results found message
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نتائج لـ'**
  String get noResultsFoundFor;

  /// No categories available message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات متاحة'**
  String get noCategoriesAvailable;

  /// Navigate to products action
  ///
  /// In ar, this message translates to:
  /// **'الانتقال إلى المنتجات'**
  String get navigateToProducts;

  /// Success message when item is added to cart
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العنصر للسلة بنجاح!'**
  String get addedToCartSuccessfully;

  /// Place order button text
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get placeOrder;

  /// Order processing dialog title
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الطلب...'**
  String get processingOrder;

  /// Order processing dialog message
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار بينما نعالج طلبك...'**
  String get pleaseWaitWhileWeProcessOrder;

  /// Order success dialog title
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الطلب بنجاح!'**
  String get orderPlacedSuccessfully;

  /// Order success dialog message
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد طلبك بنجاح.'**
  String get yourOrderHasBeenPlacedSuccessfully;

  /// Order ID label
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderId;

  /// Download invoice button text
  ///
  /// In ar, this message translates to:
  /// **'تحميل الفاتورة'**
  String get downloadInvoice;

  /// Edit profile page title
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// Image processing message
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الصورة...'**
  String get processingImage;

  /// Photo selection success message
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الصورة بنجاح'**
  String get photoSelectedSuccessfully;

  /// Photo removal confirmation message
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الصورة'**
  String get photoRemoved;

  /// Image details dialog title
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الصورة'**
  String get imageDetails;

  /// Type label
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get type;

  /// Network image type
  ///
  /// In ar, this message translates to:
  /// **'صورة شبكية'**
  String get networkImage;

  /// Local image type
  ///
  /// In ar, this message translates to:
  /// **'صورة محلية'**
  String get localImage;

  /// Status label
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// Ready for upload status
  ///
  /// In ar, this message translates to:
  /// **'جاهز للرفع'**
  String get readyForUpload;

  /// Camera permission required message
  ///
  /// In ar, this message translates to:
  /// **'مطلوب إذن الكاميرا لالتقاط الصور'**
  String get cameraPermissionRequired;

  /// Photo library permission required message
  ///
  /// In ar, this message translates to:
  /// **'مطلوب إذن معرض الصور لاختيار الصور'**
  String get photoLibraryPermissionRequired;

  /// Image picking error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في اختيار الصورة'**
  String get errorPickingImage;

  /// Permission denied error message
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الكاميرا أو مكتبة الصور'**
  String get cameraOrPhotoLibraryPermissionDenied;

  /// Image upload loading message
  ///
  /// In ar, this message translates to:
  /// **'جاري رفع الصورة...'**
  String get uploadingImage;

  /// Image upload success message
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الصورة بنجاح'**
  String get imageUploadedSuccessfully;

  /// Profile update success message
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdatedSuccessfully;

  /// Profile update error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحديث الملف الشخصي'**
  String get errorUpdatingProfile;

  /// Privacy and security page title
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get privacyAndSecurity;

  /// Privacy settings section title
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصوصية'**
  String get privacySettings;

  /// Data collection setting
  ///
  /// In ar, this message translates to:
  /// **'جمع البيانات'**
  String get dataCollection;

  /// Data collection subtitle
  ///
  /// In ar, this message translates to:
  /// **'السماح لنا بجمع بيانات الاستخدام لتحسين تجربتك'**
  String get allowUsToCollectUsageData;

  /// Personalized ads setting
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المخصصة'**
  String get personalizedAds;

  /// Personalized ads setting description
  ///
  /// In ar, this message translates to:
  /// **'اعرض إعلانات مخصصة بناءً على اهتماماتك'**
  String get showPersonalizedAdvertisements;

  /// Location sharing setting
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الموقع'**
  String get locationSharing;

  /// Location sharing setting description
  ///
  /// In ar, this message translates to:
  /// **'اسمح بالميزات والتوصيات المستندة إلى الموقع'**
  String get allowLocationBasedFeatures;

  /// Security settings section title
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الأمان'**
  String get securitySettings;

  /// Two-factor authentication setting
  ///
  /// In ar, this message translates to:
  /// **'المصادقة الثنائية'**
  String get twoFactorAuthentication;

  /// Two-factor authentication setting description
  ///
  /// In ar, this message translates to:
  /// **'فعل المصادقة الثنائية لتعزيز الأمان'**
  String get enableTwoFactorAuthentication;

  /// Biometric authentication setting
  ///
  /// In ar, this message translates to:
  /// **'المصادقة البيومترية'**
  String get biometricAuthentication;

  /// Biometric authentication setting description
  ///
  /// In ar, this message translates to:
  /// **'فعل البصمة أو التعرف على الوجه للوصول السريع'**
  String get enableBiometricAuthentication;

  /// Biometric enabled message
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل المصادقة البيومترية'**
  String get biometricAuthenticationEnabled;

  /// Biometric disabled message
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف المصادقة البيومترية'**
  String get biometricAuthenticationDisabled;

  /// Orders loading error message
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الطلبات'**
  String get failedToLoadOrders;

  /// Reset price button text
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين السعر'**
  String get resetPrice;

  /// Apply filters button text
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الفلتر'**
  String get applyFilters;

  /// Countries/states loading error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل البلدان/الولايات'**
  String get errorLoadingCountriesStates;

  /// Country selection validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار بلد'**
  String get pleaseSelectACountry;

  /// Office address label
  ///
  /// In ar, this message translates to:
  /// **'المكتب'**
  String get office;

  /// Other address label
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// Edit address page title
  ///
  /// In ar, this message translates to:
  /// **'تعديل العنوان'**
  String get editAddress;

  /// Add new address page title
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان جديد'**
  String get addNewAddress;

  /// Location details section header
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الموقع'**
  String get locationDetails;

  /// Country field label
  ///
  /// In ar, this message translates to:
  /// **'البلد'**
  String get country;

  /// City field label
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// City field hint text
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المدينة'**
  String get enterCityName;

  /// City validation message
  ///
  /// In ar, this message translates to:
  /// **'المدينة مطلوبة'**
  String get cityIsRequired;

  /// Street name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم الشارع'**
  String get streetName;

  /// Street name field hint text
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الشارع'**
  String get enterStreetName;

  /// Street name validation message
  ///
  /// In ar, this message translates to:
  /// **'اسم الشارع مطلوب'**
  String get streetNameIsRequired;

  /// Street number field label
  ///
  /// In ar, this message translates to:
  /// **'رقم الشارع'**
  String get streetNumber;

  /// Street number validation message
  ///
  /// In ar, this message translates to:
  /// **'رقم الشارع مطلوب'**
  String get streetNumberIsRequired;

  /// Building field label
  ///
  /// In ar, this message translates to:
  /// **'المبنى'**
  String get building;

  /// Floor field label
  ///
  /// In ar, this message translates to:
  /// **'الطابق'**
  String get floor;

  /// Floor field hint text
  ///
  /// In ar, this message translates to:
  /// **'رقم الطابق'**
  String get floorNumber;

  /// Apartment field label
  ///
  /// In ar, this message translates to:
  /// **'الشقة'**
  String get apartment;

  /// Apartment field hint text
  ///
  /// In ar, this message translates to:
  /// **'رقم الشقة'**
  String get apartmentNumber;

  /// Address label section header
  ///
  /// In ar, this message translates to:
  /// **'تسمية العنوان'**
  String get addressLabel;

  /// Address settings section header
  ///
  /// In ar, this message translates to:
  /// **'إعدادات العنوان'**
  String get addressSettings;

  /// Set as default address option
  ///
  /// In ar, this message translates to:
  /// **'تعيين كعنوان افتراضي'**
  String get setAsDefaultAddress;

  /// Default address description
  ///
  /// In ar, this message translates to:
  /// **'سيتم استخدام هذا العنوان للطلبات المستقبلية'**
  String get defaultAddressDescription;

  /// Update address button text
  ///
  /// In ar, this message translates to:
  /// **'تحديث العنوان'**
  String get updateAddress;

  /// Save address button text
  ///
  /// In ar, this message translates to:
  /// **'حفظ العنوان'**
  String get saveAddress;

  /// Loading text when saving
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saving;

  /// State or region field label
  ///
  /// In ar, this message translates to:
  /// **'المحافظة / المنطقة'**
  String get stateRegion;

  /// Error message when countries fail to load
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل البلدان. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.'**
  String get failedToLoadCountries;

  /// Message when no states are available for selected country
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محافظات متاحة للبلد المحدد'**
  String get noStatesAvailable;

  /// Short form for number
  ///
  /// In ar, this message translates to:
  /// **'رقم.'**
  String get number;

  /// Building field hint text
  ///
  /// In ar, this message translates to:
  /// **'اسم/رقم المبنى'**
  String get buildingNameNumber;

  /// ZIP or postal code field label
  ///
  /// In ar, this message translates to:
  /// **'الرمز البريدي'**
  String get zipPostalCode;

  /// Address label and additional info field label
  ///
  /// In ar, this message translates to:
  /// **'تسمية العنوان / معلومات إضافية'**
  String get addressLabelAdditionalInfo;

  /// Hint text for address label field
  ///
  /// In ar, this message translates to:
  /// **'مثال: المنزل، المكتب، الأهل — بالإضافة إلى المعالم إن وجدت'**
  String get addressLabelHint;

  /// Error message when saving address fails
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ العنوان'**
  String get errorSavingAddress;

  /// Success message when address is updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العنوان بنجاح'**
  String get addressUpdatedSuccessfully;

  /// Success message when default address is updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العنوان الافتراضي بنجاح'**
  String get defaultAddressUpdatedSuccessfully;

  /// Success message when address is updated (short version)
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العنوان'**
  String get addressUpdated;

  /// Success message when address is deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العنوان بنجاح'**
  String get addressDeletedSuccessfully;

  /// Success message when address is deleted (short version)
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العنوان'**
  String get addressDeleted;

  /// Default user name
  ///
  /// In ar, this message translates to:
  /// **'المستخدم'**
  String get user;

  /// Price range filter section header
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر'**
  String get priceRange;

  /// Gender filter section header
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// Season filter section header
  ///
  /// In ar, this message translates to:
  /// **'الموسم'**
  String get season;

  /// Material filter section header
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get material;

  /// Sizes filter section header
  ///
  /// In ar, this message translates to:
  /// **'المقاسات'**
  String get sizes;

  /// Colors filter section header
  ///
  /// In ar, this message translates to:
  /// **'الألوان'**
  String get colors;

  /// Availability filter section header
  ///
  /// In ar, this message translates to:
  /// **'التوفر'**
  String get availability;

  /// See less button text
  ///
  /// In ar, this message translates to:
  /// **'عرض أقل'**
  String get seeLess;

  /// See more button text
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get seeMore;

  /// Personal information section header
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInformation;

  /// Full name field label
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// Full name field hint text
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get enterYourFullName;

  /// Name validation message
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get nameIsRequired;

  /// Email field hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان بريدك الإلكتروني'**
  String get enterYourEmailAddress;

  /// Email validation message
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get emailIsRequired;

  /// Photo change hint text
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتغيير الصورة'**
  String get tapToChangePhoto;

  /// Date of birth field label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get dateOfBirth;

  /// Date of birth field hint text
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ الميلاد'**
  String get selectDateOfBirth;

  /// Choose photo dialog title
  ///
  /// In ar, this message translates to:
  /// **'اختر الصورة'**
  String get choosePhoto;

  /// Camera option text
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// Gallery option text
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// Permission denied message
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الكاميرا أو معرض الصور'**
  String get permissionDenied;

  /// ZIP code field hint text
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز البريدي'**
  String get enterZipOrPostalCode;

  /// No orders with specific status message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بهذا الحالة'**
  String get noOrdersWithThisStatus;

  /// No orders message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بعد'**
  String get noOrdersYet;

  /// Try different status suggestion
  ///
  /// In ar, this message translates to:
  /// **'حاول اختيار حالة مختلفة أو عرض جميع الطلبات'**
  String get trySelectingDifferentStatus;

  /// Start shopping suggestion
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق لترى طلباتك هنا'**
  String get startShoppingToSeeOrders;

  /// View all orders button text
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع الطلبات'**
  String get viewAllOrders;

  /// Welcome text loading error message
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل نص الترحيب'**
  String get failedToLoadWelcomeText;

  /// No subcategories message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات فرعية'**
  String get noSubcategoriesFound;

  /// Accessibility label for expanding a category to show subcategories
  ///
  /// In ar, this message translates to:
  /// **'توسيع الفئة'**
  String get expandCategory;

  /// Accessibility label for collapsing a category to hide subcategories
  ///
  /// In ar, this message translates to:
  /// **'طي الفئة'**
  String get collapseCategory;

  /// Label for first level subcategories
  ///
  /// In ar, this message translates to:
  /// **'الفئة الفرعية 1'**
  String get subcategoryOne;

  /// Label for second level subcategories
  ///
  /// In ar, this message translates to:
  /// **'الفئة الفرعية 2'**
  String get subcategoryTwo;

  /// Label for third level subcategories
  ///
  /// In ar, this message translates to:
  /// **'الفئة الفرعية 3'**
  String get subcategoryThree;

  /// Biometric user name
  ///
  /// In ar, this message translates to:
  /// **'بيومتري'**
  String get biometric;

  /// Cart items loading error
  ///
  /// In ar, this message translates to:
  /// **'فشل في الحصول على عناصر السلة'**
  String get failedToGetCartItems;

  /// Add to cart error message
  ///
  /// In ar, this message translates to:
  /// **'فشل في إضافة العنصر إلى السلة'**
  String get failedToAddItemToCart;

  /// Cart item not found error
  ///
  /// In ar, this message translates to:
  /// **'عنصر السلة غير موجود'**
  String get cartItemNotFound;

  /// Update cart quantity error
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحديث كمية عنصر السلة'**
  String get failedToUpdateCartItemQuantity;

  /// Remove from cart error
  ///
  /// In ar, this message translates to:
  /// **'فشل في إزالة العنصر من السلة'**
  String get failedToRemoveItemFromCart;

  /// Remove cart item by quantity error
  ///
  /// In ar, this message translates to:
  /// **'فشل في إزالة عنصر من السلة بالكمية'**
  String get failedToRemoveItemFromCartByQuantity;

  /// Clear cart error
  ///
  /// In ar, this message translates to:
  /// **'فشل في مسح السلة'**
  String get failedToClearCart;

  /// Reload cart error
  ///
  /// In ar, this message translates to:
  /// **'فشل في إعادة تحميل السلة'**
  String get failedToReloadCart;

  /// Item not found error
  ///
  /// In ar, this message translates to:
  /// **'العنصر غير موجود'**
  String get itemNotFound;

  /// Office furniture brand
  ///
  /// In ar, this message translates to:
  /// **'أثاث المكتب'**
  String get officeFurniture;

  /// Office chair product name
  ///
  /// In ar, this message translates to:
  /// **'كرسي المكتب'**
  String get officeChair;

  /// Black color option
  ///
  /// In ar, this message translates to:
  /// **'أسود'**
  String get black;

  /// Brown color option
  ///
  /// In ar, this message translates to:
  /// **'بني'**
  String get brown;

  /// White color option
  ///
  /// In ar, this message translates to:
  /// **'أبيض'**
  String get white;

  /// Standard size option
  ///
  /// In ar, this message translates to:
  /// **'قياسي'**
  String get standard;

  /// Office table product name
  ///
  /// In ar, this message translates to:
  /// **'طاولة المكتب'**
  String get officeTable;

  /// Ergonomic design feature
  ///
  /// In ar, this message translates to:
  /// **'تصميم مريح'**
  String get ergonomicDesign;

  /// Adjustable height feature
  ///
  /// In ar, this message translates to:
  /// **'ارتفاع قابل للتعديل'**
  String get adjustableHeight;

  /// Lumbar support feature
  ///
  /// In ar, this message translates to:
  /// **'دعم قطني'**
  String get lumbarSupport;

  /// Rolling casters feature
  ///
  /// In ar, this message translates to:
  /// **'عجلات متحركة'**
  String get rollingCasters;

  /// Mesh and plastic material
  ///
  /// In ar, this message translates to:
  /// **'شبكة وبلاستيك'**
  String get meshAndPlastic;

  /// Mesh back material
  ///
  /// In ar, this message translates to:
  /// **'ظهر شبكي'**
  String get meshBack;

  /// Plastic base material
  ///
  /// In ar, this message translates to:
  /// **'قاعدة بلاستيكية'**
  String get plasticBase;

  /// Metal frame material
  ///
  /// In ar, this message translates to:
  /// **'إطار معدني'**
  String get metalFrame;

  /// Mesh material option
  ///
  /// In ar, this message translates to:
  /// **'شبكة'**
  String get mesh;

  /// Leather material option
  ///
  /// In ar, this message translates to:
  /// **'جلد'**
  String get leather;

  /// Fabric material option
  ///
  /// In ar, this message translates to:
  /// **'قماش'**
  String get fabric;

  /// Spacious workspace feature
  ///
  /// In ar, this message translates to:
  /// **'مساحة عمل واسعة'**
  String get spaciousWorkspace;

  /// Cable management feature
  ///
  /// In ar, this message translates to:
  /// **'إدارة الكابلات'**
  String get cableManagement;

  /// Easy assembly feature
  ///
  /// In ar, this message translates to:
  /// **'تركيب سهل'**
  String get easyAssembly;

  /// Durable construction feature
  ///
  /// In ar, this message translates to:
  /// **'بناء متين'**
  String get durableConstruction;

  /// Wood and metal material
  ///
  /// In ar, this message translates to:
  /// **'خشب ومعدن'**
  String get woodAndMetal;

  /// Wood top material
  ///
  /// In ar, this message translates to:
  /// **'سطح خشبي'**
  String get woodTop;

  /// Metal legs material
  ///
  /// In ar, this message translates to:
  /// **'أرجل معدنية'**
  String get metalLegs;

  /// Wood material option
  ///
  /// In ar, this message translates to:
  /// **'خشب'**
  String get wood;

  /// Glass material option
  ///
  /// In ar, this message translates to:
  /// **'زجاج'**
  String get glass;

  /// Professional grade feature
  ///
  /// In ar, this message translates to:
  /// **'درجة مهنية'**
  String get professionalGrade;

  /// Advanced technology feature
  ///
  /// In ar, this message translates to:
  /// **'تقنية متقدمة'**
  String get advancedTechnology;

  /// High efficiency feature
  ///
  /// In ar, this message translates to:
  /// **'كفاءة عالية'**
  String get highEfficiency;

  /// Ceramic material
  ///
  /// In ar, this message translates to:
  /// **'سيراميك'**
  String get ceramic;

  /// Ceramic components material
  ///
  /// In ar, this message translates to:
  /// **'مكونات سيراميكية'**
  String get ceramicComponents;

  /// Metal housing material
  ///
  /// In ar, this message translates to:
  /// **'غلاف معدني'**
  String get metalHousing;

  /// Nike brand name
  ///
  /// In ar, this message translates to:
  /// **'نايكي'**
  String get nike;

  /// Red color option
  ///
  /// In ar, this message translates to:
  /// **'أحمر'**
  String get red;

  /// Blue color option
  ///
  /// In ar, this message translates to:
  /// **'أزرق'**
  String get blue;

  /// Green color option
  ///
  /// In ar, this message translates to:
  /// **'أخضر'**
  String get green;

  /// Air Max cushioning feature
  ///
  /// In ar, this message translates to:
  /// **'وسادة Air Max'**
  String get airMaxCushioning;

  /// Breathable mesh upper feature
  ///
  /// In ar, this message translates to:
  /// **'جزء علوي شبكي قابل للتنفس'**
  String get breathableMeshUpper;

  /// Rubber outsole feature
  ///
  /// In ar, this message translates to:
  /// **'نعل مطاطي'**
  String get rubberOutsole;

  /// Lightweight design feature
  ///
  /// In ar, this message translates to:
  /// **'تصميم خفيف'**
  String get lightweightDesign;

  /// Comfortable fit feature
  ///
  /// In ar, this message translates to:
  /// **'ملاءمة مريحة'**
  String get comfortableFit;

  /// Mesh and synthetic material
  ///
  /// In ar, this message translates to:
  /// **'شبكة وتركيبية'**
  String get meshAndSynthetic;

  /// TPU overlays material
  ///
  /// In ar, this message translates to:
  /// **'طبقات TPU'**
  String get tpuOverlays;

  /// Foam midsole material
  ///
  /// In ar, this message translates to:
  /// **'نعل متوسط رغوي'**
  String get foamMidsole;

  /// Mesh & Synthetic material option
  ///
  /// In ar, this message translates to:
  /// **'شبكة وتركيبية'**
  String get meshAndSyntheticOption;

  /// Full Mesh material option
  ///
  /// In ar, this message translates to:
  /// **'شبكة كاملة'**
  String get fullMesh;

  /// Mesh & Leather material option
  ///
  /// In ar, this message translates to:
  /// **'شبكة وجلد'**
  String get meshAndLeather;

  /// Adidas brand name
  ///
  /// In ar, this message translates to:
  /// **'أديداس'**
  String get adidas;

  /// Orange color option
  ///
  /// In ar, this message translates to:
  /// **'برتقالي'**
  String get orange;

  /// Energy return technology feature
  ///
  /// In ar, this message translates to:
  /// **'تقنية استعادة الطاقة'**
  String get energyReturnTechnology;

  /// Primeknit upper feature
  ///
  /// In ar, this message translates to:
  /// **'جزء علوي Primeknit'**
  String get primeknitUpper;

  /// Continental rubber outsole feature
  ///
  /// In ar, this message translates to:
  /// **'نعل مطاطي Continental'**
  String get continentalRubberOutsole;

  /// Responsive Boost midsole feature
  ///
  /// In ar, this message translates to:
  /// **'نعل متوسط Boost مستجيب'**
  String get responsiveBoostMidsole;

  /// Primeknit and Boost material
  ///
  /// In ar, this message translates to:
  /// **'Primeknit و Boost'**
  String get primeknitAndBoost;

  /// TPU cage material
  ///
  /// In ar, this message translates to:
  /// **'قفص TPU'**
  String get tpuCage;

  /// Boost midsole material
  ///
  /// In ar, this message translates to:
  /// **'نعل متوسط Boost'**
  String get boostMidsole;

  /// Grey color option
  ///
  /// In ar, this message translates to:
  /// **'رمادي'**
  String get grey;

  /// Light Blue color option
  ///
  /// In ar, this message translates to:
  /// **'أزرق فاتح'**
  String get lightBlue;

  /// Classic straight leg feature
  ///
  /// In ar, this message translates to:
  /// **'ساق مستقيم كلاسيكي'**
  String get classicStraightLeg;

  /// Button fly feature
  ///
  /// In ar, this message translates to:
  /// **'إغلاق بأزرار'**
  String get buttonFly;

  /// Silver color option
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get silver;

  /// Gold color option
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get gold;

  /// Health monitoring feature
  ///
  /// In ar, this message translates to:
  /// **'مراقبة الصحة'**
  String get healthMonitoring;

  /// Fitness tracking feature
  ///
  /// In ar, this message translates to:
  /// **'تتبع اللياقة'**
  String get fitnessTracking;

  /// GPS and cellular feature
  ///
  /// In ar, this message translates to:
  /// **'GPS وخليوي'**
  String get gpsAndCellular;

  /// Water resistant feature
  ///
  /// In ar, this message translates to:
  /// **'مقاوم للماء'**
  String get waterResistant;

  /// Aluminum and glass material
  ///
  /// In ar, this message translates to:
  /// **'ألومنيوم وزجاج'**
  String get aluminumAndGlass;

  /// Steve Madden brand name
  ///
  /// In ar, this message translates to:
  /// **'ستيف مادن'**
  String get steveMadden;

  /// Nude color option
  ///
  /// In ar, this message translates to:
  /// **'لحمي'**
  String get nude;

  /// Synthetic material option
  ///
  /// In ar, this message translates to:
  /// **'تركيبي'**
  String get synthetic;

  /// Stiletto heel type
  ///
  /// In ar, this message translates to:
  /// **'ستيليتو'**
  String get stiletto;

  /// Pointed toe feature
  ///
  /// In ar, this message translates to:
  /// **'مقدمة مدببة'**
  String get pointedToe;

  /// Smooth lining feature
  ///
  /// In ar, this message translates to:
  /// **'بطانة ناعمة'**
  String get smoothLining;

  /// Cushioned insole feature
  ///
  /// In ar, this message translates to:
  /// **'نعل داخلي مبطّن'**
  String get cushionedInsole;

  /// Stiletto heel feature
  ///
  /// In ar, this message translates to:
  /// **'كعب ستيليتو'**
  String get stilettoHeel;

  /// Synthetic and leather material
  ///
  /// In ar, this message translates to:
  /// **'تركيبي وجلد'**
  String get syntheticAndLeather;

  /// Michael Kors brand name
  ///
  /// In ar, this message translates to:
  /// **'مايكل كورس'**
  String get michaelKors;

  /// App name
  ///
  /// In ar, this message translates to:
  /// **'كردوسي'**
  String get bazarClone;

  /// English language name
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// Arabic language name
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Localized text example title
  ///
  /// In ar, this message translates to:
  /// **'مثال على النصوص المترجمة'**
  String get localizedTextExample;

  /// Using AppLocalizations title
  ///
  /// In ar, this message translates to:
  /// **'استخدام AppLocalizations'**
  String get usingAppLocalizations;

  /// Using localization service title
  ///
  /// In ar, this message translates to:
  /// **'استخدام خدمة الترجمة'**
  String get usingLocalizationService;

  /// RTL layout title
  ///
  /// In ar, this message translates to:
  /// **'تخطيط RTL'**
  String get rtlLayout;

  /// Profile loading error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل الملف الشخصي'**
  String get errorLoadingProfile;

  /// Orders count text
  ///
  /// In ar, this message translates to:
  /// **'طلبات'**
  String get orders;

  /// Addresses menu item
  ///
  /// In ar, this message translates to:
  /// **'العناوين'**
  String get addresses;

  /// Addresses subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة عناوين التوصيل'**
  String get manageDeliveryAddresses;

  /// Payment methods page title
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع'**
  String get paymentMethods;

  /// Payment methods subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة خيارات الدفع'**
  String get managePaymentOptions;

  /// Notifications subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة تفضيلات الإشعارات'**
  String get manageNotificationPreferences;

  /// Settings subtitle
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات وتكوين التطبيق'**
  String get appPreferencesAndConfiguration;

  /// Privacy and security subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة إعدادات الخصوصية'**
  String get manageYourPrivacySettings;

  /// Help and support page title
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpAndSupport;

  /// Help and support subtitle
  ///
  /// In ar, this message translates to:
  /// **'احصل على المساعدة وتواصل مع الدعم'**
  String get getHelpAndContactSupport;

  /// Logout menu item
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// Logout subtitle
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من حسابك'**
  String get signOutOfYourAccount;

  /// Logout confirmation message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد تسجيل الخروج؟'**
  String get areYouSureYouWantToLogout;

  /// Chat tooltip
  ///
  /// In ar, this message translates to:
  /// **'تحدث معنا'**
  String get chatWithUs;

  /// Help hero section title
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكننا مساعدتك؟'**
  String get howCanWeHelpYou;

  /// Help hero section subtitle
  ///
  /// In ar, this message translates to:
  /// **'نحن هنا لمساعدتك في أي أسئلة أو مخاوف'**
  String get weAreHereToHelp;

  /// Support availability badge
  ///
  /// In ar, this message translates to:
  /// **'دعم متاح على مدار الساعة'**
  String get twentyFourSevenSupportAvailable;

  /// Search placeholder text
  ///
  /// In ar, this message translates to:
  /// **'البحث في مقالات المساعدة والأسئلة الشائعة'**
  String get searchHelpArticlesAndFaqs;

  /// Quick actions section title
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات السريعة'**
  String get quickActions;

  /// Track order subtitle
  ///
  /// In ar, this message translates to:
  /// **'تحقق من حالة طلبك'**
  String get checkYourOrderStatus;

  /// Returns action
  ///
  /// In ar, this message translates to:
  /// **'الإرجاع'**
  String get returns;

  /// Returns subtitle
  ///
  /// In ar, this message translates to:
  /// **'طلب إرجاع'**
  String get requestAReturn;

  /// Payments action
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get payments;

  /// Payments subtitle
  ///
  /// In ar, this message translates to:
  /// **'مشاكل الدفع'**
  String get paymentIssues;

  /// Account action
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// Account subtitle
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get accountSettings;

  /// FAQ section title
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get frequentlyAskedQuestions;

  /// FAQ question 1
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكنني تتبع طلبي؟'**
  String get howDoITrackMyOrder;

  /// FAQ answer 1
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى الطلبات > اختر طلبك > تتبع. يمكنك أيضاً استخدام رقم التتبع المرسل إلى بريدك الإلكتروني.'**
  String get trackOrderAnswer;

  /// FAQ question 2
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكنني طلب إرجاع؟'**
  String get howDoIRequestAReturn;

  /// FAQ answer 2
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى الطلبات > اختر الطلب > طلب إرجاع. لديك 30 يوماً لإرجاع العناصر في حالتها الأصلية.'**
  String get returnAnswer;

  /// FAQ question 3
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكنني تغيير عنواني؟'**
  String get howCanIChangeMyAddress;

  /// FAQ answer 3
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى العناوين وقم بتعديل أو إضافة عنوان جديد. التغييرات تُطبق فوراً للطلبات الجديدة.'**
  String get addressAnswer;

  /// FAQ question 4
  ///
  /// In ar, this message translates to:
  /// **'ما هي طرق الدفع التي تقبلونها؟'**
  String get whatPaymentMethodsDoYouAccept;

  /// FAQ answer 4
  ///
  /// In ar, this message translates to:
  /// **'نقبل جميع بطاقات الائتمان الرئيسية، PayPal، وApple Pay. جميع المعاملات آمنة ومشفرة.'**
  String get paymentMethodsAnswer;

  /// Contact support section title
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالدعم'**
  String get contactSupport;

  /// Live chat option
  ///
  /// In ar, this message translates to:
  /// **'الدردشة المباشرة'**
  String get liveChat;

  /// Live chat subtitle
  ///
  /// In ar, this message translates to:
  /// **'تحدث مع فريق الدعم لدينا'**
  String get chatWithOurSupportTeam;

  /// Email support option
  ///
  /// In ar, this message translates to:
  /// **'دعم البريد الإلكتروني'**
  String get emailSupport;

  /// Phone support option
  ///
  /// In ar, this message translates to:
  /// **'دعم الهاتف'**
  String get phoneSupport;

  /// Personalized ads subtitle
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعلانات بناءً على اهتماماتك ونشاطك'**
  String get showAdsBasedOnYourInterests;

  /// Location sharing subtitle
  ///
  /// In ar, this message translates to:
  /// **'مشاركة موقعك لخدمة وتوصيل أفضل'**
  String get shareYourLocationForBetterService;

  /// Biometric authentication subtitle
  ///
  /// In ar, this message translates to:
  /// **'استخدام بصمة الإصبع أو التعرف على الوجه لفتح التطبيق'**
  String get useFingerprintOrFaceId;

  /// Two-factor authentication subtitle
  ///
  /// In ar, this message translates to:
  /// **'إضافة طبقة إضافية من الأمان لحسابك'**
  String get addAnExtraLayerOfSecurity;

  /// Change password action
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// Change password subtitle
  ///
  /// In ar, this message translates to:
  /// **'تحديث كلمة مرور حسابك'**
  String get updateYourAccountPassword;

  /// Active sessions action
  ///
  /// In ar, this message translates to:
  /// **'الجلسات النشطة'**
  String get activeSessions;

  /// Active sessions subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأجهزة المسجلة في حسابك'**
  String get manageDevicesLoggedIntoYourAccount;

  /// Delete account action
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// Delete account subtitle
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك نهائياً'**
  String get permanentlyDeleteYourAccount;

  /// Feature not implemented message
  ///
  /// In ar, this message translates to:
  /// **'سيتم تنفيذ هذه الميزة قريباً. يمكنك تغيير كلمة المرور في إعدادات التطبيق.'**
  String get thisFeatureWillBeImplementedSoon;

  /// Active sessions not implemented message
  ///
  /// In ar, this message translates to:
  /// **'سيتم تنفيذ هذه الميزة قريباً. يمكنك إدارة جلساتك النشطة هنا.'**
  String get manageYourActiveSessionsHere;

  /// Delete account warning message
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك نهائياً.'**
  String get thisActionCannotBeUndone;

  /// Notifications subtitle
  ///
  /// In ar, this message translates to:
  /// **'ابق على اطلاع'**
  String get stayInTheLoop;

  /// Enable notifications setting
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get enableNotifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In ar, this message translates to:
  /// **'قم بتفعيل الإشعارات لتصلك تحديثات فورية حول طلباتك والعروض.'**
  String get notificationsDescription;

  /// Logout success message
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get loggedOutSuccessfully;

  /// Account deletion success message
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الحساب بنجاح'**
  String get accountDeletedSuccessfully;

  /// View details button text
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// Confirmed status
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get confirmed;

  /// No cached profile data error
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات ملف شخصي مخزنة'**
  String get noCachedProfileData;

  /// Message shown when there is no internet connection
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternetConnection;

  /// Failed to get user profile error
  ///
  /// In ar, this message translates to:
  /// **'فشل في الحصول على الملف الشخصي'**
  String get failedToGetUserProfile;

  /// User profile not found error
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي غير موجود'**
  String get userProfileNotFound;

  /// Failed to update user profile error
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحديث الملف الشخصي'**
  String get failedToUpdateUserProfile;

  /// Delivery note
  ///
  /// In ar, this message translates to:
  /// **'اتركه عند الباب الأمامي إذا لم يتم الرد'**
  String get leaveAtFrontDoorIfNoAnswer;

  /// Register page subtitle
  ///
  /// In ar, this message translates to:
  /// **'انضم إلينا وابدأ التسوق'**
  String get joinUsAndStartShopping;

  /// First name length validation
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون الاسم الأول حرفين على الأقل'**
  String get firstNameMustBeAtLeastTwoCharacters;

  /// Last name length validation
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون الاسم الأخير حرفين على الأقل'**
  String get lastNameMustBeAtLeastTwoCharacters;

  /// Password field hint
  ///
  /// In ar, this message translates to:
  /// **'أنشئ كلمة مرور قوية'**
  String get createStrongPassword;

  /// Password validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة مرور'**
  String get pleaseEnterPassword;

  /// Password length validation
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون كلمة المرور 8 أحرف على الأقل'**
  String get passwordMustBeAtLeastEightCharacters;

  /// Password complexity validation
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على أحرف كبيرة وصغيرة ورقم'**
  String get passwordMustContainUppercaseLowercaseAndNumber;

  /// Confirm password field hint
  ///
  /// In ar, this message translates to:
  /// **'أكد كلمة المرور'**
  String get confirmYourPassword;

  /// Confirm password validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد كلمة المرور'**
  String get pleaseConfirmYourPassword;

  /// Terms agreement text
  ///
  /// In ar, this message translates to:
  /// **'أوافق على '**
  String get iAgreeToThe;

  /// Conjunction between terms and privacy
  ///
  /// In ar, this message translates to:
  /// **' و '**
  String get and;

  /// Addresses page title
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get myAddresses;

  /// Add address button text
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان'**
  String get addAddress;

  /// Empty addresses state title
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين بعد'**
  String get noAddressesYet;

  /// Empty addresses state description
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوان التسليم الأول لتسريع عملية الدفع والحصول على تقديرات شحن دقيقة'**
  String get addYourFirstDeliveryAddress;

  /// Add first address button text
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوانك الأول'**
  String get addYourFirstAddress;

  /// Delete address dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف العنوان'**
  String get deleteAddress;

  /// Delete address confirmation message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد حذف هذا العنوان؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get areYouSureDeleteAddress;

  /// Default address label
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get defaultAddress;

  /// Address label
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// Message when no addresses are found
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على عناوين'**
  String get noAddressesFound;

  /// Message when no address is set yet in checkout
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين عنوان بعد'**
  String get noAddressIsSetYet;

  /// Empty payment methods state title
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طرق دفع'**
  String get noPaymentMethods;

  /// Empty payment methods state description
  ///
  /// In ar, this message translates to:
  /// **'أضف طريقة الدفع الأولى للبدء'**
  String get addYourFirstPaymentMethod;

  /// Add payment method button text
  ///
  /// In ar, this message translates to:
  /// **'إضافة طريقة دفع'**
  String get addPaymentMethod;

  /// Scan card button tooltip and page title
  ///
  /// In ar, this message translates to:
  /// **'مسح البطاقة'**
  String get scanCard;

  /// Confirmation message for deleting payment method
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف طريقة الدفع هذه؟'**
  String get deletePaymentMethodConfirmation;

  /// Confirmation message for setting default payment method
  ///
  /// In ar, this message translates to:
  /// **'جعل هذه طريقة الدفع الافتراضية؟'**
  String get setDefaultPaymentMethodConfirmation;

  /// Zain Cash payment method name
  ///
  /// In ar, this message translates to:
  /// **'زين كاش'**
  String get zainCash;

  /// Al Qaseh payment method name
  ///
  /// In ar, this message translates to:
  /// **'القاصه'**
  String get alQaseh;

  /// Coming soon label for unavailable features
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// Qi Card payment method name
  ///
  /// In ar, this message translates to:
  /// **'بطاقة كيو'**
  String get qiCard;

  /// Privacy note for card scanning
  ///
  /// In ar, this message translates to:
  /// **'نحن نقرأ الرقم وتاريخ الانتهاء فقط — لا يتم حفظ أي شيء.'**
  String get scanCardPrivacyNote;

  /// Card scanning tip about lighting
  ///
  /// In ar, this message translates to:
  /// **'استخدم منطقة مضاءة جيداً وتجنب الوهج'**
  String get scanCardTipLighting;

  /// Card scanning tip about surface
  ///
  /// In ar, this message translates to:
  /// **'ضع البطاقة على سطح مسطح ومتباين'**
  String get scanCardTipSurface;

  /// Card scan result display format
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة: {cardNumber}\nتاريخ الانتهاء: {expiryDate}\nحامل البطاقة: {cardHolderName}'**
  String cardScanResult(
    String cardNumber,
    String expiryDate,
    String cardHolderName,
  );

  /// Delete payment method dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف طريقة الدفع'**
  String get deletePaymentMethod;

  /// Set as default payment method dialog title
  ///
  /// In ar, this message translates to:
  /// **'تعيين كافتراضي'**
  String get setAsDefault;

  /// Set default button text
  ///
  /// In ar, this message translates to:
  /// **'تعيين افتراضي'**
  String get setDefault;

  /// Default payment method update message
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث طريقة الدفع الافتراضية'**
  String get defaultPaymentMethodUpdated;

  /// Card scan cancelled message
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء المسح'**
  String get scanCancelled;

  /// Card scanning instruction
  ///
  /// In ar, this message translates to:
  /// **'ضع بطاقتك داخل الإطار'**
  String get positionYourCardWithinFrame;

  /// Card alignment instruction
  ///
  /// In ar, this message translates to:
  /// **'محاذاة حواف البطاقة مع الأدلة'**
  String get alignCardEdgesWithGuides;

  /// Title for tips section on offline page
  ///
  /// In ar, this message translates to:
  /// **'نصائح سريعة:'**
  String get quickTips;

  /// Card scanning tip
  ///
  /// In ar, this message translates to:
  /// **'تأكد من وضوح الأرقام'**
  String get makeSureNumbersAreClearlyVisible;

  /// Scanning in progress text
  ///
  /// In ar, this message translates to:
  /// **'جاري المسح...'**
  String get scanning;

  /// Start scan button text
  ///
  /// In ar, this message translates to:
  /// **'بدء المسح'**
  String get startScan;

  /// Edit details instruction
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تعديل التفاصيل قبل الحفظ'**
  String get youCanEditDetailsBeforeSaving;

  /// Last scan result label
  ///
  /// In ar, this message translates to:
  /// **'النتيجة الأخيرة'**
  String get lastResult;

  /// Payment method name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم طريقة الدفع'**
  String get paymentMethodName;

  /// Name field validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم'**
  String get pleaseEnterName;

  /// Cardholder name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم حامل البطاقة'**
  String get cardholderName;

  /// Cardholder name validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم حامل البطاقة'**
  String get pleaseEnterCardholderName;

  /// Card number field label
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get cardNumber;

  /// Card number validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم البطاقة'**
  String get pleaseEnterCardNumber;

  /// Card number format validation
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم بطاقة صحيح'**
  String get pleaseEnterValidCardNumber;

  /// Expiry date field label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get expiryDate;

  /// Expiry date validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال تاريخ الانتهاء'**
  String get pleaseEnterExpiryDate;

  /// CVV field label
  ///
  /// In ar, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// CVV validation message
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال CVV'**
  String get pleaseEnterCvv;

  /// CVV format validation
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال CVV صحيح'**
  String get pleaseEnterValidCvv;

  /// Payment method type field label
  ///
  /// In ar, this message translates to:
  /// **'نوع طريقة الدفع'**
  String get paymentMethodType;

  /// Credit card payment type
  ///
  /// In ar, this message translates to:
  /// **'بطاقة ائتمان'**
  String get creditCard;

  /// Debit card payment type
  ///
  /// In ar, this message translates to:
  /// **'بطاقة خصم'**
  String get debitCard;

  /// PayPal payment type
  ///
  /// In ar, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// Apple Pay payment type
  ///
  /// In ar, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// Google Pay payment type
  ///
  /// In ar, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// Bank transfer payment type
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get bankTransfer;

  /// Cash on delivery payment type
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند التسليم'**
  String get cashOnDelivery;

  /// Cash payment type
  ///
  /// In ar, this message translates to:
  /// **'دفع نقدي'**
  String get cashPayment;

  /// Card holder placeholder text
  ///
  /// In ar, this message translates to:
  /// **'حامل البطاقة'**
  String get cardHolder;

  /// Cash payment label
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get cash;

  /// Cash on delivery description
  ///
  /// In ar, this message translates to:
  /// **'ادفع نقداً عند التسليم'**
  String get payWithCashOnDelivery;

  /// Cash on delivery subtitle - pay when you receive
  ///
  /// In ar, this message translates to:
  /// **'ادفع عند الاستلام'**
  String get payWhenYouReceive;

  /// PayPal description
  ///
  /// In ar, this message translates to:
  /// **'خدمة دفع إلكتروني'**
  String get onlinePaymentService;

  /// Apple Pay description
  ///
  /// In ar, this message translates to:
  /// **'دفع بدون تلامس'**
  String get contactlessPayment;

  /// Google Pay description
  ///
  /// In ar, this message translates to:
  /// **'خدمة دفع محمول'**
  String get mobilePaymentService;

  /// Bank transfer description
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي مباشر'**
  String get directBankTransfer;

  /// Product fallback name
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get product;

  /// VAT included label
  ///
  /// In ar, this message translates to:
  /// **'شامل ضريبة القيمة المضافة'**
  String get vatIncluded;

  /// Size selection label
  ///
  /// In ar, this message translates to:
  /// **'اختر المقاس'**
  String get selectSize;

  /// Customer reviews section title
  ///
  /// In ar, this message translates to:
  /// **'آراء العملاء'**
  String get customerReviews;

  /// Deals and offers section title
  ///
  /// In ar, this message translates to:
  /// **'العروض والصفقات'**
  String get dealsAndOffers;

  /// Delivery and returns section title
  ///
  /// In ar, this message translates to:
  /// **'التوصيل والإرجاع'**
  String get deliveryAndReturns;

  /// Product care and materials section title
  ///
  /// In ar, this message translates to:
  /// **'العناية بالمواد والتركيب'**
  String get productCareAndMaterials;

  /// Country name Turkey
  ///
  /// In ar, this message translates to:
  /// **'تركيا'**
  String get turkey;

  /// Heel details section title
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الكعب'**
  String get heelDetails;

  /// Heel type label
  ///
  /// In ar, this message translates to:
  /// **'نوع الكعب'**
  String get heelType;

  /// Heel height label
  ///
  /// In ar, this message translates to:
  /// **'ارتفاع الكعب'**
  String get heelHeight;

  /// Centimeter unit
  ///
  /// In ar, this message translates to:
  /// **'سم'**
  String get cm;

  /// Recommendations loading error
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل التوصيات'**
  String get failedToLoadRecommendations;

  /// Empty recommendations state
  ///
  /// In ar, this message translates to:
  /// **'لا توجد توصيات'**
  String get noRecommendations;

  /// Customer reviews subtitle
  ///
  /// In ar, this message translates to:
  /// **'ما يقوله العملاء'**
  String get whatCustomersAreSaying;

  /// Verified purchase badge
  ///
  /// In ar, this message translates to:
  /// **'شراء موثق'**
  String get verifiedPurchase;

  /// Tomorrow delivery time
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get tomorrow;

  /// Free delivery label
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get freeDelivery;

  /// Fast delivery label
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع'**
  String get fastDelivery;

  /// Standard delivery option
  ///
  /// In ar, this message translates to:
  /// **'التوصيل العادي'**
  String get standardDelivery;

  /// Express delivery option
  ///
  /// In ar, this message translates to:
  /// **'التوصيل السريع'**
  String get expressDelivery;

  /// Recommended badge
  ///
  /// In ar, this message translates to:
  /// **'موصى به'**
  String get recommended;

  /// Limited time deal badge
  ///
  /// In ar, this message translates to:
  /// **'عرض لفترة محدودة!'**
  String get limitedTimeDeal;

  /// Deal condition text
  ///
  /// In ar, this message translates to:
  /// **'على المنتجات المختارة'**
  String get onSelectedItems;

  /// Popular badge
  ///
  /// In ar, this message translates to:
  /// **'شائع'**
  String get popular;

  /// Rewards offer description
  ///
  /// In ar, this message translates to:
  /// **'مكافآت مضاعفة على هذا الشراء'**
  String get doubleRewardsOnThisPurchase;

  /// Bonus badge
  ///
  /// In ar, this message translates to:
  /// **'مكافأة'**
  String get bonus;

  /// Care instructions section title
  ///
  /// In ar, this message translates to:
  /// **'تعليمات العناية'**
  String get careInstructions;

  /// Materials and composition section title
  ///
  /// In ar, this message translates to:
  /// **'المواد والتركيب'**
  String get materialsAndComposition;

  /// Origin and sustainability section title
  ///
  /// In ar, this message translates to:
  /// **'المنشأ والاستدامة'**
  String get originAndSustainability;

  /// Made in label
  ///
  /// In ar, this message translates to:
  /// **'صُنع في'**
  String get madeIn;

  /// Eco-friendly label
  ///
  /// In ar, this message translates to:
  /// **'صديق للبيئة'**
  String get ecoFriendly;

  /// Sustainable materials description
  ///
  /// In ar, this message translates to:
  /// **'استُخدمت مواد مستدامة'**
  String get sustainableMaterialsUsed;

  /// Recyclable label
  ///
  /// In ar, this message translates to:
  /// **'قابل لإعادة التدوير'**
  String get recyclable;

  /// Certified label
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get certified;

  /// OEKO-TEX certification
  ///
  /// In ar, this message translates to:
  /// **'معيار OEKO-TEX 100'**
  String get oekoTextStandard100;

  /// Size and fit information section title
  ///
  /// In ar, this message translates to:
  /// **'معلومات المقاس والملاءمة'**
  String get sizeAndFitInformation;

  /// Fit label
  ///
  /// In ar, this message translates to:
  /// **'الملاءمة'**
  String get fit;

  /// Regular fit description
  ///
  /// In ar, this message translates to:
  /// **'ملاءمة عادية'**
  String get regularFit;

  /// Model size label
  ///
  /// In ar, this message translates to:
  /// **'مقاس العارض'**
  String get modelSize;

  /// View size guide button
  ///
  /// In ar, this message translates to:
  /// **'عرض دليل المقاسات'**
  String get viewSizeGuide;

  /// Care instruction - do not bleach
  ///
  /// In ar, this message translates to:
  /// **'لا تبيض'**
  String get doNotBleach;

  /// Care instruction - tumble dry low heat
  ///
  /// In ar, this message translates to:
  /// **'تجفيف في المجفف على حرارة منخفضة'**
  String get tumbleDryLowHeat;

  /// Style recommendations section title
  ///
  /// In ar, this message translates to:
  /// **'أكمل الإطلالة مع'**
  String get styleItWith;

  /// Style recommendations subtitle
  ///
  /// In ar, this message translates to:
  /// **'أكمل إطلالتك مع هذه القطع المكملة'**
  String get completeYourLookWithTheseComplementaryPieces;

  /// Accessories category
  ///
  /// In ar, this message translates to:
  /// **'الإكسسوارات'**
  String get accessories;

  /// Accessories description
  ///
  /// In ar, this message translates to:
  /// **'أضف لمسة من الأناقة'**
  String get addATouchOfElegance;

  /// Classic watch product name
  ///
  /// In ar, this message translates to:
  /// **'ساعة كلاسيكية'**
  String get classicWatch;

  /// Leather belt product name
  ///
  /// In ar, this message translates to:
  /// **'حزام جلد'**
  String get leatherBelt;

  /// Silver necklace product name
  ///
  /// In ar, this message translates to:
  /// **'قلادة فضية'**
  String get silverNecklace;

  /// Footwear category
  ///
  /// In ar, this message translates to:
  /// **'الأحذية'**
  String get footwear;

  /// Footwear description
  ///
  /// In ar, this message translates to:
  /// **'ارتقِ بلعبة الأناقة'**
  String get stepUpYourStyleGame;

  /// White sneakers product name
  ///
  /// In ar, this message translates to:
  /// **'حذاء رياضي أبيض'**
  String get whiteSneakers;

  /// Black boots product name
  ///
  /// In ar, this message translates to:
  /// **'حذاء أسود'**
  String get blackBoots;

  /// Casual loafers product name
  ///
  /// In ar, this message translates to:
  /// **'حذاء مريح'**
  String get casualLoafers;

  /// Outerwear category
  ///
  /// In ar, this message translates to:
  /// **'الملابس الخارجية'**
  String get outerwear;

  /// Outerwear description
  ///
  /// In ar, this message translates to:
  /// **'ارتدي طبقات لأي طقس'**
  String get layerUpForAnyWeather;

  /// About product section title
  ///
  /// In ar, this message translates to:
  /// **'حول هذا المنتج'**
  String get aboutThisProduct;

  /// Read less button
  ///
  /// In ar, this message translates to:
  /// **'اقرأ أقل'**
  String get readLess;

  /// Read more button
  ///
  /// In ar, this message translates to:
  /// **'اقرأ المزيد'**
  String get readMore;

  /// Color selection label
  ///
  /// In ar, this message translates to:
  /// **'اختر اللون'**
  String get selectColor;

  /// Available colors count suffix
  ///
  /// In ar, this message translates to:
  /// **'لون متاح'**
  String get colorsAvailable;

  /// Default option
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get defaultOption;

  /// Material selection label
  ///
  /// In ar, this message translates to:
  /// **'اختر المادة'**
  String get selectMaterial;

  /// Heel height selection label
  ///
  /// In ar, this message translates to:
  /// **'اختر ارتفاع الكعب'**
  String get selectHeelHeight;

  /// Shopping cart page title
  ///
  /// In ar, this message translates to:
  /// **'سلة التسوق'**
  String get shoppingCart;

  /// Clear cart button text
  ///
  /// In ar, this message translates to:
  /// **'مسح السلة'**
  String get clearCart;

  /// Error message when cart fails to load
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل السلة'**
  String get errorLoadingCart;

  /// Clear cart confirmation dialog message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد مسح جميع العناصر من سلة التسوق؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get areYouSureClearCart;

  /// Total items label in cart summary
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العناصر:'**
  String get totalItems;

  /// VAT label in cart summary
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة (15%): '**
  String get vat15;

  /// Checkout dialog message
  ///
  /// In ar, this message translates to:
  /// **'سيتم توجيهك إلى صفحة الدفع لإكمال طلبك.'**
  String get youWillBeRedirectedToCheckout;

  /// Continue button text
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueButton;

  /// Total with tax label for individual cart items
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي مع الضريبة: '**
  String get totalWithTax;

  /// Fallback VAT label when API data is not available
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة 15%'**
  String get vatFallback;

  /// Welcome message with user name
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {userName}!'**
  String welcomeUser(String userName);

  /// Welcome message with user name and comma
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {userName}، '**
  String welcomeUserComma(String userName);

  /// Text shown when filtering products
  ///
  /// In ar, this message translates to:
  /// **'جاري التصفية...'**
  String get filtering;

  /// Title for email verification dialog
  ///
  /// In ar, this message translates to:
  /// **'التحقق من البريد الإلكتروني مطلوب'**
  String get emailVerificationRequired;

  /// Message explaining email verification requirement
  ///
  /// In ar, this message translates to:
  /// **'يجب التحقق من عنوان بريدك الإلكتروني قبل أن تتمكن من المتابعة. يرجى التحقق من بريدك الإلكتروني والنقر على رابط التحقق.'**
  String get emailNotVerifiedMessage;

  /// Button to resend verification email
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال البريد الإلكتروني'**
  String get resendEmail;

  /// Message shown when verification email is resent
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال بريد التحقق! يرجى التحقق من صندوق الوارد.'**
  String get verificationEmailSent;

  /// Title shown when product has no description
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد وصف متاح'**
  String get noProductDescription;

  /// Message shown when product description is not available
  ///
  /// In ar, this message translates to:
  /// **'سيكون وصف المنتج متاحاً قريباً.'**
  String get productDescriptionComingSoon;

  /// Instructions for user when offline
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.'**
  String get checkInternetConnection;

  /// Text shown while retrying connection
  ///
  /// In ar, this message translates to:
  /// **'جاري إعادة المحاولة...'**
  String get retrying;

  /// Tip to check WiFi connection
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصال WiFi الخاص بك'**
  String get checkWiFiConnection;

  /// Tip to verify mobile data
  ///
  /// In ar, this message translates to:
  /// **'تأكد من تفعيل البيانات الخلوية'**
  String get verifyMobileDataEnabled;

  /// Tip to try different location
  ///
  /// In ar, this message translates to:
  /// **'حاول الانتقال إلى موقع مختلف'**
  String get tryDifferentLocation;

  /// Tip to restart internet connection
  ///
  /// In ar, this message translates to:
  /// **'أعد تشغيل اتصالك بالإنترنت'**
  String get restartInternetConnection;

  /// Message when retry fails
  ///
  /// In ar, this message translates to:
  /// **'لا يزال لا يوجد اتصال بالإنترنت. يرجى التحقق من إعدادات الشبكة.'**
  String get stillNoInternetConnection;

  /// Status message when connected
  ///
  /// In ar, this message translates to:
  /// **'متصل بالإنترنت'**
  String get connectedToInternet;

  /// Status message when checking connection
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحقق من الاتصال...'**
  String get checkingConnection;

  /// Message shown when no terms and conditions are available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شروط متاحة'**
  String get noTermsAvailable;

  /// Description when no terms and conditions are available
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام غير متاحة حالياً. يرجى المحاولة مرة أخرى لاحقاً.'**
  String get noTermsAvailableDescription;

  /// Description for category selection dialog
  ///
  /// In ar, this message translates to:
  /// **'تحتوي هذه الفئة على فئات فرعية ومنتجات. ماذا تريد أن تستكشف؟'**
  String get categoryContainsBoth;

  /// Button text to browse subcategories
  ///
  /// In ar, this message translates to:
  /// **'تصفح الفئات الفرعية'**
  String get browseSubcategories;

  /// Button text to view products
  ///
  /// In ar, this message translates to:
  /// **'عرض المنتجات'**
  String get viewProducts;

  /// No description provided for @compare.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة'**
  String get compare;

  /// No description provided for @vs.
  ///
  /// In ar, this message translates to:
  /// **'ضد'**
  String get vs;

  /// No description provided for @selectAtLeastTwoToCompare.
  ///
  /// In ar, this message translates to:
  /// **'اختر على الأقل منتجين للمقارنة'**
  String get selectAtLeastTwoToCompare;

  /// No description provided for @failedToLoadProductDetails.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل تفاصيل المنتج'**
  String get failedToLoadProductDetails;

  /// Text indicating number of subcategories available
  ///
  /// In ar, this message translates to:
  /// **'فئات فرعية متاحة'**
  String get subcategoriesAvailable;

  /// Text indicating number of products available
  ///
  /// In ar, this message translates to:
  /// **'منتجات متاحة'**
  String get productsAvailable;

  /// Message when no subcategories are available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات فرعية متاحة'**
  String get noSubcategoriesAvailable;

  /// Text for browsing products in a category
  ///
  /// In ar, this message translates to:
  /// **'تصفح المنتجات'**
  String get browseProducts;

  /// Text for subcategories count
  ///
  /// In ar, this message translates to:
  /// **'فئات فرعية'**
  String get subcategories;

  /// Label for popular subcategories section
  ///
  /// In ar, this message translates to:
  /// **'الفئات الفرعية الشائعة:'**
  String get popularSubcategories;

  /// Text for viewing all subcategories
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع الفئات الفرعية'**
  String get viewAllSubcategories;

  /// Text for browsing products in a specific category
  ///
  /// In ar, this message translates to:
  /// **'تصفح المنتجات في هذه الفئة'**
  String get browseProductsInCategory;

  /// Text for products count
  ///
  /// In ar, this message translates to:
  /// **'منتجات'**
  String get products;

  /// Label for product tags section
  ///
  /// In ar, this message translates to:
  /// **'وسوم'**
  String get tags;

  /// Delivery status label
  ///
  /// In ar, this message translates to:
  /// **'حالة التوصيل'**
  String get deliveryStatus;

  /// Current location label
  ///
  /// In ar, this message translates to:
  /// **'الموقع الحالي'**
  String get currentLocation;

  /// Carrier label
  ///
  /// In ar, this message translates to:
  /// **'شركة الشحن'**
  String get carrier;

  /// Shipped on label
  ///
  /// In ar, this message translates to:
  /// **'تم الشحن في'**
  String get shippedOn;

  /// Out for delivery on label
  ///
  /// In ar, this message translates to:
  /// **'خارج للتوصيل في'**
  String get outForDeliveryOn;

  /// Track your order button text
  ///
  /// In ar, this message translates to:
  /// **'تتبع طلبك'**
  String get trackYourOrder;

  /// View tracking details text
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل التتبع'**
  String get viewTrackingDetails;

  /// View detailed tracking information text
  ///
  /// In ar, this message translates to:
  /// **'عرض معلومات التتبع التفصيلية'**
  String get viewDetailedTrackingInformation;

  /// Recipient name label in shipping section
  ///
  /// In ar, this message translates to:
  /// **'اسم المستلم'**
  String get recipientName;

  /// Mobile number label in shipping section
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get mobileNumber;

  /// Street label
  ///
  /// In ar, this message translates to:
  /// **'الشارع'**
  String get street;

  /// Second street line label
  ///
  /// In ar, this message translates to:
  /// **'الشارع ٢'**
  String get street2;

  /// State label
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get state;

  /// Postal/ZIP code label
  ///
  /// In ar, this message translates to:
  /// **'الرمز البريدي'**
  String get zipCode;

  /// Order validity date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الصلاحية'**
  String get validityDate;

  /// Invoice status label
  ///
  /// In ar, this message translates to:
  /// **'حالة الفاتورة'**
  String get invoiceStatus;

  /// Shipping method label
  ///
  /// In ar, this message translates to:
  /// **'طريقة الشحن'**
  String get shippingMethod;

  /// Shipping cost label
  ///
  /// In ar, this message translates to:
  /// **'تكلفة الشحن'**
  String get shippingCost;

  /// Transaction ID label
  ///
  /// In ar, this message translates to:
  /// **'رقم المعاملة'**
  String get transactionId;

  /// Status history label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الحالة'**
  String get statusHistory;

  /// Not started delivery state
  ///
  /// In ar, this message translates to:
  /// **'لم يبدأ'**
  String get notStarted;

  /// Preparing delivery state
  ///
  /// In ar, this message translates to:
  /// **'قيد التحضير'**
  String get preparing;

  /// Ready to ship delivery state
  ///
  /// In ar, this message translates to:
  /// **'جاهز للشحن'**
  String get readyToShip;

  /// In transit delivery state
  ///
  /// In ar, this message translates to:
  /// **'قيد النقل'**
  String get inTransit;

  /// Out for delivery state
  ///
  /// In ar, this message translates to:
  /// **'خارج للتوصيل'**
  String get outForDelivery;

  /// Delivery failed state
  ///
  /// In ar, this message translates to:
  /// **'فشل التوصيل'**
  String get deliveryFailed;

  /// Payment page title
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payment;

  /// Error message when payment URL is missing
  ///
  /// In ar, this message translates to:
  /// **'عنوان صفحة الدفع مفقود. يرجى المحاولة مرة أخرى.'**
  String get paymentUrlMissing;

  /// Error message when payment URL is invalid
  ///
  /// In ar, this message translates to:
  /// **'عنوان صفحة الدفع غير صحيح. يرجى المحاولة مرة أخرى.'**
  String get invalidPaymentUrl;

  /// Error message when payment page fails to load
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل صفحة الدفع: {error}'**
  String failedToLoadPaymentPage(String error);

  /// Loading message for payment page
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل صفحة الدفع...'**
  String get loadingPaymentPage;

  /// Payment error title
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الدفع'**
  String get paymentError;

  /// Generic error message when payment page fails to load
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل صفحة الدفع. يرجى المحاولة مرة أخرى.'**
  String get failedToLoadPaymentPageGeneric;

  /// Cancel payment dialog title
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدفع'**
  String get cancelPayment;

  /// Cancel payment confirmation message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إلغاء هذا الدفع؟'**
  String get cancelPaymentConfirmation;

  /// Yes button text
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No button text
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// Message when payment is cancelled or fails
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الدفع أو فشل'**
  String get paymentCancelledOrFailed;

  /// Empty state title when no page components are available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مكونات بعد'**
  String get noComponentsYet;

  /// Empty state description instructing to add components from dashboard
  ///
  /// In ar, this message translates to:
  /// **'أضف المكونات من لوحة التحكم لملء هذه الصفحة.'**
  String get addComponentsFromDashboard;

  /// Error message when invoice is not found for an order
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على فاتورة لهذا الطلب'**
  String get noInvoiceFoundForOrder;

  /// Error message when invoice file format is invalid
  ///
  /// In ar, this message translates to:
  /// **'تنسيق ملف الفاتورة غير صالح'**
  String get invalidInvoiceFileFormat;

  /// Error message when storage directory cannot be accessed
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الوصول إلى مجلد التخزين'**
  String get couldNotAccessStorageDirectory;

  /// Success message when invoice is downloaded and opened
  ///
  /// In ar, this message translates to:
  /// **'تم تنزيل وفتح الفاتورة'**
  String get invoiceDownloadedAndOpened;

  /// Message when invoice is saved and user needs to choose how to open it
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفاتورة. اختر كيفية فتحها.'**
  String get invoiceSavedChooseHowToOpen;

  /// Message when invoice is saved but cannot be opened
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفاتورة ولكن لا يمكن فتحها. يرجى تثبيت عارض PDF.'**
  String get invoiceSavedButCouldNotOpen;

  /// Message suggesting to open file from file manager
  ///
  /// In ar, this message translates to:
  /// **'حاول الفتح من مدير الملفات الخاص بك.'**
  String get tryOpeningFromFileManager;

  /// Success message prefix for invoice download
  ///
  /// In ar, this message translates to:
  /// **'تم تنزيل الفاتورة'**
  String get invoiceDownloaded;

  /// Error message when invoice download fails
  ///
  /// In ar, this message translates to:
  /// **'فشل تنزيل الفاتورة'**
  String get failedToDownloadInvoice;

  /// Error message when authentication is required
  ///
  /// In ar, this message translates to:
  /// **'مطلوب المصادقة. يرجى تسجيل الدخول مرة أخرى.'**
  String get authenticationRequiredPleaseLogin;

  /// Error message when tracking URL is not available
  ///
  /// In ar, this message translates to:
  /// **'رابط التتبع غير متاح. يرجى المحاولة مرة أخرى لاحقاً.'**
  String get trackingUrlNotAvailable;

  /// Error message when tracking URL format is invalid
  ///
  /// In ar, this message translates to:
  /// **'تنسيق رابط التتبع غير صالح'**
  String get invalidTrackingUrlFormat;

  /// Error message when tracking link cannot be opened
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن فتح رابط التتبع'**
  String get couldNotOpenTrackingLink;

  /// Error message when opening tracking link fails
  ///
  /// In ar, this message translates to:
  /// **'فشل فتح رابط التتبع'**
  String get failedToOpenTrackingLink;

  /// Text prefix for invoice sharing
  ///
  /// In ar, this message translates to:
  /// **'فاتورة للطلب'**
  String get invoiceForOrder;

  /// Delivery status - new order created
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الطلب'**
  String get deliveryStatusNew;

  /// Delivery status - scheduled for pick-up
  ///
  /// In ar, this message translates to:
  /// **'تم جدولة الطلب للاستلام'**
  String get deliveryStatusScheduled;

  /// Delivery status - collecting
  ///
  /// In ar, this message translates to:
  /// **'وكيل الاستلام في الطريق لجمع الطلب'**
  String get deliveryStatusCollecting;

  /// Delivery status - collected
  ///
  /// In ar, this message translates to:
  /// **'تم جمع الطلب من قبل وكيل الاستلام'**
  String get deliveryStatusCollected;

  /// Delivery status - in-transit
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الطلب في المستودع وهو قيد النقل'**
  String get deliveryStatusInTransit;

  /// Delivery status - on-hold
  ///
  /// In ar, this message translates to:
  /// **'حدث غير متوقع والطلب معلق'**
  String get deliveryStatusOnHold;

  /// Delivery status - out-for-delivery
  ///
  /// In ar, this message translates to:
  /// **'الطلب في الطريق للتسليم للعميل'**
  String get deliveryStatusOutForDelivery;

  /// Delivery status - partially-delivered
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الطلب جزئياً'**
  String get deliveryStatusPartiallyDelivered;

  /// Delivery status - returned-warehouse
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الطلب المرتجع في المستودع من ناقل التوصيل الأخير'**
  String get deliveryStatusReturnedWarehouse;

  /// Delivery status - returning-origin
  ///
  /// In ar, this message translates to:
  /// **'تم جدولة الطلب المرتجع للتسليم للتاجر'**
  String get deliveryStatusReturningOrigin;

  /// Delivery status - partially-returned
  ///
  /// In ar, this message translates to:
  /// **'تم إرجاع الطلب جزئياً للتاجر'**
  String get deliveryStatusPartiallyReturned;

  /// Delivery status - postponed
  ///
  /// In ar, this message translates to:
  /// **'تم إعادة جدولة الطلب لتاريخ آخر للتسليم'**
  String get deliveryStatusPostponed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
