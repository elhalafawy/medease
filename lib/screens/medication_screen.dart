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
    final meds = showHistory ? _historyMedications : _activeMedications;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black),
  onPressed: () {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.pop(context);
    }
  },
),

        centerTitle: true,
        title: const Text('Prescriptions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 4),
            const Divider(color: Color(0xFF001F3F), thickness: 1, endIndent: 200),
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
                    backgroundColor: const Color(0xFF022E5B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Add Medication', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: showHistory ? Colors.grey : Colors.black,
              )),
        ),
        GestureDetector(
          onTap: () => setState(() => showHistory = true),
          child: Text('History',
              style: TextStyle(
                fontSize: 16,
                color: showHistory ? Colors.black : const Color(0xFF555555),
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(23),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Start typing medication name',
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF555555)),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF555555), fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCapsuleBox(capsules),
              _buildCapsuleBox(date),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCapsuleBox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF555555))),
    );
  }
}
