import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/components/kc_brand.dart';
import '../../../shared/widgets/buttons/karat_badge.dart';

/// StippleDotPainter renders a micro-dot matrix pattern canvas
class StippleDotPainter extends CustomPainter {
  const StippleDotPainter({
    required this.dotColor,
    this.spacing = 18.0,
    this.dotRadius = 1.0,
  });

  final Color dotColor;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StippleDotPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor || oldDelegate.spacing != spacing;
}

class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.child,
    this.headline = 'Enterprise ERP for jewellery businesses that demand precision.',
    this.subheadline = 'Manage bullion sales, gold loan portfolios, live vault inventory, and double-entry accounting with real-time audit control.',
  });

  final Widget child;
  final String headline;
  final String subheadline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final canvasBg = isDark ? KcColors.bgDark : KcColors.bgLight;

    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: canvasBg,
        body: Stack(
          children: [
            // Background Stipple Matrix Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: StippleDotPainter(dotColor: dotColor),
              ),
            ),

            Column(
              children: [
                // Top Ticker Bar with Consistent KaratCore Emblem Logo
                _buildTopTickerBar(context, isDark),

                // Main Split Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Hero Showcase Panel with Rich Visuals & Animations
                        Expanded(
                          flex: 6,
                          child: _buildLeftHeroPanel(context, isDark),
                        ),
                        const SizedBox(width: 28),
                        // Right Auth Form Container with Entrance Animation
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? KcColors.surfaceDark : KcColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                                  blurRadius: 28,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: isDark ? KcColors.borderDark : KcColors.borderLight,
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 440),
                                  child: child,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Layout
    return Scaffold(
      backgroundColor: canvasBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: StippleDotPainter(dotColor: dotColor),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      // Consistent Official KaratCore Logo Badge
                      const KcBrandMark(
                        showWordmark: true,
                        subtitle: 'STORE OWNER PORTAL',
                        size: 38,
                      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? KcColors.surfaceDark : KcColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? KcColors.borderDark : KcColors.borderLight,
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(28),
                        child: child,
                      ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                      const SizedBox(height: 20),
                      Text(
                        'ENCRYPTED 256-BIT SECURE AUDIT • KARATCORE ERP',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTickerBar(BuildContext context, bool isDark) {
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Official KaratCore Brand Mark (Consistent across app)
          const KcBrandMark(
            showWordmark: true,
            subtitle: 'JEWELLERY ERP',
            size: 34,
          ),
          const Spacer(),
          // Live Feature Ticker with Accent Dots
          Row(
            children: [
              _tickerItem('REAL-TIME AUDIT', isDark),
              _goldDot(),
              _tickerItem('256-BIT ENCRYPTION', isDark),
              _goldDot(),
              _tickerItem('GOLD PLEDGE LOANS', isDark),
              _goldDot(),
              _tickerItem('DOUBLE-ENTRY LEDGER', isDark),
            ],
          ),
          const Spacer(),
          // Vault Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? KcColors.surfaceDark : KcColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: KcColors.success,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 800.ms),
                const SizedBox(width: 8),
                Text(
                  'VAULT SECURE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: KcColors.success,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tickerItem(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _goldDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: KcColors.goldAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLeftHeroPanel(BuildContext context, bool isDark) {
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final showcaseBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0x05FFFFFF) : const Color(0x05111214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Monospaced Category Tag Badge
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KaratBadge(
                  label: 'ENTERPRISE JEWELLERY ERP',
                  variant: KaratBadgeVariant.gold,
                  showDot: true,
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),

            // Giant Editorial Display Title
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1.0,
                  color: primaryTextColor,
                ),
                children: [
                  const TextSpan(text: 'Complete management '),
                  TextSpan(
                    text: 'platform',
                    style: TextStyle(color: primaryTextColor),
                  ),
                  const TextSpan(text: ' for high-precision '),
                  const TextSpan(
                    text: 'jewellery businesses.',
                    style: TextStyle(color: KcColors.goldAccent),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideY(begin: 0.04, end: 0),
            const SizedBox(height: 12),
            Text(
              subheadline,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.5,
                color: secondaryTextColor,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

          // Animated Visual Showcase Component (Replaces Feedback Box)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: showcaseBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header of Visual Monitor
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: KcColors.goldSubdued,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics_outlined, size: 20, color: KcColors.goldAccent),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VAULT & MARKET LIVESTREAM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: KcColors.goldAccent,
                          ),
                        ),
                        Text(
                          'Real-Time Bullion Rates & Vault Metrics',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: KcColors.successSubdued,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: KcColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE DATA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: KcColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 20),

                // Live Visual Ticker Grid
                Row(
                  children: [
                    Expanded(
                      child: _VisualMetricTile(
                        label: '24K GOLD RATE',
                        value: '₹7,450 /g',
                        change: '+0.4%',
                        isDark: isDark,
                      ),
                    ),
                    Container(width: 1, height: 44, color: borderColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _VisualMetricTile(
                          label: '22K JEWELLERY',
                          value: '₹6,830 /g',
                          change: '+0.3%',
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 44, color: borderColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _VisualMetricTile(
                          label: '999 FINE SILVER',
                          value: '₹88 /g',
                          change: '+0.1%',
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Vault Security Progress Bar Visual
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Store Vault LTV Safety Index',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          '98.4% Protected',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: KcColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.984,
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214),
                        valueColor: const AlwaysStoppedAnimation<Color>(KcColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 450.ms).slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }
}

class _VisualMetricTile extends StatelessWidget {
  const _VisualMetricTile({
    required this.label,
    required this.value,
    required this.change,
    required this.isDark,
  });

  final String label;
  final String value;
  final String change;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          change,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: KcColors.success,
          ),
        ),
      ],
    );
  }
}
