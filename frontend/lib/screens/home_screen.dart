import 'package:Sante/constants/routes.dart';
import 'package:Sante/controllers/health_tip_controller.dart';
import 'package:Sante/controllers/medication_controller.dart';
import 'package:Sante/models/appointment.dart';
import 'package:Sante/models/health_tip.dart';
import 'package:Sante/widgets/add_measure_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:Sante/controllers/appointment_controller.dart';
import '../models/chart_data.dart';
import '../controllers/measure_controller.dart';
import '../services/api_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String userName = "Utilisateur";
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();

    // ✅ Timer sécurisé avec check de `mounted`
    refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel(); // ✅ On annule bien le timer quand le widget est détruit
    super.dispose();
  }

  Future<void> _loadData() async {
    final name = await ApiService.getUserNameFromStorage();

    // ✅ Sécurité : on vérifie si le widget est toujours monté
    if (!mounted) return;

    setState(() {
      userName = name ?? "Utilisateur";
    });

    Provider.of<MeasureController>(context, listen: false).loadMeasures();
    Provider.of<MedicationController>(context, listen: false).loadTodayMedications();
    Provider.of<AppointmentController>(context, listen: false).loadAppointments();
    Provider.of<HealthTipController>(context, listen: false).fetchTips();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<MeasureController>(
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
                onPressed: () => setState(() => _currentIndex = 4),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 5),
                child: CircleAvatar(
                  backgroundColor: Colors.indigo[300],
                  child: const Icon(FlutterRemix.user_line, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: _buildDrawer(),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.error != null
                  ? Center(child: Text(controller.error!))
                  : pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
              BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Historique"),
              BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Médic."),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "RDV"),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4F46E5),
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const AddMeasureForm(),
              );

              // ✅ Recharge toute la page si on a bien ajouté une mesure
              if (result == true && mounted) {
                await _loadData(); // <- recharge les mesures, rendez-vous, conseils, etc.

                            // ✅ Affiche un SnackBar ICI (dans le bon contexte)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Mesures enregistrées avec succès"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (result == false && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ Erreur lors de l'enregistrement des mesures"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildDashboard(MeasureController controller) {
    final dateFormatted = DateFormat('d MMMM yyyy', 'fr_FR').format(DateTime.now());
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

          _buildMedicationSection(),
          _buildAppointmentSection(),
          _buildHealthTipsSection(),

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

  Widget _buildGlycemiaChart(MeasureController controller) {
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

  Widget _buildBpChart(MeasureController controller) {
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

/// Widget pour le menu latéral (Drawer)
  /// avec les différentes sections de l'application
  Widget _buildDrawer() {
    return Drawer(
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
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Section médicaments : seules les prises dans leur créneau sont affichées
  /// (ex : prise de 8h00 visible jusqu'à 10h30), sinon la prochaine prise
Widget _buildMedicationSection() {
  return Consumer<MedicationController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      if (controller.todayMedications.isEmpty) {
        return const Text("Aucun médicament prévu aujourd'hui.");
      }

      final current = controller.currentDoses;
      final next = controller.nextDoses;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Médicaments aujourd'hui", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() => _currentIndex = 2); // redirige vers Médicaments
                    },
                    child: const Text("Voir tout", style: TextStyle(color: Color(0xFF4F46E5))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (current.isNotEmpty)
                ...current.map((dose) => _buildDoseTile(dose))
              else if (next.isNotEmpty) ...[
                Text(
                  "Prochaine prise à ${DateFormat('HH:mm').format(next.first.time)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...next.map((dose) => _buildDoseTile(dose, upcoming: true)),
              ] else
                const Text("Toutes les prises du jour sont passées."),
            ],
          ),
        ),
      );
    },
  );
}

/// Une prise : badge "Pris", bouton "Prendre" (rouge si en retard),
/// ou simple heure si la prise est à venir
Widget _buildDoseTile(DoseSlot dose, {bool upcoming = false}) {
  final med = dose.medication;
  final sched = dose.schedule;
  final isTaken = sched.taken;
  final isLate = !isTaken && !upcoming && DateTime.now().isAfter(dose.time.add(const Duration(minutes: 15)));

  final badgeColor = isTaken
      ? Colors.green
      : isLate
          ? Colors.red
          : upcoming
              ? Colors.grey
              : Colors.orange;

  final details = [
    "Heure : ${sched.time}",
    if (isLate) "En retard",
    if (sched.note != null && sched.note!.isNotEmpty) sched.note!,
  ].join(" · ");

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: badgeColor.withOpacity(0.2),
        child: Icon(FlutterRemix.medicine_bottle_line, color: badgeColor),
      ),
      title: Text(
        med.dosage.isNotEmpty ? "${med.name} (${med.dosage})" : med.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(details, style: TextStyle(color: isLate ? Colors.red : null)),
      trailing: isTaken
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Pris", style: TextStyle(color: Colors.green, fontSize: 12)),
            )
          : upcoming
              ? null
              : ElevatedButton(
                  onPressed: () {
                    Provider.of<MedicationController>(context, listen: false)
                        .markScheduleAsTaken(med.id, sched.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLate ? Colors.red : const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Prendre", style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
    ),
  );
}


/// Section rendez-vous : les 3 prochains seulement, le reste est masqué
Widget _buildAppointmentSection() {
  return Consumer<AppointmentController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      final upcoming = controller.upcoming;
      if (upcoming.isEmpty) {
        return const Text("Aucun rendez-vous à venir.");
      }

      final hiddenCount = upcoming.length - 3;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Titre + bouton Voir tout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Prochains rendez-vous", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      setState(() => _currentIndex = 3); // 👈 Redirection vers l'onglet RDV
                    },
                    child: const Text("Voir tout", style: TextStyle(color: Color(0xFF4F46E5))),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 🔹 Les 3 rendez-vous les plus proches
              ...upcoming.take(3).map(_buildAppointmentTile),

              if (hiddenCount > 0)
                Text(
                  "+ $hiddenCount autre${hiddenCount > 1 ? 's' : ''} rendez-vous",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      );
    },
  );
}



