import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart';
import '../services/api_service.dart';

class HomeController with ChangeNotifier {
  double? latestGlycemia;
  String? latestTension;
  DateTime? lastUpdate;

  String? error;
  bool loading = false;

  List<ChartData> glycemiaChartData = [];
  List<BpChartData> bpChartData = [];

  Future<void> fetchLatestMeasure() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final userId = await ApiService.getUserId();
      if (userId == null) throw Exception("Utilisateur non connecté");

      final measures = await ApiService.fetchMeasures(userId);
      if (measures.isEmpty) throw Exception("Aucune mesure trouvée");

      // Dernière mesure
      final last = measures.first;
      latestGlycemia = last['glycemia']?.toDouble();
      final systolic = last['systolic']?.toInt();
      final diastolic = last['diastolic']?.toInt();
      latestTension = (systolic != null && diastolic != null) ? "$systolic/$diastolic" : "--";

      lastUpdate = DateTime.parse(last['date']);

      // 📊 Données pour les graphiques
      glycemiaChartData = measures.map<ChartData>((m) {
        return ChartData(
          time: DateFormat.Hm().format(DateTime.parse(m['date'])),
          value: (m['glycemia'] ?? 0).toDouble(),
        );
      }).toList().reversed.toList();

      bpChartData = measures.map<BpChartData>((m) {
        return BpChartData(
          time: DateFormat.Hm().format(DateTime.parse(m['date'])),
          systolic: (m['systolic'] ?? 0).toDouble(),
          diastolic: (m['diastolic'] ?? 0).toDouble(),
        );
      }).toList().reversed.toList();
    } catch (e) {
      error = "Erreur : ${e.toString()}";
    }

    loading = false;
    notifyListeners();
  }
}
