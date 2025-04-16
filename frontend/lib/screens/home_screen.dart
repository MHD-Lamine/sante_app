import 'package:Sante/models/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:Sante/services/api_service.dart';
import 'package:Sante/controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String userName = "Utilisateur";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await ApiService.getToken();
    final name = await ApiService.getUserName(); 
    setState(() {
      userName = name ?? "Utilisateur";
    });

    Provider.of<HomeController>(context, listen: false).fetchLatestMeasure();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final pages = [
          _buildDashboard(controller),
          const Center(child: Text("📊 Historique")),
          const Center(child: Text("💊 Médicaments")),
          const Center(child: Text("📅 Rendez-vous")),
          const Center(child: Text("🚨 Alertes")),
          const Center(child: Text("👤 Profil")),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text("SantéTrack"),
            backgroundColor: const Color(0xFF4F46E5),
            actions: [
              IconButton(
                icon: const Icon(FlutterRemix.notification_3_line),
                tooltip: "Alertes",
                onPressed: () {
                  setState(() => _currentIndex = 4);
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = 5);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.indigo[300],
                  child: const Icon(FlutterRemix.user_line, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF4F46E5)),
                  child: Text("SantéTrack", style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(FlutterRemix.dashboard_line),
                  title: const Text("Tableau de bord"),
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(FlutterRemix.heart_pulse_line),
                  title: const Text("Mes mesures"),
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(FlutterRemix.medicine_bottle_line),
                  title: const Text("Médicaments"),
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(FlutterRemix.calendar_check_line),
                  title: const Text("Rendez-vous"),
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(FlutterRemix.logout_box_line),
                  title: const Text("Déconnexion"),
                  onTap: () async {
                    await ApiService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              ],
            ),
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : controller.error != null
                  ? Center(child: Text(controller.error!))
                  : pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
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

  Widget _buildDashboard(HomeController controller) {
    final now = DateTime.now();
    final dateFormatted = DateFormat('d MMMM yyyy', 'fr_FR').format(now);
    final lastUpdate = controller.lastUpdate != null
        ? DateFormat('HH:mm').format(controller.lastUpdate!)
        : "--:--";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 👤 Bonjour utilisateur + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bonjour, $userName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(dateFormatted, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("Dernière mise à jour : $lastUpdate", style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                series: <LineSeries>[
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
                series: <LineSeries>[
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
