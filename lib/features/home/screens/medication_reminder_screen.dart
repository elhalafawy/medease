import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class MedicationReminderScreen extends StatefulWidget {
  final Function(String name, String dosage, String dateRange, int capsules, DateTime endDate)? onConfirm;
  final String? initialName;
  final String? initialDosage;
  final int? initialFrequency;
  final DateTime? initialStart;

  const MedicationReminderScreen({
    super.key,
    this.onConfirm,
    this.initialName,
    this.initialDosage,
    this.initialFrequency,
    this.initialStart,
  });

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;

  int frequency = 2;
  DateTime? startDate;
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  final Set<String> selectedTimes = {'08:00'};

  final List<String> times = List.generate(24, (index) => '${index.toString().padLeft(2, '0')}:00');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _dosageController = TextEditingController(text: widget.initialDosage ?? '');
    frequency = widget.initialFrequency ?? 2;
    startDate = widget.initialStart ?? DateTime.now();
    endDate = startDate!.add(const Duration(days: 6));
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Medication reminder',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(theme),
            const SizedBox(height: 24),
            _frequencySelector(theme),
            const SizedBox(height: 24),
            Text('Select time', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: times.map((t) => _timeButton(theme, t)).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim().isEmpty ? 'Unnamed' : _nameController.text.trim();
                  final dosage = _dosageController.text.trim().isEmpty ? '1 capsule' : _dosageController.text.trim();
                  final totalDays = endDate.difference(startDate!).inDays + 1;
                  final capsules = totalDays * frequency;
                  final dateRange = '${_formatDate(startDate!)} - ${_formatDate(endDate)}';

                  widget.onConfirm?.call(name, dosage, dateRange, capsules, endDate);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder set successfully!')),
                  );

                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(
                  'Confirm',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _textInputRow(theme, 'assets/icons/image 10.png', 'Name', _nameController, 'ex: Amoxicillin'),
          _textInputRow(theme, 'assets/icons/image 13.png', 'Dosage', _dosageController, 'ex: 250mg'),
          _dateRangePickerRow(theme),
          _infoRow(theme, 'assets/icons/image 14.png', 'Frequency:', _frequencyLabel(frequency)),
        ],
      ),
    );
  }

  Widget _textInputRow(ThemeData theme, String iconPath, String label, TextEditingController controller, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Text('$label:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateRangePickerRow(ThemeData theme) {
    return InkWell(
      onTap: () async {
        DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: DateTimeRange(start: startDate!, end: endDate),
        );
        if (picked != null) {
          setState(() {
            startDate = picked.start;
            endDate = picked.end;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Image.asset('assets/icons/image 12.png', width: 24, height: 24),
            const SizedBox(width: 10),
            Text('Duration:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_formatDate(startDate!)} - ${_formatDate(endDate)}',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String iconPath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface))),
        ],
      ),
    );
  }

  Widget _frequencySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [1, 2, 3, 4].map((f) {
            final selected = f == frequency;
            return GestureDetector(
              onTap: () => setState(() => frequency = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _frequencyLabel(f),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _timeButton(ThemeData theme, String time) {
    final selected = selectedTimes.contains(time);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedTimes.remove(time);
          } else {
            selectedTimes.add(time);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          time,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String _frequencyLabel(int f) {
    switch (f) {
      case 1:
        return 'Once a day';
      case 2:
        return 'Twice a day';
      case 3:
        return '3 times a day';
      case 4:
        return '4 times a day';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM , yyyy').format(date);
  }
}
