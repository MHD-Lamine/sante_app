import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Sante/services/api_service.dart';

class ChartData {
  final String time;
  final double value;

  ChartData(this.time, this.value);
}

class BpChartData {
  final String time;
  final double systolic;
  final double diastolic;

  BpChartData(this.time, this.systolic, this.diastolic);
}

class HomeController extends ChangeNotifier {
  double? latestGlycemia;
  String? latestTension;
  String? lastUpdateTime;
  bool loading = true;
  String? error;

  List<ChartData> glycemiaChartData = [];
  List<BpChartData> bpChartData = [];

  Future<void> fetchLatestMeasure() async {
    try {
      final token = await ApiService.getToken();
      final userId = await ApiService.getUserId();

      if (token == null || userId == null) {
        error = "Utilisateur non connecté";
        loading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/measures/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final latest = data.first;
          latestGlycemia = (latest['glycemia'] as num?)?.toDouble();
          final systolic = latest['systolic'];
          final diastolic = latest['diastolic'];
          latestTension = "$systolic/$diastolic";
          lastUpdateTime = latest['date'];

          final lastTen = data.take(10).toList().reversed.toList();
          glycemiaChartData = lastTen.map((m) {
            final date = DateTime.parse(m['date']);
            return ChartData("${date.hour}h", (m['glycemia'] as num?)?.toDouble() ?? 0);
          }).toList();

          bpChartData = lastTen.map((m) {
            final date = DateTime.parse(m['date']);
            return BpChartData(
              "${date.hour}h",
              (m['systolic'] as num?)?.toDouble() ?? 0,
              (m['diastolic'] as num?)?.toDouble() ?? 0,
            );
          }).toList();
        } else {
          error = "Aucune mesure trouvée";
        }
      } else {
        error = "Erreur API : ${response.statusCode}";
      }
    } catch (e) {
      error = "Erreur : $e";
    }

    loading = false;
    notifyListeners();
  }
}
