import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/add_sport_view.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/login_register_view.dart';
import 'package:fFinder/views/onboarding_view.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fFinder/views/settings_view.dart';
import 'package:flutter/cupertino.dart'; //voor ios stijl widgets
import 'package:flutter/foundation.dart'; // Voor platform check
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_food_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'add_drink_view.dart';
import 'barcode_scanner.dart';
import 'recipes_view.dart';
import 'feedback_view.dart';
import 'weight_view.dart';
import 'package:collection/collection.dart';
import 'package:fFinder/l10n/app_localizations.dart';

//homescreen is een statefulwidget omdat de inhoud verandert
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //variabelen om de status van het scherm bij te houden
  bool _isLoading = false; // of hi jaan het laden is
  String? _errorMessage; // eventuele foutmelding
  //String? _motivationalMessage;
  int _selectedIndex = 0;
  late Future<void> _userDataFuture;
  Map<String, dynamic>? _userData;
  double? _calorieAllowance;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _activeAnnouncements = [];
  StreamSubscription? _announcementSubscription;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String?> _motivationalMessageNotifier = ValueNotifier(
    null,
  );

  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _calorieInfoRowKey = GlobalKey();
  final GlobalKey _barcodeKey = GlobalKey();
  final GlobalKey _waterCircleKey = GlobalKey();
  final GlobalKey _addFabKey = GlobalKey();
  final GlobalKey _mascotteKey = GlobalKey();
  final GlobalKey _mealKey = GlobalKey();
  final GlobalKey _recipesKey = GlobalKey();
  final GlobalKey _feedbackKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _weightKey = GlobalKey();
  bool _tutorialInitialized = false;
  bool _tutorialHomeAf = false;

  static const String _appVersion = '1.1.4';

  late TutorialCoachMark tutorialCoachMark;

  late PageController _pageController; // controller voor de paginaweergave
  static const int _initialPage =
      50000; // een groot getal om ver in de toekomst te starten voor swipen

  @override
  void initState() {
    // bij de start van  widget
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
    ); // de pagina controller initializeren
    _userDataFuture = _fetchUserData();

    _listenToAnnouncements();
  }

  @override
  void didChangeDependencies() {
    // wordt aangeroepen nadat initState is voltooid
    super.didChangeDependencies();
    //_createTutorial();
    //_showTutorial();
  }

  @override
  void dispose() {
    _pageController
        .dispose(); // de controller opruimen bij het verwijderen van de widget
    _scrollController.dispose();
    _announcementSubscription?.cancel();
    _motivationalMessageNotifier.dispose(); // Notifier opruimen
    super.dispose();
  }

  void _listenToAnnouncements() {
    //luister naar actieve admin-berichten
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Annuleer een eventuele bestaande listener
    _announcementSubscription?.cancel(); // voorkom dubbele listeners

    // Start de nieuwe listener
    _announcementSubscription = FirebaseFirestore.instance
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (querySnapshot) async {
            // Deze code wordt elke keer uitgevoerd als er een wijziging is

            if (querySnapshot.docs.isEmpty) {
              if (mounted) setState(() => _activeAnnouncements = []);
              return;
            }

            // Haal de lijst met gesloten berichten van de gebruiker op
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            final dismissed = List<String>.from(
              userDoc.data()?['dismissedAnnouncements'] ?? [],
            );

            // Filter de berichten die de gebruiker nog niet heeft gesloten
            final announcementsToShow = <Map<String, dynamic>>[];
            for (var doc in querySnapshot.docs) {
              final data = doc.data();
              data['id'] = doc.id;
              if (!dismissed.contains(data['id'])) {
                announcementsToShow.add(data);
              }
            }

            // Werk de UI bij als de widget nog bestaat
            if (mounted) {
              setState(() {
                _activeAnnouncements = announcementsToShow;
              });
            }
          },
          onError: (error) {
            debugPrint("Fout bij luisteren naar admin-berichten: $error");
          },
        );
  }

  Future<void> _dismissAnnouncement(String announcementId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Verberg de kaart direct in de UI door hem uit de lijst te verwijderen
    setState(() {
      _activeAnnouncements.removeWhere((ann) => ann['id'] == announcementId);
    });

    // Voeg de ID toe aan de lijst van de gebruiker in Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'dismissedAnnouncements': FieldValue.arrayUnion([announcementId]),
        },
      );
    } catch (e) {
      debugPrint("Fout bij opslaan van gesloten bericht: $e");
    }
  }

  int _compareVersions(String a, String b) {
    List<int> pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (pa.length < 3) pa.add(0);
    while (pb.length < 3) pb.add(0);
    for (int i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
    }
    return 0;
  }

  Widget _buildAnnouncementsList(bool isDarkMode) {
    //bouw de lijst met admin-berichten
    if (_activeAnnouncements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _activeAnnouncements.map((announcement) {
        return Card(
          color: isDarkMode ? Colors.blue[900] : Colors.blue[100],
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement['title'] ??
                          AppLocalizations.of(context)!.announcement_default,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement['message'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () => _dismissAnnouncement(announcement['id']),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBannerList(bool isDarkMode) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('version')
          .doc('version')
          .get(const GetOptions(source: Source.server)), // forceer server
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          debugPrint("[BANNER] Firestore error: ${snapshot.error}");
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          debugPrint("[BANNER] version/version niet gevonden.");
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final remoteVersionRaw = data['version'];
        final remoteVersion = (remoteVersionRaw as String?)?.trim();
        debugPrint("[BANNER] Local: $_appVersion, Remote: $remoteVersionRaw");

        if (remoteVersion == null || remoteVersion.isEmpty) {
          debugPrint("[BANNER] Remote version leeg of null.");
          return const SizedBox.shrink();
        }

        final isNewer = _compareVersions(remoteVersion, _appVersion) > 0;
        debugPrint("[BANNER] isNewer=$isNewer");

        if (!isNewer) return const SizedBox.shrink();

        return Card(
          color: isDarkMode ? Colors.orange[800] : Colors.orange[100],
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.updateAvailable,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTutorial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final bool tutorialHomeAf = userDoc.data()?['tutorialHomeAf'] ?? false;

    if (!tutorialHomeAf) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            tutorialCoachMark.show(context: context);
          }
        });
      });
    }
  }

  void _createTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(context),
      colorShadow: Colors.blue.withOpacity(0.7),
      paddingFocus: 10,
      opacityShadow: 0.8,
      hideSkip: false,
      onClickTarget: (target) {
        if (target.identify == "water-circle-key") {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      },
      onSkip: () {
        debugPrint("Tutorial overgeslagen");
        prefs.setBool('home_tutorial_shown', true);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialHomeAf': true,
          });
        }
        return true; // Return true om de tutorial te sluiten
      },
      onFinish: () async {
        debugPrint("Tutorial voltooid");
        prefs.setBool('home_tutorial_shown', true);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialHomeAf': true,
          });
        }
        if (mounted) {
          setState(() {
            _tutorialHomeAf = true;
          });
          _listenToAnnouncements();
          try {
            await _fetchUserData();
          } catch (_) {}
        }
      },
    );
  }

  List<TargetFocus> _createTargets(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    List<TargetFocus> targets = [];

    //Datumkiezer
    targets.add(
      TargetFocus(
        identify: "date-key",
        keyTarget: _dateKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_date_title,
              AppLocalizations.of(context)!.tutorial_date_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    //Barcode
    targets.add(
      TargetFocus(
        identify: "barcode-key",
        keyTarget: _barcodeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_barcode_title,
              AppLocalizations.of(context)!.tutorial_barcode_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
    //Settings
    targets.add(
      TargetFocus(
        identify: "settings-key",
        keyTarget: _settingsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_settings_title,
              AppLocalizations.of(context)!.tutorial_settings_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // feedback-button
    targets.add(
      TargetFocus(
        identify: "feedback-key",
        keyTarget: _feedbackKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_feedback_title,
              AppLocalizations.of(context)!.tutorial_feedback_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Calorieën-kaart
    targets.add(
      TargetFocus(
        identify: "calorie-info-row-key",
        keyTarget: _calorieInfoRowKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.blue,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_calorie_title,
              AppLocalizations.of(context)!.tutorial_calorie_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Mascotte-kaart
    targets.add(
      TargetFocus(
        identify: "mascotte-key",
        keyTarget: _mascotteKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_mascot_title,
              AppLocalizations.of(context)!.tutorial_mascot_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Watercirkel
    targets.add(
      TargetFocus(
        identify: "water-circle-key",
        keyTarget: _waterCircleKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_water_title,
              AppLocalizations.of(context)!.tutorial_water_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Toevoegen knop
    targets.add(
      TargetFocus(
        //fab is floating action button
        identify: "add-fab-key",
        keyTarget: _addFabKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_additems_title,
              AppLocalizations.of(context)!.tutorial_additems_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    // Meals-kaart
    targets.add(
      TargetFocus(
        identify: "meal-key",
        keyTarget: _mealKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.blue,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              AppLocalizations.of(context)!.tutorial_meals_title,
              AppLocalizations.of(context)!.tutorial_meals_text,
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  Widget _buildTutorialContent(String title, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return AppLocalizations.of(context)!.today;
    } else if (selected == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return '${date.day}-${date.month}-${date.year}';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS datumkiezer
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  minimumDate: DateTime(2020),
                  maximumDate: today,
                  onDateTimeChanged: (val) {
                    setState(() {
                      _selectedDate = val;
                      final pickedWithoutTime = DateTime(
                        // update de pagina
                        val.year,
                        val.month,
                        val.day,
                      );
                      final difference = pickedWithoutTime
                          .difference(todayWithoutTime)
                          .inDays;
                      _pageController.jumpToPage(_initialPage + difference);
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text(AppLocalizations.of(context)!.today),
                onPressed: () {
                  setState(() {
                    _selectedDate = todayWithoutTime;
                    _pageController.jumpToPage(_initialPage);
                  });
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text(AppLocalizations.of(context)!.done),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: today,
        builder: (context, child) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: child!),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.today),
                    onPressed: () {
                      setState(() {
                        _selectedDate = todayWithoutTime;
                        _pageController.jumpToPage(_initialPage);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        final today = DateTime.now();
        final todayWithoutTime = DateTime(today.year, today.month, today.day);
        final pickedWithoutTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
        final difference = pickedWithoutTime
            .difference(todayWithoutTime)
            .inDays;
        _pageController.jumpToPage(_initialPage + difference);
      }
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // 1️⃣ Global DEK ophalen (Remote Config)
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Forceer het ophalen van de nieuwste config door de cache-tijd te minimaliseren
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero, // Belangrijk voor debuggen!
        ),
      );

      await remoteConfig.fetchAndActivate(); // haal nieuwste config op
      if (!mounted) return; // Stop if the widget is no longer in the tree.
      final globalDEKString = remoteConfig.getString('GLOBAL_DEK');

      if (globalDEKString.isEmpty) {
        throw Exception("GLOBAL_DEK from Remote Config is empty!");
      }

      final globalDEK = SecretKey(base64Decode(globalDEKString));

      // 2️⃣ User-specifieke DEK afleiden
      final userDEK = await deriveUserKey(globalDEK, user.uid);

      // 3️⃣ Haal data op
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || !mounted) return;

      final data = doc.data()!;

      final tutorialHomeRaw = doc.data()?['tutorialHomeAf'] ?? false;
      if (mounted) {
        setState(() {
          _tutorialHomeAf = tutorialHomeRaw == true;
        });
      }

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
        'onboardingaf',
        'activityLevel',
        'goal',
      ];
      final allFieldsPresent = requiredFields.every(
        (field) => data.containsKey(field),
      );

      if (!allFieldsPresent) {
        debugPrint(
          "Gebruikersdata is onvolledig. Navigeren naar OnboardingView.",
        );
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OnboardingView()),
            (Route<dynamic> route) => false,
          );
        }
        return; // Stop de functie hier
      }

      String? _rawWaterGoal;
      if (data.containsKey('waterGoal')) {
        _rawWaterGoal = await decryptValue(data['waterGoal'], userDEK);
      } else {
        _rawWaterGoal = null;
      }
      final double? parsedWaterGoal = _rawWaterGoal != null
          ? double.tryParse(_rawWaterGoal)
          : null;

      // 4️⃣ Decrypt alle geëncryptte velden
      final decryptedData = {
        'firstName': await decryptValue(data['firstName'], userDEK),
        'gender': await decryptValue(data['gender'], userDEK),
        'birthDate': await decryptValue(data['birthDate'], userDEK),
        'height':
            double.tryParse(await decryptValue(data['height'], userDEK)) ?? 0,
        'weight':
            double.tryParse(await decryptValue(data['weight'], userDEK)) ?? 0,
        'calorieGoal':
            double.tryParse(await decryptValue(data['calorieGoal'], userDEK)) ??
            0,
        'proteinGoal':
            double.tryParse(await decryptValue(data['proteinGoal'], userDEK)) ??
            0,
        'fatGoal':
            double.tryParse(await decryptValue(data['fatGoal'], userDEK)) ?? 0,
        'carbGoal':
            double.tryParse(await decryptValue(data['carbGoal'], userDEK)) ?? 0,
        'bmi': double.tryParse(await decryptValue(data['bmi'], userDEK)) ?? 0,
        'sleepHours':
            double.tryParse(await decryptValue(data['sleepHours'], userDEK)) ??
            0,
        'targetWeight':
            double.tryParse(
              await decryptValue(data['targetWeight'], userDEK),
            ) ??
            0,
        'waterGoal': parsedWaterGoal,
        'notificationsEnabled': data['notificationsEnabled'],
        'onboardingaf': data['onboardingaf'],
        'activityLevel': await decryptValue(data['activityLevel'], userDEK),
        'goal': await decryptValue(data['goal'], userDEK),
      };

      _userData = decryptedData;
      _calorieAllowance =
          decryptedData['calorieGoal'] as double? ??
          _calculateCalories(_userData!);
    } catch (e, s) {
      debugPrint('Could not fetch user data: $e');
      debugPrint('Stack trace: $s');

      // Controleer of de fout een FormatException is, wat duidt op corrupte data.
      if (e is FormatException) {
        debugPrint(
          'FormatException gedetecteerd. Waarschijnlijk corrupte gebruikersdata. Bezig met uitloggen.',
        );

        if (mounted) {
          // Log de gebruiker uit
          await FirebaseAuth.instance.signOut();

          // Navigeer naar het inlogscherm en wis de navigatiestack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginRegisterView()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Voor alle andere fouten, gooi de fout opnieuw zodat de FutureBuilder deze kan tonen.
        rethrow;
      }
    }
  }

  double _calculateCalories(Map<String, dynamic> data) {
    //berekent de aanbevolen dagelijkse hoeveelheid calorieen
    //calorieen
    final gender = data['gender'] ?? 'Man';
    final weight = (data['weight'] ?? 70).toDouble(); // kg
    final height = (data['height'] ?? 170).toDouble(); // cm
    final birthDateString =
        data['birthDate'] ?? DateTime(2000).toIso8601String();
    final goal = data['goal'] ?? 'Op gewicht blijven';
    final activityFull =
        data['activityLevel'] ??
        'Weinig actief: zittend werk, nauwelijks beweging, geen sport';

    final birthDate = DateTime.tryParse(birthDateString) ?? DateTime(2000);
    final age = DateTime.now().year - birthDate.year;

    double bmr;
    if (gender == 'Vrouw') {
      bmr =
          10 * weight +
          6.25 * height -
          5 * age -
          161; // Harris-Benedict formule voor vrouwen
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5; // voor mannen
    }

    final activity = activityFull.split(':')[0].trim();

    double activityFactor;
    switch (activity) {
      case 'Weinig actief':
        activityFactor = 1.2;
        break;
      case 'Licht actief':
        activityFactor = 1.375;
        break;
      case 'Gemiddeld actief':
        activityFactor = 1.55;
        break;
      case 'Zeer actief':
        activityFactor = 1.725;
        break;
      case 'Extreem actief':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    double calories = bmr * activityFactor;

    // Doel aanpassen
    switch (goal) {
      case 'Afvallen':
        calories -= 500;
        break;
      case 'Aankomen (spiermassa)':
      case 'Aankomen (algemeen)':
        calories += 300;
        break;
      case 'Op gewicht blijven':
      default:
        break;
    }

    return calories;
  }

  Future<void> _showEditWaterGoalDialog(double currentGoal) async {
    final amountController = TextEditingController(
      text: currentGoal.round().toString(),
    );
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final newGoal = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.water_goal_dialog_title,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.water_goal_dialog_label,
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return AppLocalizations.of(context)!.enter_valid_number;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(
                    context,
                  ).pop(double.parse(amountController.text));
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (newGoal != null && newGoal != currentGoal) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // update lokaal direct voor snellere UI feedback
      setState(() {
        if (_userData == null) _userData = {};
        _userData!['waterGoal'] = newGoal.toString();
      });

      try {
        final userDEK = await getUserDEKFromRemoteConfig(user.uid);
        if (userDEK == null) throw Exception("DEK niet gevonden");

        final encrypted = await encryptValue(newGoal.toString(), userDEK);

        // Schrijf naar Firestore in veld 'goal' zoals je aangaf
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'waterGoal': encrypted});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.water_goal_updated),
            ),
          );
        }
      } catch (e) {
        debugPrint("[WATER_GOAL] Fout bij opslaan: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.error_saving_water_goal +
                    e.toString(),
              ),
            ),
          );
          // revert lokaal
          setState(() {
            _userData!['waterGoal'] = currentGoal.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.errorLoadingData} ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (!_tutorialInitialized) {
          _tutorialInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _createTutorial();
            _showTutorial();
          });
        }

        // Als de data succesvol is geladen, bouw de UI
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return _buildIOSLayout();
        }
        return _buildAndroidLayout();
      },
    );
  }

  // iOS layout
  Widget _buildIOSLayout() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return CupertinoTabScaffold(
      // Tab scaffold voor iOS stijl tabs
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home),
            label: AppLocalizations.of(context)!.logs,
          ),
          BottomNavigationBarItem(
            key: _recipesKey,
            icon: const Icon(CupertinoIcons.book),
            label: AppLocalizations.of(context)!.recipesTitle,
          ),
          BottomNavigationBarItem(
            key: _weightKey,
            icon: const Icon(CupertinoIcons.chart_bar),
            label: AppLocalizations.of(context)!.weightTitle,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // bouwt de inhoud voor elke tab
        if (index == 0) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: GestureDetector(
                key: _dateKey,
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatDate(context, _selectedDate)),
                      const SizedBox(width: 8),
                      const Icon(CupertinoIcons.calendar, size: 22),
                    ],
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    key: _barcodeKey,
                    child: const Icon(
                      CupertinoIcons.barcode_viewfinder,
                      size: 28,
                    ),
                    onPressed: _scanBarcode,
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 8),
                    key: _settingsKey,
                    child: const Icon(CupertinoIcons.settings, size: 26),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            child: SafeArea(
              child: Material(
                child: Scaffold(
                  body: Stack(
                    children: [
                      _buildHomeContent(),
                      Positioned(
                        right: 16,
                        bottom: 120,
                        key: _feedbackKey,
                        child: const FeedbackButton(),
                      ),
                    ],
                  ),
                  floatingActionButton: _buildSpeedDial(),
                ),
              ),
            ),
          );
        } else if (index == 1) {
          // Tab 2: Recepten
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.recipesTitle),
            ),
            child: (() {
              final roleFromLocal = _userData?['role'];
              if (roleFromLocal != null) {
                return roleFromLocal == 'admin'
                    ? const RecipesScreen()
                    : const UnderConstructionScreen();
              }
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const UnderConstructionScreen();
                  }
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final role = data['role'] ?? data['rol'] ?? 'user';
                  return role == 'admin'
                      ? const RecipesScreen()
                      : const UnderConstructionScreen();
                },
              );
            })(),
          );
        } else {
          // Tab 3: Gewicht
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.weightTitle),
            ),
            child: const WeightView(),
          );
        }
      },
    );
  }

  //  Android layout
  Widget _buildAndroidLayout() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget body;
    Widget? fab;

    if (_selectedIndex == 0) {
      body = Stack(
        children: [
          Positioned.fill(
            child: Column(children: [Expanded(child: _buildHomeContent())]),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            key: _feedbackKey,
            child: const FeedbackButton(),
          ),
        ],
      );
      fab = _buildSpeedDial();
    } else if (_selectedIndex == 1) {
      body = (() {
        // Als we de role al in _userData hebben (geladen in _fetchUserData), gebruik die
        final roleFromLocal = _userData?['role'];
        if (roleFromLocal != null) {
          return roleFromLocal == 'admin'
              ? const RecipesScreen()
              : const UnderConstructionScreen();
        }

        // Fallback: haal role asynchroon op uit Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const UnderConstructionScreen();
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'] ?? data['rol'] ?? 'user';
            return role == 'admin'
                ? const RecipesScreen()
                : const UnderConstructionScreen();
          },
        );
      })();
      fab = null;
    } else {
      body = const WeightView();
      fab = null;
    }

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: GestureDetector(
                key: _dateKey,
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatDate(context, _selectedDate)),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  key: _barcodeKey,
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
                IconButton(
                  key: _settingsKey,
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            )
          : AppBar(
              title: Text(
                _selectedIndex == 1
                    ? AppLocalizations.of(context)!.recipesTitle
                    : AppLocalizations.of(context)!.weightTitle,
              ),
              centerTitle: true,
            ),
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: isDarkMode ? Colors.tealAccent : Colors.teal,
        unselectedItemColor: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.logs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: AppLocalizations.of(context)!.recipesTitle,
            key: _recipesKey,
          ),
          BottomNavigationBarItem(
            key: _weightKey,
            icon: const Icon(Icons.monitor_weight),
            label: AppLocalizations.of(context)!.weightTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    //fab is floating action button
    // bouwt de SpeedDial knop
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fabBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.grey[200];
    final fabForegroundColor = isDarkMode ? Colors.white : Colors.black;
    final childBackgroundColor = isDarkMode ? Colors.grey[700] : Colors.white;

    return SpeedDial(
      key: _addFabKey,
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: fabBackgroundColor,
      foregroundColor: fabForegroundColor,
      animationCurve: Curves.bounceInOut, // animatie voor het openen/sluiten
      animationDuration: const Duration(milliseconds: 300),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.restaurant),
          label: AppLocalizations.of(context)!.add_food_label,
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            // actie bij tikken
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddFoodPage(selectedDate: _selectedDate),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_drink),
          label: AppLocalizations.of(context)!.add_drink_label,
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddDrinkPage(selectedDate: _selectedDate),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.fitness_center),
          label: AppLocalizations.of(context)!.add_sport_label,
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddSportPage(selectedDate: _selectedDate),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _scanBarcode() async {
    //hij reset de foutmeldingen
    setState(() {
      _errorMessage = null;
      _isLoading = true; // Toon laadindicator
    });
    debugPrint("[HOME_SCREEN] Starting barcode scan...");

    // hij opent de barcode scanner en wacht totdat hij klaar is
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    // als er een geldige barcode is gescand en niet -1
    if (res is String && res != '-1') {
      final barcode = res;
      debugPrint("[HOME_SCREEN] Scanned barcode: $barcode");
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? productData;

      if (user != null) {
        try {
          // Controleer eerst de 'recents' collectie
          final recentDocRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recents')
              .doc(barcode);

          final docSnapshot = await recentDocRef.get();

          if (docSnapshot.exists) {
            debugPrint(
              "[HOME_SCREEN] Product found in recents for barcode: $barcode",
            );
            // Product gevonden in recents, decrypt de data
            final encryptedData = docSnapshot.data() as Map<String, dynamic>;
            debugPrint(
              "[HOME_SCREEN] Encrypted data from recents: $encryptedData",
            );

            final userDEK = await getUserDEKFromRemoteConfig(user.uid);
            if (userDEK != null) {
              debugPrint("[HOME_SCREEN] User DEK found. Decrypting...");
              final decryptedData = Map<String, dynamic>.from(encryptedData);

              // Decrypt basisvelden
              if (encryptedData['product_name'] != null) {
                decryptedData['product_name'] = await decryptValue(
                  encryptedData['product_name'],
                  userDEK,
                );
              }
              if (encryptedData['brands'] != null) {
                decryptedData['brands'] = await decryptValue(
                  encryptedData['brands'],
                  userDEK,
                );
              }
              if (encryptedData['quantity'] != null) {
                decryptedData['quantity'] = await decryptValue(
                  encryptedData['quantity'],
                  userDEK,
                );
              }

              if (encryptedData['serving_size'] != null) {
                try {
                  decryptedData['serving_size'] = await decryptValue(
                    encryptedData['serving_size'],
                    userDEK,
                  );
                } catch (e) {
                  debugPrint("[HOME_SCREEN] Error decrypting serving_size: $e");
                  // fallback naar het originele versleutelde object als decryptie faalt
                  decryptedData['serving_size'] = encryptedData['serving_size'];
                }
              }

              // Decrypt de geneste voedingswaarden
              if (encryptedData['nutriments_per_100g'] != null &&
                  encryptedData['nutriments_per_100g'] is Map) {
                final encryptedNutriments =
                    encryptedData['nutriments_per_100g']
                        as Map<String, dynamic>;
                final decryptedNutriments = <String, dynamic>{};
                for (final key in encryptedNutriments.keys) {
                  // Gebruik decryptDouble voor de numerieke waarden binnen nutriments
                  decryptedNutriments[key] = await decryptDouble(
                    encryptedNutriments[key],
                    userDEK,
                  );
                }
                decryptedData['nutriments_per_100g'] = decryptedNutriments;
              }

              productData = decryptedData;
              debugPrint("[HOME_SCREEN] Decrypted data: $productData");
            } else {
              debugPrint(
                "[HOME_SCREEN] User DEK not found. Using encrypted data as fallback.",
              );
              productData = encryptedData; // Fallback to encrypted
            }
          } else {
            debugPrint(
              "[HOME_SCREEN] Product not found in recents for barcode: $barcode",
            );
          }
        } catch (e) {
          debugPrint("[HOME_SCREEN] Error fetching from recents: $e");
          if (mounted) {
            setState(() {
              _errorMessage = "Fout bij ophalen recente producten: $e";
            });
          }
        }
      }

      if (mounted) {
        debugPrint(
          "[HOME_SCREEN] Navigating to AddFoodPage with initialProductData: $productData",
        );
        // Controleer of de widget nog bestaat
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddFoodPage(
              scannedBarcode: barcode,
              initialProductData: productData,
              selectedDate: _selectedDate,
            ),
          ),
        );
      }
    } else {
      debugPrint(
        "[HOME_SCREEN] Barcode scan cancelled or failed. Result: $res",
      );
    }

    // Verberg laadindicator
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Fout: $_errorMessage',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // bouwt de inhoud van het homescreen
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      dragStartBehavior: DragStartBehavior.start,
      onPageChanged: (index) {
        final today = DateTime.now();
        final todayWithoutTime = DateTime(today.year, today.month, today.day);
        // Voorkomt dat je naar toekomst swipet
        final newDate = todayWithoutTime.add(
          Duration(days: index - _initialPage),
        );
        if (newDate.isAfter(today)) {
          // blokkeer toekomst
          _pageController.jumpToPage(index - 1);
          return;
        }
        setState(() {
          _selectedDate = newDate;
        });
      },
      itemBuilder: (context, index) {
        // bouwt elke pagina
        final today = DateTime.now();
        final todayWithoutTime = DateTime(today.year, today.month, today.day);
        final dateForPage = todayWithoutTime.add(
          Duration(days: index - _initialPage),
        );

        // Blokkeer het bouwen van toekomstige pagina's
        if (dateForPage.isAfter(today)) {
          return Container(color: Theme.of(context).scaffoldBackgroundColor);
        }

        return _buildPageForDate(dateForPage);
      },
    );
  }

  Widget _buildPageForDate(DateTime date) {
    // bouwt de inhoud voor een specifieke datum
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return Center(child: Text(AppLocalizations.of(context)!.not_logged_in));

    final docId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 40,
        ),

        child: _buildDailyLog(
          user.uid,
          docId,
          isDarkMode,
        ), // bouwt de dagelijkse log
      ),
    );
  }

  String _localizedSportLabel(BuildContext context, String? raw) {
    final loc = AppLocalizations.of(context)!;
    final s = (raw ?? '').toString().toLowerCase();
    switch (s) {
      case 'running':
        return loc.sportRunning;
      case 'cycling':
        return loc.sportCycling;
      case 'swimming':
        return loc.sportSwimming;
      case 'walking':
        return loc.sportWalking;
      case 'fitness':
        return loc.sportFitness;
      case 'football':
        return loc.sportFootball;
      case 'tennis':
        return loc.sportTennis;
      case 'yoga':
        return loc.sportYoga;
      default:
        // Als het geen bekende id is, retourneer de originele waarde (custom naam)
        return raw ?? loc.unknownSport;
    }
  }

  Widget _buildDailyLog(String uid, String docId, bool isDarkMode) {
    // bouwt de dagelijkse log voor een specifieke dag
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('logs')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = (snapshot.hasData && snapshot.data!.exists)
            ? snapshot.data!.data() as Map<String, dynamic>
            : null;
        final entriesRaw = data?['entries'] as List<dynamic>? ?? [];

        final user = FirebaseAuth.instance.currentUser;
        if (user == null)
          return Center(
            child: Text(AppLocalizations.of(context)!.not_logged_in),
          );

        // Haal de userDEK op
        return FutureBuilder<SecretKey?>(
          future: getUserDEKFromRemoteConfig(user.uid),
          builder: (context, dekSnapshot) {
            if (dekSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!dekSnapshot.hasData || dekSnapshot.data == null) {
              return Center(
                child: Text(AppLocalizations.of(context)!.dekNotFoundForUser),
              );
            }
            final userDEK = dekSnapshot.data!;

            final selectedDate = DateTime.parse(docId);
            final startOfDay = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            );
            final endOfDay = startOfDay.add(const Duration(days: 1));

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, userPrefSnapshot) {
                final includeSportsCalories =
                    userPrefSnapshot.hasData &&
                    userPrefSnapshot.data!.exists &&
                    ((userPrefSnapshot.data!.data()
                            as Map<
                              String,
                              dynamic
                            >?)?['includeSportsCalories'] ==
                        true);

                // Daarna: realtime sports voor de geselecteerde dag
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('sports')
                      .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                      .where('timestamp', isLessThan: endOfDay)
                      .snapshots(),
                  builder: (context, sportsSnapshot) {
                    if (sportsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sportsDocs = sportsSnapshot.data?.docs ?? [];

                    // Decrypt alle sportgegevens (asynchrone future)
                    Future<List<Map<String, dynamic>>> sportsFuture = () async {
                      final result = <Map<String, dynamic>>[];
                      for (final doc in sportsDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        result.add({
                          'id': doc.id,
                          'name': await decryptValue(data['sport'], userDEK),
                          'duration': await decryptDouble(
                            data['duration_min'],
                            userDEK,
                          ),
                          'calories': await decryptDouble(
                            data['calories_burned'],
                            userDEK,
                          ),
                          'timestamp': data['timestamp'],
                        });
                      }
                      return result;
                    }();

                    // Decrypt alle entries
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: () async {
                        final decryptedEntries = <Map<String, dynamic>>[];
                        for (final entry in entriesRaw) {
                          final decryptedEntry = Map<String, dynamic>.from(
                            entry,
                          );
                          decryptedEntry['product_name'] = await decryptValue(
                            entry['product_name'],
                            userDEK,
                          );
                          decryptedEntry['meal_type'] = await decryptValue(
                            entry['meal_type'],
                            userDEK,
                          );
                          if (entry.containsKey('nutrients')) {
                            final nutrients =
                                entry['nutrients'] as Map<String, dynamic>? ??
                                {};
                            final decryptedNutrients = <String, dynamic>{};
                            for (final key in nutrients.keys) {
                              decryptedNutrients[key] = await decryptDouble(
                                nutrients[key],
                                userDEK,
                              );
                            }
                            decryptedEntry['nutrients'] = decryptedNutrients;
                          }
                          if (entry.containsKey('amount_g')) {
                            decryptedEntry['amount_g'] = await decryptDouble(
                              entry['amount_g'],
                              userDEK,
                            );
                          }
                          if (entry.containsKey('quantity')) {
                            decryptedEntry['quantity'] = await decryptValue(
                              entry['quantity'],
                              userDEK,
                            );
                          }
                          if (entry.containsKey('kcal')) {
                            decryptedEntry['kcal'] = await decryptValue(
                              entry['kcal'],
                              userDEK,
                            );
                          }
                          decryptedEntry['timestamp'] = entry['timestamp'];
                          decryptedEntry['_originalEncrypted'] = entry;

                          decryptedEntries.add(decryptedEntry);
                        }
                        return decryptedEntries;
                      }(),
                      builder: (context, entriesSnapshot) {
                        if (entriesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!entriesSnapshot.hasData) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noEntriesForDate,
                            ),
                          );
                        }

                        final entries = entriesSnapshot.data!;
                        final originalEntriesMap =
                            <Map<String, dynamic>, Map<String, dynamic>>{};
                        for (final e in entries) {
                          final orig =
                              e['_originalEncrypted'] as Map<String, dynamic>?;
                          if (orig != null) originalEntriesMap[e] = orig;
                        }

                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: sportsFuture,
                          builder: (context, sportsDataSnapshot) {
                            //final entries = entriesSnapshot.data!;
                            final sportsList = sportsDataSnapshot.data ?? [];
                            final double totalBurnedCalories = sportsList.fold(
                              0.0,
                              (sum, item) => sum + (item['calories'] ?? 0.0),
                            );

                            // Bereken nutritionele totalen (zoals eerder)
                            double totalCalories = 0;
                            double totalProteins = 0;
                            double totalFats = 0;
                            double totalCarbs = 0;
                            for (var entry in entries) {
                              if (entry.containsKey('quantity')) {
                                final kcal =
                                    double.tryParse(
                                      entry['kcal']?.toString() ?? '0',
                                    ) ??
                                    0.0;
                                totalCalories += kcal;
                              } else {
                                totalCalories +=
                                    (entry['nutrients']?['energy-kcal'] ?? 0.0);
                                totalProteins +=
                                    (entry['nutrients']?['proteins'] ?? 0.0);
                                totalFats +=
                                    (entry['nutrients']?['fat'] ?? 0.0);
                                totalCarbs +=
                                    (entry['nutrients']?['carbohydrates'] ??
                                    0.0);
                              }
                            }

                            double adjustedCalorieGoal =
                                _calorieAllowance ?? 0.0;

                            // Pas lokaal het totaal aan wanneer de gebruiker dat wil (NIET in Firestore schrijven)
                            if (includeSportsCalories) {
                              adjustedCalorieGoal += totalBurnedCalories;
                            }

                            final Map<String, List<dynamic>> meals = {
                              'breakfast': [],
                              'lunch': [],
                              'dinner': [],
                              'snack': [],
                            };

                            // Bekende NL-waardes in jouw opslag
                            final nlBreakfast = 'Ontbijt';
                            final nlLunch = 'Lunch';
                            final nlDinner = 'Avondeten';
                            final nlSnack = 'Tussendoor';

                            // Sets met mogelijke vertalingen (lowercase voor veilige vergelijking)
                            final breakfastNames = {
                              AppLocalizations.of(
                                context,
                              )!.breakfast.toLowerCase(),
                              nlBreakfast.toLowerCase(),
                              'breakfast',
                              'petit-déjeuner', // Frans
                              'frühstück', // Duits
                            };
                            final lunchNames = {
                              AppLocalizations.of(context)!.lunch.toLowerCase(),
                              nlLunch.toLowerCase(),
                              'lunch',
                              'déjeuner', // Frans
                              'mittagessen', // Duits
                            };
                            final dinnerNames = {
                              AppLocalizations.of(
                                context,
                              )!.dinner.toLowerCase(),
                              nlDinner.toLowerCase(),
                              'dinner',
                              'dîner', // Frans
                              'abendessen', // Duits
                            };
                            final snackNames = {
                              AppLocalizations.of(context)!.snack.toLowerCase(),
                              nlSnack.toLowerCase(),
                              'snack',
                              'en-cas', // Frans
                              'zwischenmahlzeit', // Duits
                            };

                            for (var entry in entries) {
                              final rawMealType =
                                  (entry['meal_type'] as String?)?.trim() ?? '';
                              final mealTypeLower = rawMealType.toLowerCase();

                              if (mealTypeLower.isNotEmpty) {
                                if (breakfastNames.contains(mealTypeLower)) {
                                  meals['breakfast']!.add(entry);
                                  continue;
                                } else if (lunchNames.contains(mealTypeLower)) {
                                  meals['lunch']!.add(entry);
                                  continue;
                                } else if (dinnerNames.contains(
                                  mealTypeLower,
                                )) {
                                  meals['dinner']!.add(entry);
                                  continue;
                                } else if (snackNames.contains(mealTypeLower)) {
                                  meals['snack']!.add(entry);
                                  continue;
                                }
                              }

                              // Fallback op timestamp als meal_type niet herkend wordt
                              final timestamp =
                                  (entry['timestamp'] as Timestamp?)
                                      ?.toDate() ??
                                  DateTime.now();
                              final hour = timestamp.hour;
                              if (hour >= 5 && hour < 11) {
                                meals['breakfast']!.add(entry);
                              } else if (hour >= 11 && hour < 15) {
                                meals['lunch']!.add(entry);
                              } else if (hour >= 15 && hour < 22) {
                                meals['dinner']!.add(entry);
                              } else {
                                meals['snack']!.add(entry);
                              }
                            }

                            // Titles per interne key — UI blijft gelocaliseerd
                            final mealTitles = {
                              'breakfast': AppLocalizations.of(
                                context,
                              )!.breakfast,
                              'lunch': AppLocalizations.of(context)!.lunch,
                              'dinner': AppLocalizations.of(context)!.dinner,
                              'snack': AppLocalizations.of(context)!.snack,
                            };

                            final baseCalorieGoal = _calorieAllowance ?? 0.0;

                            final proteinGoal =
                                _userData?['proteinGoal'] as num? ?? 0.0;
                            final fatGoal =
                                _userData?['fatGoal'] as num? ?? 0.0;
                            final carbGoal =
                                _userData?['carbGoal'] as num? ?? 0.0;

                            final remainingCalories =
                                adjustedCalorieGoal - totalCalories;

                            final progress = adjustedCalorieGoal > 0
                                ? (totalCalories / adjustedCalorieGoal).clamp(
                                    0.0,
                                    1.0,
                                  )
                                : 0.0;

                            final Map<String, double> drinkBreakdown = {};
                            double totalWater = 0;
                            for (var entry in entries) {
                              if (entry.containsKey('quantity')) {
                                final quantityString =
                                    entry['quantity'] as String? ?? '0 ml';
                                final amount =
                                    double.tryParse(
                                      quantityString.replaceAll(' ml', ''),
                                    ) ??
                                    0.0;
                                final drinkName =
                                    entry['product_name'] as String? ??
                                    AppLocalizations.of(context)!.unknown;
                                drinkBreakdown.update(
                                  drinkName,
                                  (value) => value + amount,
                                  ifAbsent: () => amount,
                                );
                                totalWater += amount;
                              }
                            }
                            final weight = _userData?['weight'] as num? ?? 70;
                            double waterGoal = weight * 32.5;
                            try {
                              final rawGoal = _userData?['waterGoal'];
                              if (rawGoal != null) {
                                final parsed = double.tryParse(
                                  rawGoal.toString(),
                                );
                                if (parsed != null && parsed > 0) {
                                  waterGoal = parsed;
                                }
                              }
                            } catch (_) {
                              // fallback blijft behouden
                            }

                            final motivationalMessage = _getMotivationalMessage(
                              context,
                              totalCalories,
                              adjustedCalorieGoal,
                              totalWater,
                              waterGoal,
                              entries.isNotEmpty,
                            );

                            if (_motivationalMessageNotifier.value == null) {
                              _motivationalMessageNotifier.value =
                                  motivationalMessage;
                            }

                            return Column(
                              children: [
                                if (_tutorialHomeAf)
                                  _buildAnnouncementsList(isDarkMode),

                                _buildBannerList(isDarkMode),
                                Card(
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          key: _calorieInfoRowKey,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildCalorieInfo(
                                              AppLocalizations.of(
                                                context,
                                              )!.eaten,
                                              totalCalories,
                                              isDarkMode,
                                            ),
                                            _buildCalorieInfo(
                                              AppLocalizations.of(
                                                context,
                                              )!.goal,
                                              adjustedCalorieGoal, // Gebruik het aangepaste doel
                                              isDarkMode,
                                            ),
                                            _buildCalorieInfo(
                                              AppLocalizations.of(
                                                context,
                                              )!.remaining,
                                              remainingCalories,
                                              isDarkMode,
                                              isRemaining: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 10,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          backgroundColor: isDarkMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                progress > 1.0
                                                    ? Colors.red
                                                    : (isDarkMode
                                                          ? Colors.green[300]!
                                                          : Colors.green),
                                              ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildMacroCircle(
                                              AppLocalizations.of(
                                                context,
                                              )!.carbs,
                                              totalCarbs,
                                              carbGoal.toDouble(),
                                              isDarkMode,
                                              Colors.orange,
                                            ),
                                            _buildMacroCircle(
                                              AppLocalizations.of(
                                                context,
                                              )!.proteins,
                                              totalProteins,
                                              proteinGoal.toDouble(),
                                              isDarkMode,
                                              const Color.fromARGB(
                                                255,
                                                0,
                                                140,
                                                255,
                                              ),
                                            ),
                                            _buildMacroCircle(
                                              AppLocalizations.of(
                                                context,
                                              )!.fats,
                                              totalFats,
                                              fatGoal.toDouble(),
                                              isDarkMode,
                                              const Color.fromARGB(
                                                255,
                                                0,
                                                213,
                                                255,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Center(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth < 500) {
                                        return Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              key: _mascotteKey,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 80,
                                                        ),
                                                    child: ValueListenableBuilder<String?>(
                                                      valueListenable:
                                                          _motivationalMessageNotifier,
                                                      builder: (context, message, child) {
                                                        // Gebruik 'message' van de notifier. Als die null is, toon een laadtekst.
                                                        return BubbleSpecialThree(
                                                          text:
                                                              message ??
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.thinking,
                                                          color: isDarkMode
                                                              ? const Color(
                                                                  0xFF1B97F3,
                                                                )
                                                              : Colors
                                                                    .blueAccent,
                                                          tail: true,
                                                          isSender: true,
                                                          textStyle:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                StreamBuilder<DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(uid)
                                                      .snapshots(),
                                                  builder: (context, userSnapshot) {
                                                    bool showGif = true;
                                                    if (userSnapshot.hasData &&
                                                        userSnapshot
                                                            .data!
                                                            .exists) {
                                                      final userData =
                                                          userSnapshot.data!
                                                                  .data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;
                                                      showGif =
                                                          userData['gif'] ==
                                                          true;
                                                    }
                                                    return GestureDetector(
                                                      onTap: () {
                                                        _motivationalMessageNotifier
                                                                .value =
                                                            _getMotivationalMessage(
                                                              context,
                                                              totalCalories,
                                                              adjustedCalorieGoal,
                                                              totalWater,
                                                              waterGoal,
                                                              entries
                                                                  .isNotEmpty,
                                                            );
                                                      },
                                                      child: showGif
                                                          ? Image.asset(
                                                              'assets/mascotte/mascottelangzaam.gif',
                                                              height: 120,
                                                            )
                                                          : Image.asset(
                                                              'assets/mascotte/mascotte1.png',
                                                              height: 120,
                                                            ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Container(
                                              key: _waterCircleKey,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showEditWaterGoalDialog(
                                                      waterGoal,
                                                    ),
                                                child: _buildWaterCircle(
                                                  totalWater,
                                                  waterGoal,
                                                  drinkBreakdown,
                                                  isDarkMode,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                key: _mascotteKey,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 80,
                                                          ),
                                                      child: ValueListenableBuilder<String?>(
                                                        valueListenable:
                                                            _motivationalMessageNotifier,
                                                        builder: (context, message, child) {
                                                          return BubbleSpecialThree(
                                                            text:
                                                                message ??
                                                                AppLocalizations.of(
                                                                  context,
                                                                )!.thinking,
                                                            color: isDarkMode
                                                                ? const Color(
                                                                    0xFF1B97F3,
                                                                  )
                                                                : Colors
                                                                      .blueAccent,
                                                            tail: true,
                                                            isSender: true,
                                                            textStyle:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  StreamBuilder<
                                                    DocumentSnapshot
                                                  >(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(uid)
                                                        .snapshots(),
                                                    builder: (context, userSnapshot) {
                                                      bool showGif = true;
                                                      if (userSnapshot
                                                              .hasData &&
                                                          userSnapshot
                                                              .data!
                                                              .exists) {
                                                        final userData =
                                                            userSnapshot.data!
                                                                    .data()
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >;
                                                        showGif =
                                                            userData['gif'] ==
                                                            true;
                                                      }
                                                      return GestureDetector(
                                                        onTap: () {
                                                          _motivationalMessageNotifier
                                                                  .value =
                                                              _getMotivationalMessage(
                                                                context,
                                                                totalCalories,
                                                                adjustedCalorieGoal,
                                                                totalWater,
                                                                waterGoal,
                                                                entries
                                                                    .isNotEmpty,
                                                              );
                                                        },
                                                        child: showGif
                                                            ? Image.asset(
                                                                'assets/mascotte/mascottelangzaam.gif',
                                                                height: 120,
                                                              )
                                                            : Image.asset(
                                                                'assets/mascotte/mascotte1.png',
                                                                height: 120,
                                                              ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 30),
                                            Flexible(
                                              flex: 1,
                                              child: Container(
                                                key: _waterCircleKey,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _showEditWaterGoalDialog(
                                                        waterGoal,
                                                      ),
                                                  child: _buildWaterCircle(
                                                    totalWater,
                                                    waterGoal,
                                                    drinkBreakdown,
                                                    isDarkMode,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (sportsList.isNotEmpty)
                                  Card(
                                    margin: const EdgeInsets.only(top: 20.0),
                                    color: isDarkMode
                                        ? Colors.grey[850]
                                        : Colors.white,
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                    children: [
                                                    Expanded(
                                                      child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.sports,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                          FontWeight.bold,
                                                        color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                      ),
                                                      softWrap: true,
                                                      maxLines: null,
                                                      overflow: TextOverflow
                                                        .visible,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    // Info knopje naast de titel
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                        const BoxConstraints(),
                                                      icon: Icon(
                                                      Icons.info_outline,
                                                      size: 20,
                                                      color: isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black54,
                                                      ),
                                                      onPressed: () {
                                                      showDialog<void>(
                                                        context: context,
                                                        builder: (context) {
                                                        final loc =
                                                          AppLocalizations.of(
                                                            context,
                                                          )!;
                                                        final infoText =
                                                          includeSportsCalories
                                                            ? loc
                                                              .sportsCaloriesInfoTextOn
                                                            : loc
                                                              .sportsCaloriesInfoTextOff;

                                                        // forceer dialog-theme zodat donkere modus consistent is
                                                        return Theme(
                                                          data: Theme.of(
                                                              context)
                                                            .copyWith(
                                                          dialogBackgroundColor:
                                                            isDarkMode
                                                              ? Colors
                                                                .grey[900]
                                                              : Theme.of(
                                                                  context)
                                                                .dialogBackgroundColor,
                                                          colorScheme:
                                                            isDarkMode
                                                              ? ColorScheme
                                                                .dark()
                                                              : Theme.of(
                                                                  context)
                                                                .colorScheme,
                                                          textTheme: isDarkMode
                                                            ? ThemeData
                                                              .dark()
                                                              .textTheme
                                                            : Theme.of(
                                                                context)
                                                              .textTheme,
                                                          ),
                                                          child: AlertDialog(
                                                          backgroundColor:
                                                            isDarkMode
                                                              ? Colors
                                                                .grey[900]
                                                              : null,
                                                          title: Text(
                                                            loc
                                                              .sportsCaloriesInfoTitle,
                                                            style: TextStyle(
                                                            color: isDarkMode
                                                              ? Colors
                                                                .white
                                                              : Colors
                                                                .black,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            infoText,
                                                            style:
                                                              TextStyle(
                                                            color: isDarkMode
                                                              ? Colors
                                                                .white70
                                                              : Colors
                                                                .black87,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                            style: TextButton
                                                              .styleFrom(
                                                              foregroundColor:
                                                                isDarkMode
                                                                  ? Colors
                                                                    .tealAccent
                                                                  : null,
                                                            ),
                                                            onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              )
                                                                .pop(),
                                                            child: Text(
                                                              AppLocalizations.of(
                                                              context,
                                                              )!
                                                                .ok,
                                                            ),
                                                            ),
                                                          ],
                                                          ),
                                                        );
                                                        },
                                                      );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  '${AppLocalizations.of(context)!.totalBurned} ${totalBurnedCalories.round()} kcal',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  softWrap: true,
                                                  maxLines: null,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 20),
                                          ...sportsList.map(
                                            (sport) => Dismissible(
                                              key: ValueKey(sport['id']),
                                              direction:
                                                  DismissDirection.endToStart,
                                              onDismissed: (direction) {
                                                _deleteSportEntry(sport['id']);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '${_localizedSportLabel(context, (sport['name'] as String?) ?? '')} ${AppLocalizations.of(context)!.deleted}',
                                                    ),
                                                  ),
                                                );
                                              },
                                              background: Container(
                                                color: Colors.red,
                                                alignment:
                                                    Alignment.centerRight,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                    ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _localizedSportLabel(
                                                        context,
                                                        (sport['name']
                                                                as String?) ??
                                                            '',
                                                      ),
                                                      style: TextStyle(
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(sport['calories'] ?? 0.0).toStringAsFixed(0)} kcal',
                                                      style: TextStyle(
                                                        color: isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                ...() {
                                  bool mealKeyAssigned = false;
                                  final widgets = <Widget>[];
                                  final anyNonEmpty = meals.values.any(
                                    (list) => list.isNotEmpty,
                                  );

                                  if (!anyNonEmpty) {
                                    widgets.add(
                                      // onzichtbaar maar aanwezig in de layout
                                      Opacity(
                                        opacity: 0,
                                        child: SizedBox(
                                          key: _mealKey,
                                          width: 300,
                                          height: 100,
                                        ),
                                      ),
                                    );
                                  }

                                  for (final mealEntry in meals.entries) {
                                    Key? currentKey;
                                    if (!mealKeyAssigned &&
                                        mealEntry.value.isNotEmpty) {
                                      currentKey = _mealKey;
                                      mealKeyAssigned = true;
                                    }

                                    if (mealEntry.value.isEmpty) {
                                      continue;
                                    }

                                    widgets.add(
                                      _buildMealSection(
                                        key: currentKey,
                                        title:
                                            mealTitles[mealEntry.key] ??
                                            mealEntry.key,
                                        entries: mealEntry.value,
                                        originalEntriesMap: originalEntriesMap,
                                        isDarkMode: isDarkMode,
                                      ),
                                    );
                                  }

                                  return widgets;
                                }(),
                                const SizedBox(height: 80),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showEditGoalDialog(double currentGoal) async {
    final amountController = TextEditingController(
      text: currentGoal.round().toString(),
    );
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final newGoal = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.calorie_goal_dialog_title,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.calorie_goal_dialog_label,
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return AppLocalizations.of(context)!.enter_valid_number;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(
                    context,
                  ).pop(double.parse(amountController.text));
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (newGoal != null && newGoal != currentGoal) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        _calorieAllowance = newGoal;
      });

      try {
        final userDEK = await getUserDEKFromRemoteConfig(user.uid);
        if (userDEK == null)
          throw Exception(AppLocalizations.of(context)!.dekNotFoundForUser);

        final encryptedGoal = await encryptValue(newGoal.toString(), userDEK);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'calorieGoal': encryptedGoal});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.calorie_goal_updated),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.error_saving_prefix +
                    e.toString(),
              ),
            ),
          );
          // Herstel de oude waarde in de UI bij een fout
          setState(() {
            _calorieAllowance = currentGoal;
          });
        }
      }
    }
  }

  String _getMotivationalMessage(
    BuildContext context,
    double totalCalories,
    double calorieGoal,
    double totalWater,
    double waterGoal,
    bool hasEntries,
  ) {
    final random = Random();

    final defaultMessages = [
      AppLocalizations.of(context)!.motivational_default_1,
      AppLocalizations.of(context)!.motivational_default_2,
      AppLocalizations.of(context)!.motivational_default_3,
      AppLocalizations.of(context)!.motivational_default_4,
      AppLocalizations.of(context)!.motivational_default_5,
      AppLocalizations.of(context)!.motivational_default_6,
    ];

    if (!hasEntries) {
      final messages = [
        AppLocalizations.of(context)!.motivational_noEntries_1,
        AppLocalizations.of(context)!.motivational_noEntries_2,
        AppLocalizations.of(context)!.motivational_noEntries_3,
        AppLocalizations.of(context)!.motivational_noEntries_4,
        AppLocalizations.of(context)!.motivational_noEntries_5,
      ];
      return messages[random.nextInt(messages.length)];
    }

    if (hasEntries && totalCalories == 0) {
      final messages = [
        AppLocalizations.of(context)!.motivational_drinksOnly_1,
        AppLocalizations.of(context)!.motivational_drinksOnly_2,
        AppLocalizations.of(context)!.motivational_drinksOnly_3,
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories > calorieGoal) {
      final messages = [
        AppLocalizations.of(context)!.motivational_overGoal_1,
        AppLocalizations.of(context)!.motivational_overGoal_2,
        AppLocalizations.of(context)!.motivational_overGoal_3,
        AppLocalizations.of(context)!.motivational_overGoal_4,
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories > calorieGoal * 0.8) {
      final messages = [
        AppLocalizations.of(context)!.motivational_almostGoal_1,
        AppLocalizations.of(context)!.motivational_almostGoal_2,
        AppLocalizations.of(context)!.motivational_almostGoal_3,
        AppLocalizations.of(context)!.motivational_almostGoal_4,
        AppLocalizations.of(context)!.motivational_almostGoal_5,
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories < calorieGoal * 0.5) {
      final messages = [
        AppLocalizations.of(context)!.motivational_belowHalf_1,
        AppLocalizations.of(context)!.motivational_belowHalf_3,
        AppLocalizations.of(context)!.motivational_belowHalf_4,
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (waterGoal > 0 && totalWater < waterGoal / 3) {
      final messages = [
        AppLocalizations.of(context)!.motivational_lowWater_1,
        AppLocalizations.of(context)!.motivational_lowWater_2,
        AppLocalizations.of(context)!.motivational_lowWater_3,
        AppLocalizations.of(context)!.motivational_lowWater_4,
        AppLocalizations.of(context)!.motivational_lowWater_5,
        AppLocalizations.of(context)!.motivational_lowWater_6,
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    return defaultMessages[random.nextInt(defaultMessages.length)];
  }

  Widget _buildWaterCircle(
    // bouwt de waterinname cirkel
    double consumed,
    double goal,
    Map<String, double> breakdown,
    bool isDarkMode,
  ) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return TweenAnimationBuilder<double>(
      // animeert de voortgang
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 750),
      builder: (context, value, child) {
        final sortedBreakdown = breakdown.entries.toList()
          ..sort(
            (a, b) => a.key.compareTo(b.key),
          ); // Sorteer de breakdown op naam

        final bool overGoal = goal > 0 && consumed > goal;
        final bool severelyOver = goal > 0 && consumed > goal * 2;
        final warningColor = severelyOver
            ? Colors.redAccent
            : (isDarkMode ? Colors.orangeAccent : Colors.orange);
        final loc = AppLocalizations.of(context)!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cirkel
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: SegmentedArcPainter(
                  progress: value,
                  goal: goal,
                  breakdown: sortedBreakdown,
                  isDarkMode: isDarkMode,
                  strokeWidth: 8,
                  loc: loc,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                        size: 24,
                      ),
                      Text(
                        '${(consumed * value / (progress.isFinite && progress > 0 ? progress : 1.0)).round()} ml',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Waarschuwing onder de cirkel wanneer boven doel
            if (overGoal)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: warningColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: warningColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.waterWarningSevere,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Doel onderaan, altijd zichtbaar
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.goal}: ${goal.round()} ml',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroCircle(
    // bouwt cirkel voor macro
    String title,
    double consumed,
    double goal,
    bool isDarkMode,
    Color color,
  ) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    //final percentage = (progress * 100).round();

    return TweenAnimationBuilder<double>(
      // animeert de voortgang
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 750),
      builder: (context, value, child) {
        return Column(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    backgroundColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Center(
                    child: Text(
                      '${(value * 100).round()}%', // Animeeert percentage tekst
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${consumed.round()}/${goal.round()}g',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalorieInfo(
    // maakt de calorie-informatie sectie
    String title,
    double value,
    bool isDarkMode, {
    bool isRemaining = false,
  }) {
    final defaultColor = isDarkMode ? Colors.white : Colors.black;
    final labelStyle = TextStyle(
      fontSize: 14,
      color: isDarkMode ? Colors.white70 : Colors.black87,
    );

    if (title == AppLocalizations.of(context)!.goal) {
      return GestureDetector(
        onTap: () => _showEditGoalDialog(value),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: labelStyle),
            const SizedBox(height: 4),
            Text(
              '${value.round()}', // toon het doel afgerond
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: defaultColor,
              ),
            ),
          ],
        ),
      );
    }

    String topText;
    String bottomText;
    Color valueColor = defaultColor;
    double displayValue = value;

    if (isRemaining) {
      // als er nog calorieen over zijn
      if (value < 0) {
        topText = AppLocalizations.of(context)!.over_goal;
        bottomText = AppLocalizations.of(context)!.calories_over_goal;
        displayValue = value.abs(); // maak positief voor weergave
        valueColor = Colors.red;
      } else {
        topText = AppLocalizations.of(context)!.youHave;
        bottomText = AppLocalizations.of(context)!.calories_remaining;
      }
    } else {
      topText = AppLocalizations.of(context)!.youHave;
      bottomText = AppLocalizations.of(context)!.calories_consumed;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(topText, style: labelStyle),
        Text(
          '${displayValue.round()}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(bottomText, style: labelStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildMealSection({
    // bouwt een maaltijdsectie
    Key? key,
    required String title,
    required List<dynamic> entries,
    required Map<dynamic, dynamic> originalEntriesMap,
    required bool isDarkMode,
    List<Map<String, dynamic>>? sports,
  }) {
    double totalMealCalories = 0;
    for (var entry in entries) {
      if (entry.containsKey('quantity')) {
        // Drankje: gebruik kcal uit het veld 'kcal'
        final kcal = double.tryParse(entry['kcal']?.toString() ?? '0') ?? 0.0;
        totalMealCalories += kcal;
      } else {
        // Voedsel: gebruik kcal uit nutrients
        totalMealCalories += (entry['nutrients']?['energy-kcal'] ?? 0.0);
      }
    }

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // uitlijning naar links
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // titel en totaal kcal
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '${totalMealCalories.round()} kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (sports != null && sports.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.sports,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              ...sports.map(
                (sport) => ListTile(
                  leading: const Icon(Icons.fitness_center, size: 24),
                  title: Text(
                    _localizedSportLabel(
                      context,
                      (sport['name'] as String?) ?? '',
                    ),
                  ),
                  trailing: Text(
                    '-${(sport['calories'] ?? 0.0).toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 73, 244, 54),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
              const Divider(height: 20),
            ],
            ...entries.asMap().entries.map((entryPair) {
              final i = entryPair.key;
              final entry = entryPair.value;

              final originalEncryptedEntry = originalEntriesMap[entry];

              // bouwt elke log entry
              //final productName = entry['product_name'] ?? 'Onbekend';
              //final calories = (entry['nutriments']?['energy-kcal'] ?? 0.0)
              //  .round();
              //             final timestamp = entry['timestamp'] as Timestamp?;
              final productName = entry['product_name'] ?? 'Onbekend';
              final timestamp = entry['timestamp'] as Timestamp?;

              String rightSideText;

              if (entry.containsKey('quantity')) {
                // Als het drinken is, toon ml EN kcal
                final quantityValue =
                    entry['quantity']?.toString().replaceAll(
                      RegExp(r'[^0-9.]'),
                      '',
                    ) ??
                    '0';
                final amount = double.tryParse(quantityValue) ?? 0.0;
                final kcalRaw = entry['kcal'];
                final kcalNumber = kcalRaw is num
                    ? kcalRaw.toDouble()
                    : double.tryParse(kcalRaw?.toString() ?? '') ?? 0.0;
                final kcalValue = kcalNumber.round().toString();

                rightSideText = '${amount.round()} ml | ${kcalValue} kcal';
              } else {
                final calories = (entry['nutrients']?['energy-kcal'] ?? 0.0)
                    .round();
                rightSideText = '$calories kcal';
              }

              return Dismissible(
                // veeg om te verwijderen
                key: Key(
                  'entry-${timestamp?.millisecondsSinceEpoch ?? 'noTs'}-$i',
                ),

                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Gebruik het originele versleutelde entry object voor arrayRemove
                  _deleteLogEntry(originalEncryptedEntry);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$productName ${AppLocalizations.of(context)!.deleted}',
                      ),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: InkWell(
                  onTap: () {
                    _showEditAmountDialog(entry, originalEncryptedEntry);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis, // voorkom overflow
                          ),
                        ),
                        Text(
                          rightSideText,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
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

  Future<void> _deleteSportEntry(String sportId) async {
    // verwijdert een sport entry uit Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sports')
          .doc(sportId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorDeletingSport} $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteLogEntry(Map<String, dynamic> entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final date = _selectedDate;
    final docId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(docId);

    // Normaliseer helper
    dynamic _normalize(dynamic v) {
      if (v is Map) {
        final map = <String, dynamic>{};
        v.forEach((k, val) => map[k] = _normalize(val));
        return map;
      }
      if (v is List) return v.map(_normalize).toList();
      if (v is Timestamp) return v.millisecondsSinceEpoch;
      if (v is DateTime) return v.millisecondsSinceEpoch;
      return v;
    }

    final targetNormalized = _normalize(entry);

    try {
      // Log current doc state for debugging
      final snap = await docRef.get();
      debugPrint("[DELETE_LOG] Doc exists: ${snap.exists}");
      if (snap.exists) {
        final data = snap.data()!;
        final currentEntries = List.from(
          data['entries'] as List<dynamic>? ?? [],
        );
        for (var i = 0; i < currentEntries.length; i++) {
          if (i >= 5) break;
        }
      } else {}

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final doc = await tx.get(docRef);
        if (!doc.exists) {
          return;
        }

        final data = doc.data()!;
        final entries = List.from(data['entries'] as List<dynamic>? ?? []);

        int? foundIndex;
        final eq = const DeepCollectionEquality();

        for (var i = 0; i < entries.length; i++) {
          final candidateNorm = _normalize(entries[i]);
          if (eq.equals(candidateNorm, targetNormalized)) {
            foundIndex = i;
            break;
          }
        }

        // heuristiek: match op timestamp if exact match failed
        if (foundIndex == null) {
          final targetTs = targetNormalized['timestamp'];
          if (targetTs != null) {
            for (var i = 0; i < entries.length; i++) {
              try {
                final cand = entries[i] as Map<String, dynamic>;
                final candTs = cand['timestamp'] is Timestamp
                    ? (cand['timestamp'] as Timestamp).millisecondsSinceEpoch
                    : cand['timestamp'] is DateTime
                    ? (cand['timestamp'] as DateTime).millisecondsSinceEpoch
                    : cand['timestamp'];
                if (candTs != null && candTs == targetTs) {
                  foundIndex = i;
                  break;
                }
              } catch (e) {
                // ignore
              }
            }
          }
        }

        if (foundIndex == null) {
          return;
        }

        entries.removeAt(foundIndex);
        if (entries.isEmpty) {
          tx.delete(docRef);
        } else {
          tx.update(docRef, {'entries': entries});
        }
      });
    } catch (e, s) {
      debugPrint("[DELETE_LOG] Error deleting entry: $e");
      debugPrint("[DELETE_LOG] Stack: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorDeleting} $e'),
          ),
        );
      }
    }
  }

  Future<void> _showEditAmountDialog(
    Map<String, dynamic> decryptedEntry,
    Map<String, dynamic> encryptedEntry,
  ) async {
    // toont dialoog om hoeveelheid aan te passen (ondersteunt g en ml)
    final isDrink = decryptedEntry.containsKey('quantity');
    double initialAmount = 100;
    String initialUnit = 'g';

    if (isDrink) {
      final qty = (decryptedEntry['quantity'] as String?) ?? '100 ml';
      final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(qty);
      if (match != null) {
        initialAmount =
            double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 100;
      }
      if (qty.toLowerCase().contains('ml'))
        initialUnit = 'ml';
      else if (qty.toLowerCase().contains('g'))
        initialUnit = 'g';
    } else {
      initialAmount = (decryptedEntry['amount_g'] as num?)?.toDouble() ?? 100.0;
      initialUnit = 'g';
    }

    final amountController = TextEditingController(
      text: initialAmount.toString(),
    );
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String unit = initialUnit;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isDrink
                    ? AppLocalizations.of(context)!.edit_amount_dialog_title_ml
                    : AppLocalizations.of(context)!.edit_amount_dialog_title_g,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: isDrink
                            ? AppLocalizations.of(context)!.edit_amount_label_ml
                            : AppLocalizations.of(context)!.edit_amount_label_g,
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white12 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white30 : Colors.black26,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value.replaceAll(',', '.')) ==
                                null ||
                            double.parse(value.replaceAll(',', '.')) <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.enter_valid_number;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Eenheid selectie - drinks default naar ml maar gebruiker kan wisselen
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.unit,
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white12 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white12 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isDrink ? 'Milliliter (ml)' : 'Gram (g)',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newAmount = double.parse(
                      amountController.text.replaceAll(',', '.'),
                    );
                    await _updateEntryAmount(
                      decryptedEntry,
                      encryptedEntry,
                      newAmount,
                      unit: unit,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateEntryAmount(
    Map<String, dynamic> decryptedEntry,
    Map<String, dynamic> encryptedEntry,
    double newAmount, {
    String unit = 'g',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = _selectedDate;
    final docId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(docId);

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dekNotFoundForUser),
          ),
        );
      }
      return;
    }

    try {
      if (decryptedEntry.containsKey('quantity')) {
        // Drink: parse origineel amount & kcal en schaal beide
        final qtyString = decryptedEntry['quantity'] as String? ?? '100 ml';
        final origMatch = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(qtyString);
        final origAmount = origMatch != null
            ? double.tryParse(origMatch.group(1)!.replaceAll(',', '.')) ?? 0
            : 0;
        final origKcal =
            double.tryParse((decryptedEntry['kcal'] ?? '0').toString()) ?? 0.0;

        // bereken factor en nieuwe kcal
        final factor = (origAmount > 0) ? (newAmount / origAmount) : 1.0;
        final newKcal = origKcal * factor;

        // bouw nieuw versleuteld entry (kopieer en overschrijf velden)
        final updatedEntry = Map<String, dynamic>.from(encryptedEntry);
        updatedEntry['quantity'] = await encryptValue(
          '${newAmount.round()} $unit',
          userDEK,
        );
        updatedEntry['kcal'] = await encryptDouble(newKcal, userDEK);

        // update in firestore: verwijder oude en voeg nieuwe toe (atomiciteit via transaction eventueel)
        await docRef.update({
          'entries': FieldValue.arrayRemove([encryptedEntry]),
        });
        await docRef.update({
          'entries': FieldValue.arrayUnion([updatedEntry]),
        });
      } else {
        // Food: herbereken amount_g en nutriments proportioneel
        final originalAmount = decryptedEntry['amount_g'] as num?;
        final originalNutriments =
            decryptedEntry['nutrients'] as Map<String, dynamic>?;

        if (originalAmount == null ||
            originalAmount <= 0 ||
            originalNutriments == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.errorCalculating),
              ),
            );
          }
          return;
        }

        final factor = newAmount / originalAmount.toDouble();

        final newNutriments = <String, dynamic>{};
        for (final key in originalNutriments.keys) {
          final value = originalNutriments[key];
          final newValue = (value is num ? value * factor : value);
          newNutriments[key] = await encryptDouble(newValue ?? 0, userDEK);
        }
        final encryptedAmount = await encryptDouble(newAmount, userDEK);

        final updatedEntry = {
          ...encryptedEntry,
          'amount_g': encryptedAmount,
          'nutrients': newNutriments,
        };

        await docRef.update({
          'entries': FieldValue.arrayRemove([encryptedEntry]),
        });
        await docRef.update({
          'entries': FieldValue.arrayUnion([updatedEntry]),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.entry_updated)),
        );
      }
    } catch (e) {
      debugPrint("[UPDATE_ENTRY] Fout bij bijwerken: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorUpdatingEntry} $e',
            ),
          ),
        );
      }
    }
  }
}

class SegmentedArcPainter extends CustomPainter {
  // aangepaste kleuren voor segmenten in de cirkel
  final double progress;
  final double goal;
  final List<MapEntry<String, double>> breakdown;
  final bool isDarkMode;
  final double strokeWidth; // dikte van de cirkel
  final AppLocalizations loc;
  SegmentedArcPainter({
    required this.progress,
    required this.goal,
    required this.breakdown,
    required this.isDarkMode,
    required this.strokeWidth,
    required this.loc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // tekent de cirkel
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width - strokeWidth) / 2; // radius rekening houdend met dikte
    const startAngle = -90 * (3.1415926535 / 180); // start bovenaan

    // Achtergrond cirkel
    final backgroundPaint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    double currentAngle = startAngle;

    for (final entry in breakdown) {
      // teken elk stukjee
      final sweepAngle =
          (entry.value / goal) * 2 * 3.1415926535; // hoek voor dit stukje
      final color = _getColorsForDrink(entry.key, isDarkMode)['background']!;

      final segmentPaint = Paint()
        ..color =
            color // kleur voor dit stukje
        ..style = PaintingStyle
            .stroke // stijl voor cirkel
        ..strokeWidth =
            strokeWidth // dikte van de cirkel
        ..strokeCap = StrokeCap.round; // afgeronde uiteinden

      final totalSweep =
          progress * 2 * 3.1415926535; // totale hoek om te tekenen
      final angleToDraw = currentAngle - startAngle; // huidige hoek

      if (angleToDraw < totalSweep) {
        // alleen tekenen binnen de voortgang
        double sweepToDraw = sweepAngle;
        if (angleToDraw + sweepAngle > totalSweep) {
          sweepToDraw = totalSweep - angleToDraw;
        } // teken het segment
        canvas.drawArc(
          // teken het segment
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          sweepToDraw,
          false,
          segmentPaint,
        );
      }
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // altijd opnieuw schilderen bij verandering
    return true;
  }

  Map<String, Color> _getColorsForDrink(String name, bool isDarkMode) {
    // bepaalt kleuren op basis van dranknaam
    final lowerCaseName = name.toLowerCase();
    if ([
      loc.water,
      'water',
    ].any((s) => lowerCaseName.contains(s.toLowerCase()))) {
      return isDarkMode
          ? {'background': Colors.blue[700]!, 'foreground': Colors.blue[200]!}
          : {'background': Colors.blue[400]!, 'foreground': Colors.blue[800]!};
    }
    if ([
      loc.coffee,
      loc.icedCoffee,
      loc.latteMacchiato,
      loc.macchiato,
      loc.flatWhite,
      loc.latte,
      loc.cappuccino,
      loc.coffeeWithMilkSugar,
      loc.coffeeBlack,
      loc.espresso,
      loc.ristretto,
      loc.lungo,
      loc.americano,
      loc.coffeeWithMilk,
      'koffie',
      'coffee',
    ].any((s) => lowerCaseName.contains(s.toLowerCase()))) {
      return isDarkMode
          ? {'background': Colors.brown[600]!, 'foreground': Colors.brown[100]!}
          : {
              'background': Colors.brown[400]!,
              'foreground': Colors.brown[800]!,
            };
    }
    if ([
      loc.tea,
      'thee',
      'tea',
    ].any((s) => lowerCaseName.contains(s.toLowerCase()))) {
      return isDarkMode
          ? {'background': Colors.amber[800]!, 'foreground': Colors.amber[200]!}
          : {
              'background': Colors.amber[500]!,
              'foreground': Colors.amber[800]!,
            };
    }
    if ([
      loc.soda,
      'fris',
      'soda',
      'cola',
    ].any((s) => lowerCaseName.contains(s.toLowerCase()))) {
      return isDarkMode
          ? {'background': Colors.red[800]!, 'foreground': Colors.red[200]!}
          : {'background': Colors.red[400]!, 'foreground': Colors.red[800]!};
    }
    return isDarkMode
        ? {'background': Colors.green[600]!, 'foreground': Colors.white}
        : {'background': Colors.green[400]!, 'foreground': Colors.black};
  }
}
