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
      final now = DateTime.now();
      for (final med in allMeds) {
        final end = DateTime.parse(med['end_date']);
        if (med['status'] == 'active' && end.isBefore(now)) {
          await _medicationService.moveToHistory(med['medication_id'], 'completed');
        }
      }
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
          // Debug button removed for production
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
                          status: med['status'],
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
    String? status,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    String medStatus = status ?? 'active';
    Color badgeColor = Colors.green;
    String badgeText = 'Active';
    if (medStatus == 'canceled') {
      badgeColor = Colors.red;
      badgeText = 'Canceled';
    } else if (medStatus == 'completed') {
      badgeColor = Colors.blue;
      badgeText = 'Completed';
    } else if (today.isAfter(end)) {
      badgeColor = Colors.blue;
      badgeText = 'Completed';
      medStatus = 'completed';
    }
    int total = 0;
    int remaining = 0;
    if (frequency == 'As needed') {
      total = 0;
      remaining = 0;
    } else {
      int timesPerDay = 1;
      if (frequency == 'Once daily') timesPerDay = 1;
      else if (frequency == 'Twice daily') timesPerDay = 2;
      else if (frequency == 'Three times daily') timesPerDay = 3;
      else if (frequency == 'Four times daily') timesPerDay = 4;
      int days = end.difference(start).inDays + 1;
      total = days * timesPerDay;
      int daysPassed = today.isBefore(start) ? 0 : (today.isAfter(end) ? days : today.difference(start).inDays + 1);
      int taken = daysPassed * timesPerDay;
      remaining = (total - taken).clamp(0, total);
    }
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
                    Row(
                      children: [
                        Text(title, style: theme.textTheme.bodyLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: badgeColor, width: 1.2),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
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
                reminderTimes.isEmpty
                  ? '--'
                  : reminderTimes.map((time) {
                      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                      final minute = time.minute.toString().padLeft(2, '0');
                      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                      return '$hour:$minute $period';
                    }).join(', '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 16, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(
                'Total pills: ',
                style: theme.textTheme.bodyMedium,
              ),
              frequency == 'As needed'
                ? const Text('--', style: TextStyle(fontWeight: FontWeight.bold))
                : Text('$remaining / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
