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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter medication name',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Container(
                          width: 120,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.medication_outlined, size: 24, color: selectedColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Name:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: selectedColor, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter medication name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 250mg',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Container(
                          width: 120,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.medical_services_outlined, size: 24, color: selectedColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Dosage:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: selectedColor, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter dosage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: unselectedColor),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 135,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(Icons.repeat, size: 24, color: selectedColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Frequency:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final selectedFreq = await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => _FrequencySelector(
                                    currentFrequency: _selectedFrequency,
                                    frequencies: _frequencies,
                                    onSelected: (freq) {
                                      Navigator.pop(context, freq);
                                    },
                                  ),
                                );
                                if (selectedFreq != null && selectedFreq != _selectedFrequency) {
                                  setState(() {
                                    _selectedFrequency = selectedFreq;
                                    _reminderTimes = getDefaultTimes(_selectedFrequency);
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    width: 110,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.grey.withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.repeat, size: 24, color: selectedColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            getFrequencyLabel(_selectedFrequency),
                                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: unselectedColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: unselectedColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: selectedColor, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                  isDense: true,
                                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Any notes...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Container(
                          width: 110,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.sticky_note_2_outlined, size: 24, color: selectedColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: unselectedColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: selectedColor, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // --- Total pills calculation or placeholder ---
                    Builder(
                      builder: (context) {
                        String totalPillsText;
                        if (_selectedFrequency == 'As needed') {
                          totalPillsText = '--';
                        } else {
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
                          totalPillsText = '$total';
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: unselectedColor),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 135,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.calculate_outlined, size: 24, color: selectedColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Total pills needed:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(totalPillsText, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
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
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Select date'),
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                      prefixIcon: Container(
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.calendar_today, size: 24, color: selectedColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: unselectedColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: unselectedColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: selectedColor, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      isDense: true,
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Select date'),
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                      prefixIcon: Container(
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.calendar_today, size: 24, color: selectedColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: unselectedColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: unselectedColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: selectedColor, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      isDense: true,
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: unselectedColor),
              ),
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
                            borderRadius: BorderRadius.circular(10),
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
                          color: Colors.white,
                          borderRadius: borderRadius,
                          border: Border.all(color: unselectedColor),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _FrequencySelector extends StatelessWidget {
  final String? currentFrequency;
  final List<String> frequencies;
  final Function(String) onSelected;

  const _FrequencySelector({
    Key? key,
    this.currentFrequency,
    required this.frequencies,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;
    final unselectedColor = theme.colorScheme.surfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

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

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Frequency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: frequencies.length,
              itemBuilder: (context, index) {
                final freq = frequencies[index];
                final isSelected = freq == currentFrequency;
                return GestureDetector(
                  onTap: () => onSelected(freq),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor : unselectedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        getFrequencyLabel(freq),
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
