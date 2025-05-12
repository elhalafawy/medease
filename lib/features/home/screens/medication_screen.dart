import 'package:flutter/material.dart';
import 'medication_reminder_screen.dart';
import '../../../core/theme/app_theme.dart';


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
    final meds = showHistory ? _historyMedications : _activeMedications;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text('Prescriptions', style: AppTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 4),
            const Divider(color: AppTheme.borderColor, thickness: 1, endIndent: 200),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: meds.length,
                itemBuilder: (context, index) {
                  final med = meds[index];
                  return _buildMedicationCard(
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
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Add Medication', style: AppTheme.bodyLarge.copyWith(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => showHistory = false),
          child: Text('Actual',
              style: AppTheme.bodyLarge.copyWith(
                color: showHistory ? AppTheme.greyColor : AppTheme.textColor,
              )),
        ),
        GestureDetector(
          onTap: () => setState(() => showHistory = true),
          child: Text('History',
              style: AppTheme.bodyLarge.copyWith(
                color: showHistory ? AppTheme.textColor : AppTheme.greyColor,
              )),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppTheme.greyColor),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Start typing medication name',
                hintStyle: AppTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationCard({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppTheme.borderColor),
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
                    Text(title, style: AppTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.medication_outlined, size: 16, color: AppTheme.greyColor),
              const SizedBox(width: 4),
              Text(capsules, style: AppTheme.bodyMedium),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.greyColor),
              const SizedBox(width: 4),
              Text(date, style: AppTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
