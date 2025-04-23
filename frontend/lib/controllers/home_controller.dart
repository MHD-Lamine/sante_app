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
      final measures = await ApiService.fetchMeasures(); // ✅ sans userId
      if (measures.isEmpty) throw Exception("Aucune mesure trouvée");

      final last = measures.first;

      latestGlycemia = (last['glycemia'] ?? 0).toDouble();
      final systolic = (last['systolic'] ?? 0).toInt();
      final diastolic = (last['diastolic'] ?? 0).toInt();

      latestTension = "$systolic/$diastolic";
      lastUpdate = DateTime.parse(last['date']);

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
      error = "Erreur de chargement : ${e.toString()}";
    }

    loading = false;
    notifyListeners();
  }
}
