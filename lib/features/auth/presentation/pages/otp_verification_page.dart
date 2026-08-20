import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/karat_badge.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';
import '../../widgets/otp_input_field.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  String _otpCode = '';
  final _authenticatorController = TextEditingController();
  final _backupCodeController = TextEditingController();

  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authenticatorController.dispose();
    _backupCodeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onVerify() async {
    final codeToVerify = ref.read(authStateProvider).otpMethod == 'authenticator'
        ? _authenticatorController.text
        : ref.read(authStateProvider).otpMethod == 'backup'
            ? _backupCodeController.text
            : _otpCode;

    final success = await ref.read(authStateProvider.notifier).verifyOtp(codeToVerify);
    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _resendCode() async {
    final success = await ref.read(authStateProvider.notifier).resendOtp();
    if (success && mounted) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new 6-digit verification code has been sent to your device.'),
          backgroundColor: KcColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final targetContact = authState.pendingEmailOrPhone ?? '+91 98200 12345';

    return AuthSplitLayout(
      headline: 'Two-Factor Security Verification',
      subheadline: 'Multi-factor authentication protects your jewellery business vault and financial records.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              KaratBadge(
                label: 'SECURITY VERIFICATION',
                variant: KaratBadgeVariant.gold,
                showDot: true,
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          Text(
            'Enter Security Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: primaryTextColor,
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 350.ms),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit verification code to $targetContact',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: KcColors.goldAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Testing Mode: Enter 123456 (or any 6-digit code) to complete verification.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
          const SizedBox(height: 24),

          // 2FA Method Selector
          Text(
            'VERIFICATION METHOD',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: secondaryTextColor,
            ),
          ).animate().fadeIn(delay: 140.ms, duration: 350.ms),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'sms',
                label: Text('SMS / Email'),
                icon: Icon(Icons.sms_outlined, size: 16),
              ),
              ButtonSegment(
                value: 'authenticator',
                label: Text('Auth App'),
                icon: Icon(Icons.phonelink_lock_outlined, size: 16),
              ),
              ButtonSegment(
                value: 'backup',
                label: Text('Backup Code'),
                icon: Icon(Icons.key_outlined, size: 16),
              ),
            ],
            selected: {authState.otpMethod},
            onSelectionChanged: (set) {
              ref.read(authStateProvider.notifier).setOtpMethod(set.first);
            },
          ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
          const SizedBox(height: 24),

          if (authState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KcColors.dangerSubdued,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: KcColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: KcColors.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        color: KcColors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms).shakeX(amount: 4),
            const SizedBox(height: 20),
          ],

          if (authState.otpMethod == 'sms') ...[
            OtpInputField(
              onCompleted: (code) {
                setState(() => _otpCode = code);
                _onVerify();
              },
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_countdown > 0)
                  Text(
                    'Resend code in ${_countdown}s',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  )
                else
                  TextButton(
                    onPressed: _resendCode,
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: KcColors.goldAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ] else if (authState.otpMethod == 'authenticator') ...[
            KcTextField(
              controller: _authenticatorController,
              label: 'Authenticator Code (TOTP)',
              hintText: 'Enter 6-digit code from Google/Microsoft Authenticator',
              prefixIcon: const Icon(Icons.security_rounded),
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
          ] else ...[
            KcTextField(
              controller: _backupCodeController,
              label: '8-Digit Security Emergency Code',
              hintText: 'e.g. 8492-3019',
              prefixIcon: const Icon(Icons.key_rounded),
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
          ],

          const SizedBox(height: 24),
          KcPrimaryButton(
            label: 'VERIFY & CONTINUE',
            fullWidth: true,
            icon: Icons.check_circle_outline_rounded,
            isLoading: authState.isAuthenticating,
            onPressed: _onVerify,
          ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
          const SizedBox(height: 12),
          KcOutlinedButton(
            label: 'BACK TO LOGIN',
            fullWidth: true,
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
        ],
      ),
    );
  }
}
