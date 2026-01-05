import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fFinder/views/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fFinder/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'views/login_register_view.dart';
import 'views/onboarding_view.dart';
import 'package:openfoodfacts/openfoodfacts.dart' hide User;
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, kReleaseMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'locale_notifier.dart';

//start van de app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // flutter engine inisializeren

  tz.initializeTimeZones(); // initialiseer timezone data

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // initialiseerd firebase voor het platform

  if (kReleaseMode) {
    debugPrint('--- BUILD MODE: RELEASE ---');
  } else if (kDebugMode) {
    debugPrint('--- BUILD MODE: DEBUG ---');
  } else {
    debugPrint('--- BUILD MODE: PROFILE ---');
  }

  if (!kIsWeb) {
    try {
      if (kReleaseMode) {
        await FirebaseAppCheck.instance.activate(
          //appcheck betekent dat alleen geverifieerde instanties van de app toegang krijgen tot firebase resources
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );
        debugPrint('[DEBUG] Firebase App Check (release) activated.');
      } else {
        // In debug: gebruik debug-provider
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        final token = await FirebaseAppCheck.instance.getToken(true);
        debugPrint('DEBUG App Check debug token: $token');
      }

      FirebaseAppCheck.instance.onTokenChange.listen((token) {
        debugPrint('[DEBUG] App Check token changed: $token');
      });
    } catch (e) {
      debugPrint('[ERROR] Error activating Firebase App Check: $e');
      if (e is FirebaseException) {
        debugPrint(
          '[ERROR DETAIL] Platform: ${e.plugin}, Code: ${e.code}, Message: ${e.message}',
        );
      }
    }
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
  await dotenv.load(fileName: "assets/env/.env"); //laad de .env file

  final prefs =
      await SharedPreferences.getInstance(); //haalt de gedeelde voorkeuren op
  final code = prefs.getString('locale'); //haalt de opgeslagen taalcode op
  if (code != null && code.isNotEmpty) {
    //als er een taalcode is opgeslagen
    appLocale.value = Locale(code); //zet de app taal naar de opgeslagen taal
  }

  //start de app
  runApp(const MyApp());
}

//de hoofdklasse van de app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      //luistert naar veranderingen in de app taal
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaleFactor: mediaQuery.textScaleFactor.clamp(
                  1.0,
                  1.3,
                ), //beperkt de tekst schaal factor tussen 1.0 en 1.3 voor grootte tekst
              ),
              child: child!,
            );
          },
          locale: locale, //zet de app taal
          localizationsDelegates: const [
            //lokalisatie delegaten voor de app
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:
              AppLocalizations.supportedLocales, //ondersteunde talen

          debugShowCheckedModeBanner: false, //verbergt de debug banner
          themeMode:
              ThemeMode.system, // systeem instelling voor light of darkmode
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
                    if (userDocSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ), //laadscherm terwijl hij wacht
                      );
                    }

                    if (userDocSnapshot.hasData &&
                        userDocSnapshot.data!.exists) {
                      final data =
                          userDocSnapshot.data!.data() as Map<String, dynamic>;
                      final bool onboardingAf = data['onboardingaf'] == true;

                      // Lijst met alle velden die verplicht zijn na de onboarding.
                      const requiredFields = [
                        'firstName',
                        'gender',
                        'birthDate',
                        'height',
                        'weight',
                        'calorieGoal',
                        'proteinGoal',
                        'fatGoal',
                        'carbGoal',
                        'bmi',
                        'sleepHours',
                        'targetWeight',
                        'notificationsEnabled',
                        'activityLevel',
                        'goal',
                      ];

                      // Controleer of alle verplichte velden bestaan in het document.
                      final allFieldsPresent = requiredFields.every(
                        (field) => data.containsKey(field),
                      );

                      if (onboardingAf && allFieldsPresent) {
                        return const HomeScreen();
                      }
                    }

                    return const OnboardingView();
                  },
                );
              }

              // Niet ingelogd
              return const LoginRegisterView();
            },
          ),
        );
      },
    );
  }
}
