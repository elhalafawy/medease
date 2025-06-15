import 'package:flutter/material.dart';
import '../../appointment/screens/appointment_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onBack;
  final VoidCallback? onBookAppointment;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    this.onBack,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Doctor Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Doctor image at the top
          Container(
            width: double.infinity,
            height: 260,
            color: theme.scaffoldBackgroundColor,
            child: Image.asset(
              '${doctor['image']}',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Floating DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.68,
            minChildSize: 0.68,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               '${doctor['name']}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${doctor['type']}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => RateDoctorDialog(doctorId: doctor['doctor_id'] ?? "b55f005f-3185-4fa3-9098-2179e0751621"),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 22),
                              const SizedBox(width: 4),
                              Text(
                                '${(doctor['rating'] as num?)?.toDouble().toStringAsFixed(1)}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                ' (${doctor['reviews']} reviews)',  
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${doctor['hospital']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatCircle(icon: Icons.person, value: '${doctor['patients']}', label: 'Patients'),
                        _StatCircle(icon: Icons.verified_user, value: '${doctor['experience']}', label: 'Years'),
                        _StatCircle(icon: Icons.star_border, value: '${(doctor['rating'] as num?)?.toDouble().toStringAsFixed(1)}', label: 'Rating'),
                        GestureDetector(
                          onTap: () {
                            print('Tapped reviews. Doctor ID: ${doctor['doctor_id']}');
                            showDialog(
                              context: context,
                              builder: (context) => DoctorReviewsDialog(doctorId: doctor['doctor_id'] as String?),
                            );
                          },
                          child: _StatCircle(icon: Icons.chat, value: '${doctor['reviews']}', label: 'Reviews'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About Me',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AboutMeSection(about: '${doctor['bio']}' ?? 'No information.'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentScreen(
                                doctor: doctor,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Favorite icon floating over image
          Positioned(
            top: 36,
            right: 32,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.favorite_border, color: theme.colorScheme.primary),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCircle extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCircle({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _AboutMeSection extends StatefulWidget {
  final String about;
  const _AboutMeSection({required this.about});
  @override
  State<_AboutMeSection> createState() => _AboutMeSectionState();
}

class _AboutMeSectionState extends State<_AboutMeSection> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxLines = expanded ? null : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.about,
          maxLines: maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
        if (!expanded && widget.about.length > 60)
          TextButton(
            onPressed: () => setState(() => expanded = true),
            child: Text(
              'Read more',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class RateDoctorDialog extends StatefulWidget {
  final String doctorId;
  const RateDoctorDialog({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<RateDoctorDialog> createState() => _RateDoctorDialogState();
}

class _RateDoctorDialogState extends State<RateDoctorDialog> {
  double _rating = 0;
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submitReview() async {
    setState(() => _loading = true);
    print('Doctor ID: ${widget.doctorId}');

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a review.')),
      );
      setState(() => _loading = false);
      return;
    }
    print('User ID: ${user.id}');

    String? patientId; // Declare patientId here
    String? patientName; // Declare patientName here

    try {
      // Attempt to fetch patient_id and full_name from the patients table
      final patientData = await Supabase.instance.client
          .from('patients')
          .select('patient_id, full_name') // Select full_name as well
          .eq('user_id', user.id)
          .single();

      patientId = patientData['patient_id'] as String?;
      patientName = patientData['full_name'] as String?; // Get patient name

      if (patientId == null) {
        throw Exception('Patient ID not found in your profile data or is null.');
      }
      print('Found Patient ID: $patientId, Patient Name: $patientName'); // Print patient name

      // Now attempt to insert the review into doctor_reviews
      await Supabase.instance.client.from('doctor_reviews').insert({
        'doctor_id': widget.doctorId,
        'patient_id': patientId,
        'rating': _rating,
        'message': _controller.text,
        'created_at': DateTime.now().toIso8601String(),
        'patient_name': patientName,
      });

      // If the insert operation completes without throwing an exception, it is considered successful.
      print('Review submitted successfully.');

      // --- Update doctor's review count and average rating ---
      // 1. Fetch all reviews for this doctor
      final doctorReviews = await Supabase.instance.client
          .from('doctor_reviews')
          .select('rating')
          .eq('doctor_id', widget.doctorId);

      // No need to check for doctorReviews.error as it will throw PostgrestException on error
      // and will be caught by the outer catch block.
      final List<Map<String, dynamic>> reviews = List<Map<String, dynamic>>.from(doctorReviews);
      double totalRating = 0;
      for (var review in reviews) {
        print('Type of review[\'rating\']: ${review['rating'].runtimeType}');
        totalRating += (review['rating'] as num).toDouble();
      }
      final newReviewCount = reviews.length;
      final newAverageRating = newReviewCount > 0 ? totalRating / newReviewCount : 0.0;

      print('New review count: $newReviewCount, New average rating: $newAverageRating');
      print('Type of newAverageRating: ${newAverageRating.runtimeType}');

      // 2. Update the doctors table
      await Supabase.instance.client
          .from('doctors')
          .update({
            'reviews': newReviewCount,
            'rating': newAverageRating,
          })
          .eq('doctor_id', widget.doctorId);

      print('Doctor reviews and rating updated successfully.');
      // --- End update doctor's review count and average rating ---

      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } on PostgrestException catch (e) {
      // Handle Postgrest-specific exceptions (e.g., no patient found, foreign key violation during insert if it still occurs)
      print('PostgrestException caught: ${e.message}, Code: ${e.code}');
      String errorMessage = 'An error occurred with the database.';
      if (e.code == '23503' && e.message.contains('foreign key')) {
        errorMessage = 'Please ensure your patient profile is complete and linked correctly.';
      } else if (e.code == 'PGRST116' && e.message.contains('0 rows')) {
        errorMessage = 'Patient profile not found. Please complete your profile in your settings.';
      } else {
        errorMessage = 'Error: ${e.message}'; // Generic Postgrest error message
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle any other unexpected exceptions (e.g., network issues)
      print('Caught generic exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      // Ensure loading state is reset in all cases (success, error, exception)
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Rate Doctor', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Write your review',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
          onPressed: _loading || _rating == 0 ? null : _submitReview,
        ),
      ],
    );
  }
}

class DoctorReviewsDialog extends StatefulWidget {
  final String? doctorId;

  const DoctorReviewsDialog({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DoctorReviewsDialog> createState() => _DoctorReviewsDialogState();
}

class _DoctorReviewsDialogState extends State<DoctorReviewsDialog> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    if (widget.doctorId == null || widget.doctorId!.isEmpty) {
      setState(() {
        _loadingReviews = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot fetch reviews: Invalid Doctor ID provided.')),
        );
      }
      print('Cannot fetch reviews: Doctor ID is null or empty.');
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('doctor_reviews')
          .select('patient_name, rating, message, created_at')
          .eq('doctor_id', widget.doctorId!)
          .order('created_at', ascending: false);

      setState(() {
        _reviews = List<Map<String, dynamic>>.from(response);
        _loadingReviews = false;
      });
    } on PostgrestException catch (e) {
      print('Error fetching reviews: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching reviews: ${e.message}')),
        );
      }
      setState(() {
        _loadingReviews = false;
      });
    } catch (e) {
      print('Unexpected error fetching reviews: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred while fetching reviews.')),
        );
      }
      setState(() {
        _loadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Doctor Reviews', style: theme.textTheme.titleLarge),
      content: _loadingReviews
          ? const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator()))
          : _reviews.isEmpty
              ? const Text('No reviews yet.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _reviews.map((review) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      review['patient_name'] ?? 'Anonymous',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (index) {
                                          final reviewRating = (review['rating'] as num?)?.toDouble() ?? 0.0;
                                          if (index < reviewRating.floor()) {
                                            return Icon(Icons.star, color: Colors.amber[600], size: 18);
                                          } else if (index < reviewRating && reviewRating % 1 != 0) {
                                            return Icon(Icons.star_half, color: Colors.amber[600], size: 18);
                                          } else {
                                            return Icon(Icons.star_border, color: Colors.amber[600], size: 18);
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(review['rating'] as num?)?.toDouble().toStringAsFixed(1)}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['message'] ?? 'No comment provided.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDate(review['created_at']),
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    final DateTime dateTime = DateTime.parse(isoDate).toLocal();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
