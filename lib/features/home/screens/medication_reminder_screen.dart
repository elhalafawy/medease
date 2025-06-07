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
    'As needed',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _dosageController.text = widget.initialDosage ?? '';
    _notesController.text = widget.initialNotes ?? '';
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? (_startDate!.add(const Duration(days: 7)));
    _selectedFrequency = widget.initialFrequency ?? _frequencies[0];
    _reminderTimes = widget.initialReminderTimes ?? getDefaultTimes(_selectedFrequency);
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
      firstDate: isStartDate ? DateTime.now() : _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _endDate = picked.add(const Duration(days: 7));
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

  // --- Helper: get default times based on frequency ---
  List<TimeOfDay> getDefaultTimes(String? freq) {
    if (freq == 'Once daily') {
      return [const TimeOfDay(hour: 0, minute: 0)]; // 12:00 AM
    } else if (freq == 'Twice daily') {
      return [const TimeOfDay(hour: 0, minute: 0), const TimeOfDay(hour: 12, minute: 0)]; // 12:00 AM, 12:00 PM
    } else if (freq == 'Three times daily') {
      return [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 16, minute: 0), const TimeOfDay(hour: 0, minute: 0)]; // 8:00 AM, 4:00 PM, 12:00 AM
    } else if (freq == 'Four times daily') {
      return [const TimeOfDay(hour: 6, minute: 0), const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 18, minute: 0), const TimeOfDay(hour: 0, minute: 0)]; // 6:00 AM, 12:00 PM, 6:00 PM, 12:00 AM
    } else {
      return [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(18);
    final selectedColor = theme.primaryColor;
    final unselectedColor = theme.colorScheme.surfaceVariant;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    // Helper for frequency display
    String getFrequencyLabel(String? freq) {
      switch (freq) {
        case 'Once daily':
          return 'Once a day';
        case 'Twice daily':
          return 'Twice a day';
        case 'Three times daily':
          return '3 times a day';
        case 'Four times daily':
          return '4 times a day';
        case 'As needed':
          return 'As needed';
        default:
          return freq ?? '';
      }
    }

    // Helper for duration display
    String getDuration(DateTime? start, DateTime? end) {
      if (start == null || end == null) return '';
      final df = DateFormat('d MMM');
      return '${df.format(start)} - ${df.format(end)},${end.year}';
    }

    // Helper for dosage
    String getDosage(String? d) => d != null && d.isNotEmpty ? d : '-';

    // Helper for name
    String getName(String? n) => n != null && n.isNotEmpty ? n : '-';

    // Frequency options for UI
    final freqOptions = [
      'Once daily',
      'Twice daily',
      'Three times daily',
      'Four times daily',
      'As needed',
    ];

    // Time grid options
    final timeGrid = [
      for (int h = 6; h <= 21; h++)
        TimeOfDay(hour: h, minute: 0),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication reminder'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Card with summary info and input fields ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              shadowColor: selectedColor.withOpacity(0.13),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.medication_outlined, size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Text('Name:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter medication name',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter medication name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.medical_services_outlined, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text('Dosage:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _dosageController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 250mg',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter dosage';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.repeat, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text('Frequency:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(getFrequencyLabel(_selectedFrequency)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.sticky_note_2_outlined, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              hintText: 'Any notes...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // --- Total pills calculation or placeholder ---
                    Builder(
                      builder: (context) {
                        if (_selectedFrequency == 'As needed') {
                          return Row(
                            children: [
                              const Icon(Icons.calculate_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text('Total pills needed: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              const Text('--', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          );
                        }
                        int days = 1;
                        if (_startDate != null && _endDate != null) {
                          days = _endDate!.difference(_startDate!).inDays + 1;
                        }
                        int timesPerDay = 1;
                        if (_selectedFrequency == 'Once daily') timesPerDay = 1;
                        else if (_selectedFrequency == 'Twice daily') timesPerDay = 2;
                        else if (_selectedFrequency == 'Three times daily') timesPerDay = 3;
                        else if (_selectedFrequency == 'Four times daily') timesPerDay = 4;
                        int total = days * timesPerDay;
                        return Row(
                          children: [
                            const Icon(Icons.calculate_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text('Total pills needed: ', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // --- Date pickers under the card ---
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    tileColor: unselectedColor,
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Select date'),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    tileColor: unselectedColor,
                    title: const Text('End Date'),
                    subtitle: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Select date'),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- Frequency segmented buttons ---
            const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: unselectedColor,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: freqOptions.map((freq) {
                  final selected = _selectedFrequency == freq;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedFrequency = freq;
                          if (freq == 'As needed') {
                            _reminderTimes = [];
                          } else {
                            _reminderTimes = getDefaultTimes(freq);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? selectedColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? selectedColor : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: selected
                                ? [BoxShadow(color: selectedColor.withOpacity(0.08), blurRadius: 6, offset: Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              getFrequencyLabel(freq),
                              style: TextStyle(
                                color: selected ? Colors.white : textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // --- Reminder Times (time slots) ---
            if (_selectedFrequency != 'As needed') ...[
              const Text('Reminder Times', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Column(
                children: List.generate(_reminderTimes.length, (index) {
                  final time = _reminderTimes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time,
                        );
                        if (picked != null) {
                          setState(() {
                            _reminderTimes[index] = picked;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: unselectedColor,
                          borderRadius: borderRadius,
                          border: Border.all(color: selectedColor, width: 1.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Time ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: selectedColor),
                                const SizedBox(width: 8),
                                Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ]
            else ...[
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Take the medication as needed according to your doctors instructions.',
                  style: TextStyle(color: Colors.grey, fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 30),
            // --- Confirm button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
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
                  backgroundColor: selectedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Confirm Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
