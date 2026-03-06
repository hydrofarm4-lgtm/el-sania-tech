// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المزرعة الطازجة';

  @override
  String get autoMode => 'الوضع التلقائي';

  @override
  String get manualMode => 'الوضع اليدوي';

  @override
  String get liveSensors => 'القراءات الحية';

  @override
  String get actuatorsRelays => 'وحدات التحكم';

  @override
  String get sensorTemp => 'درجة الحرارة';

  @override
  String get sensorHumidity => 'الرطوبة';

  @override
  String get sensorEC => 'نسبة الملوحة (EC)';

  @override
  String get sensorPH => 'مستوى الـ pH';

  @override
  String get sensorWaterLevel => 'مستوى الماء';

  @override
  String get sensorLight => 'الإضاءة';

  @override
  String get sensorSubstrate => 'رطوبة التربة';

  @override
  String get controlLedLights => 'إضاءة LED';

  @override
  String get controlWaterPump => 'مضخة المياه';

  @override
  String get controlCoolingSystem => 'نظام التبريد';

  @override
  String get controlVentilationFans => 'مراوح التهوية';

  @override
  String get controlRefillValve => 'صمام إعادة التعبئة';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get manage => 'التحكم';

  @override
  String get aiHub => 'محور الذكاء';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get tabSensors => 'القراءات';

  @override
  String get tabControls => 'التحكم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get role => 'الصلاحية';

  @override
  String get roleSuperAdmin => 'مدير النظام';

  @override
  String get roleEngineer => 'مهندس';

  @override
  String get roleWorker => 'عامل';

  @override
  String get signInTitle => 'تسجيل الدخول للمتابعة';

  @override
  String get loginButton => 'دخول';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get invalidCredentials => 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.';

  @override
  String get tempDetailsTitle => 'تفاصيل درجة الحرارة';

  @override
  String get targetRange => 'النطاق المستهدف';

  @override
  String get autoCoolingActive => 'التبريد التلقائي نشط: المراوح والمبرد تعمل';

  @override
  String get autoCoolingStandby => 'استعداد نظام التبريد: الحرارة مثالية';

  @override
  String get manualControlOnly => 'الوضع اليدوي: التحكم التلقائي معطل';

  @override
  String minTemp(Object value) {
    return 'الأدنى: $value°C';
  }

  @override
  String maxTemp(Object value) {
    return 'الأقصى: $value°C';
  }

  @override
  String get currentTemp => 'درجة الحرارة الحالية';

  @override
  String get tabProjectStatus => 'حالة المشروع';

  @override
  String get tabGreenhouses => 'البيوت المحمية';

  @override
  String get tabWorkforce => 'القوى العاملة';

  @override
  String get investorHub => 'مركز المستثمر';

  @override
  String get marketReadiness => 'جاهزية السوق';

  @override
  String get estimatedYield => 'الإنتاج التقديري';

  @override
  String get activeOperations => 'العمليات النشطة';

  @override
  String get periodicReports => 'التقارير الدورية';

  @override
  String get greenhouseManagement => 'إدارة البيوت المحمية';

  @override
  String get cropType => 'نوع المحصول';

  @override
  String get plantingDate => 'تاريخ الزراعة';

  @override
  String get harvestDate => 'تاريخ الحصاد';

  @override
  String get climateHealth => 'الحالة المناخية';

  @override
  String get workforceManagement => 'إدارة القوى العاملة';

  @override
  String get totalPersonnel => 'إجمالي الموظفين';

  @override
  String get activeTasks => 'المهام النشطة';

  @override
  String get salariesOverview => 'نظرة عامة على الرواتب';

  @override
  String get reportedIssues => 'الأعطال المسجلة';

  @override
  String get assignTask => 'إسناد مهمة';

  @override
  String get tabUserRequests => 'طلبات الانضمام';

  @override
  String get loginMode => 'تسجيل الدخول';

  @override
  String get registerMode => 'إنشاء حساب';

  @override
  String get pendingTitle => 'بانتظار الموافقة';

  @override
  String get pendingMessage =>
      'حسابك قيد المراجعة من قبل الإدارة. يرجى الانتظار.';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get selectRole => 'اختر الدور';

  @override
  String get selectGreenhouses => 'إسناد البيوت';

  @override
  String get myTasks => 'مهامي';

  @override
  String get taskPending => 'قيد الانتظار';

  @override
  String get taskInProgress => 'قيد التنفيذ';

  @override
  String get taskCompleted => 'مكتملة';

  @override
  String get reportBreakdown => 'إبلاغ عن عطل';

  @override
  String get reportDescription => 'صف المشكلة...';

  @override
  String get sendReport => 'إرسال التقرير';

  @override
  String get incidentReported => 'تم الإبلاغ عن العطل بنجاح';

  @override
  String get aiInsightPerfect =>
      'الحالة: ممتازة. جميع الأنظمة تعمل بشكل مثالي.';

  @override
  String get aiInsightGood => 'الحالة: جيدة. يوصى ببعض التعديلات الطفيفة.';

  @override
  String get aiInsightWarning => 'الحالة: تحذير. معايير خارج النطاق المثالي.';

  @override
  String get aiInsightDanger => 'الحالة: خطيرة! مطلوب اتخاذ إجراء فوري.';

  @override
  String get healthScore => 'درجة الصحة';

  @override
  String get aiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get trend24h => 'اتجاه الحساسات خلال 24 ساعة';
}
