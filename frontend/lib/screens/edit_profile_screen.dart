import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserController>(context, listen: false);
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> _saveChanges() async {
    final user = Provider.of<UserController>(context, listen: false);
    final success = await user.updateProfile(
      nameController.text.trim(),
      emailController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, user, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Modifier le profil")),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                if (user.error != null)
                  Text(user.error!, style: const TextStyle(color: Colors.red)),

                ElevatedButton(
                  onPressed: user.isLoading ? null : _saveChanges,
                  child: user.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enregistrer"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
