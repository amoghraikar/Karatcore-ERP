import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../widgets/activity_timeline.dart';
import '../../widgets/analytics_section.dart';
import '../../widgets/business_health_card.dart';
import '../../widgets/kpi_section.dart';
import '../../widgets/notifications_panel.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/today_tasks.dart';
import '../../widgets/welcome_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? 16 : 32,
          vertical: 24,
        ),
        children: [
          // 1. Editorial Greeting & Bullion Ticker
          const WelcomeHeader()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 32),

          // 2. TODAY Hero Revenue & Metric Counter
          const KpiSection()
              .animate()
              .fadeIn(delay: 80.ms, duration: 350.ms)
              .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 28),

          // 3. Quick Action Shortcuts
          const QuickActionsSection()
              .animate()
              .fadeIn(delay: 120.ms, duration: 350.ms),
          const SizedBox(height: 28),

          // 4. BUSINESS AT A GLANCE (Asymmetric Data Visualization)
          const AnalyticsSection()
              .animate()
              .fadeIn(delay: 160.ms, duration: 400.ms)
              .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 28),

          // 5. TODAY'S ATTENTION & STORE HEALTH
          if (context.isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: TodayTasksWidget()),
                SizedBox(width: 24),
                Expanded(child: BusinessHealthCard()),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms)
          else
            const Column(
              children: [
                TodayTasksWidget(),
                SizedBox(height: 24),
                BusinessHealthCard(),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 28),

          // 6. RECENT ACTIVITY STREAM & NOTIFICATIONS
          if (context.isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: ActivityTimelineWidget()),
                SizedBox(width: 24),
                Expanded(flex: 2, child: NotificationsPanelWidget()),
              ],
            ).animate().fadeIn(delay: 240.ms, duration: 400.ms)
          else
            const Column(
              children: [
                ActivityTimelineWidget(),
                SizedBox(height: 24),
                NotificationsPanelWidget(),
              ],
            ).animate().fadeIn(delay: 240.ms, duration: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
