import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:pws/views/settings_view.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter/cupertino.dart'; //voor ios stijl widgets
import 'package:flutter/foundation.dart'; // Voor platform check

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

  @override
  void initState() {
    // bij de start van  widget
    super.initState();
    _fetchUserData();
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

  double _calculateCalories(Map<String, dynamic> data) { //calorieen
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
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
            navigationBar: const CupertinoNavigationBar(middle: Text('Home')),
            child: SafeArea(child: Material(child: _buildHomeContent())),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
    );
  }

  Widget _buildHomeContent() {
    //haalt de huidige ingelogde gebruiker op
    final user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    //SingleChildScrollView zorgt ervoor dat je kan scrollen als de inhoud te groot is voor het scherm
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //zegt wie er is ingelogd
              Text(
                'Ingelogd als: ${user?.email ?? "Onbekend"}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              if (_userData != null && _calorieAllowance != null) // toont de caloriebehoefte als  data geladen
                Card(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Dagelijkse caloriebehoefte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_calorieAllowance!.round()} kcal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),
              //knop om een barcode te scannen
              ElevatedButton(
                onPressed: () async {
                  //hij reset de foutmeldingen
                  setState(() {
                    _errorMessage = null;
                  });
                  // hij opent de barcode scanner en wacht totdat hij klaar is
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  // als er een geldige barcode is gescand en niet -1
                  if (res is String && res != '-1') {
                    setState(() {
                      _isLoading = true; //start laden
                      _scannedProduct = null; // wis vorige product
                    });

                    try {
                      //configureert de zoekopdracht voor openfoodfacts
                      final configuration = ProductQueryConfiguration(
                        res,
                        language: OpenFoodFactsLanguage.DUTCH,
                        fields: [ProductField.ALL],
                        version: ProductQueryVersion.v3,
                      );

                      // haal de productinformatie op via de api
                      final ProductResultV3 result =
                          await OpenFoodAPIClient.getProductV3(configuration);
                      // als het product goed is gevonden
                      if (result.status == ProductResultV3.statusSuccess) {
                        setState(() {
                          _scannedProduct = result.product;
                        });
                      } else {
                        setState(() {
                          _errorMessage = 'Product niet gevonden in database';
                        });
                      }
                    } catch (e) {
                      //vangt de technische fouten op
                      setState(() {
                        _errorMessage = 'Fout bij ophalen: $e';
                      });
                    } finally {
                      //stop de laad animatie
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: const Text('Scan een barcode'),
              ),
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
                      ?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams)
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
    );
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
