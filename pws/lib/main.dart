import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pws/views/home_screen.dart';
import 'firebase_options.dart';
import 'views/login_register_view.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

//start van de app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // flutter engine inisializeren

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // initialiseerd firebase voor het platform
  await GoogleSignIn.instance
      .initialize(); // de sign in voor google wordt geinitialiseerd

  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'PWS',
  ); // de configuratie van de openfoodfacts api ingesteld

  // standaard taal voor openfoodfacts
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.DUTCH,
  ];
  //standaard land voor openfoodfacts
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.NETHERLANDS;
  //start de app
  runApp(const MyApp());
}

//de hoofdklasse van de app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //verbergt de debug banner
      themeMode: ThemeMode.system, // systeem instelling voor light of darkmode

      //thema voor lightmode
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      //thema voor darkmode
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.grey,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
      ),
      //controleert of de gebruiker al is ingelogd, ja: dan homescreen, nee: dan loginregisterscherm
      home: FirebaseAuth.instance.currentUser != null
          ? const HomeScreen()
          : const LoginRegisterView(),
    );
  }
}
