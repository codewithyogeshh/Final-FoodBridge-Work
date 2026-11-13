import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';

class AppTranslations {
  final Locale locale;

  const AppTranslations(this.locale);

  static AppTranslations of(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return AppTranslations(localeProvider.locale);
  }

  String get(String key) {
    final lang = locale.languageCode;
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }

  // Common Getters
  String get appName => get('app_name');
  String get appTagline => get('app_tagline');
  String get welcomeBack => get('welcome_back');
  String get signIn => get('sign_in');
  String get signOut => get('sign_out');
  String get register => get('register');
  String get email => get('email');
  String get password => get('password');
  String get forgotPassword => get('forgot_password');
  String get donor => get('donor');
  String get ngo => get('ngo');
  String get volunteer => get('volunteer');
  String get admin => get('admin');
  String get appearance => get('appearance');
  String get themeLight => get('theme_light');
  String get themeDark => get('theme_dark');
  String get themeSystem => get('theme_system');
  String get language => get('language');
  String get termsAndConditions => get('terms_and_conditions');
  String get newDonation => get('new_donation');
  String get donateFood => get('donate_food');
  String get donateClothes => get('donate_clothes');
  String get myDonations => get('my_donations');
  String get browseDonations => get('browse_donations');
  String get claimDonation => get('claim_donation');
  String get activeTasks => get('active_tasks');
  String get availableTasks => get('available_tasks');
  String get distributionRecords => get('distribution_records');
  String get logDistribution => get('log_distribution');
  String get notifications => get('notifications');
  String get profile => get('profile');
  String get liveMissionGps => get('live_mission_gps');
  String get online => get('online');
  String get offline => get('offline');
  String get availableNearYou => get('available_near_you');

  String get donorDashboard => get('donor_dashboard');
  String get ngoPortal => get('ngo_portal');
  String get volunteerDispatch => get('volunteer_dispatch');
  String get adminConsole => get('admin_console');
  String get profileAndSettings => get('profile_and_settings');

