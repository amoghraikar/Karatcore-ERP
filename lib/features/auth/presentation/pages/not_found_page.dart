import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? KcColors.obsidian950 : KcColors.slate50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            child: KcCard(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: KcColors.gold500.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.find_in_page_rounded,
                      size: 56,
                      color: KcColors.gold500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '404 - Page Not Found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? KcColors.white : KcColors.slate900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    path != null && path!.isNotEmpty
                        ? 'The requested path "$path" does not exist or requires active authentication.'
                        : 'The page you are looking for does not exist or has been relocated.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KcOutlinedButton(
                        label: 'Go to Login',
                        icon: Icons.login_rounded,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(width: 12),
                      KcPrimaryButton(
                        label: 'Go to Dashboard',
                        icon: Icons.dashboard_rounded,
                        onPressed: () => context.go(AppRoutes.dashboard),
                      ),
                    ],
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
