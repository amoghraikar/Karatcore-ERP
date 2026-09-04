import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';

class VaultShowcaseCard extends StatelessWidget {
  const VaultShowcaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KcColors.goldAccent.withValues(alpha: isDark ? 0.3 : 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: KcColors.goldAccent.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: context.isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Visual Jewellery/Vault Banner Left
                    Expanded(
                      flex: 4,
                      child: _buildImageSection(context),
                    ),
                    // Metrics & Content Right
                    Expanded(
                      flex: 6,
                      child: _buildContentSection(context, primaryTextColor, secondaryTextColor, borderColor, isDark),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildImageSection(context, height: 160),
                    _buildContentSection(context, primaryTextColor, secondaryTextColor, borderColor, isDark),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, {double? height}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppConstants.goldVault,
            fit: BoxFit.cover,
          ),
          // Gradient Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // Badge
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KcColors.goldAccent.withValues(alpha: 0.7),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, color: KcColors.goldAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'HIGH SECURITY VAULT CUSTODY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color borderColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KcColors.goldSubdued,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'VAULT RESERVE & COLLATERAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: KcColors.goldAccent,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.go(AppRoutes.ornaments),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View Inventory',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: KcColors.goldAccent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: KcColors.goldAccent),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Live Bullion Reserve & Collateral Custody',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time valuation of in-custody customer ornaments, pledged gold loan collateral, and shop bullion.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.4,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 18),
          // Metric Tiles
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildStatPill('Total Collateral Value', '₹1,08,24,500', KcColors.goldAccent, isDark),
              _buildStatPill('Net Gold In Vault', '1,450.80 g', primaryTextColor, isDark),
              _buildStatPill('Pledged Items', '342 Ornaments', KcColors.success, isDark),
              _buildStatPill('BIS Hallmark Audit', '100% Verified', KcColors.info, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color valueColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14161B) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF262A35) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
