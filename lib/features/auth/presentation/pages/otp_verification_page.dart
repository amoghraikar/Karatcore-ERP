import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
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
  final _authenticatorController = TextEditingController(text: '482910');
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
      context.go(AppRoutes.selectBranch);
    }
  }

  void _resendCode() async {
    final success = await ref.read(authStateProvider.notifier).resendOtp();
    if (success && mounted) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new 6-digit OTP code has been sent to your registered phone/email.'),
          backgroundColor: KcColors.signalGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final targetContact = authState.pendingEmailOrPhone ?? '+91 98200 12345';

    return AuthSplitLayout(
      headline: 'Two-Factor Security Verification',
      subheadline: 'Multi-factor authentication protects your jewellery business vault and financial records.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter Security Code',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit verification code to $targetContact',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // 2FA Method Selector
          Text(
            'VERIFICATION METHOD',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: scheme.onSurfaceVariant,
                ),
          ),
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
          ),
          const SizedBox(height: 24),

          if (authState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KcColors.signalRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: KcColors.signalRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: KcColors.signalRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: KcColors.signalRed,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (authState.otpMethod == 'sms') ...[
            OtpInputField(
              onCompleted: (code) {
                setState(() => _otpCode = code);
                _onVerify();
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_countdown > 0)
                  Text(
                    'Resend code in ${_countdown}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  )
                else
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text('Resend OTP Code'),
                  ),
                Text(
                  'Mock OTP: 123456',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: KcColors.gold500,
                        fontWeight: FontWeight.w700,
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
            ),
          ] else ...[
            KcTextField(
              controller: _backupCodeController,
              label: '8-Digit Security Emergency Code',
              hintText: 'e.g. 8492-3019',
              prefixIcon: const Icon(Icons.key_rounded),
            ),
          ],

          const SizedBox(height: 24),
          KcPrimaryButton(
            label: 'Verify & Continue',
            fullWidth: true,
            icon: Icons.check_circle_outline_rounded,
            isLoading: authState.isAuthenticating,
            onPressed: _onVerify,
          ),
          const SizedBox(height: 12),
          KcOutlinedButton(
            label: 'Back to Login',
            fullWidth: true,
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
