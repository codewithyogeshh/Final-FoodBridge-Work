import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/config/env_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/models/app_user.dart';
import 'session_storage_service.dart';

class AuthService {
  static const String _kRegisteredUsersKey = 'foodbridge_registered_users_registry_v1';
  static const String _kRegisteredPasswordsKey = 'foodbridge_registered_passwords_registry_v1';

  static final AuthService _instance = AuthService._internal();
  factory AuthService({SessionStorageService? sessionStorage}) {
    if (sessionStorage != null) {
      _instance._sessionStorage = sessionStorage;
    }
    return _instance;
  }

  AuthService._internal() {
    if (_isSupabaseLive) {
      _currentUser = null;
    } else {
      _currentUser = _mockUsers['donor@foodbridge.org'];
    }
  }

  bool get _isSupabaseLive {
    try {
      if (!EnvConfig.isConfigured) return false;
      supa.Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
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
      await _loadLocalRegisteredUsers();

      if (_isSupabaseLive) {
        try {
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
          } else {
            // Restore persistent session from dual-layer local storage
            final savedUser = await _sessionStorage.getUserSession();
            _currentUser = savedUser;
          }
        } catch (_) {
          final savedUser = await _sessionStorage.getUserSession();
          _currentUser = savedUser;
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

  Future<void> _loadLocalRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersMapJson = prefs.getString(_kRegisteredUsersKey);
      if (usersMapJson != null && usersMapJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(usersMapJson);
        decoded.forEach((key, val) {
          try {
            _mockUsers[key] = AppUser.fromJson(Map<String, dynamic>.from(val));
          } catch (_) {}
        });
      }

      final passwordsJson = prefs.getString(_kRegisteredPasswordsKey);
      if (passwordsJson != null && passwordsJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(passwordsJson);
        decoded.forEach((key, val) {
          _mockPasswords[key] = val.toString();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveLocalRegisteredUser(AppUser user, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersMap = <String, dynamic>{};
      for (final entry in _mockUsers.entries) {
        usersMap[entry.key] = entry.value.toJson();
      }
      await prefs.setString(_kRegisteredUsersKey, jsonEncode(usersMap));

      final passwordsMap = <String, dynamic>{};
      for (final entry in _mockPasswords.entries) {
        passwordsMap[entry.key] = entry.value;
      }
      await prefs.setString(_kRegisteredPasswordsKey, jsonEncode(passwordsMap));
    } catch (_) {}
  }

  Future<void> _savePendingNgoApplication(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('foodbridge_pending_ngos_key_v1') ?? [];
      final appMap = {
        'id': 'ngo-app-${user.id}',
        'name': user.organizationName ?? user.fullName,
        'regNo': user.registrationNumber ?? '',
        'darpanId': user.darpanId ?? '',
        'contactPerson': user.contactPerson ?? user.fullName,
        'phone': user.phone ?? '',
        'documentName': user.verificationDocumentUrl ?? '80G_Tax_Exemption_Certificate.pdf',
        'documentPath': user.verificationDocumentUrl,
        'email': user.email,
        'appliedAt': DateTime.now().toIso8601String(),
      };
      // Prevent duplicate pending entries
      list.removeWhere((item) {
        try {
          final m = jsonDecode(item);
          return m['email'] == user.email || m['id'] == 'ngo-app-${user.id}';
        } catch (_) {
          return false;
        }
      });
      list.insert(0, jsonEncode(appMap));
      await prefs.setStringList('foodbridge_pending_ngos_key_v1', list);
    } catch (_) {}
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

      AppUser? matchedUser;

      // 1. Check local registered users & mock accounts first
      if (_mockUsers.containsKey(trimmedEmail)) {
        final expectedPassword = _mockPasswords[trimmedEmail] ?? 'Password123!';
        if (password == expectedPassword) {
          matchedUser = _mockUsers[trimmedEmail];
        } else {
          throw AuthException('Incorrect password. Please verify your credentials.');
        }
      }

      // 2. Fall back to Supabase backend if not matched locally
      if (matchedUser == null && _isSupabaseLive) {
        try {
          final response = await supa.Supabase.instance.client.auth.signInWithPassword(
            email: trimmedEmail,
            password: password,
          );
          final user = response.user;
          if (user != null) {
            matchedUser = AppUser(
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
          }
        } catch (supaErr) {
          AppLogger.warning('Supabase signInWithPassword note: $supaErr');
        }
      }

      if (matchedUser == null) {
        throw AuthException('Account with this email does not exist. Please register first.');
      }

      // 3. NGO Verification Gate: Pending/Unverified NGOs CANNOT log in until Admin approves
      if (matchedUser.role == UserRole.ngo &&
          matchedUser.ngoVerificationStatus != NgoVerificationStatus.verified) {
        _currentUser = null;
        throw AuthException(
          'तुमची संस्था अजून पडताळणीमध्ये (Pending Review) आहे. ॲडमिनने डॉक्युमेंट व्हेरिफाय केल्यानंतरच लॉगिन करता येईल.',
        );
      }

      _currentUser = matchedUser;

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

      if (_isSupabaseLive) {
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

        supa.User? user;
        try {
          final response = await supa.Supabase.instance.client.auth.signUp(
            email: trimmedEmail,
            password: password,
            data: metadata,
          );
          user = response.user;
        } catch (authErr) {
          final errStr = authErr.toString().toLowerCase();
          AppLogger.warning('Supabase Auth signUp note: $authErr');
          // Gracefully absorb email rate limits (HTTP 429) so user registration proceeds seamlessly
          if (errStr.contains('rate_limit') ||
              errStr.contains('rate limit') ||
              errStr.contains('429') ||
              errStr.contains('over_email_send_rate_limit')) {
            AppLogger.info('Supabase email rate limit gracefully absorbed. Continuing registration via local persistent storage & database profiles.');
          } else {
            rethrow;
          }
        }

        final effectiveId = user?.id ?? 'usr-${role.name}-${DateTime.now().millisecondsSinceEpoch}';

        // Ensure real profile record is saved in Supabase PostgreSQL tables
        try {
          await supa.Supabase.instance.client.from('profiles').upsert({
            'id': effectiveId,
            'email': trimmedEmail,
            'full_name': fullName,
            'phone': phone,
            'role': role.name,
          });

          if (role == UserRole.donor) {
            await supa.Supabase.instance.client.from('donor_profiles').upsert({
              'user_id': effectiveId,
              'organization_name': organizationName,
              'pickup_address': address ?? 'Pune, Maharashtra',
              'city': 'Pune',
            });
          } else if (role == UserRole.ngo) {
            await supa.Supabase.instance.client.from('ngos').upsert({
              'user_id': effectiveId,
              'legal_name': organizationName ?? fullName,
              'darpan_id': darpanId ?? 'PENDING-${effectiveId.substring(0, 8)}',
              'shelter_address': address ?? 'Pune, Maharashtra',
              'verification_status': 'pending',
            });
          } else if (role == UserRole.volunteer) {
            await supa.Supabase.instance.client.from('volunteer_profiles').upsert({
              'user_id': effectiveId,
              'vehicle_type': 'two_wheeler',
              'is_online': true,
            });
          }
        } catch (dbErr) {
          AppLogger.warning('Supabase profile table upsert note: $dbErr');
        }

        final newUser = AppUser(
          id: effectiveId,
          email: user?.email ?? trimmedEmail,
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

        _mockUsers[trimmedEmail] = newUser;
        _mockPasswords[trimmedEmail] = password;
        await _saveLocalRegisteredUser(newUser, password);
        if (role == UserRole.ngo) {
          await _savePendingNgoApplication(newUser);
        }

        _currentUser = newUser;
        await _sessionStorage.saveUserSession(_currentUser!);
        _authStateController.add(_currentUser);
        AppLogger.info('User registered successfully: ${_currentUser?.email}');
        return _currentUser!;
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
        await _saveLocalRegisteredUser(newUser, password);
        if (role == UserRole.ngo) {
          await _savePendingNgoApplication(newUser);
        }

        _currentUser = newUser;
        await _sessionStorage.saveUserSession(_currentUser!);
        _authStateController.add(_currentUser);
        AppLogger.info('User registered successfully: ${_currentUser?.email}');
        return _currentUser!;
      }
    } catch (e, stack) {
      AppLogger.error('Registration failed', e, stack);
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  /// Verify an NGO after Admin approval
  Future<void> verifyNgo({
    required String ngoId,
    String? email,
    String? organizationName,
    String? darpanId,
    String? registrationNumber,
  }) async {
    String? targetEmail = email;
    if (targetEmail == null) {
      for (final entry in _mockUsers.entries) {
        if (entry.value.id == ngoId) {
          targetEmail = entry.key;
          break;
        }
      }
    }

    if (targetEmail != null && _mockUsers.containsKey(targetEmail)) {
      final existing = _mockUsers[targetEmail]!;
      final updated = AppUser(
        id: existing.id,
        email: existing.email,
        fullName: existing.fullName,
        phone: existing.phone,
        role: existing.role,
        ngoVerificationStatus: NgoVerificationStatus.verified,
        organizationName: organizationName ?? existing.organizationName,
        darpanId: darpanId ?? existing.darpanId,
        registrationNumber: registrationNumber ?? existing.registrationNumber,
        contactPerson: existing.contactPerson,
        verificationDocumentUrl: existing.verificationDocumentUrl,
        address: existing.address,
        serviceArea: existing.serviceArea,
        donorCategory: existing.donorCategory,
        availability: existing.availability,
        transportType: existing.transportType,
        hasAcceptedTerms: existing.hasAcceptedTerms,
        createdAt: existing.createdAt,
      );
      _mockUsers[targetEmail] = updated;
      final pwd = _mockPasswords[targetEmail] ?? 'Password123!';
      await _saveLocalRegisteredUser(updated, pwd);
      AppLogger.info('NGO verified successfully in AuthService: $targetEmail');
    }

    if (_isSupabaseLive) {
      try {
        await supa.Supabase.instance.client
            .from('ngos')
            .update({'verification_status': 'verified'})
            .or('user_id.eq.$ngoId,darpan_id.eq.$darpanId');
      } catch (_) {}
    }
  }

  /// Reject an NGO registration
  Future<void> rejectNgo({
    required String ngoId,
    String? email,
  }) async {
    String? targetEmail = email;
    if (targetEmail == null) {
      for (final entry in _mockUsers.entries) {
        if (entry.value.id == ngoId) {
          targetEmail = entry.key;
          break;
        }
      }
    }

    if (targetEmail != null && _mockUsers.containsKey(targetEmail)) {
      final existing = _mockUsers[targetEmail]!;
      final updated = AppUser(
        id: existing.id,
        email: existing.email,
        fullName: existing.fullName,
        phone: existing.phone,
        role: existing.role,
        ngoVerificationStatus: NgoVerificationStatus.rejected,
        organizationName: existing.organizationName,
        darpanId: existing.darpanId,
        registrationNumber: existing.registrationNumber,
        contactPerson: existing.contactPerson,
        verificationDocumentUrl: existing.verificationDocumentUrl,
        address: existing.address,
        serviceArea: existing.serviceArea,
        donorCategory: existing.donorCategory,
        availability: existing.availability,
        transportType: existing.transportType,
        hasAcceptedTerms: existing.hasAcceptedTerms,
        createdAt: existing.createdAt,
      );
      _mockUsers[targetEmail] = updated;
      final pwd = _mockPasswords[targetEmail] ?? 'Password123!';
      await _saveLocalRegisteredUser(updated, pwd);
    }
  }

  /// Request password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final trimmed = email.trim().toLowerCase();
      if (!trimmed.contains('@') || !trimmed.contains('.')) {
        throw AuthException('Please enter a valid email address.');
      }

      if (_isSupabaseLive) {
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

      if (_isSupabaseLive) {
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
    if (_currentUser != null) {
      _sessionStorage.saveUserSession(_currentUser!);
    }
    _authStateController.add(_currentUser);
    AppLogger.info('Switched active role to: ${role.name}');
  }

  /// Restore saved session from persistent storage
  Future<AppUser?> restoreSession() async {
    try {
      final savedUser = await _sessionStorage.getUserSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        _authStateController.add(_currentUser);
        AppLogger.info('Restored saved session: ${_currentUser?.email} (${_currentUser?.role.name})');
        return _currentUser;
      } else {
        _currentUser = null;
        _authStateController.add(null);
        return null;
      }
    } catch (e, stack) {
      AppLogger.error('Failed to restore session from persistent storage', e, stack);
      _currentUser = null;
      _authStateController.add(null);
      return null;
    }
  }

  /// Sign out and clear persistent session
  Future<void> signOut() async {
    try {
      if (_isSupabaseLive) {
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
