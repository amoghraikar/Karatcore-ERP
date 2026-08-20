import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../notifications/providers/notification_providers.dart';

class NotificationsPanelWidget extends ConsumerWidget {
  const NotificationsPanelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsNotifierProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];

    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STORE NOTIFICATIONS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: KcColors.goldAccent,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.go(AppRoutes.notifications),
                child: Text(
                  'View All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KcColors.goldAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No urgent store alerts.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.take(4).length,
              separatorBuilder: (context, index) => Divider(height: 16, color: borderColor),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return InkWell(
                  onTap: () {
                    if (item.isUnread) {
                      ref.read(notificationsNotifierProvider.notifier).markAsRead(item.id);
                    }
                    if (item.actionRoute != null) {
                      context.go(item.actionRoute!);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: item.isUnread ? KcColors.goldAccent : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.message,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
