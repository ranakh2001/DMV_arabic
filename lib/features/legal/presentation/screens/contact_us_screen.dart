import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/selectable_chip_group.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
import '../../../home/presentation/widgets/home_background.dart';

/// "تواصل معنا" — reached from the Profile tab. Local-only for now (UI
/// ahead of the backend): submitting shows a success message but nothing is
/// sent anywhere yet.
class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _requestType = 'technical';

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('contact.success'))));
    _subjectCtrl.clear();
    _messageCtrl.clear();
    setState(() => _requestType = 'technical');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final prefs = ref.read(prefsServiceProvider);
    final email = user?.email ?? prefs.userEmail ?? 'rana@example.com';

    final typeOptions = [
      ('technical', context.t('contact.type.technical')),
      ('payment', context.t('contact.type.payment')),
      ('suggestion', context.t('contact.type.suggestion')),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const HomeBackground(),
          SafeArea(
            child: Column(
              children: [
                AppScreenHeader(title: context.t('profile.contact_us')),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(8), context.sp(20), context.sp(24)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.t('contact.heading'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: context.sp(22),
                                  fontWeight: FontWeight.w800,
                                  color: context.appTextPrimary,
                                ),
                              ),
                              SizedBox(height: context.sp(10)),
                              Text(
                                context.t('contact.subtitle'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: context.sp(14),
                                  color: context.appTextSecondary,
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(height: context.sp(24)),
                              GlassContainer(
                                radius: 20,
                                padding: EdgeInsets.all(context.sp(18)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      context.t('contact.request_type_label'),
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: context.sp(14),
                                        fontWeight: FontWeight.w700,
                                        color: context.appTextPrimary,
                                      ),
                                    ),
                                    SizedBox(height: context.sp(10)),
                                    SelectableChipGroup<String>(
                                      options: typeOptions,
                                      value: _requestType,
                                      onChanged: (v) => setState(() => _requestType = v),
                                    ),
                                    SizedBox(height: context.sp(18)),
                                    TextFormField(
                                      controller: _subjectCtrl,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        color: context.appTextPrimary,
                                        fontSize: context.sp(15),
                                      ),
                                      decoration: InputDecoration(
                                        labelText: context.t('contact.subject_label'),
                                        hintText: context.t('contact.subject_hint'),
                                      ),
                                      validator: Validators.subject(context),
                                    ),
                                    SizedBox(height: context.sp(16)),
                                    TextFormField(
                                      controller: _messageCtrl,
                                      minLines: 4,
                                      maxLines: 6,
                                      textInputAction: TextInputAction.newline,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        color: context.appTextPrimary,
                                        fontSize: context.sp(15),
                                      ),
                                      decoration: InputDecoration(
                                        labelText: context.t('contact.message_label'),
                                        hintText: context.t('contact.message_hint'),
                                        alignLabelWithHint: true,
                                      ),
                                      validator: Validators.message(context),
                                    ),
                                    SizedBox(height: context.sp(16)),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: context.sp(14), vertical: context.sp(12)),
                                      decoration: BoxDecoration(
                                        color: context.appGlassTint,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: context.appGlassBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.alternate_email_rounded, size: context.sp(18), color: context.appPrimary),
                                          SizedBox(width: context.sp(10)),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.t('contact.registered_email'),
                                                  style: TextStyle(
                                                    fontFamily: 'Almarai',
                                                    fontSize: context.sp(12),
                                                    color: context.appTextSecondary,
                                                  ),
                                                ),
                                                SizedBox(height: context.sp(2)),
                                                Text(
                                                  email,
                                                  textDirection: TextDirection.ltr,
                                                  style: TextStyle(
                                                    fontFamily: 'Almarai',
                                                    fontSize: context.sp(14),
                                                    fontWeight: FontWeight.w700,
                                                    color: context.appTextPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.sp(22)),
                              ElevatedButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.send_rounded),
                                label: Text(context.t('contact.send')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