Widget _buildAppointmentTile(Appointment appt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final apptDay = DateTime(appt.dateTime.year, appt.dateTime.month, appt.dateTime.day);
  final daysAway = apptDay.difference(today).inDays;

  final time = DateFormat("HH:mm").format(appt.dateTime);
  final dayText = daysAway == 0
      ? "Aujourd’hui"
      : daysAway == 1
          ? "Demain"
          : DateFormat("d MMM", "fr_FR").format(appt.dateTime);

  final subtitle = [appt.doctor, appt.location].where((s) => s.isNotEmpty).join(" - ");

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.indigo.shade100),
      borderRadius: BorderRadius.circular(8),
      color: Colors.indigo.shade50.withOpacity(0.3),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(FlutterRemix.stethoscope_line, color: Color(0xFF4F46E5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(dayText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    ),
  );
}

/// Section conseil santé : un seul conseil, choisi par le backend
/// selon les dernières mesures du patient
Widget _buildHealthTipsSection() {
  return Consumer<HealthTipController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      final tip = controller.tip;
      if (tip == null) {
        return const Text("Aucun conseil santé disponible pour le moment.");
      }

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Conseil santé", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildTipTile(tip),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildTipTile(HealthTip tip) {
  IconData icon = Icons.health_and_safety;
  Color color = Colors.blue;

  switch (tip.type) {
    case "activité":
      icon = Icons.directions_walk;
      color = Colors.green;
      break;
    case "alimentation":
      icon = Icons.restaurant;
      color = Colors.orange;
      break;
    case "repos":
      icon = Icons.nightlight_round;
      color = Colors.purple;
      break;
    case "hypoglycémie":
    case "hyperglycémie":
      icon = Icons.opacity;
      color = Colors.indigo;
      break;
    case "hypertension":
    case "hypotension":
      icon = Icons.favorite;
      color = Colors.orange;
      break;
    case "fièvre":
      icon = Icons.thermostat;
      color = Colors.deepOrange;
      break;
    case "urgence":
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
      break;
  }

  final title = tip.reason ??
      (tip.type.isEmpty ? "Conseil" : tip.type[0].toUpperCase() + tip.type.substring(1));

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              Text(tip.content, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showAddMeasureDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const AddMeasureForm(),
  );
}


}
