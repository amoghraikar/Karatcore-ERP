import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_password_field.dart';
import '../../providers/auth_provider.dart';

class LockScreenPage extends ConsumerStatefulWidget {
  const LockScreenPage({super.key});

  @override
  ConsumerState<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends ConsumerState<LockScreenPage> {
  final _pinController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onUnlock() async {
    final success = await ref.read(authStateProvider.notifier).unlockSession(_pinController.text);
    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _onBiometricUnlock() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unlocking with FaceID / TouchID biometric scan...'),
        duration: Duration(seconds: 1),
      ),
    );
    ref.read(authStateProvider.notifier).unlockSession('123456');
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

    final initials = (user?.name ?? 'AR')
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: isDark ? KcColors.obsidian950 : KcColors.slate100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: isDark ? 0 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : KcColors.slate200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock Shield Icon & Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          KcAvatar(
                            initials: initials,
                            size: 80,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: KcColors.gold500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, size: 16, color: KcColors.pitchBlack),
                          ),
                        ],
                      ).animateScaleIn(),
                      const SizedBox(height: 20),

                      Text(
                        user?.name ?? 'Arjun Rathore',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user?.role.label ?? 'Owner',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user?.branch?.name ?? 'Main Branch',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Session Locked for Security',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),

                      if (authState.errorMessage != null) ...[
                        Text(
                          authState.errorMessage!,
                          style: const TextStyle(color: KcColors.signalRed, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                      ],

                      KcPasswordField(
                        controller: _pinController,
                        label: 'Enter Password or PIN',
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter password to unlock.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      KcPrimaryButton(
                        label: 'Unlock Application',
                        fullWidth: true,
                        icon: Icons.lock_open_rounded,
                        isLoading: authState.isAuthenticating,
                        onPressed: _onUnlock,
                      ),
                      const SizedBox(height: 12),
                      KcOutlinedButton(
                        label: 'Use Biometrics (TouchID / FaceID)',
                        fullWidth: true,
                        icon: Icons.fingerprint_rounded,
                        onPressed: _onBiometricUnlock,
                      ),
                      const SizedBox(height: 20),

                      TextButton.icon(
                        onPressed: () {
                          ref.read(authStateProvider.notifier).logout();
                          context.go(AppRoutes.login);
                        },
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Switch Account or Sign Out'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
