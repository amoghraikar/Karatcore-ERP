import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../providers/dashboard_provider.dart';

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartData = ref.watch(revenueChartDataProvider);
    final donutData = ref.watch(loanDistributionChartProvider);

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
          // Section Sub-header Label
          Row(
            children: [
              Text(
                'BUSINESS AT A GLANCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: KcColors.goldAccent,
                ),
              ),
              const Spacer(),
              Text(
                'Last 7 Days Performance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Asymmetric Grid for Charts
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final lineChartWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue & Disbursement Velocity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily loan principal disbursed across the weekly cycle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 50000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: borderColor,
                              strokeWidth: 1.0,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox.shrink();
                                return Text(
                                  '${(value / 1000).toStringAsFixed(0)}k',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: secondaryTextColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < chartData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      chartData[index].xLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              chartData.length,
                              (i) => FlSpot(i.toDouble(), chartData[i].value),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: KcColors.goldAccent,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: cardBg,
                                  strokeWidth: 2.5,
                                  strokeColor: KcColors.goldAccent,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: KcColors.goldAccent.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              final donutChartWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vault Collateral Composition',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Purity distribution of pledged ornaments',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 170,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: donutData.map((d) {
                          return PieChartSectionData(
                            color: d.color,
                            value: d.value > 0 ? d.value : 1.0,
                            title: '${d.value.toStringAsFixed(0)}%',
                            radius: 28,
                            titleStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: donutData.map((d) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: d.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: lineChartWidget),
                    const SizedBox(width: 32),
                    Container(width: 1, height: 280, color: borderColor),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: donutChartWidget),
                  ],
                );
              }

              return Column(
                children: [
                  lineChartWidget,
                  const SizedBox(height: 32),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 32),
                  donutChartWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
