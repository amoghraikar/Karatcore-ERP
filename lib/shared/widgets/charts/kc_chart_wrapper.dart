import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

class KcChartDataPoint {
  const KcChartDataPoint({required this.xLabel, required this.value});
  final String xLabel;
  final double value;
}

class KcDonutDataPoint {
  const KcDonutDataPoint({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;
}

abstract final class KcChartWrapper {
  static Widget lineChart({
    required BuildContext context,
    required List<KcChartDataPoint> data,
    Color? lineColor,
    double height = 220,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = lineColor ?? KcColors.emerald600;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? KcColors.navy700.withValues(alpha: 0.5) : KcColors.slate200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, idx) {
                  final index = val.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].xLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? KcColors.slate400 : KcColors.slate600,
                              fontWeight: FontWeight.w600,
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
              spots: [
                for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value),
              ],
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.28),
                    primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget barChart({
    required BuildContext context,
    required List<KcChartDataPoint> data,
    Color? barColor,
    double height = 220,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = barColor ?? KcColors.gold600;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, idx) {
                  final index = val.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].xLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? KcColors.slate400 : KcColors.slate600,
                              fontWeight: FontWeight.w600,
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
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.6),
                      ],
                    ),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static Widget donutChart({
    required BuildContext context,
    required List<KcDonutDataPoint> data,
    double height = 220,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  for (final item in data)
                    PieChartSectionData(
                      color: item.color,
                      value: item.value,
                      title: '${item.value.toInt()}%',
                      radius: 28,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in data)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
