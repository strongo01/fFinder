import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:pws/views/settings_view.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

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

  @override
  Widget build(BuildContext context) {
    //haalt de huidige ingelogde gebruiker op
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      //bovenbalk met de titel en een knop naar de instellingen
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          //nu een iconbutton dus een knop met een icoon en geen tekst
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              //hij gaat naar het instellingen scherm
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      //SingleChildScrollView zorgt ervoor dat je kan scrollen als de inhoud te groot is voor het scherm
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //zegt wie er is ingelogd
                Text('Ingelogd als: ${user?.email ?? "Onbekend"}'),
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
