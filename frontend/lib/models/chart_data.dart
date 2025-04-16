class ChartData {
  final String time;
  final double value;

  ChartData({required this.time, required this.value});
}

class BpChartData {
  final String time;
  final double systolic;
  final double diastolic;

  BpChartData({required this.time, required this.systolic, required this.diastolic});
}
