import 'dart:async';
import 'package:flutter/foundation.dart';
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

  void _init() {
    _user = _authService.currentUser;
    _subscription = _authService.authStateChanges.listen((updatedUser) {
      _user = updatedUser;
      notifyListeners();
    });
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
    String? address,
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
        address: address,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
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
      _errorMessage = e.toString();
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
