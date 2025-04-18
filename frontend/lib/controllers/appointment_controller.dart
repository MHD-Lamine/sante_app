import 'package:flutter/material.dart';
import 'package:Sante/models/appointment.dart';
import 'package:Sante/services/api_service.dart';

class AppointmentController with ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Appointment> appointments = [];

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
