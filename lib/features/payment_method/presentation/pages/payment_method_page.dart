import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/responsive_constants.dart';
import '../bloc/payment_method_bloc.dart';
import '../bloc/payment_method_event.dart';
import '../bloc/payment_method_state.dart';
import '../widgets/payment_method_card.dart';
import 'add_payment_method_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  void initState() {
    super.initState();
    // Load once on page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaymentMethodBloc>().add(LoadPaymentMethods());
      }
    });
  }
    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.paymentMethods,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
          ),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.add,
        //       color: colorScheme.onSurface,
        //     ),
        //     onPressed: () async {
        //   await HapticService.buttonClick();
        //   _navigateToAddPaymentMethod(context);
        // },
        //   ),
        // ],
      ),
      body: BlocListener<PaymentMethodBloc, PaymentMethodState>(
      listener: (context, state) {
        if (state is PaymentMethodSuccess) {
          // Avoid snackbar for default toggle to keep UI subtle
          if (state.message != AppLocalizations.of(context)!.defaultPaymentMethodUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (state is PaymentMethodError) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
        builder: (context, state) {
          if (state is PaymentMethodLoading) {
            final colorScheme = Theme.of(context).colorScheme;
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          } else if (state is PaymentMethodsLoaded) {
            return _buildPaymentMethodsList(state.paymentMethods);
          } else if (state is PaymentMethodUpdating) {
            // Keep showing list while updating to avoid blinking
            return _buildPaymentMethodsList(state.paymentMethods);
          } else if (state is PaymentMethodSuccess && state.paymentMethods != null) {
            // Render with provided list when success carries data
            return _buildPaymentMethodsList(state.paymentMethods!);
          } else if (state is PaymentMethodError) {
            return _buildErrorState(state.message);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    ),
    );
  }

  Widget _buildPaymentMethodsList(List<dynamic> paymentMethods) {
    if (paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      key: const PageStorageKey('payment_methods_list'),
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        if (index >= paymentMethods.length) {
          return const SizedBox.shrink();
        }
        
        final paymentMethod = paymentMethods[index];
        return Padding(
          padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
          child: PaymentMethodCard(
            key: ValueKey(paymentMethod.id),
            paymentMethod: paymentMethod,
            onDelete: () => _deletePaymentMethod(paymentMethod.id),
            onSetDefault: () {
              if (paymentMethod.isDefault == true) return;
              _setDefaultPaymentMethod(paymentMethod.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          Text(
            AppLocalizations.of(context)!.noPaymentMethods,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.titleFontSize,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            AppLocalizations.of(context)!.addYourFirstPaymentMethod,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          ElevatedButton.icon(
            onPressed: () async {
          await HapticService.buttonClick();
          _navigateToAddPaymentMethod(context);
        },
            icon: const Icon(Icons.add),
            label: Text(
              AppLocalizations.of(context)!.addPaymentMethod,
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.lgPadding,
                vertical: ResponsiveConstants.mdPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return AppErrorView(
      message: message,
      onRetry: () async {
        await HapticService.buttonClick();
        context.read<PaymentMethodBloc>().add(LoadPaymentMethods());
      },
    );
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: context.read<PaymentMethodBloc>(),
          child: const AddPaymentMethodPage(),
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<PaymentMethodBloc>().add(LoadPaymentMethods());
      }
    });
  }

  void _deletePaymentMethod(String id) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.deletePaymentMethod,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deletePaymentMethodConfirmation,
          style: AppFonts.getTextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(dialogContext).pop();
        },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppFonts.getTextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(dialogContext).pop();
              context.read<PaymentMethodBloc>().add(DeletePaymentMethod(id));
        },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: AppFonts.getTextStyle(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(String id) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.setAsDefault,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.setDefaultPaymentMethodConfirmation,
          style: AppFonts.getTextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(dialogContext).pop();
        },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppFonts.getTextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(dialogContext).pop();
              context.read<PaymentMethodBloc>().add(SetDefaultPaymentMethod(id));
        },
            child: Text(
              AppLocalizations.of(context)!.setDefault,
              style: AppFonts.getTextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
