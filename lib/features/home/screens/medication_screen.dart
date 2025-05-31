import 'package:flutter/material.dart';
import 'medication_reminder_screen.dart';
import '../../../core/supabase/medication_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MedicationScreen({super.key, this.onBack});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final MedicationService _medicationService = MedicationService();
  List<Map<String, dynamic>> _activeMedications = [];
  List<Map<String, dynamic>> _historyMedications = [];
  bool showHistory = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      setState(() => _isLoading = true);
      final allMeds = await _medicationService.getAllUserMedications();
      print('DEBUG: All medications fetched: ${allMeds.length}');
      print('DEBUG: First medication: ${allMeds.isNotEmpty ? allMeds.first : "No medications"}');
      
      if (showHistory) {
        _historyMedications = allMeds.where((m) => m['status'] != 'active').toList();
        print('DEBUG: History medications: ${_historyMedications.length}');
      } else {
        _activeMedications = allMeds.where((m) => m['status'] == 'active').toList();
        print('DEBUG: Active medications: ${_activeMedications.length}');
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('DEBUG: Error loading medications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addMedication(
    String name,
    String dosage,
    DateTime startDate,
    DateTime endDate,
    String frequency,
    List<TimeOfDay> reminderTimes,
    String? notes,
    String patientId,
  ) async {
    try {
      await _medicationService.addMedication(
        patientId: patientId,
        name: name,
        dosage: dosage,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        reminderTimes: reminderTimes,
        notes: notes,
      );
      await _loadMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medication: $e')),
        );
      }
    }
  }

  Future<void> _removeMedication(int index) async {
    try {
      final med = _activeMedications[index];
      await _medicationService.moveToHistory(med['medication_id'], 'canceled');
      await _loadMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing medication: $e')),
        );
      }
    }
  }

  Future<void> _editMedication(int index) async {
    final med = _activeMedications[index];
    final name = med['name'];
    final dosage = med['dosage'];
    final startDate = DateTime.parse(med['start_date']);
    final endDate = DateTime.parse(med['end_date']);
    final frequency = med['frequency'];
    final reminderTimes = (med['reminder_times'] as List)
        .map((time) => TimeOfDay(
              hour: int.parse(time.split(':')[0]),
              minute: int.parse(time.split(':')[1]),
            ))
        .toList();
    final notes = med['notes'];

    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationReminderScreen(
          initialName: name,
          initialDosage: dosage,
          initialStartDate: startDate,
          initialEndDate: endDate,
          initialFrequency: frequency,
          initialReminderTimes: reminderTimes,
          initialNotes: notes,
          onConfirm: (newName, newDosage, newStartDate, newEndDate, newFrequency, newReminderTimes, newNotes, patientId) async {
            try {
              await _medicationService.updateMedication(
                medicationId: med['medication_id'],
                name: newName,
                dosage: newDosage,
                startDate: newStartDate,
                endDate: newEndDate,
                frequency: newFrequency,
                reminderTimes: newReminderTimes,
                notes: newNotes,
              );
              await _loadMedications();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating medication: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _checkExpiredMedications() async {
    try {
      final now = DateTime.now();
      final expired = _activeMedications.where((m) => 
        DateTime.parse(m['end_date']).isBefore(now)
      ).toList();

      for (var med in expired) {
        await _medicationService.moveToHistory(med['medication_id'], 'completed');
      }
      
      await _loadMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking expired medications: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meds = showHistory ? _historyMedications : _activeMedications;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text('Prescriptions', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        actions: [
          // Debug button
          IconButton(
            icon: Icon(Icons.bug_report, color: theme.colorScheme.primary),
            onPressed: () async {
              try {
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not authenticated')),
                  );
                  return;
                }
                
                final patient = await Supabase.instance.client
                    .from('patients')
                    .select('patient_id')
                    .eq('user_id', user.id)
                    .maybeSingle();

                if (patient == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient not found')),
                  );
                  return;
                }

                await _medicationService.addMedication(
                  patientId: patient['patient_id'],
                  name: 'Test Medication',
                  dosage: '500mg',
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 30)),
                  frequency: 'Once daily',
                  reminderTimes: [TimeOfDay.now()],
                  notes: 'Test medication for debugging',
                );

                await _loadMedications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test medication added')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  _buildSearchBar(theme),
                  const SizedBox(height: 16),
                  _buildTabs(theme),
                  const SizedBox(height: 4),
                  Divider(color: theme.dividerColor, thickness: 1, endIndent: 200),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meds.length,
                      itemBuilder: (context, index) {
                        final med = meds[index];
                        return _buildMedicationCard(
                          theme: theme,
                          title: med['name'],
                          subtitle: med['notes'] ?? '',
                          dosage: med['dosage'],
                          frequency: med['frequency'],
                          startDate: DateTime.parse(med['start_date']),
                          endDate: DateTime.parse(med['end_date']),
                          reminderTimes: (med['reminder_times'] as List)
                              .map((time) => TimeOfDay(
                                    hour: int.parse(time.split(':')[0]),
                                    minute: int.parse(time.split(':')[1]),
                                  ))
                              .toList(),
                          onEdit: showHistory ? null : () => _editMedication(index),
                          onDelete: showHistory ? null : () => _removeMedication(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!showHistory)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicationReminderScreen(
                                  onConfirm: (name, dosage, startDate, endDate, frequency, reminderTimes, notes, patientId) async {
                                    await _addMedication(name, dosage, startDate, endDate, frequency, reminderTimes, notes, patientId);
                                  },
                                ),
                              ),
                            );
                            await _loadMedications();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            shadowColor: Colors.transparent,
                          ),
                          child: Text('Add Medication', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => showHistory = false);
            _loadMedications();
          },
          child: Text('Active',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: showHistory ? theme.disabledColor : theme.colorScheme.onSurface,
              )),
        ),
        GestureDetector(
          onTap: () {
            setState(() => showHistory = true);
            _loadMedications();
          },
          child: Text('History',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: showHistory ? theme.colorScheme.onSurface : theme.disabledColor,
              )),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.disabledColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medications',
                hintStyle: theme.textTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<TimeOfDay> reminderTimes,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete, color: theme.colorScheme.error),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medication_outlined, size: 16, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text('$dosage - $frequency', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(
                '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(
                reminderTimes.map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}').join(', '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
