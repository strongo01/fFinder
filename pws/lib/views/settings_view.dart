import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_register_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Uitloggen'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginRegisterView(),
                ),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}