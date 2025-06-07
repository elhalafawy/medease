// Medications Tab extracted from patient_medical_record_screen.dart
// All code is in English and self-contained for the Medications tab
// ... (code will be filled in next step) ... 

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MedicationsTab extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientId;

  const MedicationsTab({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
  });

  @override
  State<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<MedicationsTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _medicationsList = [];
  bool _isLoadingMedications = true;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedFrequency;
  String? _selectedStatus;

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
    _loadMedications();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _notesController = TextEditingController();
    _selectedFrequency = _frequencies[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    try {
      setState(() {
        _isLoadingMedications = true;
      });
      final response = await _supabase
          .from('medications')
          .select('*')
          .eq('patient_id', widget.patientId)
          .neq('status', 'cancelled')
          .order('created_at', ascending: false);

      setState(() {
        _medicationsList = List<Map<String, dynamic>>.from(response);
        _isLoadingMedications = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: ${e.toString()}')),
        );
        setState(() {
          _isLoadingMedications = false;
        });
      }
    }
  }

  Future<void> _addMedication(
      String name, String dosage, String frequency, DateTime startDate, DateTime endDate, String? notes, String status) async {
    try {
      final response = await _supabase.from('medications').insert({
        'patient_id': widget.patientId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'notes': notes,
        'status': status,
      }).select();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully!')),
        );
      }
      _loadMedications(); // Refresh the list after adding
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add medication: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateMedication(
    String medicationId,
    String name,
    String dosage,
    String frequency,
    DateTime startDate,
    DateTime endDate,
    String? notes,
    String status,
  ) async {
    try {
      final response = await _supabase
          .from('medications')
          .update({
            'name': name,
            'dosage': dosage,
            'frequency': frequency,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'notes': notes,
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('medication_id', medicationId)
          .select();

      if (response.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to update medication record: Record not found or no changes made.')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Medication record updated successfully!')));
      }
      _loadMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update medication record: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteMedication(String medicationId) async {
    if (medicationId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Cannot delete medication: Invalid medication ID.')),
        );
      }
      return;
    }

    try {
      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
                'Are you sure you want to delete this medication record?'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await _supabase
            .from('medications')
            .delete()
            .eq('medication_id', medicationId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication record deleted successfully!')),
          );
        }
        _loadMedications(); // Refresh the list after deleting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to delete medication record: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration({required String labelText, IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon:
          icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
    );
  }

  void _showNewMedicationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;

    _nameController.clear();
    _dosageController.clear();
    _notesController.clear();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = _selectedStartDate!.add(const Duration(days: 7));
    _selectedFrequency = _frequencies[0];
    _selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Medication',
                    style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Patient: ${widget.patientName}',
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Age: ${widget.patientAge}',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(labelText: 'Medication Name', icon: Icons.medical_services_outlined),
                    style: AppTheme.bodyLarge,
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
                    decoration: _buildInputDecoration(labelText: 'Dosage', icon: Icons.medical_services),
                    style: AppTheme.bodyLarge,
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
                    decoration: _buildInputDecoration(labelText: 'Frequency', icon: Icons.repeat),
                    items: _frequencies.map((String freq) {
                      return DropdownMenuItem<String>(
                        value: freq,
                        child: Text(freq),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFrequency = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select frequency';
                      }
                      return null;
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return _frequencies.map((String value) {
                        return Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedStartDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
                    ),
                    decoration: _buildInputDecoration(labelText: 'Start Date', icon: Icons.calendar_today_outlined),
                    style: AppTheme.bodyLarge,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedStartDate) {
                        setState(() {
                          _selectedStartDate = picked;
                          if (_selectedEndDate == null || _selectedEndDate!.isBefore(_selectedStartDate!)) {
                            _selectedEndDate = _selectedStartDate!.add(const Duration(days: 7));
                          }
                        });
                      }
                    },
                    validator: (value) {
                      if (_selectedStartDate == null) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedEndDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                    ),
                    decoration: _buildInputDecoration(labelText: 'End Date', icon: Icons.calendar_today_outlined),
                    style: AppTheme.bodyLarge,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedEndDate ?? DateTime.now(),
                        firstDate: _selectedStartDate ?? DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedEndDate) {
                        setState(() {
                          _selectedEndDate = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (_selectedEndDate == null) {
                        return 'Please select end date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(labelText: 'Notes', icon: Icons.note_alt),
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: _buildInputDecoration(labelText: 'Status', icon: Icons.info_outline),
                    items: <String>['active', 'completed', 'canceled']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "${value[0].toUpperCase()}${value.substring(1)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select status';
                      }
                      return null;
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return <String>['active', 'completed', 'canceled'].map((String value) {
                        return Text(
                          "${value[0].toUpperCase()}${value.substring(1)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: AppTheme.bodyLarge
                                .copyWith(color: AppTheme.greyColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _addMedication(
                              _nameController.text,
                              _dosageController.text,
                              _selectedFrequency!,
                              _selectedStartDate!,
                              _selectedEndDate!,
                              _notesController.text.isEmpty ? null : _notesController.text,
                              _selectedStatus!,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: AppTheme.bodyLarge,
                        ),
                        child: const Text('Add Medication'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMedicationDialog(
      BuildContext context, Map<String, dynamic> medication) {
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;

    final TextEditingController nameController =
        TextEditingController(text: medication['name'] ?? '');
    final TextEditingController dosageController =
        TextEditingController(text: medication['dosage'] ?? '');
    final TextEditingController notesController =
        TextEditingController(text: medication['notes'] ?? '');

    DateTime? selectedStartDate = medication['start_date'] != null
        ? DateTime.parse(medication['start_date'])
        : null;
    DateTime? selectedEndDate = medication['end_date'] != null
        ? DateTime.parse(medication['end_date'])
        : null;
    String? selectedFrequency = medication['frequency'] ?? _frequencies[0];
    String? selectedStatus = medication['status'] ?? 'active';

    final String medicationId = medication['medication_id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Medication',
                    style: AppTheme.titleLarge
                        .copyWith(color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Patient: ${widget.patientName}',
                    style:
                        AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Age: ${widget.patientAge}',
                    style:
                        AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: _buildInputDecoration(labelText: 'Medication Name', icon: Icons.medical_services_outlined),
                    style: AppTheme.bodyLarge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dosageController,
                    decoration: _buildInputDecoration(labelText: 'Dosage', icon: Icons.medical_services),
                    style: AppTheme.bodyLarge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dosage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: _buildInputDecoration(labelText: 'Frequency', icon: Icons.repeat),
                    items: _frequencies.map((String freq) {
                      return DropdownMenuItem<String>(
                        value: freq,
                        child: Text(freq),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFrequency = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select frequency';
                      }
                      return null;
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return _frequencies.map((String value) {
                        return Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedStartDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(selectedStartDate!),
                    ),
                    decoration: _buildInputDecoration(labelText: 'Start Date', icon: Icons.calendar_today_outlined),
                    style: AppTheme.bodyLarge,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedStartDate) {
                        setState(() {
                          selectedStartDate = picked;
                          if (selectedEndDate == null || selectedEndDate!.isBefore(selectedStartDate!)) {
                            selectedEndDate = selectedStartDate!.add(const Duration(days: 7));
                          }
                        });
                      }
                    },
                    validator: (value) {
                      if (selectedStartDate == null) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedEndDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(selectedEndDate!),
                    ),
                    decoration: _buildInputDecoration(labelText: 'End Date', icon: Icons.calendar_today_outlined),
                    style: AppTheme.bodyLarge,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate ?? DateTime.now(),
                        firstDate: selectedStartDate ?? DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedEndDate) {
                        setState(() {
                          selectedEndDate = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (selectedEndDate == null) {
                        return 'Please select end date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(labelText: 'Notes', icon: Icons.note_alt),
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: _buildInputDecoration(labelText: 'Status', icon: Icons.info_outline),
                    items: <String>['active', 'completed', 'canceled']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "${value[0].toUpperCase()}${value.substring(1)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select status';
                      }
                      return null;
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return <String>['active', 'completed', 'canceled'].map((String value) {
                        return Text(
                          "${value[0].toUpperCase()}${value.substring(1)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }).toList();
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel',
                            style: AppTheme.bodyLarge
                                .copyWith(color: AppTheme.greyColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _updateMedication(
                              medicationId,
                              nameController.text,
                              dosageController.text,
                              selectedFrequency!,
                              selectedStartDate!,
                              selectedEndDate!,
                              notesController.text.isEmpty ? null : notesController.text,
                              selectedStatus!,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: AppTheme.bodyLarge,
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMedicationDialog(context),
        label: Text('Add Medication', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoadingMedications
          ? const Center(child: CircularProgressIndicator())
          : _medicationsList.isEmpty
              ? Center(
                  child: Text('No medications found',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
                  itemCount: _medicationsList.length,
                  itemBuilder: (context, index) =>
                      _buildMedicationCard(_medicationsList[index]),
                ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final String medicationName = medication['name'] ?? 'N/A';
    final String dosage = medication['dosage'] ?? 'N/A';
    final String frequency = medication['frequency'] ?? 'N/A';
    final String? startDateString = medication['start_date'];
    final String? endDateString = medication['end_date'];

    String durationText = 'N/A';
    DateTime? startDate;
    DateTime? endDate;
    if (startDateString != null && endDateString != null) {
      try {
        startDate = DateTime.parse(startDateString);
        endDate = DateTime.parse(endDateString);
        final Duration duration = endDate.difference(startDate);
        durationText =
            '${duration.inDays + 1} days';
      } catch (e) {
        durationText = 'Invalid date format';
      }
    }

    final String status = (medication['status'] ?? 'N/A').toString().toLowerCase();
    Color statusColor = AppTheme.greyColor;
    String badgeText = '';
    if (status == 'active') {
      statusColor = Colors.green;
      badgeText = 'Active';
    } else if (status == 'completed') {
      statusColor = Colors.blue;
      badgeText = 'Completed';
    } else if (status == 'canceled') {
      statusColor = Colors.red;
      badgeText = 'Canceled';
    }

    int total = 0;
    int remaining = 0;
    if (frequency == 'As needed' || startDate == null || endDate == null) {
      total = 0;
      remaining = 0;
    } else {
      int timesPerDay = 1;
      if (frequency == 'Once daily') timesPerDay = 1;
      else if (frequency == 'Twice daily') timesPerDay = 2;
      else if (frequency == 'Three times daily') timesPerDay = 3;
      else if (frequency == 'Four times daily') timesPerDay = 4;
      int days = endDate.difference(startDate).inDays + 1;
      total = days * timesPerDay;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int daysPassed = today.isBefore(startDate) ? 0 : (today.isAfter(endDate) ? days : today.difference(startDate).inDays + 1);
      remaining = (total - daysPassed * timesPerDay).clamp(0, total);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(medicationName,
                  style:
                      AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1.2),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Dosage: ${dosage}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text('Frequency: ${frequency}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text(
            (startDate != null && endDate != null)
              ? 'Start: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}   End: ${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}'
              : 'Start/End: N/A',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Text('Pills: ', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor)),
              (frequency == 'As needed' || startDate == null || endDate == null)
                ? const Text('--', style: TextStyle(fontWeight: FontWeight.bold))
                : Text('$remaining / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Status: ',
                  style:
                      AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              Text(badgeText,
                  style: AppTheme.bodyMedium.copyWith(
                      color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditMedicationDialog(context, medication);
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  label: Text('Edit',
                      style: AppTheme.bodyLarge
                          .copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (medication['medication_id']?.toString().isNotEmpty ?? false) {
                      _deleteMedication(medication['medication_id'].toString());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot delete record: Invalid medication ID')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Delete',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 