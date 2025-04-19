import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddMeasureForm extends StatefulWidget {
  const AddMeasureForm({super.key});

  @override
  State<AddMeasureForm> createState() => _AddMeasureFormState();
}

class _AddMeasureFormState extends State<AddMeasureForm> {
  final TextEditingController glycemiaController = TextEditingController();
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ajouter vos mesures", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: glycemiaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Glycémie (mmol/L)",
                hintText: "Ex: 5.6",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tension systolique (ex: 120)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tension diastolique (ex: 80)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: temperatureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Température (°C)",
                hintText: "Ex: 37.2",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : _saveAllMeasures,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllMeasures() async {
    try {
      setState(() => isLoading = true);

      final userId = await ApiService.getUserId();
      final now = DateTime.now();
      final date = "${now.year}-${_two(now.month)}-${_two(now.day)} ${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}";

      final glycemia = double.tryParse(glycemiaController.text.trim());
      final systolic = int.tryParse(systolicController.text.trim());
      final diastolic = int.tryParse(diastolicController.text.trim());
      final temperature = double.tryParse(temperatureController.text.trim());

      final body = {
        "user_id": userId,
        "date": date,
        "glycemia": glycemia,
        "systolic": systolic,
        "diastolic": diastolic,
        "temperature": temperature,
      };

      await ApiService.post('/measures', body);

      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
