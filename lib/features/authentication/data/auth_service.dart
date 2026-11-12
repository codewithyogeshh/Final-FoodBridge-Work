import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/config/env_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/models/app_user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    if (!EnvConfig.isConfigured) {
      _currentUser = _mockUsers['donor@foodbridge.org'];
    }
  }

  AppUser? _currentUser;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;
  AppUser? get currentUser => _currentUser;

  // Pre-configured mock accounts for robust development, evaluation & instant testing
  static final Map<String, AppUser> _mockUsers = {
    'donor@foodbridge.org': AppUser(
      id: 'usr-donor-101',
      email: 'donor@foodbridge.org',
      fullName: 'Vikram Joshi (Green Cafe)',
      phone: '+91 98200 12345',
      role: UserRole.donor,
      organizationName: 'The Green Leaf Bistro',
      address: 'Shop 4, MG Road, Pune, Maharashtra 411001',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    'ngo@foodbridge.org': AppUser(
      id: 'usr-ngo-202',
      email: 'ngo@foodbridge.org',
      fullName: 'Asha Food Shelter Trust',
      phone: '+91 98220 54321',
      role: UserRole.ngo,
      ngoVerificationStatus: NgoVerificationStatus.verified,
      organizationName: 'Asha Children Foundation',
      darpanId: 'MH/2019/0219482',
      address: 'Plot 12, Swargate, Pune, Maharashtra 411042',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    'volunteer@foodbridge.org': AppUser(
      id: 'usr-vol-303',
      email: 'volunteer@foodbridge.org',
      fullName: 'Rohit Kulkarni',
      phone: '+91 97654 99887',
      role: UserRole.volunteer,
      address: 'Kothrud, Pune, Maharashtra 411038',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    'admin@foodbridge.org': AppUser(
      id: 'usr-adm-001',
      email: 'admin@foodbridge.org',
      fullName: 'Super Admin - Neha Deshmukh',
      phone: '+91 94220 11223',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
  };

  /// Initialize auth state (check session)
  Future<void> initialize() async {
    try {
      if (EnvConfig.isConfigured) {
        final session = supa.Supabase.instance.client.auth.currentSession;
        if (session != null) {
          final user = session.user;
          _currentUser = AppUser(
            id: user.id,
            email: user.email ?? '',
            fullName: user.userMetadata?['full_name'] as String? ?? 'User',
            phone: user.phone,
            role: UserRole.fromString(user.userMetadata?['role'] as String?),
            ngoVerificationStatus: NgoVerificationStatus.fromString(
              user.userMetadata?['ngo_verification_status'] as String?,
            ),
            organizationName: user.userMetadata?['organization_name'] as String?,
            darpanId: user.userMetadata?['darpan_id'] as String?,
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );
        }
      } else {
        // Default to a pre-authenticated Donor demo user so the app can be immediately explored
        _currentUser = _mockUsers['donor@foodbridge.org'];
      }
      _authStateController.add(_currentUser);
    } catch (e, stack) {
      AppLogger.error('Auth initialization error', e, stack);
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Sign in with email and password
  Future<AppUser> signIn({
    required String email,
    required String password,
    UserRole? requestedRole,
  }) async {
    try {
      if (EnvConfig.isConfigured) {
        final response = await supa.Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = response.user;
        if (user == null) {
          throw const AuthException('Invalid login response from server.');
        }

        _currentUser = AppUser(
          id: user.id,
          email: user.email ?? email,
          fullName: user.userMetadata?['full_name'] as String? ?? 'User',
          phone: user.phone,
          role: UserRole.fromString(user.userMetadata?['role'] as String?),
          ngoVerificationStatus: NgoVerificationStatus.fromString(
            user.userMetadata?['ngo_verification_status'] as String?,
          ),
          organizationName: user.userMetadata?['organization_name'] as String?,
          darpanId: user.userMetadata?['darpan_id'] as String?,
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        );
      } else {
        // Mock authentication
        await Future.delayed(const Duration(milliseconds: 600));

        final trimmedEmail = email.trim().toLowerCase();
        if (_mockUsers.containsKey(trimmedEmail)) {
          _currentUser = _mockUsers[trimmedEmail];
        } else {
          // Create custom mock profile for any entered email
          _currentUser = AppUser(
            id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            fullName: email.split('@').first.toUpperCase(),
            role: requestedRole ?? UserRole.donor,
            ngoVerificationStatus: requestedRole == UserRole.ngo
                ? NgoVerificationStatus.verified
                : NgoVerificationStatus.unverified,
            createdAt: DateTime.now(),
          );
        }
      }

      _authStateController.add(_currentUser);
      AppLogger.info('Signed in successfully: ${_currentUser?.email} (${_currentUser?.role.name})');
      return _currentUser!;
    } catch (e, stack) {
      AppLogger.error('Sign-in failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Register a new user
  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? organizationName,
    String? darpanId,
    String? address,
  }) async {
    try {
      if (EnvConfig.isConfigured) {
        final metadata = {
          'full_name': fullName,
          'role': role.name,
          'phone': phone,
          'organization_name': organizationName,
          'darpan_id': darpanId,
          'address': address,
          'ngo_verification_status': role == UserRole.ngo
              ? NgoVerificationStatus.pending.name
              : NgoVerificationStatus.unverified.name,
        };

        final response = await supa.Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: metadata,
        );

        final user = response.user;
        if (user == null) {
          throw const AuthException('Registration failed. Please try again.');
        }

        _currentUser = AppUser(
          id: user.id,
          email: user.email ?? email,
          fullName: fullName,
          phone: phone,
          role: role,
          ngoVerificationStatus: role == UserRole.ngo
              ? NgoVerificationStatus.pending
              : NgoVerificationStatus.unverified,
          organizationName: organizationName,
          darpanId: darpanId,
          address: address,
          createdAt: DateTime.now(),
        );
      } else {
        // Mock registration
        await Future.delayed(const Duration(milliseconds: 700));

        final newUser = AppUser(
          id: 'usr-${role.name}-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          fullName: fullName,
          phone: phone,
          role: role,
          ngoVerificationStatus: role == UserRole.ngo
              ? NgoVerificationStatus.verified // Allow instant access in demo mode
              : NgoVerificationStatus.unverified,
          organizationName: organizationName,
          darpanId: darpanId,
          address: address,
          createdAt: DateTime.now(),
        );

        _mockUsers[email.toLowerCase().trim()] = newUser;
        _currentUser = newUser;
      }

      _authStateController.add(_currentUser);
      AppLogger.info('User registered successfully: ${_currentUser?.email}');
      return _currentUser!;
    } catch (e, stack) {
      AppLogger.error('Registration failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Switch active role / demo profile instantly
  void switchDemoRole(UserRole role) {
    switch (role) {
      case UserRole.donor:
        _currentUser = _mockUsers['donor@foodbridge.org'];
        break;
      case UserRole.ngo:
        _currentUser = _mockUsers['ngo@foodbridge.org'];
        break;
      case UserRole.volunteer:
        _currentUser = _mockUsers['volunteer@foodbridge.org'];
        break;
      case UserRole.admin:
        _currentUser = _mockUsers['admin@foodbridge.org'];
        break;
    }
    _authStateController.add(_currentUser);
    AppLogger.info('Switched active role to: ${role.name}');
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (EnvConfig.isConfigured) {
        await supa.Supabase.instance.client.auth.signOut();
      }
      _currentUser = null;
      _authStateController.add(null);
      AppLogger.info('Signed out successfully');
    } catch (e, stack) {
      AppLogger.error('Sign-out failed', e, stack);
      throw AuthException(e.toString());
    }
  }
}
