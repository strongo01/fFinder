import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic>? _searchResults;
  final List<bool> _selectedToggle = <bool>[true, false, false];

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isLoading = false;
      });
      return;
    }

    final trimmed = query.trim();

    if (trimmed.length < 2) {
      setState(() {
        _searchResults = null;
        _errorMessage = 'Voer minimaal 2 tekens in.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
        "https://world.openfoodfacts.org/cgi/search.pl"
        "?search_terms=${Uri.encodeComponent(trimmed)}"
        "&search_simple=1"
        "&json=1"
        "&action=process",
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      final List all = (data["products"] as List?) ?? [];

      final escaped = RegExp.escape(trimmed);
      final wholeWord = RegExp(
        r'\b' + escaped + r'\b',
        caseSensitive: false,
        unicode: true,
      );
      final startsWith = RegExp(
        '^' + escaped,
        caseSensitive: false,
        unicode: true,
      );

      List filtered = all.where((p) {
        final name =
            "${p["product_name"] ?? ''} "
            "${p["generic_name"] ?? ''} "
            "${p["brands"] ?? ''}";
        return wholeWord.hasMatch(name);
      }).toList();

      if (filtered.isEmpty) {
        filtered = all.where((p) {
          final name =
              "${p["product_name"] ?? ''} "
              "${p["generic_name"] ?? ''} "
              "${p["brands"] ?? ''}";
          return startsWith.hasMatch(name);
        }).toList();
      }

      // fallback naar alle producten
      final finalList = filtered.isNotEmpty ? filtered : all;

      // limiet
      const maxResults = 50;
      final limited = finalList.length > maxResults
          ? finalList.sublist(0, maxResults)
          : finalList;

      setState(() {
        _searchResults = limited;
      });
    } catch (e, st) {
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
          decoration: InputDecoration(
            hintText: 'Zoek producten...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Zoek',
              onPressed: () {
                FocusScope.of(context).unfocus();
                _searchProducts(_searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            FocusScope.of(context).unfocus();
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
        final product = _searchResults![index] as Map<String, dynamic>;
        return ListTile(
          title: Text((product['product_name'] as String?) ?? 'Onbekende naam'),
          subtitle: Text((product['brands'] as String?) ?? 'Onbekend merk'),
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
