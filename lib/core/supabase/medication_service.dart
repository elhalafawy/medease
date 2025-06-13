import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class MedicationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all medications for the current user
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('medications')
          .select()
          .eq('patient_id', user.id)
          .order('start_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch medications: $e');
    }
  }

  // Add a new medication
  Future<void> addMedication({
    required String patientId,
    required String name,
    required String dosage,
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
    required List<TimeOfDay> reminderTimes,
    String? notes,
  }) async {
    try {
      await _supabase.from('medications').insert({
        'patient_id': patientId,
        'name': name,
        'dosage': dosage,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'frequency': frequency,
        'reminder_times': reminderTimes.map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}').toList(),
        'notes': notes,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Commenting out notification creation as requested
      // for (var time in reminderTimes) {
      //   await _createMedicationReminderNotification(
      //     patientId: patientId,
      //     medicationName: name,
      //     reminderTime: time,
      //   );
      // }

    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  // Commenting out the notification creation function as requested
  // Future<void> _createMedicationReminderNotification({
  //   required String patientId,
  //   required String medicationName,
  //   required TimeOfDay reminderTime,
  // }) async {
  //   try {
  //     final now = DateTime.now();
  //     final notificationTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       reminderTime.hour,
  //       reminderTime.minute,
  //     );

  //     DateTime scheduledTime = notificationTime;
  //     if (scheduledTime.isBefore(now)) {
  //       scheduledTime = scheduledTime.add(const Duration(days: 1));
  //     }

  //     print('DEBUG: Attempting to insert notification with receiver_id: $patientId, message: It\'s time to take your medication: $medicationName at ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}.');

  //     await _supabase.from('notifications').insert({
  //       'receiver_id': patientId,
  //       'message': 'It\'s time to take your medication: $medicationName at ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}.',
  //       'type': 'medication_reminder',
  //       'status': 'unread',
  //       'created_at': DateTime.now().toIso8601String(),
  //       'scheduled_at': scheduledTime.toIso8601String(),
  //     });
  //     print('Medication reminder notification created for patient $patientId for $medicationName at ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}');
  //   } catch (e) {
  //     print('Failed to create medication reminder notification: $e');
  //     throw Exception('Failed to create medication reminder notification: $e');
  //   }
  // }

  // Update an existing medication
  Future<void> updateMedication({
    required String medicationId,
    required String name,
    required String dosage,
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
    required List<TimeOfDay> reminderTimes,
    String? notes,
  }) async {
    try {
      await _supabase.from('medications').update({
        'name': name,
        'dosage': dosage,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'frequency': frequency,
        'reminder_times': reminderTimes.map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}').toList(),
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('medication_id', medicationId);
    } catch (e) {
      throw Exception('Failed to update medication: $e');
    }
  }

  // Delete a medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('medications')
          .delete()
          .eq('medication_id', medicationId)
          .eq('patient_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }

  // Move medication to history
  Future<void> moveToHistory(String medicationId, String status) async {
    try {
      await _supabase.from('medications').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('medication_id', medicationId);
    } catch (e) {
      throw Exception('Failed to move medication to history: $e');
    }
  }

  // Get active medications
  Future<List<Map<String, dynamic>>> getActiveMedications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('medications')
          .select()
          .eq('patient_id', user.id)
          .eq('status', 'active')
          .order('start_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch active medications: $e');
    }
  }

  // Get medication history
  Future<List<Map<String, dynamic>>> getMedicationHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('medications')
          .select()
          .eq('patient_id', user.id)
          .neq('status', 'active')
          .order('start_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch medication history: $e');
    }
  }

  // Fetch all medications for all patients of the current user
  Future<List<Map<String, dynamic>>> getAllUserMedications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('DEBUG: Fetching medications for user: ${user.id}');

    // Get all patient_ids for this user
    final patients = await _supabase
        .from('patients')
        .select('patient_id')
        .eq('user_id', user.id);

    print('DEBUG: Found patients: $patients');

    final patientIds = (patients as List).map((p) => p['patient_id']).toList();
    print('DEBUG: Patient IDs: $patientIds');

    if (patientIds.isEmpty) {
      print('DEBUG: No patients found for user');
      return [];
    }

    // Debug: Check medications directly for the first patient
    final directCheck = await _supabase
        .from('medications')
        .select()
        .eq('patient_id', patientIds.first);
    print('DEBUG: Direct check for patient ${patientIds.first}: ${directCheck.length} medications');

    // Fetch all medications for these patient_ids
    final meds = await _supabase
        .from('medications')
        .select()
        .inFilter('patient_id', patientIds)
        .order('start_date', ascending: false);

    print('DEBUG: Fetched medications: ${meds.length}');
    if (meds.isNotEmpty) {
      print('DEBUG: First medication: ${meds.first}');
    }

    return List<Map<String, dynamic>>.from(meds);
  }
} 