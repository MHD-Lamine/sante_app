import 'package:Sante/controllers/health_tip_controller.dart';
import 'package:Sante/controllers/medication_controller.dart';
import 'package:Sante/models/appointment.dart';
import 'package:Sante/models/health_tip.dart';
import 'package:Sante/models/medication.dart';
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
    
    refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _loadData(); // recharge toutes les données
    });

    @override
    void dispose() {
      refreshTimer?.cancel(); // arrêter le timer quand la page se ferme
      super.dispose();
    }
  }

  Future<void> _loadData() async {
    final name = await ApiService.getUserNameFromStorage();
    setState(() {
      userName = name ?? "Utilisateur";
    });

    Provider.of<MeasureController>(context, listen: false).loadMeasures(); //Chargement des mesures
    Provider.of<MedicationController>(context, listen: false).loadTodayMedications(); //Chargement des médicaments
    Provider.of<AppointmentController>(context, listen: false).loadAppointments(); //Chargement des rendez-vous
    Provider.of<HealthTipController>(context, listen: false).fetchTips(); //Chargement des conseils santé


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
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
    );
  }

  /// Widget pour afficher la section des médicaments
  /// avec un badge indiquant s'il a été pris ou non
Widget _buildMedicationSection() {
  return Consumer<MedicationController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      final meds = controller.todayMedications;
      if (meds.isEmpty) {
        return const Text("Aucun médicament prévu aujourd'hui.");
      }

      final now = DateTime.now();

      // Médicaments ayant au moins une prise dans la tranche horaire (ou en retard)
      final visibleMeds = meds.where((med) {
        return med.schedules.any((s) {
          try {
            final parts = s.time.split(":");
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            final schedTime = DateTime(now.year, now.month, now.day, hour, minute);

            final isWithinRange = now.isAfter(schedTime.subtract(const Duration(minutes: 10))) &&
                now.isBefore(schedTime.add(const Duration(minutes: 150)));

            final isLate = !s.taken && now.isAfter(schedTime.add(const Duration(minutes: 5)));

            return isWithinRange || isLate || s.taken;
          } catch (_) {
            return false;
          }
        });
      }).toList();

      if (visibleMeds.isEmpty) {
        return const Text("Aucun médicament à prendre en ce moment.");
      }

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
              ...visibleMeds.map(_buildMedicationTile).toList(),
            ],
          ),
        ),
      );
    },
  );
}

/// Widget pour afficher chaque médicament
/// avec un badge indiquant s'il a été pris ou non
/// et un bouton pour le marquer comme pris
Widget _buildMedicationTile(Medication med) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${med.name} (${med.dosage})",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // 🕒 Affichage des prises
          ...med.schedules.map((sched) {
            final now = DateTime.now();
            final parts = sched.time.split(":");
            final hour = int.tryParse(parts[0]) ?? 0;
            final minute = int.tryParse(parts[1]) ?? 0;

            final schedTime = DateTime(now.year, now.month, now.day, hour, minute);
            final isTaken = sched.taken;
            final isLate = !isTaken && now.isAfter(schedTime.add(const Duration(minutes: 15))); // ⚠️ En retard après 15 min
            final isSoon = !isTaken && now.isAfter(schedTime.subtract(const Duration(minutes: 30))) && now.isBefore(schedTime.add(const Duration(hours: 1)));

            final badgeColor = isTaken
                ? Colors.green
                : (isLate ? Colors.red : Colors.orange);

            final badgeText = isTaken
                ? "Pris"
                : (isLate ? "En retard" : sched.time);

            return Visibility(
              visible: isTaken || isLate || isSoon,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: badgeColor.withOpacity(0.2),
                    child: Icon(
                      FlutterRemix.time_line,
                      color: badgeColor,
                    ),
                  ),
                  title: Text("Heure : ${sched.time}"),
                  subtitle: sched.note != null ? Text(sched.note!) : null,
                  trailing: isTaken
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("Pris", style: TextStyle(color: Colors.green, fontSize: 12)),
                        )
                      : isLate
                          ? const Text("En retard", style: TextStyle(color: Colors.red, fontSize: 12))
                          : ElevatedButton(
                              onPressed: () {
                                Provider.of<MedicationController>(context, listen: false)
                                    .markScheduleAsTaken(med.id, sched.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Prendre", style: TextStyle(fontSize: 12)),
                            ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}


Widget _buildAppointmentSection() {
  return Consumer<AppointmentController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      final allAppointments = controller.appointments;
      if (allAppointments.isEmpty) {
        return const Text("Aucun rendez-vous à venir.");
      }

      final firstThree = allAppointments.take(3).toList();

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

              // 🔹 Liste des 3 premiers RDV
              ...firstThree.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.event_note, color: Color(0xFF4F46E5)),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("${a.doctor} - ${a.location}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat("d MMM", "fr_FR").format(a.dateTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat("HH:mm").format(a.dateTime), style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
    },
  );
}



Widget _buildAppointmentTile(Appointment appt) {
  final isTomorrow = appt.dateTime.difference(DateTime.now()).inDays == 1;
  final isToday = appt.dateTime.day == DateTime.now().day;

  final time = DateFormat("HH:mm").format(appt.dateTime);
  final dayText = isToday ? "Aujourd’hui" : isTomorrow ? "Demain" : DateFormat("d MMM").format(appt.dateTime);

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
              Text(appt.doctor ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

Widget _buildHealthTipsSection() {
  return Consumer<HealthTipController>(
    builder: (context, controller, _) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error != null) {
        return Text(controller.error!, style: const TextStyle(color: Colors.red));
      }

      final tips = controller.tips;
      if (tips.isEmpty) {
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
              const Text("Conseils santé", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...tips.map((tip) => _buildTipTile(tip)).toList(),
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

  if (tip.type == "activité") {
    icon = Icons.directions_walk;
    color = Colors.green;
  } else if (tip.type == "alimentation") {
    icon = Icons.restaurant;
    color = Colors.orange;
  } else if (tip.type == "repos") {
    icon = Icons.nightlight_round;
    color = Colors.purple;
  }

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
              Text(tip.type[0].toUpperCase() + tip.type.substring(1), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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
