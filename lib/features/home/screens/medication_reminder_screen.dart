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
    
    // Calculate total pills needed
    String totalPillsText = 'N/A';
    if (_startDate != null && _endDate != null && _selectedFrequency != 'As needed') {
      final int durationInDays = _endDate!.difference(_startDate!).inDays + 1;
      int dosesPerDay = 0;
      if (_selectedFrequency == 'Once daily') {
        dosesPerDay = 1;
      } else if (_selectedFrequency == 'Twice daily') {
        dosesPerDay = 2;
      } else if (_selectedFrequency == 'Three times daily') {
        dosesPerDay = 3;
      } else if (_selectedFrequency == 'Four times daily') {
        dosesPerDay = 4;
      }
      final int totalPills = durationInDays * dosesPerDay;
      totalPillsText = '$totalPills pills over $durationInDays days';
    } else if (_selectedFrequency == 'As needed') {
      totalPillsText = 'As needed';
    }

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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Medication reminder',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Card with summary info and input fields ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
              shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter medication name',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        prefixIcon: Container(
                          width: 120,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.medication_outlined, size: 24, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Name:',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 250mg',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        prefixIcon: Container(
                          width: 120,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.cases_outlined, size: 24, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dosage:',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter dosage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                                  color: theme.colorScheme.outline.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(Icons.calculate_outlined, size: 24, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Total pills needed:',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              totalPillsText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                                  color: theme.colorScheme.outline.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(Icons.repeat, size: 24, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Frequency:',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
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
                                  backgroundColor: theme.colorScheme.surface,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                                          color: theme.colorScheme.outline.withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.repeat, size: 24, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            getFrequencyLabel(_selectedFrequency),
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Any notes...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        prefixIcon: Container(
                          width: 110,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.sticky_note_2_outlined, size: 24, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Notes:',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
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
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      prefixIcon: Container(
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.calendar_today, size: 24, color: theme.colorScheme.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      isDense: true,
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    onTap: () => _selectDate(context, true),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Select date'),
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      labelStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      prefixIcon: Container(
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.calendar_today, size: 24, color: theme.colorScheme.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      isDense: true,
                      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    onTap: () => _selectDate(context, false),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- Frequency segmented buttons ---
            Text(
              'Frequency',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
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
                            color: selected ? theme.colorScheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              getFrequencyLabel(freq),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
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
              Text(
                'Reminder Times',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
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
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  primary: theme.colorScheme.primary,
                                  onSurface: theme.colorScheme.onSurface,
                                  surface: theme.colorScheme.surface,
                                  onPrimary: theme.colorScheme.onPrimary,
                                ),
                                textTheme: theme.textTheme,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _reminderTimes[index] = picked;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: borderRadius,
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_outlined, size: 22, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  time.format(context),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            if (_reminderTimes.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _removeReminderTime(index),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _addReminderTime,
                icon: Icon(Icons.add, color: theme.colorScheme.primary),
                label: Text(
                  'Add another time',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onConfirm(
                      _nameController.text,
                      _dosageController.text,
                      _startDate!,
                      _endDate!,
                      _selectedFrequency!,
                      _reminderTimes,
                      _notesController.text.isEmpty ? null : _notesController.text,
                      'reminderId', // Placeholder, will be generated server-side
                    );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Reminder',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
  final ValueChanged<String> onSelected;

  const _FrequencySelector({
    required this.currentFrequency,
    required this.frequencies,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Frequency',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Flexible( // Use Flexible to constrain the height of the ListView
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: frequencies.length,
              itemBuilder: (context, index) {
                final freq = frequencies[index];
                final isSelected = freq == currentFrequency;
                return ListTile(
                  title: Text(
                    freq,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                  onTap: () => onSelected(freq),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
