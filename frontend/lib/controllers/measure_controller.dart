import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart';
import '../services/api_service.dart';

class MeasureController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  double? latestGlycemia;
  String? latestTension;
  DateTime? lastUpdate;

  List<ChartData> glycemiaChartData = [];
  List<BpChartData> bpChartData = [];

  Future<void> loadMeasures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final measures = await ApiService.fetchMeasures();
      if (measures.isEmpty) throw Exception("Aucune mesure disponible");

      final last = measures.first;

      latestGlycemia = (last['glycemia'] ?? 0).toDouble();
      final systolic = last['systolic']?.toInt();
      final diastolic = last['diastolic']?.toInt();
      latestTension = (systolic != null && diastolic != null)
          ? "$systolic/$diastolic"
          : "--";

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
      error = "Erreur lors du chargement : $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
