import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationReminderScreen extends StatefulWidget {
  final String? initialName;
  final String? initialDosage;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialFrequency;
  final List<TimeOfDay>? initialReminderTimes;
  final String? initialNotes;
  final Function(String, String, DateTime, DateTime, String, List<TimeOfDay>, String?, String) onConfirm;

  const MedicationReminderScreen({
    super.key,
    this.initialName,
    this.initialDosage,
    this.initialStartDate,
    this.initialEndDate,
    this.initialFrequency,
    this.initialReminderTimes,
    this.initialNotes,
    required this.onConfirm,
  });

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedFrequency;
  List<TimeOfDay> _reminderTimes = [];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 6 hours',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _dosageController.text = widget.initialDosage ?? '';
    _notesController.text = widget.initialNotes ?? '';
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedFrequency = widget.initialFrequency ?? _frequencies[0];
    _reminderTimes = widget.initialReminderTimes ?? [TimeOfDay.now()];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : _endDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );
    if (picked != null) {
      setState(() {
        _reminderTimes[index] = picked;
      });
    }
  }

  void _addReminderTime() {
    setState(() {
      _reminderTimes.add(TimeOfDay.now());
    });
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialName == null ? 'Add Medication' : 'Edit Medication'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'Enter medication name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medication name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                hintText: 'Enter dosage (e.g., 250mg)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dosage';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
              ),
              items: _frequencies.map((String frequency) {
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFrequency = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Select date'),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Select date'),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Reminder Times', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._reminderTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return ListTile(
                title: Text('Reminder ${index + 1}'),
                subtitle: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () => _selectTime(context, index),
                    ),
                    if (_reminderTimes.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeReminderTime(index),
                      ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addReminderTime,
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder Time'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
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
                  final patientId = patient['patient_id'];

                  widget.onConfirm(
                    _nameController.text,
                    _dosageController.text,
                    _startDate!,
                    _endDate!,
                    _selectedFrequency!,
                    _reminderTimes,
                    _notesController.text.isEmpty ? null : _notesController.text,
                    patientId,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.initialName == null ? 'Add Medication' : 'Update Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
