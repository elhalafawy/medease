import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

class GenderPieChart extends StatelessWidget {
  const GenderPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 14,
        sections: [
          PieChartSectionData(
            color: const Color(0xFFEC4899), // pink
            value: 40,
            title: '40%',
            radius: 18,
            titleStyle: AppTheme.bodyMedium.copyWith(color: Colors.white, fontSize: 10),
          ),
          PieChartSectionData(
            color: const Color(0xFF3B82F6), // blue
            value: 50,
            title: '50%',
            radius: 18,
            titleStyle: AppTheme.bodyMedium.copyWith(color: Colors.white, fontSize: 10),
          ),
          PieChartSectionData(
            color: const Color(0xFF34D399), // green
            value: 10,
            title: '10%',
            radius: 18,
            titleStyle: AppTheme.bodyMedium.copyWith(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
} 