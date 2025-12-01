import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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

//homescreen is een statefulwidget omdat de inhoud verandert
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //variabelen om de status van het scherm bij te houden
  Product? _scannedProduct; //het gevonden product
  bool _isLoading = false; // of hi jaan het laden is
  String? _errorMessage; // eventuele foutmelding
  String? _motivationalMessage;
  int _selectedIndex = 0;

  Map<String, dynamic>? _userData;
  double? _calorieAllowance;
  DateTime _selectedDate = DateTime.now();

  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _calorieInfoRowKey = GlobalKey();
  final GlobalKey _barcodeKey = GlobalKey();
  final GlobalKey _waterCircleKey = GlobalKey();
  final GlobalKey _addFabKey = GlobalKey();
  final GlobalKey _mascotteKey = GlobalKey();
  final GlobalKey _mealKey = GlobalKey();
  final GlobalKey _recipesKey = GlobalKey();
  final GlobalKey _feedbackKey = GlobalKey();
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
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createTutorial();
    _showTutorial();
  }

  @override
  void dispose() {
    _pageController
        .dispose(); // de controller opruimen bij het verwijderen van de widget
    super.dispose();
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
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          tutorialCoachMark.show(context: context);
        }
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
      hideSkip: true,
      onFinish: () {
        print("Tutorial voltooid");
        prefs.setBool('home_tutorial_shown', true);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'tutorialHomeAf': true,
          });
        }
      },
      onClickTarget: (target) {
        print('Target geklikt: $target');
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
              'Datum wisselen',
              'Tik hier om naar een andere dag te gaan.',
              isDarkMode,
            ),
          ),
        ],
      ),
    );

    //Receptenkiezer
    targets.add(
      TargetFocus(
        identify: "recipes-key",
        keyTarget: _recipesKey,

        shape: ShapeLightFocus.RRect,
        color: Colors.blue,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              'Recepten',
              'Tik hier om naar recepten te zoeken.',
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
              'Barcode scannen',
              'Tik hier om een product te scannen en snel toe te voegen aan je dag.',
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
              'Feedback geven',
              'Hier kan je feedback geven over de app. Werkt er iets niet of iets wat je graag nog wilt zien in de app? We horen graag van je!',
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
              'Calorieën overzicht',
              'Hier zie je een samenvatting van je calorie-inname voor de dag.',
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
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              'Reppy', //TODO: verander titel
              'Reppy geeft persoonlijke motivatie en tips!', //TODO: verander tekst
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
              'Drinken',
              'Houd hier bij hoeveel je per dag drinkt. De cirkel laat ziet hoeveel je nog moet drinken om je doel te bereiken.',
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
              'Items toevoegen',
              'Gebruik deze knop om snel een maaltijd of drankje aan je dag toe te voegen.',
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
              'Logs', //TODO: verander titel
              'Hier verschijnen al het voedsel en alle drankjes die je toevoegt.',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Vandaag';
    } else if (selected == yesterday) {
      return 'Gisteren';
    } else {
      return '${date.day}-${date.month}-${date.year}';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
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
                child: const Text('Vandaag'),
                onPressed: () {
                  setState(() {
                    _selectedDate = todayWithoutTime;
                    _pageController.jumpToPage(_initialPage);
                  });
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: const Text('Klaar'),
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
                    child: const Text('Vandaag'),
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
    // haalt de gebruikersgegevens op uit Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _userData = doc.data();
        _calorieAllowance = _calculateCalories(_userData!);
      });
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
        'Weinig actief: je zit veel, weinig beweging per dag';

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

  @override
  Widget build(BuildContext context) {
    // Check of we op iOS zitten
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildIOSLayout();
    }
    // Anders (Android/Web) de standaard layout
    return _buildAndroidLayout();
  }

  // iOS layout
  Widget _buildIOSLayout() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return CupertinoTabScaffold(
      // Tab scaffold voor iOS stijl tabs
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Vandaag',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Instellingen',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // bouwt de inhoud voor elke tab
        if (index == 0) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                key: _recipesKey,
                child: const Text(
                  'Recepten',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RecipesScreen(),
                    ),
                  );
                },
              ),
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
                      Text(_formatDate(_selectedDate)),
                      const SizedBox(width: 8),
                      const Icon(CupertinoIcons.calendar, size: 22),
                    ],
                  ),
                ),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                key: _barcodeKey,
                child: const Icon(CupertinoIcons.barcode_viewfinder, size: 32),
                onPressed: _scanBarcode,
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
        } else {
          // Tab 2: Instellingen
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              //middle: Text('Instellingen'),
            ),
            child: const SettingsScreen(),
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
      // Home-tab
      body = Stack(
        children: [
          _buildHomeContent(),
          Positioned(
            right: 16,
            bottom: 120,
            key: _feedbackKey,
            child: const FeedbackButton(),
          ),
        ],
      );
      fab = _buildSpeedDial();
    } else {
      // Recepten-tab
      body = const RecipesScreen();
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
                      Text(_formatDate(_selectedDate)),
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
          : AppBar(title: const Text('Recepten'), centerTitle: true),
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Logs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recepten',
            key: _recipesKey,
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
          label: 'Voedsel',
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            // actie bij tikken
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddFoodPage()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_drink),
          label: 'Drinken',
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddDrinkPage()),
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

    // hij opent de barcode scanner en wacht totdat hij klaar is
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    // als er een geldige barcode is gescand en niet -1
    if (res is String && res != '-1') {
      final barcode = res;
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
            // Product gevonden in recents, gebruik die data
            productData = docSnapshot.data() as Map<String, dynamic>;
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _errorMessage = "Fout bij ophalen recente producten: $e";
            });
          }
        }
      }

      if (mounted) {
        // Controleer of de widget nog bestaat
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddFoodPage(
              scannedBarcode: barcode,
              initialProductData: productData,
            ),
          ),
        );
      }
    }

    // Verberg laadindicator
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHomeContent() {
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
    if (user == null) return const Center(child: Text("Niet ingelogd."));

    final docId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDailyLog(
          user.uid,
          docId,
          isDarkMode,
        ), // bouwt de dagelijkse log
      ),
    );
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
        final entries = data?['entries'] as List<dynamic>? ?? [];

        double totalCalories = 0;
        double totalProteins = 0;
        double totalFats = 0;
        double totalCarbs = 0;

        final Map<String, List<dynamic>> meals = {
          // Maaltijdcategorieën
          'Ontbijt': [],
          'Lunch': [],
          'Avondeten': [],
          'Tussendoor': [],
        };

        for (var entry in entries) {
          // berekent de totale macro's en verdeelt de maaltijden
          totalCalories += (entry['nutriments']?['energy-kcal'] ?? 0.0);
          totalProteins += (entry['nutriments']?['proteins'] ?? 0.0);
          totalFats += (entry['nutriments']?['fat'] ?? 0.0);
          totalCarbs += (entry['nutriments']?['carbohydrates'] ?? 0.0);
          final mealType = entry['meal_type'] as String?;

          if (mealType != null && meals.containsKey(mealType)) {
            //als maaltijdtype bekend is
            meals[mealType]!.add(entry);
          } else {
            // Fallback
            final timestamp =
                (entry['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final hour = timestamp.hour;
            if (hour >= 5 && hour < 11) {
              meals['Ontbijt']!.add(entry);
            } else if (hour >= 11 && hour < 15) {
              meals['Lunch']!.add(entry);
            } else if (hour >= 15 && hour < 22) {
              meals['Avondeten']!.add(entry);
            } else {
              meals['Tussendoor']!.add(entry);
            }
          }
        }

        final calorieGoal = _calorieAllowance ?? 0.0;
        final proteinGoal = _userData?['proteinGoal'] as num? ?? 0.0;
        final fatGoal = _userData?['fatGoal'] as num? ?? 0.0;
        final carbGoal = _userData?['carbGoal'] as num? ?? 0.0;

        final remainingCalories = calorieGoal - totalCalories;
        final progress = calorieGoal > 0
            ? (totalCalories / calorieGoal).clamp(0.0, 1.0)
            : 0.0;

        final Map<String, double> drinkBreakdown = {}; // voor waterinname
        double totalWater = 0;
        for (var entry in entries) {
          if (entry['meal_type'] == 'Drinken') {
            final quantityString = entry['quantity'] as String? ?? '0 ml';
            final amount =
                double.tryParse(quantityString.replaceAll(' ml', '')) ?? 0.0;
            final drinkName = entry['product_name'] as String? ?? 'Onbekend';
            drinkBreakdown.update(
              // waterinname per drankje bijhouden
              drinkName,
              (value) => value + amount, // optellen als al aanwezig
              ifAbsent: () => amount, // nieuw drankje toevoegen
            );
            totalWater += amount;
          }
        }
        final weight = _userData?['weight'] as num? ?? 70;
        final waterGoal = weight * 32.5;

        final motivationalMessage = _getMotivationalMessage(
          totalCalories,
          calorieGoal,
          totalWater,
          waterGoal,
          entries.isNotEmpty,
        );

        if (_motivationalMessage == null) {
          _motivationalMessage = motivationalMessage;
        }

        return Column(
          children: [
            Card(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      key: _calorieInfoRowKey,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Calorie-informatie
                        _buildCalorieInfo('Gegeten', totalCalories, isDarkMode),
                        _buildCalorieInfo('Doel', calorieGoal, isDarkMode),
                        _buildCalorieInfo(
                          'Over',
                          remainingCalories,
                          isDarkMode,
                          isRemaining: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      // Calorie voortgangsbalk
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        // kleur op basis van voortgang
                        progress > 1.0
                            ? Colors.red
                            : (isDarkMode ? Colors.green[300]! : Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      // Macro-cirkels
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroCircle(
                          'Koolhydraten',
                          totalCarbs,
                          carbGoal.toDouble(),
                          isDarkMode,
                          Colors.orange,
                        ),
                        _buildMacroCircle(
                          'Eiwitten',
                          totalProteins,
                          proteinGoal.toDouble(),
                          isDarkMode,
                          const Color.fromARGB(255, 0, 140, 255),
                        ),
                        _buildMacroCircle(
                          'Vetten',
                          totalFats,
                          fatGoal.toDouble(),
                          isDarkMode,
                          const Color.fromARGB(255, 0, 213, 255),
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
                  if (constraints.maxWidth < 400) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          key: _mascotteKey,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 80),
                                child: BubbleSpecialThree(
                                  text:
                                      _motivationalMessage ??
                                      motivationalMessage,
                                  color: isDarkMode
                                      ? const Color(0xFF1B97F3)
                                      : Colors.blueAccent,
                                  tail: true,
                                  isSender: true,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _motivationalMessage =
                                      _getMotivationalMessage(
                                        totalCalories,
                                        calorieGoal,
                                        totalWater,
                                        waterGoal,
                                        entries.isNotEmpty,
                                      );
                                });
                              },
                              child: Image.asset(
                                'assets/mascotte/mascottelangzaam.gif',
                                height: 120,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          key: _waterCircleKey,
                          child: _buildWaterCircle(
                            totalWater,
                            waterGoal.toDouble(),
                            drinkBreakdown,
                            isDarkMode,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            key: _mascotteKey,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  child: BubbleSpecialThree(
                                    text:
                                        _motivationalMessage ??
                                        motivationalMessage,
                                    color: isDarkMode
                                        ? const Color(0xFF1B97F3)
                                        : Colors.blueAccent,
                                    tail: true,
                                    isSender: true,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _motivationalMessage =
                                        _getMotivationalMessage(
                                          totalCalories,
                                          calorieGoal,
                                          totalWater,
                                          waterGoal,
                                          entries.isNotEmpty,
                                        );
                                  });
                                },
                                child: Image.asset(
                                  'assets/mascotte/mascottelangzaam.gif',
                                  height: 120,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Flexible(
                          flex: 1,
                          child: Container(
                            key: _waterCircleKey,
                            child: _buildWaterCircle(
                              totalWater,
                              waterGoal.toDouble(),
                              drinkBreakdown,
                              isDarkMode,
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
            ...() {
              bool mealKeyAssigned = false;
              return meals.entries.map((mealEntry) {
                Key? currentKey;
                if (!mealKeyAssigned) {
                  currentKey = _mealKey;
                  mealKeyAssigned = true;
                }

                // Maak de sectie onzichtbaar als hij leeg is
                if (mealEntry.value.isEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: Offstage(
                      offstage: true,
                      child: _buildMealSection(
                        key: currentKey,
                        title: mealEntry.key,
                        entries: const [],
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  );
                }

                return _buildMealSection(
                  key: currentKey, // Geef de sleutel hier door
                  title: mealEntry.key,
                  entries: mealEntry.value,
                  isDarkMode: isDarkMode,
                );
              }).toList();
            }(),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  String _getMotivationalMessage(
    double totalCalories,
    double calorieGoal,
    double totalWater,
    double waterGoal,
    bool hasEntries,
  ) {
    final random = Random();

    const defaultMessages = [
      'Goed bezig, ga zo door!',
      'Elke stap telt!',
      'Je doet het geweldig!',
      'Wist je dat fFinder een afkorting is voor FoodFinder?',
      'Je logt beter dan 97% van de mensen... waarschijnlijk.',
    ];

    if (!hasEntries) {
      const messages = [
        'Klaar om je dag te loggen?',
        'Een nieuwe dag, nieuwe kansen!',
        'Laten we beginnen!',
        'Elke gezonde dag start met één invoer.',
        'Je eerste maaltijd zit verstopt. Zoek hem even op!',
      ];
      return messages[random.nextInt(messages.length)];
    }

    if (hasEntries && totalCalories == 0) {
      const messages = [
        'Goed dat je al drinken hebt gelogd! Wat wordt je eerste maaltijd?',
        'Hydratatie is een goed begin. Tijd om ook wat te eten.',
        'Lekker bezig! Wat wordt je eerste hapje?',
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories > calorieGoal) {
      const messages = [
        'Doel bereikt! Rustig aan nu.',
        'Wow, je zit boven je doel!',
        'Goed bezig, morgen weer een dag.',
        'Goed bezig vandaag, echt waar!',
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories > calorieGoal * 0.8) {
      const messages = [
        'Je bent er bijna!',
        'Nog een klein stukje te gaan!',
        'Bijna je caloriedoel bereikt!',
        'Goed bezig! Let op de laatste stap.',
        'Je doet het fantastisch, bijna daar!',
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (calorieGoal > 0 && totalCalories < calorieGoal * 0.5) {
      const messages = [
        'Je bent goed op weg, ga zo door!',
        'De eerste helft zit erop, houd de focus!',
        'Blijf je maaltijden en drankjes loggen.',
        'Je doet het geweldig, blijf volhouden!',
      ];
      final allMessages = [...messages, ...defaultMessages];
      return allMessages[random.nextInt(allMessages.length)];
    }

    if (waterGoal > 0 && totalWater < waterGoal / 3) {
      const messages = [
        'Vergeet niet te drinken vandaag!',
        'Een slokje water is een goed begin.',
        'Warm of koud, water is altijd goed!',
        'Hydrateren is belangrijk!',
        'Een glas water kan wonderen doen.',
        'Even pauze? Drink een beetje water.',
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

        return Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: SegmentedArcPainter(
                  // aangepaste kleur voor soorten
                  progress: value,
                  goal: goal,
                  breakdown: sortedBreakdown,
                  isDarkMode: isDarkMode,
                  strokeWidth: 8,
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
                        '${(consumed * value / (progress.isFinite && progress > 0 ? progress : 1.0)).round()} ml', // Animeer de hoeveelheid water
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
            Text(
              'Doel: ${goal.round()} ml', // Toon doel
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
    final percentage = (progress * 100).round();

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

    if (title == 'Doel') {
      return Column(
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
      );
    }

    String topText;
    String bottomText;
    Color valueColor = defaultColor;
    double displayValue = value;

    if (isRemaining) {
      // als er nog calorieen over zijn
      if (value < 0) {
        topText = 'Je bent';
        bottomText = 'calorieën over je doel';
        displayValue = value.abs(); // maak positief voor weergave
        valueColor = Colors.red;
      } else {
        topText = 'Je hebt nog';
        bottomText = 'calorieën over';
      }
    } else {
      topText = 'Je hebt';
      bottomText = 'calorieën gegeten';
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
        Text(bottomText, style: labelStyle),
      ],
    );
  }

  Widget _buildMealSection({
    // bouwt een maaltijdsectie
    Key? key,
    required String title,
    required List<dynamic> entries,
    required bool isDarkMode,
  }) {
    double totalMealCalories = 0;
    for (var entry in entries) {
      // berekent de totale calorieën voor de maaltijd
      totalMealCalories += (entry['nutriments']?['energy-kcal'] ?? 0.0);
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
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...entries.map((entry) {
              // bouwt elke log entry
              final productName = entry['product_name'] ?? 'Onbekend';
              final calories = (entry['nutriments']?['energy-kcal'] ?? 0.0)
                  .round();
              final timestamp = entry['timestamp'] as Timestamp?;

              String rightSideText;

              if (entry['meal_type'] == 'Drinken') {
                // Als het drinken is, toon ml anders kcal
                rightSideText = entry['quantity'] as String? ?? '0 ml';
              } else {
                final calories = (entry['nutriments']?['energy-kcal'] ?? 0.0)
                    .round();
                rightSideText = '$calories kcal';
              }

              return Dismissible(
                // veeg om te verwijderen
                key: Key(timestamp?.toString() ?? UniqueKey().toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteLogEntry(entry);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$productName verwijderd')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ), // ruimte aan de zijkant
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: InkWell(
                  // tik om hoeveelheid aan te passen
                  onTap: () {
                    _showEditAmountDialog(entry);
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

  Future<void> _deleteLogEntry(Map<String, dynamic> entry) async {
    // verwijdert een log entry uit Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = _selectedDate;
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(todayDocId);

    try {
      await docRef.update({
        'entries': FieldValue.arrayRemove([entry]),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fout bij verwijderen: $e')));
      }
    }
  }

  Future<void> _showEditAmountDialog(Map<String, dynamic> entry) async {
    // toont dialoog om hoeveelheid aan te passen
    final amountController = TextEditingController(
      text: (entry['amount_g'] ?? '100').toString(),
    ); // standaard 100gof ml
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final newAmount = await showDialog<double>(
      // toont dialoog en wacht op hoeveelheid
      context: context,
      builder: (context) {
        // bouwt dialoog
        return AlertDialog(
          title: Text(
            'Hoeveelheid aanpassen (gram of mililiter)',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Form(
            key: formKey, // formulier sleutel voor validatie gebriiken
            child: TextFormField(
              controller: amountController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: const TextInputType.numberWithOptions(
                // numeriek toetsenbord
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hoeveelheid (g of ml)',
              ),
              validator: (value) {
                // validatie van invoer
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Voer een geldig getal in';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(
                    double.parse(amountController.text),
                  ); // nieuwe hoeveelheid
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      // als er een nieuwe hoeveelheid is opgegeven
      _updateEntryAmount(entry, newAmount);
    }
  }

  Future<void> _updateEntryAmount(
    // werkt de hoeveelheid van een log entry bij in de la Firestore
    Map<String, dynamic> originalEntry,
    double newAmount,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = _selectedDate;
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(todayDocId);

    final originalAmount = originalEntry['amount_g'] as num?;
    final originalNutriments =
        originalEntry['nutriments'] as Map<String, dynamic>?;

    if (originalAmount == null ||
        originalAmount <= 0 ||
        originalNutriments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fout: Originele productgegevens zijn onvolledig om te herberekenen.',
          ),
        ),
      );
      return;
    }
    final factor =
        newAmount / originalAmount.toDouble(); // bereken de schaalfactor

    final newNutriments = originalNutriments.map(
      (key, value) => MapEntry(key, (value is num ? value * factor : value)),
    ); // herbereken de nutriments

    final updatedEntry = {
      ...originalEntry,
      'amount_g': newAmount,
      'nutriments': newNutriments,
    };

    try {
      // werk de entry bij in Firestore
      final doc = await docRef.get();
      if (doc.exists) {
        final entries = List<Map<String, dynamic>>.from(
          doc.data()?['entries'] ?? [],
        );

        final originalTimestamp = originalEntry['timestamp'] as Timestamp?;
        if (originalTimestamp == null) return;

        final index = entries.indexWhere(
          (e) => e['timestamp'] == originalTimestamp,
        );

        if (index != -1) {
          // als entry gevonden is
          entries[index] = updatedEntry;
          await docRef.update({'entries': entries});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fout bij bijwerken: $e')));
    }
  }

  //hulpmethode om netjes een rij te maken met een label en de waarde
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // ruimte tussen de rijen
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // zorgt dat de tekst bovenaan uitgelijnd is
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Onbekend / Niet opgegeven'),
          ), // vult de rest van de rij op met de waarde
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool isUp;
  final Color color;

  _ArrowPainter({required this.isUp, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isUp) {
      path.moveTo(size.width * 0.5, size.height);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.5,
        0,
      );
      path.moveTo(size.width * 0.1, size.height * 0.3);
      path.lineTo(size.width * 0.5, 0);
      path.lineTo(size.width * 0.9, size.height * 0.3);
    } else {
      path.moveTo(size.width * 0.5, 0);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.6,
        size.width * 0.5,
        size.height,
      );
      path.moveTo(size.width * 0.1, size.height * 0.7);
      path.lineTo(size.width * 0.5, size.height);
      path.lineTo(size.width * 0.9, size.height * 0.7);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SegmentedArcPainter extends CustomPainter {
  // aangepaste kleuren voor segmenten in de cirkel
  final double progress;
  final double goal;
  final List<MapEntry<String, double>> breakdown;
  final bool isDarkMode;
  final double strokeWidth; // dikte van de cirkel

  SegmentedArcPainter({
    required this.progress,
    required this.goal,
    required this.breakdown,
    required this.isDarkMode,
    required this.strokeWidth,
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

    if (lowerCaseName.contains('water')) {
      return isDarkMode
          ? {'background': Colors.blue[700]!, 'foreground': Colors.blue[200]!}
          : {'background': Colors.blue[400]!, 'foreground': Colors.blue[800]!};
    }
    if (lowerCaseName.contains('koffie')) {
      return isDarkMode
          ? {'background': Colors.brown[600]!, 'foreground': Colors.brown[100]!}
          : {
              'background': Colors.brown[400]!,
              'foreground': Colors.brown[800]!,
            };
    }
    if (lowerCaseName.contains('thee')) {
      return isDarkMode
          ? {'background': Colors.amber[800]!, 'foreground': Colors.amber[200]!}
          : {
              'background': Colors.amber[500]!,
              'foreground': Colors.amber[800]!,
            };
    }
    if (lowerCaseName.contains('fris') || lowerCaseName.contains('soda')) {
      return isDarkMode
          ? {'background': Colors.red[800]!, 'foreground': Colors.red[200]!}
          : {'background': Colors.red[400]!, 'foreground': Colors.red[800]!};
    }
    return isDarkMode
        ? {'background': Colors.grey[600]!, 'foreground': Colors.white}
        : {'background': Colors.grey[400]!, 'foreground': Colors.black};
  }
}
