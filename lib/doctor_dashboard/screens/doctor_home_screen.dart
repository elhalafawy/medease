import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gender_pie_chart.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/review_card.dart';
import 'doctor_reviews_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_notifications_screen.dart';
import 'doctor_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorHomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const DoctorHomeScreen({super.key, this.onTabChange});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _showReviews = false;
  int newDoctorNotifCount = 3;
  List<Map<String, dynamic>> doctorAppointments = [];
  Map<String, double> _genderStats = {'male': 0, 'female': 0};
  List<Map<String, dynamic>> _doctorReviews = [];
  List<Map<String, dynamic>> _allDoctorReviews = [];
  String _selectedAnalyticsPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    _loadGenderStats();
    _loadDoctorReviews();
    _loadAllDoctorReviewsForAverage();
  }

  Future<void> _loadGenderStats() async {
    try {
      final response =
          await Supabase.instance.client.from('patients').select('gender');

      int maleCount = 0;
      int femaleCount = 0;
      int totalCount = response.length;

      for (var patient in response) {
        if (patient['gender'] == 'male') {
          maleCount++;
        } else if (patient['gender'] == 'female') {
          femaleCount++;
        }
      }

      setState(() {
        _genderStats = {
          'male': totalCount > 0
              ? (maleCount / totalCount * 100).roundToDouble()
              : 0,
          'female': totalCount > 0
              ? (femaleCount / totalCount * 100).roundToDouble()
              : 0,
        };
      });
    } catch (e) {
      print('Error loading gender stats: $e');
    }
  }

  Future<void> _loadDoctorReviews() async {
    try {
      final response = await Supabase.instance.client
          .from('doctor_reviews')
          .select('*')
          .order('created_at', ascending: false)
          .limit(3);
      print('Supabase response (limited): $response');

      setState(() {
        _doctorReviews = List<Map<String, dynamic>>.from(response);
        print('Doctor reviews (limited) after setState: $_doctorReviews');
      });
    } catch (e) {
      print('Error loading limited doctor reviews: $e');
    }
  }

  Future<void> _loadAllDoctorReviewsForAverage() async {
    try {
      final response = await Supabase.instance.client
          .from('doctor_reviews')
          .select('*');
      print('Supabase response (all reviews): $response');

      setState(() {
        _allDoctorReviews = List<Map<String, dynamic>>.from(response);
        print('All doctor reviews after setState: $_allDoctorReviews');
      });
    } catch (e) {
      print('Error loading all doctor reviews for average: $e');
    }
  }

  double _getAverageRating() {
    if (_allDoctorReviews.isEmpty) {
      return 0.0;
    }
    double totalRating = 0;
    for (var review in _allDoctorReviews) {
      totalRating += (review['rating'] as num?)?.toDouble() ?? 0.0;
    }
    return totalRating / _allDoctorReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (!_showReviews) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundImage: AssetImage(
                                      'assets/images/doctor_photo.png'),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Welcome Dr.Ahmed, ",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const Text(
                                          "👋",
                                          style: AppTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DoctorProfileScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.account_circle,
                                              size: 16,
                                              color: AppTheme.primaryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Doctor Profile",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                final displayAppointments =
                                    doctorAppointments.isEmpty
                                        ? [
                                            {
                                              'patient': 'Menna Ahmed',
                                              'date': '20.04.2023',
                                              'time': '16:30 - 18:30',
                                            },
                                            {
                                              'patient': 'Rana Mohamed',
                                              'date': '22.04.2023',
                                              'time': '11:00-16:00',
                                            },
                                          ]
                                        : doctorAppointments;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DoctorNotificationsScreen(
                                      appointmentsCount:
                                          displayAppointments.length,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.notifications_none,
                                        size: 32, color: AppTheme.primaryColor),
                                    if (newDoctorNotifCount > 0)
                                      Positioned(
                                        right: 2,
                                        top: 0,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            '$newDoctorNotifCount',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Cards Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Gender Card
                              Container(
                                width: 108,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Gender",
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                              fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    const SizedBox(
                                        height: 65,
                                        width: 40,
                                        child: GenderPieChart()),
                                    const SizedBox(height: 2),
                                    Column(
                                      children: [
                                        _GenderLegend(
                                            color: const Color(0xFF3B82F6),
                                            label: 'Men'),
                                        const SizedBox(height: 1),
                                        _GenderLegend(
                                            color: const Color(0xFFEC4899),
                                            label: 'Women'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Messages Card
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DoctorMessagesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 108,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Messages",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 13),
                                          textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                            Icons.chat_bubble_outline,
                                            color: AppTheme.primaryColor,
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Appointments Card
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          leading: IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          title: const Text('Appointments'),
                                          backgroundColor:
                                              AppTheme.appBarBackgroundColor,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                        ),
                                        body: DoctorAppointmentsScreen(
                                          appointments: const [],
                                          onBack: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 115,
                                  margin: const EdgeInsets.only(right: 0),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Appointments",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 13),
                                          textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.star_border,
                                            color: AppTheme.primaryColor,
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Analytics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Analytics",
                              style: AppTheme.titleLarge,
                            ),
                            DropdownButton<String>(
                              value: _selectedAnalyticsPeriod,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: AppTheme.greyColor),
                              underline: const SizedBox.shrink(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedAnalyticsPeriod = newValue!;
                                });
                              },
                              items: <String>['This Week', 'This Month']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: AppTheme.bodyMedium,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnalyticsChart(selectedPeriod: _selectedAnalyticsPeriod),
                        ),
                        const SizedBox(height: 24),
                        // Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Reviews",
                              style: AppTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showReviews = true;
                                });
                              },
                              child: Text(
                                "See All Reviews",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              _getAverageRating().toStringAsFixed(1),
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text("Total ${_allDoctorReviews.length} Reviews",
                                style: AppTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_doctorReviews.isNotEmpty)
                          ..._doctorReviews.map((review) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ReviewCard(
                                patientName: review['patient_name'] as String?,
                                rating: (review['rating'] as num?)?.toDouble(),
                                reviewText: review['message'] as String?,
                                reviewDate: review['created_at'] != null
                                    ? DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0]
                                    : null,
                              ),
                            );
                          }).toList()
                        else
                          const Center(
                            child: Text('No reviews yet.'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: AppTheme.textColor),
                            onPressed: () {
                              setState(() {
                                _showReviews = false;
                              });
                            },
                          ),
                          const Text(
                            'Reviews',
                            style: AppTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: DoctorReviewsScreen(
                          showAppBar: false, showBottomBar: false),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenderLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _GenderLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.bodyMedium),
      ],
    );
  }
}
