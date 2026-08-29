import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/notifications/notification_settings_provider.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
import '../../../legal/presentation/screens/about_us_screen.dart';
import '../../../legal/presentation/screens/contact_us_screen.dart';
import '../../../legal/presentation/screens/privacy_policy_screen.dart';
import '../../../legal/presentation/screens/terms_of_use_screen.dart';
import '../../../states/domain/entities/us_state.dart';
import '../../../states/presentation/providers/states_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/edit_field_dialog.dart';
import '../widgets/language_toggle_row.dart';
import 'change_password_screen.dart';
import '../widgets/notifications_toggle_row.dart';
import '../widgets/profile_field_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/selected_state_card.dart';
import '../widgets/settings_link_tile.dart';
import '../widgets/theme_toggle_row.dart';
import '../../../home/presentation/widgets/tab_screen_header.dart';

/// The "حسابي" (My Account) tab — profile info, selected state, account
/// settings and sign-out. Profile fields are backed by `/users/profile`.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final themeMode = ref.watch(themeModeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final prefs = ref.read(prefsServiceProvider);
    final cachedUser = ref.read(authControllerProvider).user;
    final statesAsync = ref.watch(statesProvider);

    final name = profile?.fullName ?? cachedUser?.name ?? prefs.userName ?? '';
    final email = profile?.email ?? cachedUser?.email ?? prefs.userEmail ?? '';
    final phone =
        profile?.phoneNumber ?? cachedUser?.phone ?? prefs.userPhone ?? '';
    final rawPhotoUrl = profile?.profilePhotoUrl ?? cachedUser?.avatarUrl;
    final photoUrl = rawPhotoUrl != null
        ? ApiConstants.resolveStorageUrl(rawPhotoUrl)
        : null;

    final currentStateId = profile?.stateId ?? prefs.selectedStateId;
    final resolvedStateName = statesAsync.maybeWhen(
      data: (states) {
        for (final s in states) {
          if (s.id == currentStateId) return s.name(arabic: isArabic);
        }
        return null;
      },
      orElse: () => null,
    );
    final stateDisplayName =
        resolvedStateName ??
        prefs.selectedState ??
        context.t('profile.select_state_sheet_title');

    ref.listen(profileControllerProvider, (prev, next) {
      if (next.loadStatus == ProfileLoadStatus.failed &&
          prev?.loadStatus != ProfileLoadStatus.failed &&
          next.loadError != null) {
        _showSnackBar(next.loadError!);
      }
    });

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop || context.isTablet
                ? 520
                : double.infinity,
          ),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(profileControllerProvider.notifier).load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(16),
                context.sp(20),
                context.sp(24),
              ),
              children: [
                TabScreenHeader(title: context.t('profile.title')),
                SizedBox(height: context.sp(20)),
                ProfileHeaderCard(
                  name: name,
                  email: email,
                  photoUrl: photoUrl,
                  onEditAvatar: () => _editPhoto(),
                ),
                SizedBox(height: context.sp(20)),
                SelectedStateCard(
                  displayName: stateDisplayName,
                  currentStateId: currentStateId,
                  onChanged: (state) => _onStateChanged(state, isArabic),
                ),
                SizedBox(height: context.sp(16)),
                GlassContainer(
                  radius: 20,
                  child: Column(
                    children: [
                      ProfileFieldTile(
                        label: context.t('field.name'),
                        value: name,
                        onEdit: () => _editField(
                          label: context.t('field.name'),
                          apiField: 'full_name',
                          initialValue: name,
                          validator: Validators.name(context),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      ProfileFieldTile(
                        label: context.t('field.email'),
                        value: email,
                        onEdit: () => _editField(
                          label: context.t('field.email'),
                          apiField: 'email',
                          initialValue: email,
                          validator: Validators.email(context),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      ProfileFieldTile(
                        label: context.t('field.phone'),
                        value: phone,
                        onEdit: () => _editField(
                          label: context.t('field.phone'),
                          apiField: 'phone_number',
                          initialValue: phone,
                          validator: Validators.phone(context),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      ProfileFieldTile(
                        label: context.t('profile.field_photo'),
                        onEdit: () => _editPhoto(),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: context.sp(12),
                              backgroundColor: context.appPrimary.withAlpha(35),
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      color: context.appPrimary,
                                      size: context.sp(14),
                                    )
                                  : null,
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
                          MaterialPageRoute<void>(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      SettingsLinkTile(
                        icon: Icons.privacy_tip_outlined,
                        label: context.t('profile.privacy_policy'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      SettingsLinkTile(
                        icon: Icons.gavel_rounded,
                        label: context.t('profile.terms_of_use'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const TermsOfUseScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      SettingsLinkTile(
                        icon: Icons.support_agent_rounded,
                        label: context.t('profile.contact_us'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ContactUsScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      SettingsLinkTile(
                        icon: Icons.info_outline_rounded,
                        label: context.t('profile.about_us'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutUsScreen(),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      LanguageToggleRow(
                        isArabic: isArabic,
                        onChanged: (toArabic) => ref
                            .read(localeProvider.notifier)
                            .setLocale(Locale(toArabic ? 'ar' : 'en')),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      ThemeToggleRow(
                        mode: themeMode,
                        onChanged: (mode) =>
                            ref.read(themeModeProvider.notifier).setMode(mode),
                      ),
                      Divider(height: 1, color: context.appGlassBorder),
                      NotificationsToggleRow(
                        value: notificationSettings.push,
                        onChanged: (v) => ref
                            .read(notificationSettingsProvider.notifier)
                            .update(notificationSettings.copyWith(push: v)),
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
      ),
    );
  }

  Future<void> _onStateChanged(UsState state, bool isArabic) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setSelectedStateId(state.id);
    await prefs.setSelectedState(state.name(arabic: isArabic));

    final succeeded = await ref
        .read(profileControllerProvider.notifier)
        .updateSelectedState(state.id);
    if (!mounted) return;

    if (succeeded) {
      _showSnackBar(
        context.ts('profile.field_updated', {
          'field': context.t('profile.selected_state'),
        }),
      );
    } else {
      final error = ref.read(profileControllerProvider).updateError;
      _showSnackBar(error ?? context.t('error.unknown'));
    }
  }

  Future<void> _editField({
    required String label,
    required String apiField,
    required String initialValue,
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
    if (result == null || !mounted || result == initialValue) return;

    final succeeded = await ref.read(profileControllerProvider.notifier).update(
      {apiField: result},
    );
    if (!mounted) return;

    if (succeeded) {
      _showSnackBar(context.ts('profile.field_updated', {'field': label}));
    } else {
      final error = ref.read(profileControllerProvider).updateError;
      _showSnackBar(error ?? context.t('error.unknown'));
    }
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
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _editPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(sheetContext.t('profile.photo_gallery')),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(sheetContext.t('profile.photo_camera')),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 70,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? context.t('error.unknown'));
      return;
    }
    if (picked == null || !mounted) return;

    final succeeded = await ref
        .read(profileControllerProvider.notifier)
        .uploadPhoto(File(picked.path));
    if (!mounted) return;

    if (succeeded) {
      _showSnackBar(context.t('profile.photo_updated'));
    } else {
      final error = ref.read(profileControllerProvider).updateError;
      _showSnackBar(error ?? context.t('error.unknown'));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
