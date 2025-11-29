import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:pws/views/settings_view.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter/cupertino.dart'; //voor ios stijl widgets
import 'package:flutter/foundation.dart'; // Voor platform check
import 'add_food_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

  Map<String, dynamic>? _userData;
  double? _calorieAllowance;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    // bij de start van  widget
    super.initState();
    _fetchUserData();
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchUserData() async {
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
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
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

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate.isBefore(today)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
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
        if (index == 0) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: GestureDetector(
                onTap: () => _selectDate(context),
                child: Text(_formatDate(_selectedDate)),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.barcode_viewfinder),
                onPressed: _scanBarcode,
              ),
            ),
            child: SafeArea(
              child: Material(
                child: Scaffold(
                  body: _buildHomeContent(),
                  floatingActionButton: _buildSpeedDial(),
                ),
              ),
            ),
          );
        } else {
          // Tab 2: Instellingen
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Instellingen'),
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _selectDate(context),
          child: Text(_formatDate(_selectedDate)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildHomeContent(),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildSpeedDial() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fabBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.grey[200];
    final fabForegroundColor = isDarkMode ? Colors.white : Colors.black;
    final childBackgroundColor = isDarkMode ? Colors.grey[700] : Colors.white;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: fabBackgroundColor,
      foregroundColor: fabForegroundColor,
      animationCurve: Curves.bounceInOut,
      animationDuration: const Duration(milliseconds: 300),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.restaurant),
          label: 'Voedsel',
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPage()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_drink),
          label: 'Drinken',
          backgroundColor: childBackgroundColor,
          labelStyle: TextStyle(color: fabForegroundColor),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Functie voor drinken is nog niet beschikbaar.'),
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

    // hij opent de barcode scanner en wacht totdat hij klaar is
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Scan Barcode')),
          body: const SimpleBarcodeScannerPage(),
        ),
      ),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddPage(
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe van rechts naar links
        if (details.primaryVelocity! < -100) {
          _goToNextDay();
        }
        // Swipe van links naar rechts
        else if (details.primaryVelocity! > 100) {
          _goToPreviousDay();
        }
      },
      //SingleChildScrollView zorgt ervoor dat je kan scrollen als de inhoud te groot is voor het scherm
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDailyLog(),
                const SizedBox(height: 30),
                //laadcircel animatie
                if (_isLoading) const CircularProgressIndicator(),
                //toont een foutmelding in het rood gecenteerd als die er is
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                //als er een product gevonden is, dan laat hij die resultaten zien
                if (_scannedProduct != null) ...[
                  const Text(
                    'Resultaat:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  //algemene product informatie
                  _buildInfoRow('Naam', _scannedProduct!.productName),
                  _buildInfoRow('Merk', _scannedProduct!.brands),
                  _buildInfoRow('Hoeveelheid', _scannedProduct!.quantity),

                  const Divider(),
                  const Text(
                    'Voedingswaarden (per 100g/ml):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // lijst met de voedingswaarden
                  _buildInfoRow(
                    'Energie (kcal)',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Vetten',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.fat, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    '  - Waarvan verzadigd',
                    _scannedProduct!.nutriments
                        ?.getValue(
                          Nutrient.saturatedFat,
                          PerSize.oneHundredGrams,
                        )
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Koolhydraten',
                    _scannedProduct!.nutriments
                        ?.getValue(
                          Nutrient.carbohydrates,
                          PerSize.oneHundredGrams,
                        )
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    '  - Waarvan suikers',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.sugars, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Vezels',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.fiber, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Eiwitten',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.proteins, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Zout',
                    _scannedProduct!.nutriments
                        ?.getValue(Nutrient.salt, PerSize.oneHundredGrams)
                        ?.toStringAsFixed(2),
                  ),

                  const Divider(),
                  //extra informatie voor toevoeginen en de allergien van het product
                  _buildInfoRow(
                    'Additieven',
                    _scannedProduct!.additives?.names.join(", "),
                  ),
                  _buildInfoRow(
                    'Allergenen',
                    _scannedProduct!.allergens?.names.join(", "),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyLog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final date = _selectedDate;
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logs')
          .doc(todayDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : null;
        final entries = data?['entries'] as List<dynamic>? ?? [];

        double totalCalories = 0;
        double totalProteins = 0;
        double totalFats = 0;
        double totalCarbs = 0;

        final Map<String, List<dynamic>> meals = {
          'Ontbijt': [],
          'Lunch': [],
          'Avondeten': [],
          'Snacks': [],
        };

        for (var entry in entries) {
          totalCalories += (entry['nutriments']?['energy-kcal'] ?? 0.0);
          totalProteins += (entry['nutriments']?['proteins'] ?? 0.0);
          totalFats += (entry['nutriments']?['fat'] ?? 0.0);
          totalCarbs += (entry['nutriments']?['carbohydrates'] ?? 0.0);
          final mealType = entry['meal_type'] as String?;

          if (mealType != null && meals.containsKey(mealType)) {
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
              meals['Snacks']!.add(entry);
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

        return Column(
          children: [
            Card(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 1.0
                            ? Colors.red
                            : (isDarkMode ? Colors.green[300]! : Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
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
            ...meals.entries.map((mealEntry) {
              if (mealEntry.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildMealSection(
                title: mealEntry.key,
                entries: mealEntry.value,
                isDarkMode: isDarkMode,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMacroCircle(
    String title,
    double consumed,
    double goal,
    bool isDarkMode,
    Color color,
  ) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: isDarkMode
                    ? Colors.grey[700]
                    : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '$percentage%',
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
  }

  Widget _buildCalorieInfo(
    String title,
    double value,
    bool isDarkMode, {
    bool isRemaining = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.round()}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection({
    required String title,
    required List<dynamic> entries,
    required bool isDarkMode,
  }) {
    double totalMealCalories = 0;
    for (var entry in entries) {
      totalMealCalories += (entry['nutriments']?['energy-kcal'] ?? 0.0);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              final productName = entry['product_name'] ?? 'Onbekend';
              final calories = (entry['nutriments']?['energy-kcal'] ?? 0.0)
                  .round();
              final timestamp = entry['timestamp'] as Timestamp?;

              return Dismissible(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: InkWell(
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$calories kcal',
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
    final amountController = TextEditingController(
      text: (entry['amount_g'] ?? '100').toString(),
    );
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final newAmount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hoeveelheid aanpassen (gram of mililiter)',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hoeveelheid (g of ml)',
              ),
              validator: (value) {
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
                  Navigator.of(
                    context,
                  ).pop(double.parse(amountController.text));
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      _updateEntryAmount(entry, newAmount);
    }
  }

  Future<void> _updateEntryAmount(
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
    final factor = newAmount / originalAmount.toDouble();

    final newNutriments = originalNutriments.map(
      (key, value) => MapEntry(key, (value is num ? value * factor : value)),
    );

    final updatedEntry = {
      ...originalEntry,
      'amount_g': newAmount,
      'nutriments': newNutriments,
    };

    try {
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
