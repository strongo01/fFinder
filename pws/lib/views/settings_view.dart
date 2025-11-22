import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_register_view.dart';

//scherm voor de instellingen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bovenste balk van de pagina met de titel
      appBar: AppBar(title: const Text('Instellingen')),
      //inhoud van de pagina, gecentreerd door Center
      body: Center(
        //ElevatedButton.icon dus een knop met een icoon en tekst
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Uitloggen'),
          // de functie die hij uitgevoerd als je op de knop drukt
          onPressed: () async {
            await FirebaseAuth.instance.signOut(); //logt uit van firebase
            //controleert of het scherm nog actief is
            if (context.mounted) {
              // gaat terug naar de loginregisterview en verwijdert alle vorige paginas zodat je geen pijltje terug knop hebt
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
