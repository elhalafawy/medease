import 'package:flutter/material.dart';
import 'medication_reminder_screen.dart';


class MedicationScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MedicationScreen({super.key, this.onBack});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final List<Map<String, dynamic>> _activeMedications = [
    {
      'name': 'Amoxicillin 250mg',
      'desc': 'Antibiotic for bacterial infections',
      'capsules': '14 capsules',
      'date': '14 - 30 May , 2025',
      'end': DateTime(2025, 5, 30),
    },
    {
      'name': 'Lisinopril 10mg',
      'desc': 'ACE inhibitors',
      'capsules': '18 capsules',
      'date': '11 - 30 June , 2025',
      'end': DateTime(2025, 6, 30),
    },
  ];

  final List<Map<String, dynamic>> _historyMedications = [];

  bool showHistory = false;

  void _addMedication(String name, String dosage, String dateRange, int capsuleCount, DateTime endDate) {
    setState(() {
      _activeMedications.add({
        'name': '$name $dosage',
        'desc': 'Custom entry',
        'capsules': '$capsuleCount capsules',
        'date': dateRange,
        'end': endDate,
      });
    });
  }

  void _removeMedication(int index) {
    final med = _activeMedications[index];
    setState(() {
      _activeMedications.removeAt(index);
      _historyMedications.add({...med, 'desc': 'Canceled'});
    });
  }

  void _editMedication(int index) async {
    final med = _activeMedications[index];
    final parts = (med['name'] as String).split(' ');
    final name = parts.first;
    final dosage = parts.skip(1).join(' ');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationReminderScreen(
          initialName: name,
          initialDosage: dosage,
          initialFrequency: int.tryParse(med['capsules'].toString().split(' ').first) ?? 2,
          initialStart: DateTime.now(),
          onConfirm: (newName, newDosage, newDateRange, newCapsules, newEnd) {
            setState(() {
              _activeMedications[index] = {
                'name': '$newName $newDosage',
                'desc': 'Edited entry',
                'capsules': '$newCapsules capsules',
                'date': newDateRange,
                'end': newEnd,
              };
            });
          },
        ),
      ),
    );
  }

  void _checkExpiredMedications() {
    final now = DateTime.now();
    final expired = _activeMedications.where((m) => m['end'].isBefore(now)).toList();
    setState(() {
      _activeMedications.removeWhere((m) => m['end'].isBefore(now));
      for (var m in expired) {
        _historyMedications.add({...m, 'desc': 'Completed'});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkExpiredMedications();
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
      ),
      body: Padding(
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
                    subtitle: med['desc'],
                    capsules: med['capsules'],
                    date: med['date'],
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationReminderScreen(
                            onConfirm: (name, dosage, dateRange, capsuleCount, endDate) {
                              _addMedication(name, dosage, dateRange, capsuleCount, endDate);
                            },
                          ),
                        ),
                      );
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
          onTap: () => setState(() => showHistory = false),
          child: Text('Actual',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: showHistory ? theme.disabledColor : theme.colorScheme.onSurface,
              )),
        ),
        GestureDetector(
          onTap: () => setState(() => showHistory = true),
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
                hintText: 'Start typing medication name',
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
    required String capsules,
    required String date,
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
              Text(capsules, style: theme.textTheme.bodyMedium),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(date, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
