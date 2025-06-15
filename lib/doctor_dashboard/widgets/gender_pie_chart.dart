import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenderPieChart extends StatefulWidget {
  const GenderPieChart({super.key});

  @override
  State<GenderPieChart> createState() => _GenderPieChartState();
}

class _GenderPieChartState extends State<GenderPieChart> {
  int maleCount = 0;
  int femaleCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenderData();
  }

  Future<void> _loadGenderData() async {
    if (!mounted) return;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('gender')
          .eq('role', 'patient');

      if (!mounted) return;

      int male = 0;
      int female = 0;

      for (var user in response) {
        if (user['gender']?.toLowerCase() == 'male') {
          male++;
        } else if (user['gender']?.toLowerCase() == 'female') {
          female++;
        }
      }

      if (!mounted) return;

      setState(() {
        maleCount = male;
        femaleCount = female;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading gender data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const SizedBox(
        height: 65,
        width: 40,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    // final total = maleCount + femaleCount; // لم يعد يستخدم بعد تحويلها لأزرق بالكامل

    return SizedBox(
      height: 170,
      width: 170,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 14,
          sections: [
            PieChartSectionData(
              color: theme.colorScheme.primary,
              value: 100,
              title: '100%',
              radius: 18,
              titleStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
