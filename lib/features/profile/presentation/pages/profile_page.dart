import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:zalando_clone_app/features/orders/presentation/pages/orders_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zalando_clone_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:zalando_clone_app/features/profile/presentation/pages/help_support_page.dart';
import 'package:zalando_clone_app/features/profile/presentation/pages/privacy_security_page.dart';
import 'package:zalando_clone_app/features/profile/presentation/pages/contact_us_page.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_order.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_shimmer.dart';
import '../widgets/logout_dialog.dart';
import '../../../home/presentation/constants/home_constants.dart';
import '../../../payment_method/presentation/pages/payment_method_page.dart';
import '../../../payment_method/presentation/bloc/payment_method_bloc.dart';
import '../../../payment_method/presentation/bloc/payment_method_event.dart';
import '../../../addresses/presentation/pages/addresses_page.dart';
import '../../../../features/addresses/addresses.dart' as Addresses;
import '../../../settings/presentation/pages/notifications_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';
import '../../../auth/presentation/bloc/biometric_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
// import 'package:restart_app/restart_app.dart'; // Removed due to Android namespace issues
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool _isGuest = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkGuest();
    final currentState = context.read<ProfileBloc>().state;
    if (currentState is! ProfileLoaded) {
      context.read<ProfileBloc>().add(LoadUserProfile());
    }
  }

  Future<void> _checkGuest() async {
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final cached = await storage.read(key: AppConstants.userKey);
      final isGuest = (cached ?? '').toLowerCase().contains('guest: true');
      if (mounted) {
        setState(() {
          _isGuest = isGuest;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LoggedOut) {
            debugPrint('ProfilePage:Listener → LoggedOut received, dispatching AuthBloc.LogoutRequested');
            context.read<AuthBloc>().add(LogoutRequested());
            context.read<BiometricBloc>().add(DisableBiometric());
            // Clear currency data
            context.read<CurrencyProvider>().clearCurrency();
            AppSnackBar.success(context, AppLocalizations.of(context)!.loggedOutSuccessfully);
            // Don't navigate here - let AuthWrapper handle navigation after AuthBloc completes
          } else if (state is AccountDeleted) {
            debugPrint('ProfilePage:Listener → AccountDeleted received, dispatching AuthBloc.LogoutRequested');
            context.read<AuthBloc>().add(LogoutRequested());
            context.read<BiometricBloc>().add(DisableBiometric());
            // Clear currency data
            context.read<CurrencyProvider>().clearCurrency();
            AppSnackBar.success(context, AppLocalizations.of(context)!.accountDeletedSuccessfully);
            // Don't navigate here - let AuthWrapper handle navigation after AuthBloc completes
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (_isGuest) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline, 
                              size: 44, 
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.mdSpacing),
                          Text(
                            AppLocalizations.of(context)!.guestUser,
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.lgFontSize, 
                              fontWeight: FontWeight.w700, 
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            AppLocalizations.of(context)!.signInToUnlockFeatures,
                            style: AppFonts.getTextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveConstants.lgSpacing),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushAuth(
                                  BlocProvider(
                                    create: (context) => di.sl<BiometricBloc>(),
                                    child: const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(AppLocalizations.of(context)!.signIn,
                                style: AppFonts.getTextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            );
          }
          if (state is ProfileInitial || state is ProfileLoading || state is ProfileUpdating) {
            return const ProfileShimmer();
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingProfile,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.lgFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  Text(
                    state.message,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.smFontSize,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadUserProfile());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdated) {
            final UserProfile currentProfile = state is ProfileLoaded 
                ? state.profile 
                : (state as ProfileUpdated).profile;
            final List<UserOrder> currentOrders = state is ProfileLoaded 
                ? state.orders 
                : [];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppBar(
                    backgroundColor: colorScheme.background,
                    elevation: 0,
                    title: Text(
                      AppLocalizations.of(context)!.profile,
                      style: AppFonts.getTextStyle(
                        fontSize: ResponsiveConstants.titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    iconTheme: IconThemeData(
                      color: colorScheme.onBackground,
                    ),
                    actions: [
                      IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: colorScheme.onBackground,
                    ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => di.sl<SettingsBloc>(),
                                child: const SettingsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    child: Column(
                      children: [
                        ProfileHeader(profile: currentProfile),
                        SizedBox(height: ResponsiveConstants.lgSpacing),
                      ProfileMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: AppLocalizations.of(context)!.myOrders,
                          subtitle: '${currentOrders.length} ${AppLocalizations.of(context)!.orders}',
                          iconColor: Colors.blue.shade600,
                          iconBackgroundColor: Colors.blue.shade50,
                          onTap: () {
                            context.read<ProfileBloc>().add(LoadUserOrders());
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => di.sl<OrdersBloc>(),
                                  child: const OrdersPage(),
                                ),
                              ),
                            );
                          },
                        ),

                        ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          title: AppLocalizations.of(context)!.addresses,
                          subtitle: AppLocalizations.of(context)!.manageDeliveryAddresses,
                          iconColor: Colors.green.shade600,
                          iconBackgroundColor: Colors.green.shade50,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      di.sl<Addresses.AddressBloc>(),
                                  child: const AddressesPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.payment_outlined,
                          title: AppLocalizations.of(context)!.paymentMethods,
                          subtitle: AppLocalizations.of(context)!.managePaymentOptions,
                          iconColor: Colors.orange.shade600,
                          iconBackgroundColor: Colors.orange.shade50,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => di.sl<PaymentMethodBloc>()..add(LoadPaymentMethods()),
                                  child: const PaymentMethodPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          title: AppLocalizations.of(context)!.notifications,
                          subtitle: AppLocalizations.of(context)!.manageNotificationPreferences,
                          iconColor: Colors.purple.shade600,
                          iconBackgroundColor: Colors.purple.shade50,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.settings,
                          title: AppLocalizations.of(context)!.settings,
                          subtitle: AppLocalizations.of(context)!.appPreferencesAndConfiguration,
                          iconColor: Colors.indigo.shade600,
                          iconBackgroundColor: Colors.indigo.shade50,
                          onTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.security_outlined,
                          title: AppLocalizations.of(context)!.privacyAndSecurity,
                          subtitle: AppLocalizations.of(context)!.manageYourPrivacySettings,
                          iconColor: Colors.teal.shade600,
                          iconBackgroundColor: Colors.teal.shade50,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => di.sl<BiometricBloc>(),
                                  child: const PrivacySecurityPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        ProfileMenuItem(
                          icon: Icons.contact_mail_outlined,
                          title: _tr(context, en: 'Contact Us', ar: 'اتصل بنا'),
                          subtitle: _tr(context, en: 'Get in touch with our team', ar: 'تواصل مع فريقنا'),
                          iconColor: Colors.amber.shade700,
                          iconBackgroundColor: Colors.amber.shade50,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ContactUsPage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        Divider(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        SizedBox(height: ResponsiveConstants.mdSpacing),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          title: AppLocalizations.of(context)!.logout,
                          subtitle: AppLocalizations.of(context)!.signOutOfYourAccount,
                          iconColor: Colors.red.shade600,
                          iconBackgroundColor: Colors.red.shade50,
                          textColor: Colors.red.shade700,
                          onTap: () {
                            debugPrint('ProfilePage:UI → Logout tapped, showing dialog');
                            _showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during logout
      builder: (context) => const LogoutDialog(),
    );
  }

  String _tr(BuildContext context, {required String en, required String ar}) {
    return Directionality.of(context) == TextDirection.rtl ? ar : en;
  }
}
