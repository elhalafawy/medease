import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ChartPeriod {
  thisWeek,
  thisMonth,
}

class AnalyticsChart extends StatefulWidget {
  final String selectedPeriod;

  const AnalyticsChart({super.key, required this.selectedPeriod});

  @override
  State<AnalyticsChart> createState() => _AnalyticsChartState();
}

class _AnalyticsChartState extends State<AnalyticsChart> {
  List<double> _thisWeekData = List.filled(7, 0.0);
  List<double> _thisMonthData = List.filled(31, 0.0);
  double _maxY = 12.0;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  @override
  void didUpdateWidget(covariant AnalyticsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _loadChartData();
    }
  }

  Future<void> _loadChartData() async {
    final now = DateTime.now();
    List<Map<String, dynamic>> fetchedAppointments = [];

    try {
      if (widget.selectedPeriod == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        final response = await Supabase.instance.client
            .from('appointments')
            .select('date')
            .gte('date', startOfWeek.toIso8601String().split('T')[0])
            .lte('date', endOfWeek.toIso8601String().split('T')[0])
            .eq('status', 'completed');

        fetchedAppointments = List<Map<String, dynamic>>.from(response);

        final Map<int, int> weeklyCounts = {};
        for (var i = 1; i <= 7; i++) {
          weeklyCounts[i] = 0;
        }

        for (var appt in fetchedAppointments) {
          if (appt['date'] != null) {
            final date = DateTime.parse(appt['date']);
            final weekday = date.weekday;
            weeklyCounts[weekday] = (weeklyCounts[weekday] ?? 0) + 1;
          }
        }

        setState(() {
          _thisWeekData = List.generate(7, (index) {
            final weekday = index + 1;
            return weeklyCounts[weekday]?.toDouble() ?? 0.0;
          });
          _maxY = _thisWeekData.reduce((curr, next) => curr > next ? curr : next) + 2;
          if (_maxY < 10) _maxY = 10;
        });
      } else if (widget.selectedPeriod == 'This Month') {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        final response = await Supabase.instance.client
            .from('appointments')
            .select('date')
            .gte('date', startOfMonth.toIso8601String().split('T')[0])
            .lte('date', endOfMonth.toIso8601String().split('T')[0])
            .eq('status', 'completed');

        fetchedAppointments = List<Map<String, dynamic>>.from(response);

        final int daysInMonth = endOfMonth.day;
        _thisMonthData = List.filled(daysInMonth, 0.0);

        for (var appt in fetchedAppointments) {
          if (appt['date'] != null) {
            final date = DateTime.parse(appt['date']);
            final dayOfMonth = date.day;
            if (dayOfMonth <= daysInMonth) {
              _thisMonthData[dayOfMonth - 1] = (_thisMonthData[dayOfMonth - 1]) + 1.0;
            }
          }
        }

        setState(() {
          _maxY = _thisMonthData.reduce((curr, next) => curr > next ? curr : next) + 2;
          if (_maxY < 10) _maxY = 10;
        });
      }
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _maxY,
              minY: 0,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      if (value % 2 == 0 && value <= _maxY) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface,
                          ),
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
                      final List<String> labels;
                      if (widget.selectedPeriod == 'This Week') {
                        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      } else {
                        labels = List.generate(_thisMonthData.length, (index) => (index + 1).toString());
                      }
                      if (value.toInt() < labels.length) {
                        if (widget.selectedPeriod == 'This Month' && value.toInt() % 7 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          labels[value.toInt()],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: widget.selectedPeriod == 'This Month' ? 7 : 1,
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                verticalInterval: 1,
                horizontalInterval: 2,
                getDrawingVerticalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
              ),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final theme = Theme.of(context);
    final List<double> dataToDisplay;
    if (widget.selectedPeriod == 'This Week') {
      dataToDisplay = _thisWeekData;
    } else {
      dataToDisplay = _thisMonthData;
    }

    return List.generate(
      dataToDisplay.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataToDisplay[index],
            color: theme.colorScheme.primary,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}
