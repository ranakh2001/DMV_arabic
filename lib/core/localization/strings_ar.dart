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
  'auth.welcome.subtitle': 'سجّل الدخول أو أنشئ حسابًا للبدء في رحلة الحصول على رخصة القيادة',
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
  'auth.register.welcome_subtitle': 'ابدأ رحلتك للحصول على رخصة القيادة الأمريكية بكل سهولة واحترافية.',
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
  'auth.verify.max_resends': 'لقد وصلت إلى الحد الأقصى لإعادة الإرسال (3 مرات/ساعة).',

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
  'field.phone': 'رقم الهاتف',
  'field.phone_hint': '+1 (555) 000-0000',
  'field.email_or_phone': 'البريد الإلكتروني أو رقم الهاتف',
  'field.password': 'كلمة المرور',
  'field.password_hint': '••••••••',
  'field.confirm_password': 'تأكيد كلمة المرور',
  'field.confirm_password_hint': '••••••••',
  'field.code': 'رمز التحقق',
  'field.new_password': 'كلمة المرور الجديدة',
  'field.state': 'الولاية',
  'field.state_hint': 'اختر ولايتك',

  // --- Password strength
  'password.strength.label': 'قوة كلمة المرور:',
  'password.strength.weak': 'ضعيفة',
  'password.strength.fair': 'مقبولة',
  'password.strength.good': 'جيدة',
  'password.strength.strong': 'قوية',

  // --- Errors (Arabic first)
  'error.network': 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وأعد المحاولة.',
  'error.server': 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
  'error.timeout': 'انتهت مهلة الطلب. تحقق من اتصالك.',
  'error.unauthorized': 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
  'error.storage': 'خطأ في التخزين الآمن. سيتم تسجيل خروجك تلقائياً.',
  'error.unknown': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',

  // --- Authenticated placeholder
  'home.greeting': 'تم تسجيل الدخول بنجاح',
  'home.welcome': 'مرحباً بك في DMV بالعربي',

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
  'notif.push': 'إشعارات الدفع',
  'notif.reminders': 'تذكيرات الاشتراك',
  'notif.content': 'تحديثات المحتوى',
  'notif.announcements': 'الإعلانات',
  'notif.sound': 'صوت الإشعارات',

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
  'auth.forgot_verify.subtitle': 'أرسلنا رمزاً مكوناً من 6 أرقام إلى',
  'auth.forgot_verify.no_code': 'لم تستلم الرمز؟',
  'auth.forgot_verify.submit': 'تحقق من الرمز',
  'auth.forgot_verify.resend': 'إعادة إرسال الرمز',
  'auth.forgot_verify.spam_hint':
      'يرجى التأكد من مراجعة صندوق البريد الوارد أو المزعج (Spam) إذا لم تجد الرمز',

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
};
