import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fFinder/views/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fFinder/views/home_screen.dart';
import 'firebase_options.dart';
import 'views/login_register_view.dart';
import 'views/onboarding_view.dart';
import 'package:openfoodfacts/openfoodfacts.dart' hide User;
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

//start van de app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // flutter engine inisializeren

  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // initialiseerd firebase voor het platform

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }

  await GoogleSignIn.instance
      .initialize(); // de sign in voor google wordt geinitialiseerd

  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'fFinder',
  ); // de configuratie van de openfoodfacts api ingesteld

  // standaard taal voor openfoodfacts
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.DUTCH,
  ];
  //standaard land voor openfoodfacts
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.NETHERLANDS;

  await NotificationService().initialize(); //initialiseer notificatie service
  await dotenv.load(fileName: "assets/env/.env");

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
        //font voor de app
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
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
        //font voor de app
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      ),
      //controleert of de gebruiker al is ingelogd en of onboarding af is, ja: dan homescreen, nee: dan loginregisterscherm of onboardingview
      home: StreamBuilder<User?>(
        //luistert naar de authenticatie status
        stream: FirebaseAuth.instance
            .authStateChanges(), //stream van authenticatie veranderingen
        builder: (context, snapshot) {
          //builder functie die reageert op veranderingen in de stream
          if (snapshot.connectionState == ConnectionState.waiting) {
            //wacht op de verbinding
            return const Scaffold(
              //laat een laadscherm zien terwijl hij wacht
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            //als er een gebruiker is ingelogd
            // Gebruiker is ingelogd, check nu Firestore voor onboardingaf
            return FutureBuilder<DocumentSnapshot>(
              //haalt het document van de gebruiker op
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userDocSnapshot) {
                //builder functie die reageert op het ophalen van het document
                if (userDocSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                  //als het document bestaat
                  final data =
                      userDocSnapshot.data!.data()
                          as Map<String, dynamic>; //haal de data op
                  final bool onboardingAf =
                      data['onboardingaf'] ??
                      false; //controleer of onboarding is voltooid

                  if (onboardingAf) {
                    return const HomeScreen();
                  } else {
                    return const OnboardingView();
                  }
                }

                // Als het document niet bestaat, stuur naar onboarding
                return const OnboardingView();
              },
            );
          }

          // Niet ingelogd
          return const LoginRegisterView();
        },
      ),
    );
  }
}
