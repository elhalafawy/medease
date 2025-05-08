import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GenderPieChart extends StatelessWidget {
  const GenderPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 18,
        sections: [
          PieChartSectionData(
            color: Colors.pink.shade300,
            value: 40,
            title: '40%',
            radius: 25,
            titleStyle: TextStyle(fontSize: 10, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.blue.shade400,
            value: 50,
            title: '50%',
            radius: 25,
            titleStyle: TextStyle(fontSize: 10, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green.shade400,
            value: 10,
            title: '10%',
            radius: 25,
            titleStyle: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
} 