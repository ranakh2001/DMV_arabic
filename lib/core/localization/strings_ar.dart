/// Arabic string map. Keys match [StringsEn].
const Map<String, String> stringsAr = {
  // --- App
  'app.name': 'DMV بالعربي',
  'app.tagline': 'استعد لاختبار رخصة القيادة',

  // --- Common
  'common.ok': 'حسناً',
  'common.cancel': 'إلغاء',
  'common.confirm': 'تأكيد',
  'common.save': 'حفظ',
  'common.close': 'إغلاق',
  'common.back': 'رجوع',
  'common.next': 'التالي',
  'common.skip': 'تخطي',
  'common.loading': 'جارٍ التحميل...',
  'common.retry': 'إعادة المحاولة',
  'common.error': 'خطأ',
  'common.success': 'نجاح',
  'common.or': 'أو',
  'common.required': 'مطلوب',
  'common.optional': 'اختياري',

  // --- Welcome screen
  'auth.welcome.greeting': 'أهلا بك',
  'auth.welcome.subtitle':
      'سجّل الدخول أو أنشئ حسابًا للبدء في رحلة الحصول على رخصة القيادة',
  'auth.welcome.login_btn': 'تسجيل الدخول',
  'auth.welcome.register_btn': 'إنشاء حساب جديد',
  'auth.welcome.terms': 'بتسجيلك أنت توافق على شروط الخدمة',

  // --- Auth screens
  'auth.login.title': 'تسجيل الدخول',
  'auth.login.subtitle': 'أهلاً بك مجدداً في رحلتك نحو رخصة القيادة',
  'auth.login.submit': 'دخول',
  'auth.login.no_account': 'ما عندك حساب؟',
  'auth.login.sign_up': 'سجل الآن',
  'auth.login.forgot': 'نسيت كلمة المرور؟',

  'auth.register.title': 'إنشاء حساب',
  'auth.register.subtitle': 'انضم الآن وابدأ الاستعداد',
  'auth.register.welcome_title': 'مرحباً بك معنا',
  'auth.register.welcome_subtitle':
      'ابدأ رحلتك للحصول على رخصة القيادة الأمريكية بكل سهولة واحترافية.',
  'auth.register.submit': 'إنشاء الحساب +',
  'auth.register.have_account': 'لديك حساب بالفعل؟',
  'auth.register.sign_in': 'تسجيل الدخول',
  'auth.register.agree_terms': 'أوافق على ',
  'auth.register.terms_use': 'شروط الاستخدام',
  'auth.register.and_privacy': ' و',
  'auth.register.privacy_policy': 'سياسة الخصوصية',
  'auth.register.terms_suffix': ' الخاصة بـ DMV بالعربي.',

  'auth.verify.title': 'تحقق من هويتك',
  'auth.verify.subtitle': 'أدخل الرمز المرسل إلى',
  'auth.verify.submit': 'تحقق',
  'auth.verify.resend': 'إعادة إرسال الرمز',
  'auth.verify.resend_in': 'إعادة الإرسال بعد',
  'auth.verify.expires_in': 'ينتهي الرمز بعد',
  'auth.verify.expired': 'انتهت صلاحية الرمز',
  'auth.verify.max_resends':
      'لقد وصلت إلى الحد الأقصى لإعادة الإرسال (3 مرات/ساعة).',
  'auth.verify.resend_unavailable':
      'لم يصلك الرمز؟ يرجى المحاولة لاحقاً أو التواصل مع الدعم.',

  'auth.forgot.title': 'نسيت كلمة المرور',
  'auth.forgot.subtitle': 'أدخل بريدك أو رقم هاتفك لإعادة تعيين كلمة المرور',
  'auth.forgot.submit': 'إرسال رمز الاسترداد',
  'auth.forgot.back_login': 'العودة لتسجيل الدخول',

  'auth.reset.title': 'إعادة تعيين كلمة المرور',
  'auth.reset.subtitle': 'أدخل الرمز وكلمة المرور الجديدة',
  'auth.reset.submit': 'تعيين كلمة مرور جديدة',

  'auth.social.google': 'المتابعة بحساب Google',
  'auth.social.apple': 'المتابعة بحساب Apple',
  'auth.social.unavailable': 'تسجيل الدخول الاجتماعي غير متاح حالياً.',

  'auth.logout': 'تسجيل الخروج',
  'auth.logout.confirm': 'هل أنت متأكد من تسجيل الخروج؟',

  // --- Form fields
  'field.name': 'الاسم الكامل',
  'field.name_hint': 'ادخل اسمك بالكامل',
  'field.email': 'البريد الإلكتروني',
  'field.email_hint': 'أدخل بريدك الإلكتروني',
  'field.phone': 'رقم الهاتف',
  'field.phone_hint': '+1 (555) 000-0000',
  'field.email_or_phone': 'البريد الإلكتروني أو رقم الهاتف',
  'field.password': 'كلمة المرور',
  'field.password_hint': '••••••••',
  'field.confirm_password': 'تأكيد كلمة المرور',
  'field.confirm_password_hint': '••••••••',
  'field.code': 'رمز التحقق',
  'field.current_password': 'كلمة المرور الحالية',
  'field.new_password': 'كلمة المرور الجديدة',
  'field.state': 'الولاية',
  'field.state_hint': 'اختر ولايتك',
  'validator.state.required': 'يرجى اختيار الولاية.',

  // --- Password strength
  'password.strength.label': 'قوة كلمة المرور:',
  'password.strength.weak': 'ضعيفة',
  'password.strength.fair': 'مقبولة',
  'password.strength.good': 'جيدة',
  'password.strength.strong': 'قوية',

  // --- Errors (Arabic first)
  'error.network': 'لا يوجد اتصال بالإنترنت، الرجاء التحقق من الشبكة',
  'error.server': 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
  'error.timeout': 'انتهت مهلة الطلب. تحقق من اتصالك.',
  'error.unauthorized': 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
  'error.storage': 'خطأ في التخزين الآمن. سيتم تسجيل خروجك تلقائياً.',
  'error.unknown': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',

  // --- Home screen
  'home.greeting': 'أهلاً بك، {name} 👋',
  'home.subtitle': 'استمر في التحضير - اختبارك أقرب مما تتخيل 🚗',
  'home.progress_label': 'إجمالي التقدم',
  'home.subscribe_title': 'اشترك الآن',
  'home.subscribe_subtitle': 'للوصول الكامل',
  'home.subscribe_cta': 'اشترك',
  'home.stats_card': 'إحصائياتي',
  'home.quick_test_card': 'اختبار سريع',
  'home.continue_section_title': 'أكمل من حيث توقفت',
  'home.start_first_simulation_title': 'ابدأ أول محاكاة لك الآن',
  'home.view_all': 'عرض الكل',
  'home.simulation_test_title': 'اختبار محاكاة – ولاية كاليفورنيا',
  'home.simulation_test_title_named': 'اختبار محاكاة – ولاية {state}',
  'home.continue_now': 'استمر الآن',
  'home.start_now': 'ابدأ الآن',
  'home.quick_quiz_subtitle': 'أجب على 10 أسئلة عشوائية',
  'home.start': 'ابدأ',
  'home.no_notifications': 'لا توجد إشعارات جديدة',
  'home.coming_soon': 'قريباً...',

  // --- Bottom navigation
  'nav.home': 'الرئيسية',
  'nav.simulation': 'المحاكاة',
  'nav.stats': 'إحصائياتي',
  'nav.profile': 'حسابي',

  // --- Settings
  'settings.language': 'اللغة',
  'settings.theme': 'المظهر',
  'settings.theme.dark': 'داكن',
  'settings.theme.light': 'فاتح',
  'settings.theme.system': 'تلقائي',
  'settings.language.ar': 'العربية',
  'settings.language.en': 'English',

  // --- Splash
  'splash.tagline': 'استعد لامتحان القيادة بالعربي',
  'splash.version': 'V1.0.0',
  'splash.copyright': '©MARVA-SYSTEMS',

  // --- Onboarding
  'onboarding.slide1.title': 'رحلتك نحو رخصة القيادة تبدأ هنا',
  'onboarding.slide1.subtitle':
      'استعد لامتحان السياقة الأمريكي بثقة – أسئلة حقيقية، شرح واضح، بالعربي',
  'onboarding.slide1.cta': 'ابدأ الآن',
  'onboarding.slide2.title': 'اختبارات حقيقية من كل ولاية',
  'onboarding.slide2.subtitle':
      'أكثر من 250 سؤال مقسمة حسب ولايتك – مع شرح لكل إجابة بالعربي الفصيح',
  'onboarding.slide2.feat1': 'أسئلة ذكية',
  'onboarding.slide2.feat2': 'وضع محاكاة',
  'onboarding.slide2.feat3': 'تتبع تقدمك',
  'onboarding.slide3.title': 'اختر ولايتك للبدء',
  'onboarding.slide3.subtitle': 'كل ولاية لها قوانين خاصة – نوصلك للأسئلة الصح',
  'onboarding.slide3.placeholder': 'اختر الولاية...',
  'onboarding.slide3.hint': 'يمكنك تغيير الولاية لاحقاً من الإعدادات',
  'onboarding.slide1.badge_questions': '+250',
  'onboarding.slide1.badge_states': '50 ولاية',
  'onboarding.slide1.badge_quiz': 'اختبار حسب الولاية',
  'onboarding.slide3.search': 'ابحث...',
  'onboarding.start': 'هيا نبدأ',
  'onboarding.have_account': 'عندك حساب؟ سجل دخولك',

  // --- Notifications
  'notifications.title': 'الإشعارات',
  'notifications.empty': 'لا توجد إشعارات بعد',
  'notifications.error': 'تعذر جلب الإشعارات.',
  'notif.push': 'إشعارات الدفع',

  // --- Forgot password flow
  'auth.forgot.badge': 'استعادة كلمة المرور',
  'auth.forgot.question': 'نسيت كلمة المرور؟',
  'auth.forgot.phone_subtitle':
      'أدخل رقم هاتفك وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
  'auth.forgot.send_code': 'إرسال رمز التحقق',
  'auth.forgot.remember': 'تذكّرت كلمة المرور؟',
  'auth.forgot.sign_in_link': 'سجّل دخولك',

  // --- Forgot verify step
  'auth.forgot_verify.badge': 'التحقق من الهوية',
  'auth.forgot_verify.title': 'أدخل رمز التحقق',
  'auth.forgot_verify.subtitle': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
  'auth.forgot_verify.no_code': 'لم تستلم الرمز؟',
  'auth.forgot_verify.submit': 'تحقق من الرمز',
  'auth.forgot_verify.resend': 'إعادة إرسال الرمز',

  // --- Reset password
  'auth.reset.badge': 'الخطوة الأخيرة',
  'auth.reset.new_title': 'كلمة مرور جديدة',
  'auth.reset.new_subtitle': 'اختر كلمة مرور قوية لحماية حسابك',
  'auth.reset.save': 'حفظ كلمة المرور',
  'auth.reset.header': 'إنشاء كلمة مرور',

  // --- Password rules checklist
  'password.rule.length': 'على الأقل 8 أحرف',
  'password.rule.uppercase': 'يحتوي على حرف كبير (A-Z)',
  'password.rule.digit': 'يحتوي على رقم واحد على الأقل',
  'password.rule.special': r'يحتوي على رمز خاص (@#$%^&*)',

  // --- Profile tab
  'profile.title': 'الملف الشخصي',
  'profile.subscriber': 'مشترك',
  'profile.selected_state': 'الولاية المختارة',
  'profile.field_photo': 'الصورة الشخصية',
  'profile.edit_photo': 'تعديل الصورة',
  'profile.photo_gallery': 'اختيار من المعرض',
  'profile.photo_camera': 'التقاط صورة',
  'profile.photo_updated': 'تم تحديث الصورة الشخصية',
  'profile.change_password': 'تغيير كلمة المرور',
  'profile.privacy_policy': 'سياسة الخصوصية',
  'profile.terms_of_use': 'شروط الاستخدام',
  'profile.contact_us': 'تواصل معنا',
  'profile.about_us': 'من نحن',
  'profile.ui_language': 'لغة الواجهة',
  'profile.ui_theme': 'مظهر التطبيق',
  'profile.edit_field_title': 'تعديل {field}',
  'profile.field_updated': 'تم تحديث {field}',
  'profile.select_state_sheet_title': 'اختر ولايتك',
  'profile.state_updated': 'تم تحديث الولاية',

  // --- Stats tab
  'stats.title': 'الاحصائيات',
  'stats.empty_message':
      'لا توجد بيانات بعد — أكمل أول محاكاة لك لعرض إحصائياتك',
  'stats.success_rate': 'نسبة النجاح',
  'stats.improvement': 'تحسّن {percent}% عن المعدل السابق',
  'stats.performance_message':
      'أداء ممتاز! أنت تقترب من الجاهزية التامة للاختبار الحقيقي.',
  'stats.completed_simulations': 'المحاكاة المنجزة',
  'stats.total_questions': 'إجمالي الأسئلة',
  'stats.total_questions_more': 'أكثر من {count}',
  'stats.average_score': 'متوسط النتيجة',
  'stats.highest_score': 'أعلى نتيجة',
  'stats.score_path_title': 'مسار الدرجات',
  'stats.last_10_attempts': 'آخر 10 محاولات',
  'stats.pass_threshold': 'حد النجاح',
  'stats.last_attempt': 'المحاولة الأخيرة',
  'stats.first_attempt': 'المحاولة الأولى',
  'stats.by_category_title': 'الأداء حسب الفئة',
  'stats.load_error': 'تعذر تحميل الإحصائيات.',

  // --- Simulation tab
  'simulation.title': 'محاكاة اختبار DMV',
  'simulation.ready_question': 'هل أنت مستعد لتجربة الاختبار؟',
  'simulation.details_title': 'تفاصيل الاختبار',
  'simulation.question_count_label': 'عدد الأسئلة',
  'simulation.question_count_value': '{count} سؤالاً',
  'simulation.min_pass_label': 'الحد الأدنى للنجاح',
  'simulation.min_pass_value': '{count} إجابة صحيحة',
  'simulation.time_label': 'الوقت المسموح',
  'simulation.time_value': 'بدون حد زمني',
  'simulation.autosave_note': 'يتم حفظ تقدمك تلقائياً كل 30 ثانية',
  'simulation.review_note': 'يمكنك مراجعة وتعديل إجاباتك قبل التسليم',
  'simulation.start': 'بدء المحاكاة',
  'simulation.free_trial_button': 'التجربة المجانية',

  // --- Practice (free trial) question screen
  'practice.question_progress': 'سؤال {current} من {total}',
  'practice.correct': 'إجابة صحيحة!',
  'practice.incorrect': 'إجابة خاطئة',
  'practice.next': 'السؤال التالي',
  'practice.previous': 'السؤال السابق',
  'practice.trial_ended_title': 'انتهت التجربة المجانية',
  'practice.trial_ended_message': 'لقد استخدمت {used} من {total} أسئلة مجانية',
  'practice.subscribe_now': 'اشترك الآن',

  // --- Exam question screen
  'exam.question_progress': 'سؤال {current} من {total}',
  'exam.next': 'التالي',
  'exam.previous': 'السابق',
  'exam.submit': 'تسليم الاختبار',
  'exam.submit_confirm_title': 'تسليم الاختبار؟',
  'exam.submit_confirm_message':
      'هل أنت متأكد من رغبتك في التسليم؟ لن تتمكن من تعديل إجاباتك بعد ذلك.',
  'exam.submitted_message': 'تم تسليم الاختبار بنجاح',
  'exam.exit_confirm_title': 'الخروج من المحاكاة؟',
  'exam.exit_confirm_message': 'سيتم فقدان تقدمك في هذه المحاولة.',
  'exam.exit_confirm_action': 'خروج',

  // --- Simulation exam (live API)
  'exam.picker.title': 'اختر اختبار المحاكاة',
  'exam.picker.empty': 'لا توجد اختبارات متاحة لهذه الولاية حالياً.',
  'exam.picker.error': 'تعذر جلب قائمة الاختبارات.',
  'exam.picker.questions_count': '{count} سؤال',
  'exam.picker.start': 'ابدأ',
  'exam.select_state_first': 'يرجى اختيار الولاية أولاً.',
  'exam.start_error': 'تعذر بدء الاختبار. حاول مرة أخرى.',
  'exam.history_title': 'سجل المحاولات',
  'exam.history_empty': 'لا توجد محاولات سابقة بعد.',
  'exam.history_error': 'تعذر جلب سجل المحاولات.',
  'exam.result.title': 'نتيجة الاختبار',
  'exam.result.passed': 'ناجح',
  'exam.result.failed': 'راسب',
  'exam.result.score_label': 'النتيجة',
  'exam.result.correct_label': 'إجابات صحيحة',
  'exam.result.incorrect_label': 'إجابات خاطئة',
  'exam.result.time_label_value': 'الوقت: {time}',
  'exam.result.review_title': 'مراجعة الإجابات',
  'exam.result.your_answer': 'إجابتك',
  'exam.result.correct_answer': 'الصحيحة',
  'exam.result.no_answer': 'لم تتم الإجابة',
  'exam.result.error': 'تعذر جلب نتيجة الاختبار.',
  'exam.result.done': 'تم',

  // --- Validators
  'validator.email.required': 'البريد الإلكتروني مطلوب.',
  'validator.email.invalid': 'صيغة البريد الإلكتروني غير صحيحة.',
  'validator.phone.required': 'رقم الهاتف مطلوب.',
  'validator.phone.invalid': 'أدخل رقم هاتف أمريكي صحيح.',
  'validator.email_or_phone.required': 'البريد الإلكتروني أو رقم الهاتف مطلوب.',
  'validator.password.required': 'كلمة المرور مطلوبة.',
  'validator.password.min_length': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
  'validator.confirm_password.required': 'تأكيد كلمة المرور مطلوب.',
  'validator.confirm_password.mismatch': 'كلمتا المرور غير متطابقتين.',
  'validator.code.required': 'رمز التحقق مطلوب.',
  'validator.code.invalid': 'رمز التحقق يتكون من 6 أرقام.',
  'validator.name.required': 'الاسم مطلوب.',
  'validator.subject.required': 'الموضوع مطلوب.',
  'validator.message.required': 'الرسالة مطلوبة.',

  // --- Legal: مشترك
  'legal.last_updated': 'آخر تحديث: {date}',
  'legal.contact.email': 'support@dmvarabic.com',
  'legal.contact.copied': 'تم نسخ البريد الإلكتروني',

  // --- Legal: شاشة سياسة الخصوصية
  'legal.privacy.title': 'سياسة الخصوصية والشروط',
  'legal.privacy.updated_date': '25 مايو 2024',
  'legal.privacy.s1.title': 'إخلاء المسؤولية القانونية',
  'legal.privacy.s1.body':
      'هذا التطبيق أداة تعليمية وتثقيفية فقط، تهدف لمساعدة المستخدمين على فهم قوانين القيادة في الولايات المتحدة. القوانين واللوائح الخاصة بكل ولاية قد تتغير بشكل دوري، ونحن نسعى جاهدين لتحديث المحتوى بانتظام، لكننا لا نضمن دقة المعلومات بنسبة 100% في جميع الأوقات. التطبيق ليس جهة رسمية تابعة لأي حكومة، ويظل الكتيب الرسمي الصادر عن دائرة المركبات في ولايتك هو المرجع القانوني الأول.',
  'legal.privacy.s2.title': 'اللغة والخدمات الرسمية',
  'legal.privacy.s2.body':
      'تقع على عاتق المستخدم مسؤولية التحقق من توفر اختبار القيادة الرسمي باللغة العربية في ولايته المقصودة، فلا توفر كل الولايات اختباراتها بلغات غير الإنجليزية. كما ننصح بالاستعانة بمترجمين معتمدين عند التعامل مع الوثائق الرسمية، حيث أن الترجمات المتوفرة داخل التطبيق هي لأغراض تعليمية وتبسيطية فقط، تهدف لمساعدة الطلاب على الاستعداد.',
  'legal.privacy.s3.title': 'سياسة الخصوصية وحماية البيانات',
  'legal.privacy.s3.body':
      'نجمع الحد الأدنى فقط من بياناتك الشخصية (مثل البريد الإلكتروني ونوع الولاية) لتقديم تجربة مخصصة ومتابعة تقدمك في الاختبارات. نلتزم بحماية بياناتك باستخدام تقنيات تشفير معتمدة، ونؤكد أننا لا نبيع أو نؤجر معلوماتك الشخصية لأي طرف ثالث لأغراض تجارية. تُستخدم بياناتك فقط لتحسين أداء التطبيق وحل المشكلات الفنية.',
  'legal.privacy.s4.title': 'سياسة الاشتراكات والمدفوعات',
  'legal.privacy.s4.body':
      'تتم جميع العمليات المالية عبر متاجر التطبيقات الرسمية (App Store / Google Play) وتخضع لسياساتها وشروطها. نظراً لطبيعة المحتوى الرقمي المتاح فوراً بعد الاشتراك، لا نوفر سياسة استرداد للأموال بمجرد تفعيل الاشتراك والوصول إلى المحتوى التعليمي الكامل، ما لم ينص قانون حماية المستهلك في ولايتك على خلاف ذلك.',
  'legal.privacy.s5.title': 'قبول الشروط',
  'legal.privacy.s5.body':
      'باستخدامك تطبيق DMV بالعربي، فإنك تقر بأنك قرأت وفهمت هذه الشروط وتوافق على الالتزام بها. إذا كنت لا توافق على أي جزء منها، يرجى التوقف عن استخدام التطبيق. نحتفظ بالحق في تحديث هذه الشروط في أي وقت، وسيتم إخطارك بأي تغييرات جوهرية.',
  'legal.privacy.contact.title': 'للتواصل معنا',
  'legal.privacy.contact.body':
      'إذا كانت لديك أي استفسارات، يسعدنا تواصلك معنا عبر:',
  'legal.privacy.delete_account': 'حذف حسابي',
  'legal.privacy.delete_account.subtitle':
      'سيتم حذف جميع بيانات حسابك ونتائجك نهائياً. لا يمكن التراجع عن هذا الإجراء.',
  'legal.privacy.delete_account.confirm_title': 'حذف الحساب',
  'legal.privacy.delete_account.confirm_message':
      'هل أنت متأكد من رغبتك في حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',

  // --- Legal: شاشة شروط الاستخدام
  'legal.terms.title': 'شروط الاستخدام',
  'legal.terms.updated_date': '20 مايو 2024',
  'legal.terms.s1.title': 'قبول الشروط',
  'legal.terms.s1.body':
      'باستخدامك تطبيق DMV بالعربي، فإنك تقر بأنك قرأت وفهمت ووافقت على الالتزام بهذه الشروط. إذا كنت لا توافق على أي جزء منها، يرجى عدم استخدام الخدمة. صُمم هذا التطبيق لمساعدة المستخدمين في التحضير لاختبارات القيادة في الولايات المتحدة باللغة العربية.',
  'legal.terms.s2.title': 'وصف الخدمة',
  'legal.terms.s2.body':
      'يوفر تطبيق DMV بالعربي مواد تعليمية واختبارات تجريبية وترجمة لقوانين المرور في مختلف الولايات الأمريكية. نسعى لتقديم أدق المعلومات الممكنة، إلا أنه لا يمكن اعتبارها بديلاً عن المستندات الرسمية الصادرة عن دائرة المركبات (DMV). تُقدَّم الخدمة "كما هي" دون أي ضمانات من أي نوع.',
  'legal.terms.highlight': 'نحن نلتزم بحماية حقوقك وبياناتك',
  'legal.terms.s3.title': 'سلوك المستخدم',
  'legal.terms.s3.item1': 'يجب استخدام التطبيق للأغراض التعليمية الشخصية فقط.',
  'legal.terms.s3.item2':
      'يُمنع منعاً باتاً محاولة نسخ أو استخراج المحتوى البرمجي أو قواعد البيانات الخاصة بالتطبيق.',
  'legal.terms.s3.item3':
      'أنت مسؤول عن الحفاظ على سرية معلومات حسابك ونشاطك داخل التطبيق.',
  'legal.terms.s4.title': 'إخلاء المسؤولية القانونية',
  'legal.terms.s4.body':
      'لا يتحمل فريق DMV بالعربي أي مسؤولية عن رسوب أي مستخدم في اختبار القيادة الحقيقي، أو عن أي مخالفات مرورية قد يرتكبها. المعلومات المقدمة لأغراض إرشادية وتدريبية فقط، والقوانين قد تختلف من ولاية لأخرى وقد تتغير من وقت لآخر؛ لذا يجب دائماً الرجوع إلى الكتيب الرسمي لولاية إقامتك.',
  'legal.terms.s5.title': 'التعديلات على الخدمة',
  'legal.terms.s5.body':
      'نحتفظ بالحق في تعديل الخدمة أو تعليقها أو إيقافها (أو أي جزء منها) في أي وقت، مع أو بدون إشعار مسبق. كما يحق لنا تحديث هذه الشروط بشكل دوري، ويُعد استمرارك في استخدام التطبيق بعد نشر أي تعديلات موافقة صريحة منك عليها.',
  'legal.terms.footer_note':
      'بضغطك على «متابعة»، فإنك توافق على شروط الاستخدام وسياسة الخصوصية',
  'legal.terms.continue': 'متابعة',

  // --- شاشة من نحن
  'legal.about.title': 'من نحن',
  'legal.about.version': 'الإصدار {version}',
  'legal.about.description_title': 'عن التطبيق',

  // --- شاشة تغيير كلمة المرور
  'change_password.hero_subtitle':
      'قم بتأمين حسابك عبر تحديث كلمة المرور الخاصة بك بانتظام',
  'change_password.save': 'حفظ التغييرات',
  'change_password.success': 'تم تغيير كلمة المرور بنجاح',

  // --- شاشة تواصل معنا
  'contact.heading': 'نحب نسمع منك!',
  'contact.subtitle':
      'اكتب رسالتك وفريقنا سيرد عليك بأقرب وقت ممكن. نحن هنا لمساعدتك في رحلتك للحصول على الرخصة.',
  'contact.request_type_label': 'نوع الطلب',
  'contact.type.technical': 'مشكلة تقنية',
  'contact.type.payment': 'استفسار عن الدفع',
  'contact.type.suggestion': 'اقتراح',
  'contact.subject_label': 'الموضوع',
  'contact.subject_hint': 'مثلاً: مشكلة في تسجيل الدخول',
  'contact.message_label': 'الرسالة',
  'contact.message_hint': 'اكتب رسالتك هنا...',
  'contact.registered_email': 'البريد الإلكتروني المسجل',
  'contact.send': 'إرسال',
  'contact.success': 'تم إرسال رسالتك بنجاح',

  // --- خطط الاشتراك
  'subscription.title': 'خطط الاشتراك',
  'subscription.trial_remaining':
      'لديك {remaining} من {total} أسئلة مجانية متبقية',
  'subscription.unlock_title': 'افتح كل المميزات',
  'subscription.unlock_subtitle':
      'اختبر بثقة وتقدم بسرعة أكبر نحو رخصتك من خلال الوصول غير المحدود',
  'subscription.plan.monthly': 'شهري',
  'subscription.plan.yearly': 'سنوي',
  'subscription.price.per_month': '/ شهر',
  'subscription.price.per_year': '/ سنة',
  'subscription.best_value': 'الأكثر توفيرًا',
  'subscription.choose_plan': 'اختر هذه الخطة',
  'subscription.feature.unlimited_questions': 'أسئلة غير محدودة',
  'subscription.feature.detailed_explanations': 'شروحات مفصلة لكل سؤال',
  'subscription.feature.real_simulation': 'محاكاة الاختبار الحقيقي',
  'subscription.feature.all_monthly': 'كل مميزات الخطة الشهرية',
  'subscription.feature.save_50': 'توفير ٥٠٪ سنويًا',
  'subscription.feature.priority_support': 'دعم فني متميز ٢٤/٧',
  'subscription.feature.offline_mode': 'وضع الأوفلاين متاح',
  'subscription.auto_renew': 'تجديد تلقائي',
  'subscription.secure_payment': 'وسائل دفع آمنة',
  'subscription.contact_question': 'هل لديك أسئلة؟',
  'subscription.contact_us': 'تواصل معنا',

  // --- الدفع
  'payment.title': 'الدفع',
  'payment.order_summary': 'ملخص الطلب',
  'payment.method_title': 'طريقة الدفع',
  'payment.method.google_pay': 'Google Pay',
  'payment.method.apple_pay': 'Apple Pay',
  'payment.method.card': 'بطاقة ائتمان / خصم',
  'payment.divider_or': 'أو',
  'payment.pay_now': 'ادفع {price}',
  'payment.secure_note': 'معلومات دفعك مشفّرة وآمنة',
  'payment.success.title': 'تم الاشتراك بنجاح!',
  'payment.success.subtitle': 'أصبح لديك الآن وصول كامل لجميع الميزات',
  'payment.success.start': 'ابدأ الآن',
  'payment.activating': 'جاري تفعيل اشتراكك...',
  'payment.activation_pending':
      'تم استلام الدفع، جاري تفعيل اشتراكك وسيصلك إشعار قريباً',
};
