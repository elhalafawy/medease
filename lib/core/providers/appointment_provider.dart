import 'package:flutter/foundation.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _appointments = [];

  List<Map<String, dynamic>> get appointments => _appointments;

  void addAppointment(Map<String, dynamic> appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void removeAppointment(String appointmentId) {
    _appointments.removeWhere((appointment) => appointment['id'] == appointmentId);
    notifyListeners();
  }

  void updateAppointment(String appointmentId, Map<String, dynamic> updatedAppointment) {
    final index = _appointments.indexWhere((appointment) => appointment['id'] == appointmentId);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListeners();
    }
  }
} 