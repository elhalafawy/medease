import 'package:flutter/material.dart';
import '../../features/doctor/models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _error;
  Doctor? _selectedDoctor;

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Doctor? get selectedDoctor => _selectedDoctor;

  Future<void> loadDoctors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with actual API call
      _doctors = [
        Doctor(
          id: '1',
          name: 'Dr. Ahmed Mohamed',
          type: 'Cardiologist',
          rating: '4.9',
          patients: '1500',
          experience: '15 years',
          reviews: '800',
          image: 'assets/images/doctor_male.png',
          hospital: 'Kasr Al-Ainy Hospital',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }

  void clearSelectedDoctor() {
    _selectedDoctor = null;
    notifyListeners();
  }

  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return _doctors;
    
    return _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
             doctor.type.toLowerCase().contains(query.toLowerCase()) ||
             doctor.hospital.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Doctor> filterDoctors(String type) {
    if (type.isEmpty || type == 'All') return _doctors;
    return _doctors.where((doctor) => doctor.type.toLowerCase() == type.toLowerCase()).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}