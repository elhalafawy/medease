import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt()], style: TextStyle(fontSize: 10));
              },
              interval: 1,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 10, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 14, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 9, color: Colors.blue)], showingTooltipIndicators: []),
          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 11, color: Colors.blue)], showingTooltipIndicators: []),
        ],
      ),
    );
  }
} 