import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeController>(context, listen: false).fetchLatestMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("SantéTrack"),
            backgroundColor: const Color(0xFF4F46E5),
            actions: [
              IconButton(
                icon: const Icon(FlutterRemix.notification_3_line),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.indigo[300],
                child: const Icon(FlutterRemix.user_line, color: Colors.white),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: const [
                DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF4F46E5)),
                  child: Text("SantéTrack", style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(leading: Icon(FlutterRemix.dashboard_line), title: Text("Tableau de bord")),
                ListTile(leading: Icon(FlutterRemix.heart_pulse_line), title: Text("Mes mesures")),
                ListTile(leading: Icon(FlutterRemix.medicine_bottle_line), title: Text("Médicaments")),
                ListTile(leading: Icon(FlutterRemix.calendar_check_line), title: Text("Rendez-vous")),
                ListTile(leading: Icon(FlutterRemix.user_settings_line), title: Text("Mon profil")),
                ListTile(leading: Icon(FlutterRemix.settings_3_line), title: Text("Paramètres")),
                Divider(),
                ListTile(leading: Icon(FlutterRemix.logout_box_line), title: Text("Déconnexion")),
              ],
            ),
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : controller.error != null
                  ? Center(child: Text(controller.error!))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildMeasureCard("Glycémie", controller.latestGlycemia?.toStringAsFixed(1) ?? "--", "mmol/L", Icons.opacity, Colors.indigo),
                              const SizedBox(width: 8),
                              _buildMeasureCard("Tension", controller.latestTension ?? "--", "", Icons.favorite, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildGlycemiaChart(controller),
                          const SizedBox(height: 16),
                          _buildBpChart(controller),
                        ],
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4F46E5),
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
              BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Historique"),
              BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Médic."),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "RDV"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeasureCard(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$value $unit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlycemiaChart(HomeController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Évolution glycémie", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: controller.glycemiaChartData,
                    xValueMapper: (ChartData data, _) => data.time,
                    yValueMapper: (ChartData data, _) => data.value,
                    color: Colors.indigo,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBpChart(HomeController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Évolution tension", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<BpChartData, String>(
                    name: "Systolique",
                    dataSource: controller.bpChartData,
                    xValueMapper: (BpChartData data, _) => data.time,
                    yValueMapper: (BpChartData data, _) => data.systolic,
                    color: Colors.orange,
                  ),
                  LineSeries<BpChartData, String>(
                    name: "Diastolique",
                    dataSource: controller.bpChartData,
                    xValueMapper: (BpChartData data, _) => data.time,
                    yValueMapper: (BpChartData data, _) => data.diastolic,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
