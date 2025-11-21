import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:pws/views/settings_view.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Product? _scannedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ingelogd als: ${user?.email ?? "Onbekend"}'),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _errorMessage = null;
                    });

                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimpleBarcodeScannerPage(),
                        ));

                    if (res is String && res != '-1') {
                      setState(() {
                        _isLoading = true;
                        _scannedProduct = null;
                      });

                      try {
                        final configuration = ProductQueryConfiguration(
                          res,
                          language: OpenFoodFactsLanguage.DUTCH,
                          fields: [ProductField.ALL],
                          version: ProductQueryVersion.v3,
                        );

                        final ProductResultV3 result =
                            await OpenFoodAPIClient.getProductV3(configuration);

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
                        setState(() {
                          _errorMessage = 'Fout bij ophalen: $e';
                        });
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Scan een barcode'),
                ),
                const SizedBox(height: 30),
                

                if (_isLoading) const CircularProgressIndicator(),


                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

if (_scannedProduct != null) ...[
                  const Text(
                    'Resultaat:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Naam', _scannedProduct!.productName),
                  _buildInfoRow('Merk', _scannedProduct!.brands),
                  _buildInfoRow('Hoeveelheid', _scannedProduct!.quantity),
                  
                  const Divider(),
                  const Text('Voedingswaarden (per 100g/ml):', style: TextStyle(fontWeight: FontWeight.bold)),
                  
                  _buildInfoRow(
                    'Energie (kcal)', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    'Vetten', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    '  - Waarvan verzadigd', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    'Koolhydraten', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    '  - Waarvan suikers', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    'Vezels', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    'Eiwitten', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams)?.toStringAsFixed(1)
                  ),
                  _buildInfoRow(
                    'Zout', 
                    _scannedProduct!.nutriments?.getValue(Nutrient.salt, PerSize.oneHundredGrams)?.toStringAsFixed(2)
                  ),

                  const Divider(),
                  _buildInfoRow(
                    'Additieven', 
                    _scannedProduct!.additives?.names.join(", ")
                  ),
                  _buildInfoRow(
                    'Allergenen', 
                    _scannedProduct!.allergens?.names.join(", ")
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }
}