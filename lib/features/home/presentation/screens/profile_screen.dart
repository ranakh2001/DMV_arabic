import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
import '../../../legal/presentation/screens/contact_us_screen.dart';
import '../../../legal/presentation/screens/privacy_policy_screen.dart';
import '../widgets/edit_field_dialog.dart';
import '../widgets/language_toggle_row.dart';
import 'change_password_screen.dart';
import '../widgets/profile_field_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/selected_state_card.dart';
import '../widgets/settings_link_tile.dart';
import '../widgets/tab_screen_header.dart';

/// The "حسابي" (My Account) tab — profile info, selected state, account
/// settings and sign-out. All edits are local-only for now (UI ahead of the
/// backend); nothing here calls an API.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late String _name;
  late String _email;
  late String _phone;
  late String _selectedState;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    final prefs = ref.read(prefsServiceProvider);
    _name = user?.name ?? prefs.userName ?? 'رنا الخضري';
    _email = user?.email ?? prefs.userEmail ?? 'rana@example.com';
    _phone = user?.phone ?? prefs.userPhone ?? '+1 555 123 4567';
    _selectedState = prefs.selectedState ?? 'كاليفورنيا';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity),
          child: ListView(
            padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(16), context.sp(20), context.sp(24)),
            children: [
              TabScreenHeader(title: context.t('profile.title')),
              SizedBox(height: context.sp(20)),
              ProfileHeaderCard(
                name: _name,
                email: _email,
                onEditAvatar: () => _showComingSoon(context),
              ),
              SizedBox(height: context.sp(20)),
              SelectedStateCard(
                selectedState: _selectedState,
                onChanged: _onStateChanged,
              ),
              SizedBox(height: context.sp(16)),
              GlassContainer(
                radius: 20,
                child: Column(
                  children: [
                    ProfileFieldTile(
                      label: context.t('field.name'),
                      value: _name,
                      onEdit: () => _editField(
                        label: context.t('field.name'),
                        initialValue: _name,
                        validator: Validators.name(context),
                        onSaved: (v) => setState(() => _name = v),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    ProfileFieldTile(
                      label: context.t('field.email'),
                      value: _email,
                      onEdit: () => _editField(
                        label: context.t('field.email'),
                        initialValue: _email,
                        validator: Validators.email(context),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (v) => setState(() => _email = v),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    ProfileFieldTile(
                      label: context.t('field.phone'),
                      value: _phone,
                      onEdit: () => _editField(
                        label: context.t('field.phone'),
                        initialValue: _phone,
                        validator: Validators.phone(context),
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => setState(() => _phone = v),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    ProfileFieldTile(
                      label: context.t('profile.field_photo'),
                      onEdit: () => _showComingSoon(context),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: context.sp(12),
                            backgroundColor: context.appPrimary.withAlpha(35),
                            child: Icon(Icons.person_rounded, color: context.appPrimary, size: context.sp(14)),
                          ),
                          SizedBox(width: context.sp(8)),
                          Text(
                            context.t('profile.edit_photo'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w600,
                              color: context.appPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(16)),
              GlassContainer(
                radius: 20,
                child: Column(
                  children: [
                    SettingsLinkTile(
                      icon: Icons.lock_outline_rounded,
                      label: context.t('profile.change_password'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    SettingsLinkTile(
                      icon: Icons.privacy_tip_outlined,
                      label: context.t('profile.privacy_policy'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    SettingsLinkTile(
                      icon: Icons.support_agent_rounded,
                      label: context.t('profile.contact_us'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const ContactUsScreen()),
                      ),
                    ),
                    Divider(height: 1, color: context.appGlassBorder),
                    LanguageToggleRow(
                      isArabic: isArabic,
                      onChanged: (toArabic) => ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(toArabic ? 'ar' : 'en')),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(20)),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appError,
                  side: BorderSide(color: context.appError.withAlpha(140)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(context.t('auth.logout')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStateChanged(String value) {
    setState(() => _selectedState = value);
    ref.read(prefsServiceProvider).setSelectedState(value);
    _showSnackBar(context.ts('profile.field_updated', {'field': context.t('profile.selected_state')}));
  }

  Future<void> _editField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) async {
    final result = await showEditFieldDialog(
      context,
      label: label,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
    );
    if (result == null || !mounted) return;
    onSaved(result);
    _showSnackBar(context.ts('profile.field_updated', {'field': label}));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.t('auth.logout')),
        content: Text(dialogContext.t('auth.logout.confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.t('common.confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOutLocally();
    }
  }

  void _showComingSoon(BuildContext context) => _showSnackBar(context.t('home.coming_soon'));

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
