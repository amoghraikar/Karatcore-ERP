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
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          const WelcomeHeader().animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          const KpiSection().animate().fadeIn(delay: 100.ms, duration: 350.ms),
          const SizedBox(height: 24),
          const QuickActionsSection().animate().fadeIn(delay: 150.ms, duration: 350.ms),
          const SizedBox(height: 24),
          const AnalyticsSection().animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),
          if (context.isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ActivityTimelineWidget()),
                SizedBox(width: 16),
                Expanded(child: NotificationsPanelWidget()),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms)
          else
            const Column(
              children: [
                ActivityTimelineWidget(),
                SizedBox(height: 16),
                NotificationsPanelWidget(),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
          const SizedBox(height: 24),
          if (context.isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: TodayTasksWidget()),
                SizedBox(width: 16),
                Expanded(child: BusinessHealthCard()),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms)
          else
            const Column(
              children: [
                TodayTasksWidget(),
                SizedBox(height: 16),
                BusinessHealthCard(),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
