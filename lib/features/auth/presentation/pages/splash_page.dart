import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/animations.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/components/kc_brand.dart';
import '../../models/auth_state.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  void _startInitialization() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    switch (authState.status) {
      case AuthStatus.authenticated:
        context.go(AppRoutes.dashboard);
        break;
      case AuthStatus.pendingBranch:
        context.go(AppRoutes.selectBranch);
        break;
      case AuthStatus.locked:
      case AuthStatus.sessionExpired:
        context.go(AppRoutes.locked);
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        context.go(AppRoutes.login);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? KcColors.obsidian950 : KcColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KcBrandMark(
              showWordmark: true,
              subtitle: 'JEWELLERY MANAGEMENT ERP',
              size: 56,
            ).animateScaleIn().animateFadeIn(),
            const SizedBox(height: 48),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  backgroundColor: isDark ? Colors.white12 : KcColors.slate200,
                  valueColor: const AlwaysStoppedAnimation<Color>(KcColors.gold500),
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing System & Security Context...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white38 : KcColors.slate500,
                    letterSpacing: 0.5,
                  ),
            ).animateFadeIn(),
          ],
        ),
      ),
    );
  }
}
