import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/route_guard.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../domain/models/app_user.dart';
import 'auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? initialRole;
  final int cooldownSeconds;
  final int otpLength;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.initialRole,
    this.cooldownSeconds = 60,
    this.otpLength = 6,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final int _otpLength;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isResending = false;
  bool _isVerifying = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _otpLength = widget.otpLength;
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _secondsRemaining = widget.cooldownSeconds;
    if (_secondsRemaining > 0) {
      _startCooldownTimer();
    }

    // Auto-focus the first OTP field after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCooldownTimer([int? seconds]) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds ?? widget.cooldownSeconds;
    });
    if (_secondsRemaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text?.trim() ?? '';
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 6) {
        setState(() {
          _inlineError = null;
          for (int i = 0; i < _otpLength; i++) {
            if (i < digits.length) {
              _controllers[i].text = digits[i];
            } else {
              _controllers[i].clear();
            }
          }
        });
        if (_focusNodes.isNotEmpty) {
          _focusNodes[_focusNodes.length - 1].unfocus();
        }
        _handleVerify();
      } else if (digits.isNotEmpty) {
        setState(() {
          for (int i = 0; i < digits.length && i < _otpLength; i++) {
            _controllers[i].text = digits[i];
          }
        });
      }
    } catch (_) {}
  }

  void _onDigitChanged(int index, String value) {
    final cleanDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length >= 6) {
      setState(() {
        _inlineError = null;
        for (int i = 0; i < _otpLength; i++) {
          if (i < cleanDigits.length) {
            _controllers[i].text = cleanDigits[i];
          } else {
            _controllers[i].clear();
          }
        }
      });
      final nextIndex = cleanDigits.length < _otpLength ? cleanDigits.length : _otpLength - 1;
      _focusNodes[nextIndex].requestFocus();
      _handleVerify();
      return;
    }

    if (cleanDigits.length > 1) {
      final lastDigit = cleanDigits[cleanDigits.length - 1];
      _controllers[index].text = lastDigit;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      setState(() {
        _inlineError = null;
      });
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length >= 6) {
          _handleVerify();
        }
      }
      return;
    }

    setState(() {
      _inlineError = null;
    });

    if (cleanDigits.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length >= 6) {
          _handleVerify();
        }
      }
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  Future<void> _handleVerify() async {
    final code = _otpCode;
    if (_isVerifying) return;
    if (code.length < 6 || code.length > _otpLength) {
      setState(() {
        _inlineError = 'कृपया ईमेलवर आलेला संपूर्ण ६-अंकी पडताळणी कोड टाका.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _inlineError = null;
    });

    final auth = context.read<AuthProvider>();
    final role = UserRole.fromString(widget.initialRole);

    try {
      final success = await auth.verifyEmailOtp(
        email: widget.email,
        token: code,
        role: role,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! Welcome to FoodBridge. (ईमेल पडताळणी यशस्वी)'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        final verifiedUser = auth.user;
        final effectiveRole = verifiedUser?.role ?? role;

        if (effectiveRole == UserRole.ngo) {
          // Unverified NGO route to review notice & login
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.verified_user_outlined,
                  color: AppColors.warningOrange, size: 48),
              title: const Text('पडताळणी प्रलंबित (Pending Review)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center),
              content: const SingleChildScrollView(
                child: Text(
                  'तुमचा ईमेल यशस्वीरित्या पडताळला गेला आहे!\n\nसंस्थेचे अधिकृत 12A/80G डॉक्युमेंट FoodBridge ॲडमिन पडताळणीसाठी पाठवले आहे. ॲडमिन मंजुरीनंतरच तुमचे लॉगिन सुरू होईल.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/login');
                  },
                  child: const Text('समजले (लॉगिनवर जा)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          final destination = RouteGuard.homeForRole(
            effectiveRole,
            verifiedUser?.donorCategory,
          );
          if (mounted) {
            try {
              context.go(destination);
            } catch (_) {}
          }
        }
      } else {
        final errorMsg = auth.errorMessage != null
            ? AppException.humanize(auth.errorMessage)
            : 'हा पडताळणी कोड चुकीचा आहे किंवा संपला आहे. कृपया "Resend Code" वर क्लिक करून नवीन कोड मागवा.';
        setState(() {
          _isVerifying = false;
          _inlineError = errorMsg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = AppException.humanize(e);
        setState(() {
          _isVerifying = false;
          _inlineError = errorMsg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _inlineError = null;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.resendOtp(email: widget.email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (success) {
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A fresh 6-digit code has been sent to ${widget.email}'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      setState(() {
        _inlineError = auth.errorMessage ??
            'Unable to resend verification code. Please wait before retrying.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_inlineError!),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: AppColors.primaryGreen,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Headline & Description
                  Text(
                    'Enter Verification Code',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.charcoal,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We have sent a $_otpLength-digit verification code to:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.mutedGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Displayed Email with Edit / Change option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.email.isEmpty
                              ? 'your email'
                              : widget.email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark
                                ? AppColors.primaryAccentDark
                                : AppColors.deepGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Change Email',
                        color: AppColors.primaryGreen,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/register');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // OTP Digit Boxes
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final boxWidth = _otpLength > 6
                          ? ((constraints.maxWidth - (_otpLength - 1) * 6) / _otpLength).clamp(32.0, 42.0)
                          : 48.0;
                      final boxHeight = _otpLength > 6 ? 52.0 : 58.0;
                      final fontSize = _otpLength > 6 ? 20.0 : 24.0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_otpLength, (index) {
                          final hasError = _inlineError != null;
                          return SizedBox(
                            width: boxWidth,
                            height: boxHeight,
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (event) => _onKeyDown(index, event),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.deepGreen,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.white,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: hasError
                                          ? AppColors.errorRed
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: hasError
                                          ? AppColors.errorRed
                                          : AppColors.primaryGreen,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                onChanged: (val) => _onDigitChanged(index, val),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Paste OTP from Clipboard Button
                  Center(
                    child: TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste_outlined, size: 16, color: AppColors.primaryGreen),
                      label: const Text(
                        'Paste OTP from Clipboard (क्लिपबोर्डवरून OTP पेस्ट करा)',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inline Error Banner
                  if (_inlineError != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _inlineError!,
                              style: const TextStyle(
                                color: AppColors.errorRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Verify OTP Button
                  FBButton(
                    label: 'Verify OTP',
                    isLoading: auth.isLoading || _isVerifying,
                    onPressed: _otpCode.length >= 6 &&
                            _otpCode.length <= _otpLength &&
                            !auth.isLoading &&
                            !_isVerifying
                        ? _handleVerify
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Resend with 60-Second Cooldown
                  Center(
                    child: _secondsRemaining > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 16, color: AppColors.mutedGrey),
                              const SizedBox(width: 6),
                              Text(
                                'Resend code in ${_secondsRemaining.toString().padLeft(2, '0')}s',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : TextButton.icon(
                            onPressed:
                                _isResending || auth.isLoading ? null : _handleResend,
                            icon: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryGreen,
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 18),
                            label: const Text(
                              'Resend OTP Code',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Security notice badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark.withOpacity(0.5)
                          : AppColors.mintLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'For your security, never share this 6-digit code with anyone. FoodBridge will never ask for your code.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.deepGreen,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
