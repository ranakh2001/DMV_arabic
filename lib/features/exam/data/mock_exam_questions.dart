import 'package:flutter/material.dart';
import '../domain/entities/answer_option.dart';
import '../domain/entities/exam_question.dart';

/// Placeholder question bank — no backend/API yet. Real DMV content and
/// per-state variants will replace this once the questions service ships.
const _questionBank = <ExamQuestion>[
  ExamQuestion(
    id: 'q_intersection_warning',
    mediaIcon: Icons.warning_amber_rounded,
    promptEn: 'What should you do when you see this warning sign as you approach an intersection?',
    promptAr: 'ماذا يجب أن تفعل عندما ترى هذه اللافتة المرورية عند الاقتراب من تقاطع؟',
    correctOptionId: 'b',
    options: [
      AnswerOption(
        id: 'a',
        textEn: 'Stop completely before entering the intersection no matter the traffic.',
        textAr: 'التوقف تماماً قبل الدخول إلى التقاطع مهما كانت الحالة المرورية.',
      ),
      AnswerOption(
        id: 'b',
        textEn: 'Slow down and be ready to stop, giving right of way to pedestrians.',
        textAr: 'إبطاء السرعة والاستعداد للتوقف لإعطاء الأولوية لحركة المرور المشاة.',
      ),
      AnswerOption(
        id: 'c',
        textEn: 'Speed up to cross the intersection before other cars arrive.',
        textAr: 'زيادة السرعة لتجاوز التقاطع قبل وصول السيارات الأخرى.',
      ),
      AnswerOption(
        id: 'd',
        textEn: 'Ignore the sign if the opposite street is completely clear.',
        textAr: 'تجاهل اللافتة إذا كان الشارع المقابل خالياً تماماً من السيارات.',
      ),
    ],
  ),
  ExamQuestion(
    id: 'q_school_zone_speed',
    mediaIcon: Icons.speed_rounded,
    promptEn: 'Unless otherwise posted, what is the typical speed limit in a school zone while children are present?',
    promptAr: 'ما هو حد السرعة المعتاد في منطقة المدرسة أثناء وجود الأطفال، ما لم تُذكر لافتة مختلفة؟',
    correctOptionId: 'a',
    options: [
      AnswerOption(id: 'a', textEn: '25 mph (about 40 km/h)', textAr: '25 ميلاً/ساعة (حوالي 40 كم/س)'),
      AnswerOption(id: 'b', textEn: '45 mph (about 72 km/h)', textAr: '45 ميلاً/ساعة (حوالي 72 كم/س)'),
      AnswerOption(id: 'c', textEn: '60 mph (about 96 km/h)', textAr: '60 ميلاً/ساعة (حوالي 96 كم/س)'),
      AnswerOption(id: 'd', textEn: 'There is no speed limit in school zones', textAr: 'لا يوجد حد سرعة في مناطق المدارس'),
    ],
  ),
  ExamQuestion(
    id: 'q_stop_sign',
    mediaIcon: Icons.do_not_disturb_on_rounded,
    promptEn: 'At a stop sign with no other traffic around, you should:',
    promptAr: 'عند لافتة "قف" وعدم وجود أي حركة مرور أخرى حولك، يجب عليك:',
    correctOptionId: 'c',
    options: [
      AnswerOption(id: 'a', textEn: 'Slow down without a full stop and continue', textAr: 'إبطاء السرعة دون توقف كامل ثم المتابعة'),
      AnswerOption(id: 'b', textEn: 'Stop only if another vehicle is visible', textAr: 'التوقف فقط إذا كانت هناك سيارة أخرى ظاهرة'),
      AnswerOption(id: 'c', textEn: 'Come to a complete stop, then proceed when safe', textAr: 'التوقف توقفاً تاماً، ثم المتابعة عند التأكد من الأمان'),
      AnswerOption(id: 'd', textEn: 'Honk your horn instead of stopping', textAr: 'استخدام المنبه بدلاً من التوقف'),
    ],
  ),
  ExamQuestion(
    id: 'q_four_way_stop',
    mediaIcon: Icons.crop_square_rounded,
    promptEn: 'At a four-way stop, two vehicles arrive at the same time from different directions. Who goes first?',
    promptAr: 'عند تقاطع بأربع لافتات "قف"، وصلت سيارتان في نفس اللحظة من اتجاهين مختلفين. من يمر أولاً؟',
    correctOptionId: 'b',
    options: [
      AnswerOption(id: 'a', textEn: 'Whoever honks first', textAr: 'من يستخدم المنبه أولاً'),
      AnswerOption(id: 'b', textEn: 'The vehicle on the right goes first', textAr: 'السيارة القادمة من اليمين تمر أولاً'),
      AnswerOption(id: 'c', textEn: 'The faster vehicle goes first', textAr: 'السيارة الأسرع تمر أولاً'),
      AnswerOption(id: 'd', textEn: 'Both must reverse and wait for a third car', textAr: 'يجب على كلتيهما التراجع وانتظار سيارة ثالثة'),
    ],
  ),
  ExamQuestion(
    id: 'q_sign_shapes',
    mediaIcon: Icons.category_rounded,
    promptEn: 'Which of the following signs means "two-way traffic ahead"?',
    promptAr: 'أي من الإشارات التالية تعني "حركة مرور باتجاهين أمامك"؟',
    correctOptionId: 'a',
    options: [
      AnswerOption(id: 'a', icon: Icons.swap_horiz_rounded),
      AnswerOption(id: 'b', icon: Icons.arrow_upward_rounded),
      AnswerOption(id: 'c', icon: Icons.call_merge_rounded),
      AnswerOption(id: 'd', icon: Icons.roundabout_left_rounded),
    ],
  ),
  ExamQuestion(
    id: 'q_seatbelt',
    mediaIcon: Icons.airline_seat_legroom_normal_rounded,
    promptEn: 'When is it required to wear a seat belt in the vehicle?',
    promptAr: 'متى يكون ربط حزام الأمان إلزامياً داخل المركبة؟',
    correctOptionId: 'd',
    options: [
      AnswerOption(id: 'a', textEn: 'Only on highways', textAr: 'فقط على الطرق السريعة'),
      AnswerOption(id: 'b', textEn: 'Only for the driver', textAr: 'فقط بالنسبة للسائق'),
      AnswerOption(id: 'c', textEn: 'Only on trips longer than 30 minutes', textAr: 'فقط في الرحلات التي تزيد عن 30 دقيقة'),
      AnswerOption(id: 'd', textEn: 'At all times for driver and passengers', textAr: 'في جميع الأوقات لكل من السائق والركاب'),
    ],
  ),
  ExamQuestion(
    id: 'q_bac_limit',
    mediaIcon: Icons.no_drinks_rounded,
    promptEn: "What is the legal blood alcohol concentration (BAC) limit for drivers 21 and older in most states?",
    promptAr: 'ما هو الحد القانوني لتركيز الكحول في الدم (BAC) للسائقين البالغين 21 عاماً فأكثر في معظم الولايات؟',
    correctOptionId: 'b',
    options: [
      AnswerOption(id: 'a', textEn: '0.02%', textAr: '0.02%'),
      AnswerOption(id: 'b', textEn: '0.08%', textAr: '0.08%'),
      AnswerOption(id: 'c', textEn: '0.15%', textAr: '0.15%'),
      AnswerOption(id: 'd', textEn: 'There is no legal limit', textAr: 'لا يوجد حد قانوني'),
    ],
  ),
  ExamQuestion(
    id: 'q_following_distance',
    mediaIcon: Icons.timer_outlined,
    promptEn: 'What is the recommended following distance behind the vehicle ahead in normal conditions?',
    promptAr: 'ما هي مسافة التتبع الموصى بها خلف السيارة التي أمامك في الظروف العادية؟',
    correctOptionId: 'c',
    options: [
      AnswerOption(id: 'a', textEn: 'Half a second', textAr: 'نصف ثانية'),
      AnswerOption(id: 'b', textEn: 'One second', textAr: 'ثانية واحدة'),
      AnswerOption(id: 'c', textEn: 'At least three seconds', textAr: 'ثلاث ثوانٍ على الأقل'),
      AnswerOption(id: 'd', textEn: 'There is no recommended distance', textAr: 'لا توجد مسافة موصى بها'),
    ],
  ),
  ExamQuestion(
    id: 'q_school_bus',
    mediaIcon: Icons.directions_bus_filled_rounded,
    promptEn: 'A school bus ahead has stopped with its red lights flashing. What must you do?',
    promptAr: 'توقفت حافلة مدرسية أمامك وأضواؤها الحمراء تومض. ماذا يجب عليك أن تفعل؟',
    correctOptionId: 'a',
    options: [
      AnswerOption(id: 'a', textEn: 'Stop and wait until the lights stop flashing', textAr: 'التوقف والانتظار حتى تتوقف الأضواء عن الوميض'),
      AnswerOption(id: 'b', textEn: 'Pass carefully at a slow speed', textAr: 'التجاوز بحذر وبسرعة بطيئة'),
      AnswerOption(id: 'c', textEn: 'Pass only from the opposite lane', textAr: 'التجاوز فقط من المسار المقابل'),
      AnswerOption(id: 'd', textEn: 'Honk and continue driving', textAr: 'استخدام المنبه ومتابعة القيادة'),
    ],
  ),
  ExamQuestion(
    id: 'q_right_on_red',
    mediaIcon: Icons.traffic_rounded,
    promptEn: 'Unless a sign prohibits it, when may you turn right at a red light?',
    promptAr: 'ما لم تمنع ذلك لافتة، متى يمكنك الانعطاف يميناً عند الإشارة الحمراء؟',
    correctOptionId: 'b',
    options: [
      AnswerOption(id: 'a', textEn: 'Never, red always means stop', textAr: 'أبداً، الإشارة الحمراء تعني التوقف دائماً'),
      AnswerOption(id: 'b', textEn: 'After coming to a complete stop and yielding to traffic and pedestrians', textAr: 'بعد التوقف التام وإعطاء الأولوية للمركبات والمشاة'),
      AnswerOption(id: 'c', textEn: 'Only if you honk first', textAr: 'فقط إذا استخدمت المنبه أولاً'),
      AnswerOption(id: 'd', textEn: 'Only between 9 AM and 5 PM', textAr: 'فقط بين الساعة 9 صباحاً و5 مساءً'),
    ],
  ),
  ExamQuestion(
    id: 'q_fog_lights',
    mediaIcon: Icons.foggy,
    promptEn: 'When driving in heavy fog, you should use:',
    promptAr: 'عند القيادة في ضباب كثيف، يجب عليك استخدام:',
    correctOptionId: 'a',
    options: [
      AnswerOption(id: 'a', textEn: 'Low-beam headlights', textAr: 'الأضواء المنخفضة (الشورت)'),
      AnswerOption(id: 'b', textEn: 'High-beam headlights', textAr: 'الأضواء العالية (الفل لايت)'),
      AnswerOption(id: 'c', textEn: 'Hazard lights only, no headlights', textAr: 'أضواء التحذير فقط دون الأضواء الأمامية'),
      AnswerOption(id: 'd', textEn: 'No lights, to avoid glare', textAr: 'دون إضاءة، لتجنب الوهج'),
    ],
  ),
  ExamQuestion(
    id: 'q_railroad_crossing',
    mediaIcon: Icons.train_rounded,
    promptEn: 'As you approach a railroad crossing with flashing lights, you should:',
    promptAr: 'عند الاقتراب من معبر سكة حديد وأضواؤه تومض، يجب عليك:',
    correctOptionId: 'd',
    options: [
      AnswerOption(id: 'a', textEn: 'Speed up to cross before the train arrives', textAr: 'زيادة السرعة للعبور قبل وصول القطار'),
      AnswerOption(id: 'b', textEn: 'Stop only if you can see the train', textAr: 'التوقف فقط إذا رأيت القطار'),
      AnswerOption(id: 'c', textEn: 'Drive around the lowered gate carefully', textAr: 'الالتفاف حول الحاجز المنخفض بحذر'),
      AnswerOption(id: 'd', textEn: 'Stop at least 15 feet from the tracks and wait', textAr: 'التوقف على بعد 15 قدماً على الأقل من القضبان والانتظار'),
    ],
  ),
  ExamQuestion(
    id: 'q_fire_hydrant_parking',
    mediaIcon: Icons.local_fire_department_rounded,
    promptEn: 'How close to a fire hydrant are you generally allowed to park?',
    promptAr: 'ما هي أقرب مسافة يُسمح لك فيها بالوقوف بجانب صنبور إطفاء الحريق؟',
    correctOptionId: 'c',
    options: [
      AnswerOption(id: 'a', textEn: 'Right next to it, as long as the engine is off', textAr: 'بجانبه مباشرة، طالما المحرك مطفأ'),
      AnswerOption(id: 'b', textEn: 'Within 5 feet', textAr: 'ضمن 5 أقدام'),
      AnswerOption(id: 'c', textEn: 'At least 15 feet away', textAr: 'على بعد 15 قدماً على الأقل'),
      AnswerOption(id: 'd', textEn: 'There is no restriction', textAr: 'لا يوجد أي قيد'),
    ],
  ),
  ExamQuestion(
    id: 'q_phone_use',
    mediaIcon: Icons.phonelink_erase_rounded,
    promptEn: 'Texting on a handheld phone while driving is:',
    promptAr: 'إرسال الرسائل النصية عبر هاتف محمول أثناء القيادة يُعتبر:',
    correctOptionId: 'a',
    options: [
      AnswerOption(id: 'a', textEn: 'Prohibited in most states and unsafe at any speed', textAr: 'ممنوعاً في معظم الولايات وغير آمن بأي سرعة'),
      AnswerOption(id: 'b', textEn: 'Allowed while stopped at a red light only', textAr: 'مسموح فقط أثناء التوقف عند الإشارة الحمراء'),
      AnswerOption(id: 'c', textEn: 'Allowed if you hold the phone with one hand', textAr: 'مسموح إذا أمسكت الهاتف بيد واحدة'),
      AnswerOption(id: 'd', textEn: 'Allowed on empty roads', textAr: 'مسموح في الطرق الخالية'),
    ],
  ),
];

/// Builds a working exam of [count] questions by cycling through the mock
/// bank (question banks are recycled once real content runs out — same
/// approach real DMV practice apps use). Each cycled copy gets a unique id
/// so answer selections don't collide.
List<ExamQuestion> buildExamQuestions(int count) {
  return List.generate(count, (i) {
    final base = _questionBank[i % _questionBank.length];
    return base.copyWith(id: '${base.id}_$i');
  });
}
