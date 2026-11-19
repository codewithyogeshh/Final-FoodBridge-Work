import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../data/auth_service.dart';
import '../domain/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  UserRole get currentRole => _user?.role ?? UserRole.donor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isNgoVerified => _user?.isNgoVerified ?? false;
  bool get hasAcceptedTerms => _user?.hasAcceptedTerms ?? false;

  void _init() {
    _user = _authService.currentUser;
    _subscription = _authService.authStateChanges.listen((updatedUser) {
      _user = updatedUser;
      notifyListeners();
    });
  }

  Future<AppUser?> restoreSession() async {
    final restored = await _authService.restoreSession();
    _user = restored;
    notifyListeners();
    return _user;
  }

  Future<bool> login({
    required String email,
    required String password,
    UserRole? requestedRole,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
        requestedRole: requestedRole,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? organizationName,
    String? darpanId,
    String? registrationNumber,
    String? contactPerson,
    String? verificationDocumentUrl,
    String? address,
    String? serviceArea,
    String? donorCategory,
    String? availability,
    String? transportType,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        organizationName: organizationName,
        darpanId: darpanId,
        registrationNumber: registrationNumber,
        contactPerson: contactPerson,
        verificationDocumentUrl: verificationDocumentUrl,
        address: address,
        serviceArea: serviceArea,
        donorCategory: donorCategory,
        availability: availability,
        transportType: transportType,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  /// Initiate registration and dispatch 6-digit OTP email
  Future<bool> initiateRegistration({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? organizationName,
    String? darpanId,
    String? registrationNumber,
    String? contactPerson,
    String? verificationDocumentUrl,
    String? address,
    String? serviceArea,
    String? donorCategory,
    String? availability,
    String? transportType,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await _authService.initiateRegistrationWithOtp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        organizationName: organizationName,
        darpanId: darpanId,
        registrationNumber: registrationNumber,
        contactPerson: contactPerson,
        verificationDocumentUrl: verificationDocumentUrl,
        address: address,
        serviceArea: serviceArea,
        donorCategory: donorCategory,
        availability: availability,
        transportType: transportType,
      );
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  /// Verify 6-digit email OTP and complete authentication
  Future<bool> verifyEmailOtp({
    required String email,
    required String token,
    UserRole? role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.verifyEmailOtp(
        email: email,
        token: token,
        role: role,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  /// Resend 6-digit OTP email
  Future<bool> resendOtp({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resendOtp(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(email: email, newPassword: newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> acceptTerms() async {
    if (_user != null) {
      final updated = _user!.copyWith(hasAcceptedTerms: true);
      await _authService.updateUser(updated);
      _user = updated;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    required String fullName,
    String? phone,
    String? address,
    String? serviceArea,
    String? organizationName,
    String? transportType,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      final updated = _user!.copyWith(
        fullName: fullName.trim(),
        phone: phone?.trim(),
        address: address?.trim(),
        serviceArea: serviceArea?.trim(),
        organizationName: organizationName?.trim(),
        transportType: transportType?.trim(),
        avatarUrl: avatarUrl,
        clearAvatar: clearAvatar || (avatarUrl != null && avatarUrl.isEmpty),
      );
      await _authService.updateUser(updated);
      _user = updated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void switchRole(UserRole role) {
    _authService.switchDemoRole(role);
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = AppException.humanize(e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
