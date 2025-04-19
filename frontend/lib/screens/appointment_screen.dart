import 'package:Sante/controllers/appointment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les rendez-vous"),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: Consumer<AppointmentController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(child: Text(controller.error!, style: const TextStyle(color: Colors.red)));
          }

          final appointments = controller.appointments;

          if (appointments.isEmpty) {
            return const Center(child: Text("Aucun rendez-vous trouvé."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final rdv = appointments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF4F46E5).withOpacity(0.2),
                      child: const Icon(FlutterRemix.stethoscope_line, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rdv.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(rdv.location, style: const TextStyle(color: Colors.grey)),
                          if (rdv.doctor != null)
                            Text("Avec ${rdv.doctor}", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(DateFormat('d MMM', 'fr_FR').format(rdv.dateTime),
                            style: const TextStyle(color: Color(0xFF4F46E5))),
                        Text(DateFormat('HH:mm').format(rdv.dateTime),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
