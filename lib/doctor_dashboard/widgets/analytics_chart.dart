import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

enum ChartPeriod {
  thisWeek,
  lastWeek,
}

class AnalyticsChart extends StatefulWidget {
  const AnalyticsChart({super.key});

  @override
  State<AnalyticsChart> createState() => _AnalyticsChartState();
}

class _AnalyticsChartState extends State<AnalyticsChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.thisWeek;

  // Fixed data for This Week and Last Week
  final List<double> _thisWeekData = [
    0,
    2,
    4,
    6,
    8,
    10,
    12
  ]; // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final List<double> _lastWeekData = [
    0,
    2,
    4,
    6,
    8,
    10,
    12
  ]; // Mon, Tue, Wed, Thu, Fri, Sat, Sun

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPeriod = ChartPeriod.thisWeek;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: _selectedPeriod == ChartPeriod.thisWeek
                    ? AppTheme.primaryColor
                    : Colors.grey,
              ),
              child: const Text('This Week'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPeriod = ChartPeriod.lastWeek;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: _selectedPeriod == ChartPeriod.lastWeek
                    ? AppTheme.primaryColor
                    : Colors.grey,
              ),
              child: const Text('Last Week'),
            ),
          ],
        ),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 12,
              minY: 0,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      if (value % 2 == 0 && value <= 12) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.bodyMedium.copyWith(fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      return Text(days[value.toInt()],
                          style: AppTheme.bodyMedium.copyWith(fontSize: 10));
                    },
                    interval: 1,
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(7, (index) {
      if (_selectedPeriod == ChartPeriod.thisWeek) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: _thisWeekData[index],
                color: AppTheme.primaryColor,
                width: 8), // This Week bar
            BarChartRodData(
                toY: _lastWeekData[index],
                color: Colors.grey,
                width: 8), // Last Week bar
          ],
          showingTooltipIndicators: [],
        );
      } else {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: _lastWeekData[index],
                color: AppTheme.primaryColor,
                width: 16), // Last Week bar
          ],
          showingTooltipIndicators: [],
        );
      }
    });
  }
}