  static const Map<String, Map<String, String>> _strings = {
    // ENGLISH
    'en': {
      'app_name': 'FoodBridge',
      'app_tagline': 'Share More. Waste Less. Help More.',
      'welcome': 'Welcome to FoodBridge',
      'welcome_sub': 'Connecting surplus food and clothing with verified NGOs and volunteer couriers in real time.',
      'onboarding_role_donor': 'I Want to Donate',
      'onboarding_role_ngo': 'We are an NGO / Shelter',
      'onboarding_role_volunteer': 'I Want to Volunteer',
      'create_donation': 'Create a Donation',
      'welcome_back': 'Welcome Back',
      'welcome_back_sub': 'Sign in with your FoodBridge credentials or choose a quick role profile below.',
      'sign_in': 'Sign In',
      'sign_out': 'Sign Out',
      'register': 'Register',
      'email': 'Email Address',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember Me',
      'donor': 'Donor',
      'ngo': 'NGO Shelter',
      'volunteer': 'Volunteer',
      'admin': 'Administrator',
      'donor_dashboard': 'Donor Dashboard',
      'ngo_portal': 'NGO Portal',
      'volunteer_dispatch': 'Volunteer Dispatch',
      'admin_console': 'Admin Console',
      'profile_and_settings': 'Profile & Settings',
      'appearance': 'Appearance',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'theme_mode': 'Theme Mode',
      'language': 'Language / भाषा',
      'select_language': 'Select Language',
      'terms_and_conditions': 'Terms & Conditions',
      'terms_title': 'FoodBridge Platform & Safety Charter',
      'terms_subtitle': 'Please review and accept our community standards before proceeding.',
      'terms_agree': 'I agree to the FoodBridge Terms of Service, FSSAI Food Safety Guidelines, and Community Privacy Charter.',
      'terms_dignity': 'I commit to treating all donors, volunteers, shelter partners, and beneficiaries with dignity and respect.',
      'accept_continue': 'Accept & Continue',
      'decline_signout': 'Decline & Sign Out',
      'new_donation': 'New Donation',
      'donate_food': 'Donate Surplus Food',
      'donate_food_sub': 'Cooked meals, raw produce, bakery & dairy (FSSAI pledge)',
      'donate_clothes': 'Donate Clean Clothing',
      'donate_clothes_sub': 'Winterwear, blankets, children & adult garments',
      'my_donations': 'My Donations',
      'browse_donations': 'Browse Donations',
      'claim_donation': 'Claim Donation',
      'claim_for_shelter': 'Claim Donation for Shelter',
      'active_tasks': 'Active Deliveries',
      'available_tasks': 'Available Dispatches',
      'distribution_records': 'Distribution Records',
      'log_distribution': 'Log Distribution',
      'notifications': 'Notifications',
      'profile': 'Profile & Settings',
      'live_mission_gps': 'Open Live Mission & GPS',
      'online': 'Online',
      'offline': 'Offline',
      'available_near_you': 'Available Near You',
      'filter_all': 'All Listings',
      'filter_food': 'Surplus Food 🍛',
      'filter_clothing': 'Clothing 👕',
      'filter_urgent': 'Expiring Soon ⏳',
      'stats_rescued': 'Meals Rescued',
      'stats_clothes': 'Clothes Distributed',
      'stats_co2': 'CO2e Diverted',
      'quick_profile': 'Quick Select Demo Profile:',
      'switch_role': 'SWITCH ACTIVE ROLE VIEW',
      'preferences': 'PREFERENCES & ACCESSIBILITY',
      'safety_charter_badge': 'FSSAI Certified Safety Standards',
      'darpan_verified': 'Darpan / 80G Verified',
      'volunteer_limit': 'Active: {count} / Max 2',
      'pickup_deadline': 'Collect by',
      'view_details': 'View Full Specs',
      'confirm_pickup': 'Confirm Food Picked Up',
      'confirm_delivery': 'Confirm Safe Handover',
      'overview': 'Overview',
      'verifications': 'Verifications',
      'user_management': 'User Management',
      'complaints': 'Complaints',
      'audit_logs': 'Audit Logs',
    },

    // HINDI (हिंदी)
    'hi': {
      'app_name': 'फूडब्रिज (FoodBridge)',
      'app_tagline': 'अधिक साझा करें। कम बर्बाद करें। अधिक मदद करें।',
      'welcome': 'फूडब्रिज में आपका स्वागत है',
      'welcome_sub': 'अतिरिक्त भोजन और कपड़ों को सत्यापित गैर-सरकारी संगठनों और स्वयंसेवकों से सीधे जोड़ना।',
      'onboarding_role_donor': 'मैं दान करना चाहता हूँ',
      'onboarding_role_ngo': 'हम एनजीओ / आश्रम हैं',
      'onboarding_role_volunteer': 'मैं स्वयंसेवक बनना चाहता हूँ',
      'create_donation': 'दान बनाएं',
      'welcome_back': 'वापसी पर स्वागत है',
      'welcome_back_sub': 'अपने फूडब्रिज खाते में लॉगिन करें या त्वरित डेमो प्रोफाइल चुनें।',
      'sign_in': 'लॉग इन करें',
      'sign_out': 'लॉग आउट करें',
      'register': 'पंजीकरण करें',
      'email': 'ईमेल पता',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'remember_me': 'मुझे याद रखें',
      'donor': 'दाता (Donor)',
      'ngo': 'एनजीओ / आश्रम (NGO)',
      'volunteer': 'स्वयंसेवक (Volunteer)',
      'admin': 'प्रशासक (Admin)',
      'donor_dashboard': 'दाता डैशबोर्ड',
      'ngo_portal': 'एनजीओ पोर्टल',
      'volunteer_dispatch': 'स्वयंसेवक डिस्पैच',
      'admin_console': 'प्रशासक कंसोल',
      'profile_and_settings': 'प्रोफ़ाइल और सेटिंग्स',
      'appearance': 'रूप-रंग (थीम)',
      'theme_light': 'लाइट (Light)',
      'theme_dark': 'डार्क (Dark)',
      'theme_system': 'सिस्टम (System)',
      'theme_mode': 'थीम मोड',
      'language': 'भाषा (Language)',
      'select_language': 'भाषा चुनें',
      'terms_and_conditions': 'नियम और शर्तें',
      'terms_title': 'फूडब्रिज सुरक्षा और समुदाय चार्टर',
      'terms_subtitle': 'आगे बढ़ने से पहले कृपया हमारे सुरक्षा और स्वच्छता मानकों को स्वीकार करें।',
      'terms_agree': 'मैं फूडब्रिज सेवा की शर्तों, FSSAI खाद्य सुरक्षा दिशानिर्देशों और गोपनीयता नीति से सहमत हूँ।',
      'terms_dignity': 'मैं सभी दाताओं, स्वयंसेवकों और लाभार्थियों के साथ सम्मान और गरिमा से व्यवहार करने की प्रतिज्ञा करता हूँ।',
      'accept_continue': 'स्वीकार करें और आगे बढ़ें',
      'decline_signout': 'अस्वीकार करें और लॉग आउट करें',
      'new_donation': 'नया दान करें',
      'donate_food': 'अतिरिक्त भोजन दान करें',
      'donate_food_sub': 'पका हुआ भोजन, राशन, बेकरी और डेयरी (FSSAI सुरक्षा प्रतिज्ञा)',
      'donate_clothes': 'स्वच्छ कपड़े दान करें',
      'donate_clothes_sub': 'सर्दियों के कपड़े, कंबल, बच्चों और बड़ों के वस्त्र',
      'my_donations': 'मेरे दान (My Donations)',
      'browse_donations': 'दान खोजें',
      'claim_donation': 'दान का दावा करें',
      'claim_for_shelter': 'आश्रम के लिए दान सुरक्षित करें',
      'active_tasks': 'सक्रिय डिलीवरी (Active Tasks)',
      'available_tasks': 'उपलब्ध कार्य (Available Tasks)',
      'distribution_records': 'वितरण रिकॉर्ड',
      'log_distribution': 'वितरण दर्ज करें',
      'notifications': 'सूचनाएं (Notifications)',
      'profile': 'प्रोफ़ाइल और सेटिंग्स',
      'live_mission_gps': 'लाइव मिशन और जीपीएस शुरू करें',
      'online': 'ऑनलाइन (सक्रिय)',
      'offline': 'ऑफलाइन',
      'available_near_you': 'आपके निकट उपलब्ध दान',
      'filter_all': 'सभी दान',
      'filter_food': 'अतिरिक्त भोजन 🍛',
      'filter_clothing': 'कपड़े 👕',
      'filter_urgent': 'शीघ्र समाप्ति ⏳',
      'stats_rescued': 'बचाया गया भोजन (भोजन संख्या)',
      'stats_clothes': 'वितरित कपड़े',
      'stats_co2': 'CO2 उत्सर्जन बचत',
      'quick_profile': 'त्वरित डेमो प्रोफ़ाइल चुनें:',
      'switch_role': 'सक्रिय भूमिका दृश्य बदलें',
      'preferences': 'प्राथमिकताएं और सुगमता (Accessibility)',
      'safety_charter_badge': 'FSSAI प्रमाणित सुरक्षा मानक',
      'darpan_verified': 'दर्पण / 80G सत्यापित',
      'volunteer_limit': 'सक्रिय कार्य: {count} / अधिकतम 2',
      'pickup_deadline': 'उठाने की अंतिम समय-सीमा',
      'view_details': 'पूर्ण विवरण देखें',
      'confirm_pickup': 'भोजन प्राप्ति की पुष्टि करें',
      'confirm_delivery': 'सफल वितरण की पुष्टि करें',
      'overview': 'अवलोकन (Overview)',
      'verifications': 'सत्यापन कतार',
      'user_management': 'उपयोगकर्ता प्रबंधन',
      'complaints': 'शिकायत निवारण',
      'audit_logs': 'ऑडिट लॉग्स',
    },

    // MARATHI (मराठी)
    'mr': {
      'app_name': 'फूडब्रिज (FoodBridge)',
      'app_tagline': 'अधिक शेअर करा. कमी वाया घालवा. अधिक मदत करा.',
      'welcome': 'फूडब्रिजमध्ये आपले स्वागत आहे',
      'welcome_sub': 'शिल्लक अन्न आणि कपडे गरजू संस्था आणि स्वयंसेवकांपर्यंत तत्काळ पोहोचवणारे व्यासपीठ.',
      'onboarding_role_donor': 'मला दान करायचे आहे',
      'onboarding_role_ngo': 'आम्ही स्वयंसेवी संस्था / निवारा आहोत',
      'onboarding_role_volunteer': 'मला स्वयंसेवक व्हायचे आहे',
      'create_donation': 'दान तयार करा',
      'welcome_back': 'पुन्हा स्वागत आहे',
      'welcome_back_sub': 'आपल्या फूडब्रिज खात्यामध्ये प्रवेश करा किंवा खालील डेमो प्रोफाइल निवडा.',
      'sign_in': 'लॉग इन करा',
      'sign_out': 'लॉग आउट करा',
      'register': 'नोंदणी करा',
      'email': 'ईमेल पत्ता',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड विसरलात?',
      'remember_me': 'माझी माहिती लक्षात ठेवा',
      'donor': 'दाता (Donor)',
      'ngo': 'स्वयंसेवी संस्था / निवारा (NGO)',
      'volunteer': 'स्वयंसेवक (Volunteer)',
      'admin': 'प्रशासक (Admin)',
      'donor_dashboard': 'दाता डॅशबोर्ड',
      'ngo_portal': 'स्वयंसेवी संस्था पोर्टल',
      'volunteer_dispatch': 'स्वयंसेवक डिस्पॅच',
      'admin_console': 'प्रशासक कन्सोल',
      'profile_and_settings': 'प्रोफाइल व सेटिंग्ज',
      'appearance': 'देखावा / थीम (Appearance)',
      'theme_light': 'लाइट (Light)',
      'theme_dark': 'डार्क (Dark)',
      'theme_system': 'सिस्टम (System)',
      'theme_mode': 'थीम प्रकार',
      'language': 'भाषा (Language)',
      'select_language': 'भाषा निवडा',
      'terms_and_conditions': 'नियम व अटी',
      'terms_title': 'फूडब्रिज सुरक्षा आणि समुदाय सनद',
      'terms_subtitle': 'पुढे जाण्यापूर्वी कृपया आमचे अन्न सुरक्षा, स्वच्छता आणि समुदाय नियम स्वीकारा.',
      'terms_agree': 'मी फूडब्रिज सेवा अटी, FSSAI अन्न सुरक्षा नियम आणि गोपनीयता धोरणाशी सहमत आहे.',
      'terms_dignity': 'मी सर्व दाते, स्वयंसेवक आणि लाभार्थ्यांशी आदर आणि सन्मानाने वागण्याची प्रतिज्ञा करतो.',
      'accept_continue': 'स्वीकारा आणि पुढे जा',
      'decline_signout': 'नाकारा आणि बाहेर पडा',
      'new_donation': 'नवीन दान करा',
      'donate_food': 'शिल्लक अन्न दान करा',
      'donate_food_sub': 'शिजलेले जेवण, किराणा, बेकरी व दुग्धजन्य पदार्थ (FSSAI सुरक्षा प्रतिज्ञा)',
      'donate_clothes': 'स्वच्छ कपडे दान करा',
      'donate_clothes_sub': 'उबदार कपडे, चादरी, लहान मुलांचे व प्रौढांचे कपडे',
      'my_donations': 'माझी दाने (My Donations)',
      'browse_donations': 'दान शोधा',
      'claim_donation': 'दान स्वीकारा',
      'claim_for_shelter': 'आश्रमासाठी दान आरक्षित करा',
      'active_tasks': 'सक्रिय मोहिमा (Active Deliveries)',
      'available_tasks': 'उपलब्ध कामे (Available Tasks)',
      'distribution_records': 'वाटप नोंदी (Distribution Records)',
      'log_distribution': 'वाटप नोंदवा',
      'notifications': 'सूचना (Notifications)',
      'profile': 'प्रोफाइल व सेटिंग्ज',
      'live_mission_gps': 'थेट मोहीम आणि जीपीएस सुरू करा',
      'online': 'ऑनलाइन (उपलब्ध)',
      'offline': 'ऑफलाइन',
      'available_near_you': 'तुमच्या जवळ उपलब्ध दाने',
      'filter_all': 'सर्व दाने',
      'filter_food': 'शिल्लक अन्न 🍛',
      'filter_clothing': 'कपडे 👕',
      'filter_urgent': 'लवकर संपणारे ⏳',
      'stats_rescued': 'वाचवलेले जेवण (ताट संख्या)',
      'stats_clothes': 'वाटप केलेले कपडे',
      'stats_co2': 'CO2 उत्सर्जन बचत',
      'quick_profile': 'त्वरित डेमो प्रोफाइल निवडा:',
      'switch_role': 'सक्रिय भूमिका दृश्य बदला',
      'preferences': 'प्राधान्ये आणि सुलभता (Accessibility)',
      'safety_charter_badge': 'FSSAI प्रमाणित सुरक्षा मानक',
      'darpan_verified': 'दर्पण / 80G नोंदणीकृत',
      'volunteer_limit': 'सक्रिय मोहिमा: {count} / कमाल 2',
      'pickup_deadline': 'घेऊन जाण्याची अंतिम वेळ',
      'view_details': 'पूर्ण तपशील पहा',
      'confirm_pickup': 'अन्न ताब्यात घेतल्याची पुष्टी करा',
      'confirm_delivery': 'सुरक्षित हस्तांतरण पूर्ण करा',
      'overview': 'आढावा (Overview)',
      'verifications': 'संस्था पडताळणी',
      'user_management': 'वापरकर्ता व्यवस्थापन',
      'complaints': 'तक्रार निवारण',
      'audit_logs': 'ऑडिट लॉग्स',
    },
  };
}

extension TranslationExtension on BuildContext {
  AppTranslations get tr => AppTranslations.of(this);
}
