import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  String? _errorMessage;
  bool _isLoading = false;
  Product? _scannedProduct;
  List<Product>? _searchResults;
  final List<bool> _selectedToggle = <bool>[true, false, false];

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchConfig = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
        ],
        language: OpenFoodFactsLanguage.DUTCH,
        fields: [ProductField.ALL],
        version: ProductQueryVersion.v3,
      );

      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null,
        searchConfig,
      );

      if (result.products != null) {
        setState(() {
          _searchResults = result.products;
        });
      } else {
        setState(() {
          _errorMessage = 'Geen producten gevonden.';
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

  Future<void> _scanBarcode() async {
    //hij reset de foutmeldingen
    setState(() {
      _errorMessage = null;
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
        final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
          configuration,
        );
        // als het product goed is gevonden
        if (result.status == ProductResultV3.statusSuccess) {
          setState(() {
            _scannedProduct = result.product;
          });
        } else {
          setState(() {
            _errorMessage = 'Product niet gevonden in de database';
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
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: const InputDecoration(
            hintText: 'Zoek producten...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _searchProducts(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    _selectedTabIndex = index;
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: (MediaQuery.of(context).size.width - 36) / 3,
                ),
                isSelected: _selectedToggle,
                children: const [
                  Text('Recent'),
                  Text('Favorieten'),
                  Text('Mijn Producten'),
                ],
              ),
            ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    } else {
      return _buildProductList();
    }
  }

  Widget _buildSearchResults() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults == null) {
      return Center(
        child: Text(
          'Begin met typen om te zoeken.',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      );
    }
    if (_searchResults!.isEmpty) {
      return Center(
        child: Text(
          'Geen producten gevonden.',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final product = _searchResults![index];
        return ListTile(
          title: Text(product.productName ?? 'Onbekende naam'),
          subtitle: Text(product.brands ?? 'Onbekend merk'),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildProductList() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    switch (_selectedTabIndex) {
      case 0: // Recent
        return Center(
          child: Text(
            'Recente producten',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
        );
      case 1: // Favorieten
        return Center(
          child: Text(
            'Favoriete producten',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
        );
      case 2: // Door mij aangemaakt
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_products')
              .where('userId', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Je hebt nog geen producten aangemaakt.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Er is een fout opgetreden.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }

            final products = snapshot.data!.docs;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                final name = product['name'] ?? 'Onbekend';
                final brand = product['brand'] ?? 'Geen merk';
                final calories = product['calories']?.toString() ?? '0';

                return ListTile(
                  title: Text(name),
                  subtitle: Text(brand),
                  trailing: Text('$calories kcal'),
                  onTap: () {},
                );
              },
            );
          },
        );
      default:
        return Container();
    }
  }
}
