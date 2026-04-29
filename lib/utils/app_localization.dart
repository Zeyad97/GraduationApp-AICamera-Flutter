import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'EmergiCam',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Authentication
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      
      // Onboarding
      'onboarding_title_1': 'AI-Powered Monitoring',
      'onboarding_desc_1': 'Advanced AI camera detects falls, emergencies, and abnormal activities in real-time',
      'onboarding_title_2': 'Instant Alerts',
      'onboarding_desc_2': 'Get immediate notifications and alerts when emergency situations are detected',
      'onboarding_title_3': 'Emergency Contacts',
      'onboarding_desc_3': 'Manage your emergency contacts and ensure help arrives when needed',
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      
      // Home
      'dashboard': 'Dashboard',
      'alerts': 'Alerts',
      'contacts': 'Contacts',
      'messages': 'Messages',
      'settings': 'Settings',
      'welcome_back': 'Welcome Back',
      'todays_alerts': "Today's Alerts",
      'recent_alerts': 'Recent Alerts',
      'emergency_contacts': 'Emergency Contacts',
      'test_alert': 'Test Alert',
      'no_alerts': 'No alerts yet',
      'no_contacts': 'No contacts yet',
      
      // Alerts
      'alert_history': 'Alert History',
      'active_alerts': 'Active Alerts',
      'resolved_alerts': 'Resolved Alerts',
      'test_alert_desc': 'Send a test alert to verify system',
      'send_test_alert': 'Send Test Alert',
      'alert_sent': 'Alert sent successfully',
      'fall_detected': 'Fall Detected',
      'emergency_gesture': 'Emergency Gesture',
      'immobility': 'Prolonged Immobility',
      'abnormal_activity': 'Abnormal Activity',
      'medical_emergency': 'Medical Emergency',
      'acknowledge': 'Acknowledge',
      'resolve': 'Resolve',
      'false_alarm': 'False Alarm',
      
      // Contacts
      'add_contact': 'Add Contact',
      'edit_contact': 'Edit Contact',
      'delete_contact': 'Delete Contact',
      'contact_name': 'Contact Name',
      'relationship': 'Relationship',
      'is_emergency_contact': 'Emergency Contact',
      'family': 'Family',
      'friend': 'Friend',
      'caregiver': 'Caregiver',
      'doctor': 'Doctor',
      'nurse': 'Nurse',
      'other': 'Other',
      'call': 'Call',
      'message': 'Message',
      
      // Messages
      'chat': 'Chat',
      'type_message': 'Type a message...',
      'send': 'Send',
      'no_messages': 'No messages yet',
      
      // Settings
      'profile': 'Profile',
      'appearance': 'Appearance',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'about': 'About',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_default': 'System Default',
      'english': 'English',
      'arabic': 'Arabic',
      'developed_by': 'Developed by',
      'version': 'Version',
      
      // Camera Integration
      'camera_setup': 'Camera Setup',
      'camera_status': 'Camera Status',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'integration_guide': 'Integration Guide',
      'integration_desc': 'To connect your AI camera system:',
      'integration_step_1': '1. Install the AI detection server on your computer',
      'integration_step_2': '2. Configure the server with your camera feed',
      'integration_step_3': '3. Connect this app using the server API key',
      'integration_step_4': '4. The app will receive real-time alerts from the AI system',
      'api_key': 'API Key',
      'server_url': 'Server URL',
      'connect_camera': 'Connect Camera',
      
      // Errors & Validation
      'invalid_email': 'Invalid email address',
      'invalid_phone': 'Invalid phone number',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_dont_match': 'Passwords do not match',
      'field_required': 'This field is required',
      'login_failed': 'Login failed. Check your credentials',
      'registration_failed': 'Registration failed. Email may already exist',
    },
    'ar': {
      // Common
      'app_name': 'EmergiCam',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'confirm': 'تأكيد',
      'yes': 'نعم',
      'no': 'لا',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      
      // Authentication
      'login': 'تسجيل الدخول',
      'register': 'تسجيل',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'confirm_password': 'تأكيد كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'dont_have_account': 'ليس لديك حساب؟',
      'already_have_account': 'لديك حساب بالفعل؟',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      
      // Onboarding
      'onboarding_title_1': 'مراقبة بالذكاء الاصطناعي',
      'onboarding_desc_1': 'كاميرا ذكية تكتشف السقوط والطوارئ والأنشطة غير الطبيعية في الوقت الفعلي',
      'onboarding_title_2': 'تنبيهات فورية',
      'onboarding_desc_2': 'احصل على إشعارات وتنبيهات فورية عند اكتشاف حالات الطوارئ',
      'onboarding_title_3': 'جهات الاتصال الطارئة',
      'onboarding_desc_3': 'قم بإدارة جهات الاتصال الطارئة وتأكد من وصول المساعدة عند الحاجة',
      'skip': 'تخطي',
      'next': 'التالي',
      'get_started': 'ابدأ الآن',
      
      // Home
      'dashboard': 'لوحة التحكم',
      'alerts': 'التنبيهات',
      'contacts': 'جهات الاتصال',
      'messages': 'الرسائل',
      'settings': 'الإعدادات',
      'welcome_back': 'مرحباً بعودتك',
      'todays_alerts': 'تنبيهات اليوم',
      'recent_alerts': 'التنبيهات الأخيرة',
      'emergency_contacts': 'جهات الاتصال الطارئة',
      'test_alert': 'اختبار التنبيه',
      'no_alerts': 'لا توجد تنبيهات بعد',
      'no_contacts': 'لا توجد جهات اتصال بعد',
      
      // Alerts
      'alert_history': 'سجل التنبيهات',
      'active_alerts': 'التنبيهات النشطة',
      'resolved_alerts': 'التنبيهات المحلولة',
      'test_alert_desc': 'إرسال تنبيه تجريبي للتحقق من النظام',
      'send_test_alert': 'إرسال تنبيه تجريبي',
      'alert_sent': 'تم إرسال التنبيه بنجاح',
      'fall_detected': 'تم اكتشاف سقوط',
      'emergency_gesture': 'إشارة طوارئ',
      'immobility': 'عدم حركة لفترة طويلة',
      'abnormal_activity': 'نشاط غير طبيعي',
      'medical_emergency': 'طوارئ طبية',
      'acknowledge': 'تأكيد الاستلام',
      'resolve': 'حل',
      'false_alarm': 'إنذار خاطئ',
      
      // Contacts
      'add_contact': 'إضافة جهة اتصال',
      'edit_contact': 'تعديل جهة الاتصال',
      'delete_contact': 'حذف جهة الاتصال',
      'contact_name': 'اسم جهة الاتصال',
      'relationship': 'العلاقة',
      'is_emergency_contact': 'جهة اتصال طارئة',
      'family': 'عائلة',
      'friend': 'صديق',
      'caregiver': 'مقدم رعاية',
      'doctor': 'طبيب',
      'nurse': 'ممرضة',
      'other': 'أخرى',
      'call': 'اتصال',
      'message': 'رسالة',
      
      // Messages
      'chat': 'محادثة',
      'type_message': 'اكتب رسالة...',
      'send': 'إرسال',
      'no_messages': 'لا توجد رسائل بعد',
      
      // Settings
      'profile': 'الملف الشخصي',
      'appearance': 'المظهر',
      'language': 'اللغة',
      'theme': 'السمة',
      'notifications': 'الإشعارات',
      'about': 'حول',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'system_default': 'افتراضي النظام',
      'english': 'English',
      'arabic': 'العربية',
      'developed_by': 'تطوير',
      'version': 'الإصدار',
      
      // Camera Integration
      'camera_setup': 'إعداد الكاميرا',
      'camera_status': 'حالة الكاميرا',
      'connected': 'متصل',
      'disconnected': 'غير متصل',
      'integration_guide': 'دليل التكامل',
      'integration_desc': 'لتوصيل نظام الكاميرا الذكي الخاص بك:',
      'integration_step_1': '1. قم بتثبيت خادم الكشف بالذكاء الاصطناعي على جهاز الكمبيوتر الخاص بك',
      'integration_step_2': '2. قم بتكوين الخادم مع موجز الكاميرا الخاص بك',
      'integration_step_3': '3. قم بتوصيل هذا التطبيق باستخدام مفتاح API الخاص بالخادم',
      'integration_step_4': '4. سيتلقى التطبيق تنبيهات في الوقت الفعلي من نظام الذكاء الاصطناعي',
      'api_key': 'مفتاح API',
      'server_url': 'عنوان URL للخادم',
      'connect_camera': 'توصيل الكاميرا',
      
      // Errors & Validation
      'invalid_email': 'عنوان بريد إلكتروني غير صالح',
      'invalid_phone': 'رقم هاتف غير صالح',
      'password_too_short': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'passwords_dont_match': 'كلمات المرور غير متطابقة',
      'field_required': 'هذا الحقل مطلوب',
      'login_failed': 'فشل تسجيل الدخول. تحقق من بيانات الاعتماد الخاصة بك',
      'registration_failed': 'فشل التسجيل. قد يكون البريد الإلكتروني موجوداً بالفعل',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
