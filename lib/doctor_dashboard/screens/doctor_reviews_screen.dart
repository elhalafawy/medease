import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart' as app_theme;
import '../widgets/doctor_bottom_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/review_card.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showBottomBar;
  final String? doctorId;

  const DoctorReviewsScreen({
    super.key,
    this.showAppBar = true,
    this.showBottomBar = true,
    this.doctorId,
  });

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabase = Supabase.instance.client;
      final query = widget.doctorId != null
          ? supabase
              .from('doctor_reviews')
              .select('*, profiles:patient_id(full_name)')
              .eq('doctor_id', widget.doctorId as String)
              .order('created_at', ascending: false)
          : supabase
              .from('doctor_reviews')
              .select('*, profiles:patient_id(full_name)')
              .order('created_at', ascending: false);

      final reviews = await query;

      setState(() {
        _reviews = List<Map<String, dynamic>>.from(reviews);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: app_theme.AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                'Reviews',
                style: app_theme.AppTheme.titleLarge.copyWith(color: Colors.white),
              ),
              centerTitle: true,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading reviews',
                        style: app_theme.AppTheme.titleLarge.copyWith(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: app_theme.AppTheme.bodyMedium.copyWith(color: app_theme.AppTheme.greyColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReviews,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mail_outline, size: 64, color: app_theme.AppTheme.greyColor),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: app_theme.AppTheme.titleLarge.copyWith(color: app_theme.AppTheme.greyColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reviews from patients will appear here.',
                            style: app_theme.AppTheme.bodyMedium.copyWith(color: app_theme.AppTheme.greyColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        final patientName = review['profiles']?['full_name'] ?? 'Anonymous';
                        final date = DateTime.parse(review['created_at']).toLocal();
                        final formattedDate = date.toLocal().toString().split(' ')[0];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ReviewCard(
                            patientName: patientName,
                            rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                            reviewText: review['message'] as String?,
                            reviewDate: formattedDate,
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: widget.showBottomBar ? const DoctorBottomBar(currentIndex: 0) : null,
    );
  }
} 