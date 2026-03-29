import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../widgets/address_card.dart';
import '../widgets/address_shimmer.dart';
import 'edit_address_page.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const LoadAddresses());
  }

  // Helper method to translate address-related messages
  String _translateMessage(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    final msg = message.toLowerCase();
    
    if (msg.contains('default address updated successfully')) {
      return l10n.defaultAddressUpdatedSuccessfully;
    } else if (msg.contains('address added successfully')) {
      return l10n.addressAddedSuccessfully;
    } else if (msg.contains('address added')) {
      return l10n.addressAdded;
    } else if (msg.contains('address updated successfully')) {
      return l10n.addressUpdatedSuccessfully;
    } else if (msg.contains('address updated')) {
      return l10n.addressUpdated;
    } else if (msg.contains('address deleted successfully')) {
      return l10n.addressDeletedSuccessfully;
    } else if (msg.contains('address deleted')) {
      return l10n.addressDeleted;
    }
    
    // Return original message if no translation found
    return message;
  }

  String _translateErrorMessage(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    final msg = message.toLowerCase();
    if (msg.contains('address') ||
        msg.contains('country') ||
        msg.contains('state') ||
        msg.contains('province') ||
        msg.contains('network') ||
        msg.contains('failed') ||
        msg.contains('error') ||
        msg.contains('exception')) {
      return l10n.errorSavingAddress;
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 20),
        onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        AppLocalizations.of(context)!.myAddresses,
        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
   
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          await HapticService.buttonClick();
          _openAddAddress();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: Text(
          AppLocalizations.of(context)!.addAddress,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressSuccess) {
            final msg = state.message.toLowerCase();
            // Do not show a snackbar for setting default address
            if (!msg.contains('default')) {
              final translatedMessage = _translateMessage(context, state.message);
              AppSnackBar.success(context, translatedMessage);
            }
          } else if (state is AddressError) {
            AppSnackBar.error(context, _translateErrorMessage(context, state.message));
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return _buildLoadingState();
          }
          if (state is AddressesLoaded) {
            if (state.addresses.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAddressesList(state.addresses);
          }
          if (state is AddressUpdating) {
            if (state.addresses.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAddressesList(state.addresses);
          }
          if (state is AddressSuccess && state.addresses != null) {
            // Handle success state with addresses (for immediate UI updates)
            if (state.addresses!.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAddressesList(state.addresses!);
          }
          // Handle countries/states loading states - these come from edit page
          // We should preserve the previous addresses state instead of showing loading
          if (state is CountriesLoading || state is CountriesLoaded || 
              state is StatesLoading || state is StatesLoaded) {
            // Try to preserve previous addresses state if available
            // This prevents the main page from showing loading when edit page loads countries/states
            return _buildEmptyState();
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const AddressShimmer();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.xlPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 72,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          Text(
            AppLocalizations.of(context)!.noAddressesYet,
            style: AppFonts.getTextStyle(fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            AppLocalizations.of(context)!.addYourFirstDeliveryAddress,
            style: AppFonts.getTextStyle(fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.xlSpacing),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                await HapticService.buttonClick();
                _openAddAddress();
              },
              icon: const Icon(Icons.add_location_alt),
              label: Text(
                AppLocalizations.of(context)!.addYourFirstAddress,
                style: AppFonts.getTextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesList(List<dynamic> addresses) {
    return ListView.separated(
      key: const PageStorageKey('addresses_list'),
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => SizedBox(height: ResponsiveConstants.mdSpacing),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return AddressCard(
          address: address,
          onEdit: () => _openEditAddress(address),
          onDelete: () => _showDeleteConfirmation(address),
          onSetDefault: () => _setDefaultAddress(address),
        );
      },
    );
  }

  void _openAddAddress() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: const EditAddressPage(),
        ),
      ),
    );
    if (mounted && result == true) {
      context.read<AddressBloc>().add(const LoadAddresses());
    }
  }

  void _openEditAddress(dynamic address) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: EditAddressPage(address: address),
        ),
      ),
    );
    if (mounted && result == true) {
      context.read<AddressBloc>().add(const LoadAddresses());
    }
  }

  void _setDefaultAddress(dynamic address) {
    if (!address.isDefault) {
      context.read<AddressBloc>().add(SetDefaultAddressEvent(address.id));
    }
  }

  void _showDeleteConfirmation(dynamic address) {
    final addressBloc = context.read<AddressBloc>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: colorScheme.error, size: 24),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.deleteAddress,
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.areYouSureDeleteAddress,
          style: AppFonts.getTextStyle(fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppFonts.getTextStyle(color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
              addressBloc.add(DeleteAddressEvent(address.id));
        },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

 
}