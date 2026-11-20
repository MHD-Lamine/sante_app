import 'package:flutter/material.dart';
import 'package:Sante/models/appointment.dart';
import 'package:Sante/services/api_service.dart';

class AppointmentController with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Appointment> appointments = [];

  /// Rendez-vous pas encore passés, du plus proche au plus lointain
  List<Appointment> get upcoming {
    final now = DateTime.now();
    return appointments.where((a) => a.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Charger les rendez-vous à venir
  Future<void> loadAppointments() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      appointments = await ApiService.fetchUpcomingAppointments();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
