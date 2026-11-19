class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';

  /// Convert any technical error or auth exception into a clear, empathetic, human-readable message.
  static String humanize(dynamic error) {
    if (error == null) return 'अज्ञात त्रुटी आली. कृपया पुन्हा प्रयत्न करा.';
    final str = error.toString().toLowerCase();

    // 1. Duplicate Account / User Already Exists
    if (str.contains('already registered') ||
        str.contains('user already exists') ||
        str.contains('email address already exists') ||
        str.contains('already exists') ||
        str.contains('user_already_exists') ||
        str.contains('आधीपासून खाते अस्तित्वात आहे') ||
        str.contains('आधीच खाते तयार केलेले आहे')) {
      return 'या ईमेलवर आधीच खाते तयार केलेले आहे. एका ईमेलवरून दुसरे नवीन खाते तयार करता येत नाही. कृपया लॉगिन करा किंवा पासवर्ड विसरला असल्यास "Forgot Password" वापरा.';
    }

    // 2. Password Requirements (Supabase 12-char policy)
    if (str.contains('at least 12 characters') ||
        str.contains('weak_password') ||
        str.contains('password should be') ||
        str.contains('password must be') ||
        str.contains('weak password')) {
      return 'सुरक्षिततेसाठी पासवर्ड किमान १२ अक्षरांचा असावा ज्यामध्ये अक्षरे, अंक आणि विशेष चिन्ह असावेत (उदा. FoodBridge@2026).';
    }

    // 3. Invalid Login Credentials / Wrong Password
    if (str.contains('invalid login credentials') ||
        str.contains('invalid_credentials') ||
        str.contains('incorrect password')) {
      return 'ईमेल किंवा पासवर्ड चुकीचा आहे. कृपया माहिती तपासून पुन्हा लॉगिन करा.';
    }

    // 4. User Not Found
    if (str.contains('does not exist') ||
        str.contains('user not found') ||
        str.contains('account with this email does not exist')) {
      return 'या ईमेलवर कोणतेही खाते सापडले नाही. कृपया आधी नवीन खाते नोंदणी (Register) करा.';
    }

    // 5. Email Not Confirmed / Verified
    if (str.contains('email not verified') ||
        str.contains('email_not_confirmed') ||
        str.contains('email not confirmed')) {
      return 'तुमचा ईमेल अजून पडताळलेला नाही. कृपया ईमेलवर आलेला ६-अंकी कोड (OTP) टाकून पडताळणी पूर्ण करा.';
    }

    // 6. Invalid or Expired OTP / Token
    if (str.contains('token has expired') ||
        str.contains('otp_expired') ||
        str.contains('invalid verification code') ||
        str.contains('invalid or expired') ||
        str.contains('invalid token') ||
        str.contains('token is invalid') ||
        str.contains('invalid otp')) {
      return 'हा पडताळणी कोड (OTP) चुकीचा आहे किंवा त्याची मुदत संपली आहे. कृपया खालील "Resend Code" वर क्लिक करून नवीन कोड मागवा.';
    }

    // 7. Incomplete OTP Length
    if (str.contains('complete 6-digit') ||
        str.contains('complete verification code') ||
        str.contains('enter all')) {
      return 'कृपया ईमेलवर आलेला संपूर्ण ६-अंकी पडताळणी कोड बरोबर टाका.';
    }

    // 8. Rate Limit / 429
    if (str.contains('rate_limit') ||
        str.contains('rate limit') ||
        str.contains('over_email_send_rate_limit') ||
        str.contains('429')) {
      return 'सुरक्षेच्या कारणास्तव खूप विनंत्या पाठवल्या आहेत. कृपया १ मिनिट (६० सेकंद) थांबा आणि पुन्हा प्रयत्न करा.';
    }

    // 9. Document Required (Donor Aadhaar/PAN or NGO Darpan)
    if (str.contains('identity proof') ||
        str.contains('document') ||
        str.contains('ओळखपत्र') ||
        str.contains('aadhar') ||
        str.contains('aadhaar') ||
        str.contains('pan card')) {
      return 'कृपया दात्याचे ओळखपत्र (Aadhaar किंवा PAN Card) जोडा. अन्नाच्या सुरक्षिततेसाठी आणि विश्वासासाठी हे आवश्यक आहे.';
    }

    // 10. Network / Connection Error
    if (str.contains('socketexception') ||
        str.contains('network') ||
        str.contains('failed host lookup') ||
        str.contains('connection refused') ||
        str.contains('clientexception')) {
      return 'इंटरनेट कनेक्शन उपलब्ध नाही. कृपया तुमचा मोबाईल डेटा किंवा वायफाय तपासून पुन्हा प्रयत्न करा.';
    }

    // Fallback: If it's an AppException with clean message, return its message
    if (error is AppException && error.message.isNotEmpty && !error.message.startsWith('AuthApi')) {
      return error.message;
    }

    // Clean up generic prefixes
    String clean = error.toString()
        .replaceAll('AuthApiException: ', '')
        .replaceAll('AuthWeakPasswordException: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('AppException: ', '')
        .replaceAll('Exception: ', '');
    return clean;
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}
