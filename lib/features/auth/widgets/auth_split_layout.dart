import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/components/kc_brand.dart';

class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.child,
    this.headline = 'Secure Access to Your Jewellery Business',
    this.subheadline = 'Manage sales, bullion inventory, gold loans, and accounting with real-time audit control.',
  });

  final Widget child;
  final String headline;
  final String subheadline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left Hero/Brand Panel
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [KcColors.obsidian950, KcColors.obsidian900]
                        : [KcColors.obsidian900, KcColors.obsidian800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KcBrandMark(
                      showWordmark: true,
                      subtitle: 'ENTERPRISE ERP',
                      size: 40,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KcColors.gold500.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KcColors.gold500.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: KcColors.gold400),
                          SizedBox(width: 6),
                          Text(
                            'ENTERPRISE GRADE SECURITY',
                            style: TextStyle(
                              color: KcColors.gold400,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subheadline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 36),
                    // Security Reassurance Cards
                    const Row(
                      children: [
                        _FeatureBadge(
                          icon: Icons.verified_user_rounded,
                          title: '256-bit Encryption',
                          subtitle: 'Bank grade protocol',
                        ),
                        SizedBox(width: 24),
                        _FeatureBadge(
                          icon: Icons.fingerprint_rounded,
                          title: 'Multi-Factor Auth',
                          subtitle: 'Role-based access',
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '© 2026 KaratCore ERP. All rights reserved.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Form Card
            Expanded(
              flex: 6,
              child: Container(
                color: scheme.surface,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet layout
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const KcBrandMark(showWordmark: true, size: 36),
                  const SizedBox(height: 32),
                  child,
                  const SizedBox(height: 32),
                  Text(
                    'Protected by KaratCore Security Shield',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
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

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: KcColors.gold400, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
