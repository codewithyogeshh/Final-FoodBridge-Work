import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/config/env_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/models/app_user.dart';
import 'session_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService({SessionStorageService? sessionStorage}) {
    if (sessionStorage != null) {
      _instance._sessionStorage = sessionStorage;
    }
    return _instance;
  }

  AuthService._internal() {
    if (!EnvConfig.isConfigured) {
      _currentUser = _mockUsers['donor@foodbridge.org'];
    }
  }

  SessionStorageService _sessionStorage = SessionStorageService();
  void setSessionStorage(SessionStorageService storage) => _sessionStorage = storage;

  AppUser? _currentUser;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;
  AppUser? get currentUser => _currentUser;

  // Pre-configured mock passwords
  static final Map<String, String> _mockPasswords = {
    'donor@foodbridge.org': 'Password123!',
    'ngo@foodbridge.org': 'Password123!',
    'volunteer@foodbridge.org': 'Password123!',
    'admin@foodbridge.org': 'Password123!',
  };

  // Pre-configured mock accounts for robust development, evaluation & instant testing
  static final Map<String, AppUser> _mockUsers = {
    'donor@foodbridge.org': AppUser(
      id: 'usr-donor-101',
      email: 'donor@foodbridge.org',
      fullName: 'Vikram Joshi (Green Leaf Bistro)',
      phone: '+91 98200 12345',
      role: UserRole.donor,
      donorCategory: 'Restaurant / Cafe',
      organizationName: 'The Green Leaf Bistro',
      address: 'Shop 4, MG Road, Pune, Maharashtra 411001',
      serviceArea: 'Camp / MG Road, Pune',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    'ngo@foodbridge.org': AppUser(
      id: 'usr-ngo-202',
      email: 'ngo@foodbridge.org',
      fullName: 'Sunita Rao (Asha Foundation)',
      phone: '+91 98220 54321',
      role: UserRole.ngo,
      ngoVerificationStatus: NgoVerificationStatus.verified,
      organizationName: 'Asha Children Foundation',
      contactPerson: 'Sunita Rao',
      darpanId: 'MH/2019/0219482',
      registrationNumber: '80G-PUN-2019-114',
      verificationDocumentUrl: 'docs/verification/asha_foundation_darpan.pdf',
      address: 'Plot 12, Swargate, Pune, Maharashtra 411042',
      serviceArea: 'Swargate & Hadapsar, Pune',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    'volunteer@foodbridge.org': AppUser(
      id: 'usr-vol-303',
      email: 'volunteer@foodbridge.org',
      fullName: 'Rohit Kulkarni',
      phone: '+91 97654 99887',
      role: UserRole.volunteer,
      serviceArea: 'Kothrud & Deccan, Pune',
      availability: 'Weekdays & Evenings',
      transportType: 'Two-Wheeler / Scooter',
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

  /// Initialize auth state (check session persistence)
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
            registrationNumber: user.userMetadata?['registration_number'] as String?,
            contactPerson: user.userMetadata?['contact_person'] as String?,
            verificationDocumentUrl: user.userMetadata?['verification_document_url'] as String?,
            address: user.userMetadata?['address'] as String?,
            serviceArea: user.userMetadata?['service_area'] as String?,
            donorCategory: user.userMetadata?['donor_category'] as String?,
            availability: user.userMetadata?['availability'] as String?,
            transportType: user.userMetadata?['transport_type'] as String?,
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );
        }
      } else {
        // Try restoring persistent session from storage
        final savedUser = await _sessionStorage.getUserSession();
        if (savedUser != null) {
          _currentUser = savedUser;
        } else {
          // Default to pre-authenticated Donor demo user
          _currentUser = _mockUsers['donor@foodbridge.org'];
        }
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
      final trimmedEmail = email.trim().toLowerCase();

      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        throw AuthException('Please provide a valid email address.');
      }

      if (EnvConfig.isConfigured) {
        final response = await supa.Supabase.instance.client.auth.signInWithPassword(
          email: trimmedEmail,
          password: password,
        );
        final user = response.user;
        if (user == null) {
          throw AuthException('Invalid login response from server.');
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
          registrationNumber: user.userMetadata?['registration_number'] as String?,
          contactPerson: user.userMetadata?['contact_person'] as String?,
          verificationDocumentUrl: user.userMetadata?['verification_document_url'] as String?,
          address: user.userMetadata?['address'] as String?,
          serviceArea: user.userMetadata?['service_area'] as String?,
          donorCategory: user.userMetadata?['donor_category'] as String?,
          availability: user.userMetadata?['availability'] as String?,
          transportType: user.userMetadata?['transport_type'] as String?,
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        );
      } else {
        // Mock authentication
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_mockUsers.containsKey(trimmedEmail)) {
          throw AuthException('Account with this email does not exist. Please register first.');
        }

        final expectedPassword = _mockPasswords[trimmedEmail] ?? 'Password123!';
        if (password != expectedPassword) {
          throw AuthException('Incorrect password. Please verify your credentials.');
        }

        _currentUser = _mockUsers[trimmedEmail];
      }

      // Persist session to secure storage
      await _sessionStorage.saveUserSession(_currentUser!);

      _authStateController.add(_currentUser);
      AppLogger.info('Signed in successfully: ${_currentUser?.email} (${_currentUser?.role.name})');
      return _currentUser!;
    } catch (e, stack) {
      AppLogger.error('Sign-in failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Register a new user with role-specific profiles
  Future<AppUser> register({
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
    try {
      // 1. Security Check: Never allow public registration to create an admin account
      if (role == UserRole.admin) {
        throw AuthException('Administrator accounts cannot be created via public registration. Contact FoodBridge Security.');
      }

      final trimmedEmail = email.trim().toLowerCase();

      // 2. Validate email format
      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        throw AuthException('Please provide a valid email address.');
      }

      // 3. Validate password length
      if (password.length < 8) {
        throw AuthException('Password must be at least 8 characters long.');
      }

      // 4. Check for duplicate registration
      if (_mockUsers.containsKey(trimmedEmail)) {
        throw AuthException('An account with this email address already exists. Please sign in instead.');
      }

      if (EnvConfig.isConfigured) {
        final metadata = {
          'full_name': fullName,
          'role': role.name,
          'phone': phone,
          'organization_name': organizationName,
          'darpan_id': darpanId,
          'registration_number': registrationNumber,
          'contact_person': contactPerson,
          'verification_document_url': verificationDocumentUrl,
          'address': address,
          'service_area': serviceArea,
          'donor_category': donorCategory,
          'availability': availability,
          'transport_type': transportType,
          'ngo_verification_status': role == UserRole.ngo
              ? NgoVerificationStatus.pending.name
              : NgoVerificationStatus.unverified.name,
        };

        final response = await supa.Supabase.instance.client.auth.signUp(
          email: trimmedEmail,
          password: password,
          data: metadata,
        );

        final user = response.user;
        if (user == null) {
          throw AuthException('Registration failed. Please try again.');
        }

        _currentUser = AppUser(
          id: user.id,
          email: user.email ?? trimmedEmail,
          fullName: fullName,
          phone: phone,
          role: role,
          ngoVerificationStatus: role == UserRole.ngo
              ? NgoVerificationStatus.pending
              : NgoVerificationStatus.unverified,
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
          createdAt: DateTime.now(),
        );
      } else {
        // Mock registration
        await Future.delayed(const Duration(milliseconds: 300));

        final newUser = AppUser(
          id: 'usr-${role.name}-${DateTime.now().millisecondsSinceEpoch}',
          email: trimmedEmail,
          fullName: fullName,
          phone: phone,
          role: role,
          ngoVerificationStatus: role == UserRole.ngo
              ? NgoVerificationStatus.pending // Pending admin verification
              : NgoVerificationStatus.unverified,
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
          createdAt: DateTime.now(),
        );

        _mockUsers[trimmedEmail] = newUser;
        _mockPasswords[trimmedEmail] = password;
        _currentUser = newUser;
      }

      // Persist session
      await _sessionStorage.saveUserSession(_currentUser!);

      _authStateController.add(_currentUser);
      AppLogger.info('User registered successfully: ${_currentUser?.email}');
      return _currentUser!;
    } catch (e, stack) {
      AppLogger.error('Registration failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Request password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final trimmed = email.trim().toLowerCase();
      if (!trimmed.contains('@') || !trimmed.contains('.')) {
        throw AuthException('Please enter a valid email address.');
      }

      if (EnvConfig.isConfigured) {
        await supa.Supabase.instance.client.auth.resetPasswordForEmail(trimmed);
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_mockUsers.containsKey(trimmed)) {
          throw AuthException('No account found with this email address.');
        }
      }
      AppLogger.info('Password reset email sent to: $trimmed');
    } catch (e, stack) {
      AppLogger.error('Send password reset failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Complete password reset
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 8) {
        throw AuthException('Password must be at least 8 characters long.');
      }

      final trimmed = email.trim().toLowerCase();

      if (EnvConfig.isConfigured) {
        await supa.Supabase.instance.client.auth.updateUser(
          supa.UserAttributes(password: newPassword),
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_mockUsers.containsKey(trimmed)) {
          throw AuthException('No account found with this email address.');
        }
        _mockPasswords[trimmed] = newPassword;
      }
      AppLogger.info('Password reset successfully for: $trimmed');
    } catch (e, stack) {
      AppLogger.error('Password reset failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Update user in session and memory
  Future<void> updateUser(AppUser user) async {
    _currentUser = user;
    if (_mockUsers.containsKey(user.email)) {
      _mockUsers[user.email] = user;
    }
    await _sessionStorage.saveUserSession(user);
    _authStateController.add(_currentUser);
    AppLogger.info('User updated: ${user.email}, acceptedTerms=${user.hasAcceptedTerms}');
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

  /// Sign out and clear persistent session
  Future<void> signOut() async {
    try {
      if (EnvConfig.isConfigured) {
        await supa.Supabase.instance.client.auth.signOut();
      }
      await _sessionStorage.clearUserSession();
      _currentUser = null;
      _authStateController.add(null);
      AppLogger.info('Signed out successfully');
    } catch (e, stack) {
      AppLogger.error('Sign-out failed', e, stack);
      throw AuthException(e.toString());
    }
  }
}
