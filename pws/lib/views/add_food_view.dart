import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPage extends StatefulWidget {
  final String? scannedBarcode;
  final Map<String, dynamic>? initialProductData;

  const AddPage({super.key, this.scannedBarcode, this.initialProductData});
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  String? _errorMessage;
  bool _isLoading = false;
  List<dynamic>? _searchResults;
  final List<bool> _selectedToggle = <bool>[true, false, false, false];

  @override
  void initState() {
    super.initState();
    if (widget.scannedBarcode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showProductDetails(
            widget.scannedBarcode!,
            productData: widget.initialProductData,
          );
        }
      });
    }
  }

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
        "https://nl.openfoodfacts.org/cgi/search.pl"
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

      if (mounted) {
        setState(() {
          _searchResults = limited;
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
      final barcode = res;
      final user = FirebaseAuth.instance.currentUser;

      // Als er geen gebruiker is, haal direct op van API
      if (user == null) {
        _showProductDetails(barcode);
        return;
      }

      // Toon laadindicator terwijl we Firestore controleren
      setState(() {
        _isLoading = true;
      });

      try {
        // Controleer eerst collectie
        final recentDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('recents')
            .doc(barcode);

        final docSnapshot = await recentDocRef.get();

        if (docSnapshot.exists) {
          // Product gevonden in recents, gebruik die data
          final productData = docSnapshot.data() as Map<String, dynamic>;
          // Roep de details sheet aan met de gevonden data
          _showProductDetails(barcode, productData: productData);
        } else {
          // Product niet in recents, haal op van API
          _showProductDetails(barcode);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Fout bij controleren van recente producten: $e";
          });
        }
      } finally {
        // Verberg laadindicator NADAT de data is doorgegeven
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
          if (_searchController.text.isEmpty &&
              (_selectedTabIndex == 2 || _selectedTabIndex == 3))
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: _selectedTabIndex == 2
                  ? 'Product toevoegen'
                  : 'Maaltijd toevoegen',
              onPressed: _selectedTabIndex == 2
                  ? _showAddMyProductSheet
                  : _showAddMealSheet,
            ),
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
                  minWidth: (MediaQuery.of(context).size.width - 48) / 4,
                ),
                isSelected: _selectedToggle,
                children: const [
                  Text('Recent'),
                  Text('Favorieten'),
                  Text('Mijn Producten'),
                  Text('Maaltijden'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Geen producten gevonden.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showAddMyProductSheet,
              child: const Text('Wilt u zelf een product toevoegen?'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults!.length + 1,
      itemBuilder: (context, index) {
        if (index == _searchResults!.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton(
              onPressed: _showAddMyProductSheet,
              child: const Text(
                'Niet de gewenste resultaten: voeg een product toe!',
              ),
            ),
          );
        }

        final product = _searchResults![index] as Map<String, dynamic>;
        final imageUrl = product['image_front_small_url'] as String?;

        return ListTile(
          leading: imageUrl != null
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                )
              : const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.fastfood),
                ),
          title: Text((product['product_name'] as String?) ?? 'Onbekende naam'),
          subtitle: Text((product['brands'] as String?) ?? 'Onbekend merk'),
          onTap: () {
            final barcode = product['_id'] as String?;
            if (barcode != null) {
              _showProductDetails(barcode);
            }
          },
        );
      },
    );
  }

  Future<void> _showAddMyProductSheet() async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _brandController = TextEditingController();
    final _quantityController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _fatController = TextEditingController();
    final _saturatedFatController = TextEditingController();
    final _carbsController = TextEditingController();
    final _sugarsController = TextEditingController();
    final _fiberController = TextEditingController();
    final _proteinsController = TextEditingController();
    final _saltController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nieuw Product Toevoegen',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Productnaam'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Naam is verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _brandController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Merk'),
                  ),
                  TextFormField(
                    controller: _quantityController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Hoeveelheid (bijv. 100g, 250ml)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voedingswaarden per 100g/ml',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Energie (kcal)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Calorieën zijn verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _fatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vetten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saturatedFatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan verzadigd',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Koolhydraten',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _sugarsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan suikers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _fiberController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vezels'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Eiwitten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saltController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Zout'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('my_products')
                            .add({
                              'product_name': _nameController.text,
                              'brands': _brandController.text,
                              'quantity': _quantityController.text,
                              'timestamp': FieldValue.serverTimestamp(),
                              'nutriments_per_100g': {
                                'energy-kcal':
                                    double.tryParse(_caloriesController.text) ??
                                    0,
                                'fat': double.tryParse(_fatController.text),
                                'saturated-fat': double.tryParse(
                                  _saturatedFatController.text,
                                ),
                                'carbohydrates': double.tryParse(
                                  _carbsController.text,
                                ),
                                'sugars': double.tryParse(
                                  _sugarsController.text,
                                ),
                                'fiber': double.tryParse(_fiberController.text),
                                'proteins': double.tryParse(
                                  _proteinsController.text,
                                ),
                                'salt': double.tryParse(_saltController.text),
                              },
                            });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Opslaan'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addRecentProduct(
    Product product, {
    Map<String, dynamic>? editedNutriments,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Gebruiker niet ingelogd

    final barcode = product.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recents')
        .doc(barcode);

    final nutriments = product.nutriments;
    final productData = {
      'product_name': product.productName,
      'brands': product.brands,
      'image_front_url': product.imageFrontUrl,
      'quantity': product.quantity,
      'timestamp': FieldValue.serverTimestamp(),
      'nutriments_per_100g':
          editedNutriments ??
          {
            'energy-kcal': nutriments?.getValue(
              Nutrient.energyKCal,
              PerSize.oneHundredGrams,
            ),
            'fat': nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
            'saturated-fat': nutriments?.getValue(
              Nutrient.saturatedFat,
              PerSize.oneHundredGrams,
            ),
            'carbohydrates': nutriments?.getValue(
              Nutrient.carbohydrates,
              PerSize.oneHundredGrams,
            ),
            'sugars': nutriments?.getValue(
              Nutrient.sugars,
              PerSize.oneHundredGrams,
            ),
            'fiber': nutriments?.getValue(
              Nutrient.fiber,
              PerSize.oneHundredGrams,
            ),
            'proteins': nutriments?.getValue(
              Nutrient.proteins,
              PerSize.oneHundredGrams,
            ),
            'salt': nutriments?.getValue(
              Nutrient.salt,
              PerSize.oneHundredGrams,
            ),
          },
      'allergens': product.allergens?.names,
      'additives': product.additives?.names,
      'isMyProduct': false,
    };

    // Verwijder null waarden uit de map voordat je opslaat
    productData.removeWhere((key, value) => value == null);
    (productData['nutriments_per_100g'] as Map).removeWhere(
      (key, value) => value == null,
    );

    await docRef.set(productData, SetOptions(merge: true));
  }

  Future<void> _addRecentMyProduct(
    Map<String, dynamic> productData,
    String docId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recents')
        .doc(docId);

    final dataToSave = Map<String, dynamic>.from(productData);
    dataToSave['timestamp'] = FieldValue.serverTimestamp();
    dataToSave['isMyProduct'] = true;

    await docRef.set(dataToSave, SetOptions(merge: true));
  }

  Future<void> _addFavoriteProduct(
    Product product, {
    Map<String, dynamic>? editedNutriments,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final barcode = product.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(barcode);

    final nutriments = product.nutriments;
    final productData = {
      'product_name': product.productName,
      'brands': product.brands,
      'image_front_url': product.imageFrontUrl,
      'quantity': product.quantity,
      'timestamp': FieldValue.serverTimestamp(),
      'nutriments_per_100g':
          editedNutriments ??
          {
            'energy-kcal': nutriments?.getValue(
              Nutrient.energyKCal,
              PerSize.oneHundredGrams,
            ),
            'fat': nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
            'saturated-fat': nutriments?.getValue(
              Nutrient.saturatedFat,
              PerSize.oneHundredGrams,
            ),
            'carbohydrates': nutriments?.getValue(
              Nutrient.carbohydrates,
              PerSize.oneHundredGrams,
            ),
            'sugars': nutriments?.getValue(
              Nutrient.sugars,
              PerSize.oneHundredGrams,
            ),
            'fiber': nutriments?.getValue(
              Nutrient.fiber,
              PerSize.oneHundredGrams,
            ),
            'proteins': nutriments?.getValue(
              Nutrient.proteins,
              PerSize.oneHundredGrams,
            ),
            'salt': nutriments?.getValue(
              Nutrient.salt,
              PerSize.oneHundredGrams,
            ),
          },
      'allergens': product.allergens?.names,
      'additives': product.additives?.names,
    };

    productData.removeWhere((key, value) => value == null);
    (productData['nutriments_per_100g'] as Map).removeWhere(
      (key, value) => value == null,
    );

    await docRef.set(productData, SetOptions(merge: true));
  }

  Future<void> _removeFavoriteProduct(String barcode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(barcode)
        .delete();
  }

  Future<bool> _isFavorite(String barcode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(barcode)
        .get();
    return doc.exists;
  }

  Future<Map<String, dynamic>?> _showProductDetails(
    String barcode, {
    Map<String, dynamic>? productData,
    bool isForMeal = false,
    double? initialAmount,
  }) async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        Product? product;
        String? error;
        bool isLoading = true;
        bool isFavorite = false;

        final formKey = GlobalKey<FormState>();
        final caloriesController = TextEditingController();
        final fatController = TextEditingController();
        final amountController = TextEditingController(
          text: initialAmount?.toString() ?? '',
        );
        final saturatedFatController = TextEditingController();
        final carbsController = TextEditingController();
        final sugarsController = TextEditingController();
        final fiberController = TextEditingController();
        final proteinsController = TextEditingController();
        final saltController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> fetchDetails() async {
              if (productData != null) {
                try {
                  final isFav = await _isFavorite(barcode);
                  final nutriments =
                      productData['nutriments_per_100g']
                          as Map<String, dynamic>? ??
                      {};

                  caloriesController.text =
                      nutriments['energy-kcal']?.toString() ?? '';
                  fatController.text = nutriments['fat']?.toString() ?? '';
                  saturatedFatController.text =
                      nutriments['saturated-fat']?.toString() ?? '';
                  carbsController.text =
                      nutriments['carbohydrates']?.toString() ?? '';
                  sugarsController.text =
                      nutriments['sugars']?.toString() ?? '';
                  fiberController.text = nutriments['fiber']?.toString() ?? '';
                  proteinsController.text =
                      nutriments['proteins']?.toString() ?? '';
                  saltController.text = nutriments['salt']?.toString() ?? '';

                  product = Product(
                    barcode: barcode,
                    productName: productData['product_name'],
                    brands: productData['brands'],
                    quantity: productData['quantity'],
                    imageFrontUrl: productData['image_front_url'],
                    additives: Additives(
                      [],
                      (productData['additives'] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ??
                          [],
                    ),
                    allergens: Allergens(
                      [],
                      (productData['allergens'] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ??
                          [],
                    ),
                  );

                  setModalState(() {
                    isLoading = false;
                    isFavorite = isFav;
                  });
                } catch (e) {
                  setModalState(() {
                    error = 'Fout bij laden lokale data: $e';
                    isLoading = false;
                  });
                }
                return;
              }

              try {
                final isFav = await _isFavorite(barcode);
                final config = ProductQueryConfiguration(
                  barcode,
                  language: OpenFoodFactsLanguage.DUTCH,
                  fields: [ProductField.ALL],
                  version: ProductQueryVersion.v3,
                );
                final result = await OpenFoodAPIClient.getProductV3(config);

                if (result.status == ProductResultV3.statusSuccess &&
                    result.product != null) {
                  final p = result.product!;

                  caloriesController.text =
                      p.nutriments
                          ?.getValue(
                            Nutrient.energyKCal,
                            PerSize.oneHundredGrams,
                          )
                          ?.toString() ??
                      '';
                  fatController.text =
                      p.nutriments
                          ?.getValue(Nutrient.fat, PerSize.oneHundredGrams)
                          ?.toString() ??
                      '';
                  saturatedFatController.text =
                      p.nutriments
                          ?.getValue(
                            Nutrient.saturatedFat,
                            PerSize.oneHundredGrams,
                          )
                          ?.toString() ??
                      '';
                  carbsController.text =
                      p.nutriments
                          ?.getValue(
                            Nutrient.carbohydrates,
                            PerSize.oneHundredGrams,
                          )
                          ?.toString() ??
                      '';
                  sugarsController.text =
                      p.nutriments
                          ?.getValue(Nutrient.sugars, PerSize.oneHundredGrams)
                          ?.toString() ??
                      '';
                  fiberController.text =
                      p.nutriments
                          ?.getValue(Nutrient.fiber, PerSize.oneHundredGrams)
                          ?.toString() ??
                      '';
                  proteinsController.text =
                      p.nutriments
                          ?.getValue(Nutrient.proteins, PerSize.oneHundredGrams)
                          ?.toString() ??
                      '';
                  saltController.text =
                      p.nutriments
                          ?.getValue(Nutrient.salt, PerSize.oneHundredGrams)
                          ?.toString() ??
                      '';

                  setModalState(() {
                    product = p;
                    isLoading = false;
                    isFavorite = isFav;
                  });
                } else {
                  setModalState(() {
                    error = 'Product niet gevonden.';
                    isLoading = false;
                  });
                }
              } catch (e) {
                setModalState(() {
                  error = 'Fout bij ophalen: $e';
                  isLoading = false;
                });
              }
            }

            if (product == null && error == null && isLoading) {
              fetchDetails();
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (error != null) {
                  return Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (product == null) {
                  return const Center(
                    child: Text('Geen productinformatie beschikbaar.'),
                  );
                }

                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final textColor = isDarkMode ? Colors.white : Colors.black;

                return Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product!.productName ?? 'Onbekende naam',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: textColor),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.red
                                    : (isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                              ),
                              onPressed: () async {
                                if (product != null) {
                                  if (isFavorite) {
                                    await _removeFavoriteProduct(
                                      product!.barcode!,
                                    );
                                    setModalState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  } else {
                                    // Valideer voordat je toevoegt aan favorieten
                                    if (formKey.currentState!.validate()) {
                                      final nutrimentsData = {
                                        'energy-kcal': double.tryParse(
                                          caloriesController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'fat': double.tryParse(
                                          fatController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'saturated-fat': double.tryParse(
                                          saturatedFatController.text
                                              .replaceAll(',', '.'),
                                        ),
                                        'carbohydrates': double.tryParse(
                                          carbsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'sugars': double.tryParse(
                                          sugarsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'fiber': double.tryParse(
                                          fiberController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'proteins': double.tryParse(
                                          proteinsController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'salt': double.tryParse(
                                          saltController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                      };

                                      await _addFavoriteProduct(
                                        product!,
                                        editedNutriments: nutrimentsData,
                                      );
                                      setModalState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Vul alle verplichte velden in (kcal).',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final nutrimentsData = {
                                    'energy-kcal': double.tryParse(
                                      caloriesController.text.replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    ),
                                    'fat': double.tryParse(
                                      fatController.text.replaceAll(',', '.'),
                                    ),
                                    'saturated-fat': double.tryParse(
                                      saturatedFatController.text.replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    ),
                                    'carbohydrates': double.tryParse(
                                      carbsController.text.replaceAll(',', '.'),
                                    ),
                                    'sugars': double.tryParse(
                                      sugarsController.text.replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    ),
                                    'fiber': double.tryParse(
                                      fiberController.text.replaceAll(',', '.'),
                                    ),
                                    'proteins': double.tryParse(
                                      proteinsController.text.replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    ),
                                    'salt': double.tryParse(
                                      saltController.text.replaceAll(',', '.'),
                                    ),
                                  };

                                  if (product != null) {
                                    await _addRecentProduct(
                                      product!,
                                      editedNutriments: nutrimentsData,
                                    );
                                  }

                                  final bool? wasAdded =
                                      await _showAddLogDialog(
                                        context,
                                        product!.productName ??
                                            'Onbekend product',
                                        nutrimentsData,
                                      );
                                  if (wasAdded == true && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vul alle verplichte velden in (kcal).',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildEditableInfoRow(
                          'Energie (kcal)',
                          caloriesController,
                          isDarkMode,
                          isRequired: true,
                        ),
                        _buildEditableInfoRow(
                          'Vetten',
                          fatController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          '  - Waarvan verzadigd',
                          saturatedFatController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          'Koolhydraten',
                          carbsController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          '  - Waarvan suikers',
                          sugarsController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          'Vezels',
                          fiberController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          'Eiwitten',
                          proteinsController,
                          isDarkMode,
                        ),
                        _buildEditableInfoRow(
                          'Zout',
                          saltController,
                          isDarkMode,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Additieven',
                          product!.additives?.names.join(", "),
                        ),
                        _buildInfoRow(
                          'Allergenen',
                          product!.allergens?.names.join(", "),
                        ),
                        if (isForMeal) ...[
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: amountController,
                            autofocus: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Hoeveelheid voor maaltijd',
                              suffixText: 'g',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hoeveelheid is verplicht';
                              }
                              if (double.tryParse(value.replaceAll(',', '.')) ==
                                  null) {
                                return 'Ongeldig getal';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            child: const Text('Voeg toe aan Maaltijd'),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final nutrimentsData = {
                                  'energy-kcal': double.tryParse(
                                    caloriesController.text.replaceAll(
                                      ',',
                                      '.',
                                    ),
                                  ),
                                  'fat': double.tryParse(
                                    fatController.text.replaceAll(',', '.'),
                                  ),
                                  'saturated-fat': double.tryParse(
                                    saturatedFatController.text.replaceAll(
                                      ',',
                                      '.',
                                    ),
                                  ),
                                  'carbohydrates': double.tryParse(
                                    carbsController.text.replaceAll(',', '.'),
                                  ),
                                  'sugars': double.tryParse(
                                    sugarsController.text.replaceAll(',', '.'),
                                  ),
                                  'fiber': double.tryParse(
                                    fiberController.text.replaceAll(',', '.'),
                                  ),
                                  'proteins': double.tryParse(
                                    proteinsController.text.replaceAll(
                                      ',',
                                      '.',
                                    ),
                                  ),
                                  'salt': double.tryParse(
                                    saltController.text.replaceAll(',', '.'),
                                  ),
                                };

                                final productForMeal = {
                                  '_id': product!.barcode,
                                  'product_name': product!.productName,
                                  'brands': product!.brands,
                                  'image_front_small_url':
                                      product!.imageFrontSmallUrl,
                                  'nutriments_per_100g': nutrimentsData,
                                };

                                final result = {
                                  'amount': double.parse(
                                    amountController.text.replaceAll(',', '.'),
                                  ),
                                  'product': productForMeal,
                                };
                                Navigator.pop(context, result);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller,
    bool isDarkMode, {
    bool isRequired = false,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: textColor),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Waarde mist',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Verplicht';
                }
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Ongeldig';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    switch (_selectedTabIndex) {
      case 0: // Recent
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je recente producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recents')
              .orderBy('timestamp', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Geen recente producten gevonden.',
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
                final productDoc = products[index];
                final product = productDoc.data() as Map<String, dynamic>;
                final name = product['product_name'] ?? 'Onbekende naam';
                final brand = product['brands'] ?? 'Onbekend merk';
                final imageUrl = product['image_front_url'] as String?;
                final isMyProduct = product['isMyProduct'] as bool? ?? false;

                return ListTile(
                  leading: imageUrl != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        )
                      : const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.fastfood),
                        ),
                  title: Text(name),
                  subtitle: Text(brand),
                  onTap: () {
                    if (isMyProduct) {
                      _showMyProductDetails(product, productDoc.id);
                    } else {
                      _showProductDetails(productDoc.id, productData: product);
                    }
                  },
                );
              },
            );
          },
        );
      case 1: // Favorieten
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je favoriete producten te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Geen favoriete producten gevonden.',
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
                final productDoc = products[index];
                final product = productDoc.data() as Map<String, dynamic>;
                final name = product['product_name'] ?? 'Onbekende naam';
                final brand = product['brands'] ?? 'Onbekend merk';
                final imageUrl = product['image_front_url'] as String?;

                return ListTile(
                  leading: imageUrl != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        )
                      : const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.fastfood),
                        ),
                  title: Text(name),
                  subtitle: Text(brand),
                  onTap: () {
                    _showProductDetails(productDoc.id, productData: product);
                  },
                );
              },
            );
          },
        );
      case 2: // Door gebruiker aangemaakt
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
              .collection('users')
              .doc(user.uid)
              .collection('my_products')
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
                final productDoc = products[index];
                final product = productDoc.data() as Map<String, dynamic>;
                final name = product['product_name'] ?? 'Onbekende naam';
                final brand = product['brands'] ?? 'Geen merk';
                final nutriments =
                    product['nutriments_per_100g'] as Map<String, dynamic>?;
                final calories = nutriments?['energy-kcal']?.toString() ?? '0';

                return Dismissible(
                  key: Key(productDoc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Bevestig verwijdering",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          content: Text(
                            "Weet je zeker dat je '$name' wilt verwijderen?",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Annuleren"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Verwijderen",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('my_products')
                        .doc(productDoc.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'$name' verwijderd")),
                    );
                  },
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(brand),
                    trailing: Text('$calories kcal'),
                    onTap: () {
                      _showMyProductDetails(
                        product,
                        productDoc.id,
                      ); // Pass document ID
                    },
                  ),
                );
              },
            );
          },
        );
      case 3: // Maaltijden
        if (user == null) {
          return Center(
            child: Text(
              'Log in om je maaltijden te zien.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('meals')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Je hebt nog geen maaltijden aangemaakt.',
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

            final meals = snapshot.data!.docs;

            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final mealDoc = meals[index];
                final meal = mealDoc.data() as Map<String, dynamic>;
                final name = meal['name'] ?? 'Onbekende maaltijd';

                return Dismissible(
                  key: Key(mealDoc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Bevestig verwijdering",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          content: Text(
                            "Weet je zeker dat je maaltijd '$name' wilt verwijderen?",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Annuleren"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Verwijderen",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('meals')
                        .doc(mealDoc.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Maaltijd '$name' verwijderd")),
                    );
                  },
                  child: ListTile(
                    title: Text(name),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      tooltip: 'Log maaltijd',
                      onPressed: () {
                        final mealWithId = Map<String, dynamic>.from(meal);
                        mealWithId['id'] = mealDoc.id;
                        _logMeal(context, mealWithId);
                      },
                    ),
                    onTap: () {
                      _showAddMealSheet(existingMeal: meal, mealId: mealDoc.id);
                    },
                  ),
                );
              },
            );
          },
        );
      default:
        return Container();
    }
  }

  Future<void> _logMeal(BuildContext context, Map<String, dynamic> meal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ingredients =
        (meal['ingredients'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deze maaltijd heeft geen ingrediënten.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalNutriments = <String, double>{
      'energy-kcal': 0,
      'fat': 0,
      'saturated-fat': 0,
      'carbohydrates': 0,
      'sugars': 0,
      'fiber': 0,
      'proteins': 0,
      'salt': 0,
    };
    double totalAmount = 0;

    for (final ingredient in ingredients) {
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0;
      final nutrimentsPer100g =
          (ingredient['nutriments_per_100g'] as Map<String, dynamic>?) ?? {};
      final factor = amount / 100.0;
      totalAmount += amount;

      totalNutriments.forEach((key, value) {
        final nutrientValue =
            (nutrimentsPer100g[key] as num?)?.toDouble() ?? 0.0;
        totalNutriments[key] =
            (totalNutriments[key] ?? 0.0) + (nutrientValue * factor);
      });
    }

    final String? selectedMealType = await _showSelectMealTypeDialog(context);
    if (selectedMealType == null) return;

    final now = DateTime.now();
    final todayDocId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final dailyLogRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(todayDocId);

    final logEntry = {
      'product_name': meal['name'] ?? 'Onbekende maaltijd',
      'amount_g': totalAmount,
      'timestamp': Timestamp.now(),
      'nutriments': totalNutriments,
      'meal_type': selectedMealType,
      'is_meal': true,
    };

    try {
      await dailyLogRef.set({
        'entries': FieldValue.arrayUnion([logEntry]),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('"${meal['name']}" toegevoegd aan je logboek.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan van maaltijd: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showSelectMealTypeDialog(BuildContext context) async {
    final hour = DateTime.now().hour;
    String selectedMeal;
    if (hour >= 5 && hour < 11) {
      selectedMeal = 'Ontbijt';
    } else if (hour >= 11 && hour < 15) {
      selectedMeal = 'Lunch';
    } else if (hour >= 15 && hour < 22) {
      selectedMeal = 'Avondeten';
    } else {
      selectedMeal = 'Snacks';
    }
    final List<String> mealTypes = ['Ontbijt', 'Lunch', 'Avondeten', 'Snacks'];

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Log Maaltijd', style: TextStyle(color: textColor)),
              content: DropdownButtonFormField<String>(
                value: selectedMeal,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(labelText: 'Sectie'),
                items: mealTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setDialogState(() {
                    selectedMeal = newValue!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, selectedMeal);
                  },
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddMealSheet({
    Map<String, dynamic>? existingMeal,
    String? mealId,
  }) async {
    final _mealNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    List<Map<String, dynamic>> ingredientEntries = [];

    if (existingMeal != null) {
      _mealNameController.text = existingMeal['name'] ?? '';
      final ingredients =
          (existingMeal['ingredients'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      for (var ingredient in ingredients) {
        ingredientEntries.add({
          'searchController': TextEditingController(),
          'amountController': TextEditingController(
            text: ingredient['amount']?.toString() ?? '',
          ),
          'searchResults': null,
          'selectedProduct': {
            'product_name': ingredient['product_name'],
            'brands': ingredient['brands'],
            '_id': ingredient['product_id'],
            'image_front_small_url': ingredient['image_front_small_url'],
            'nutriments_per_100g': ingredient['nutriments_per_100g'],
          },
          'isSearching': false,
        });
      }
    } else {
      ingredientEntries.add({
        'searchController': TextEditingController(),
        'amountController': TextEditingController(),
        'searchResults': null,
        'selectedProduct': null,
        'isSearching': false,
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDarkMode ? Colors.white : Colors.black;

            Future<void> searchProductsForIngredient(
              String query,
              int index,
            ) async {
              if (query.length < 2) {
                setModalState(() {
                  ingredientEntries[index]['searchResults'] = null;
                });
                return;
              }
              setModalState(() {
                ingredientEntries[index]['isSearching'] = true;
              });

              final url = Uri.parse(
                "https://nl.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&json=1&action=process",
              );
              final response = await http.get(url);
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                setModalState(() {
                  ingredientEntries[index]['searchResults'] =
                      (data["products"] as List?) ?? [];
                  ingredientEntries[index]['isSearching'] = false;
                });
              } else {
                setModalState(() {
                  ingredientEntries[index]['isSearching'] = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nieuwe Maaltijd Samenstellen',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _mealNameController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Naam van maaltijd',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Naam is verplicht'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingrediënten',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: textColor),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ingredientEntries.length,
                        itemBuilder: (context, index) {
                          final entry = ingredientEntries[index];
                          final searchController =
                              entry['searchController']
                                  as TextEditingController;
                          final amountController =
                              entry['amountController']
                                  as TextEditingController;
                          final selectedProduct =
                              entry['selectedProduct'] as Map<String, dynamic>?;

                          if (selectedProduct != null) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(selectedProduct['product_name']),
                                subtitle: Text(
                                  'Hoeveelheid: ${amountController.text}g',
                                ),
                                onTap: () async {
                                  final barcode =
                                      selectedProduct['_id'] as String?;
                                  if (barcode == null) return;

                                  final currentAmount = double.tryParse(
                                    amountController.text,
                                  );

                                  final result = await _showProductDetails(
                                    barcode,
                                    productData: selectedProduct,
                                    isForMeal: true,
                                    initialAmount: currentAmount,
                                  );

                                  if (result != null &&
                                      result['amount'] != null) {
                                    setModalState(() {
                                      amountController.text = result['amount']
                                          .toString();
                                      entry['selectedProduct'] =
                                          result['product'];
                                    });
                                  }
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setModalState(() {
                                      ingredientEntries.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        labelText: 'Product ${index + 1}',
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: () =>
                                              searchProductsForIngredient(
                                                searchController.text,
                                                index,
                                              ),
                                        ),
                                      ),
                                      onSubmitted: (query) =>
                                          searchProductsForIngredient(
                                            query,
                                            index,
                                          ),
                                    ),
                                  ),
                                  if (ingredientEntries.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          ingredientEntries.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (entry['isSearching'] as bool)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (entry['searchResults'] != null)
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    itemCount:
                                        (entry['searchResults'] as List).length,
                                    itemBuilder: (context, resultIndex) {
                                      final product =
                                          (entry['searchResults']
                                              as List)[resultIndex];
                                      return ListTile(
                                        title: Text(
                                          product['product_name'] ?? 'Onbekend',
                                        ),
                                        subtitle: Text(
                                          product['brands'] ?? 'Onbekend',
                                        ),
                                        onTap: () async {
                                          final barcode =
                                              product['_id'] as String?;
                                          if (barcode == null) return;

                                          final result =
                                              await _showProductDetails(
                                                barcode,
                                                isForMeal: true,
                                              );

                                          if (result != null &&
                                              result['amount'] != null) {
                                            setModalState(() {
                                              amountController.text =
                                                  result['amount'].toString();
                                              entry['selectedProduct'] =
                                                  result['product'];
                                              entry['searchResults'] = null;
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                          tooltip: 'Voeg nog een product toe',
                          onPressed: () {
                            setModalState(() {
                              ingredientEntries.add({
                                'searchController': TextEditingController(),
                                'amountController': TextEditingController(),
                                'searchResults': null,
                                'selectedProduct': null,
                                'isSearching': false,
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            List<Map<String, dynamic>> finalProducts = [];
                            for (var entry in ingredientEntries) {
                              if (entry['selectedProduct'] != null &&
                                  (entry['amountController']
                                          as TextEditingController)
                                      .text
                                      .isNotEmpty) {
                                final product =
                                    entry['selectedProduct']
                                        as Map<String, dynamic>;
                                final amount = double.tryParse(
                                  (entry['amountController']
                                          as TextEditingController)
                                      .text,
                                );
                                if (amount != null) {
                                  finalProducts.add({
                                    'product_id': product['_id'],
                                    'product_name': product['product_name'],
                                    'brands': product['brands'],
                                    'image_front_small_url':
                                        product['image_front_small_url'],
                                    'amount': amount,
                                    'nutriments_per_100g':
                                        product['nutriments_per_100g'],
                                  });
                                }
                              }
                            }

                            if (finalProducts.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Voeg minimaal één product toe.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final mealData = {
                              'name': _mealNameController.text,
                              'ingredients': finalProducts,
                              'timestamp': FieldValue.serverTimestamp(),
                            };

                            final collection = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('meals');

                            if (mealId != null) {
                              await collection.doc(mealId).update(mealData);
                            } else {
                              await collection.add(mealData);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          mealId != null
                              ? 'Wijzigingen Opslaan'
                              : 'Maaltijd Opslaan',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditMyProductSheet(
    Map<String, dynamic> productData,
    String docId,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final nutriments =
        productData['nutriments_per_100g'] as Map<String, dynamic>? ?? {};

    final _nameController = TextEditingController(
      text: productData['product_name'],
    );
    final _brandController = TextEditingController(text: productData['brands']);
    final _quantityController = TextEditingController(
      text: productData['quantity'],
    );
    final _caloriesController = TextEditingController(
      text: nutriments['energy-kcal']?.toString(),
    );
    final _fatController = TextEditingController(
      text: nutriments['fat']?.toString(),
    );
    final _saturatedFatController = TextEditingController(
      text: nutriments['saturated-fat']?.toString(),
    );
    final _carbsController = TextEditingController(
      text: nutriments['carbohydrates']?.toString(),
    );
    final _sugarsController = TextEditingController(
      text: nutriments['sugars']?.toString(),
    );
    final _fiberController = TextEditingController(
      text: nutriments['fiber']?.toString(),
    );
    final _proteinsController = TextEditingController(
      text: nutriments['proteins']?.toString(),
    );
    final _saltController = TextEditingController(
      text: nutriments['salt']?.toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product Bewerken',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Productnaam'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Naam is verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _brandController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Merk'),
                  ),
                  TextFormField(
                    controller: _quantityController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Hoeveelheid (bijv. 100g, 250ml)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voedingswaarden per 100g/ml',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Energie (kcal)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Calorieën zijn verplicht'
                        : null,
                  ),
                  TextFormField(
                    controller: _fatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vetten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saturatedFatController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan verzadigd',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Koolhydraten',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _sugarsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: '  - Waarvan suikers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _fiberController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Vezels'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Eiwitten'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _saltController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Zout'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final updatedData = {
                          'product_name': _nameController.text,
                          'brands': _brandController.text,
                          'quantity': _quantityController.text,
                          'timestamp': FieldValue.serverTimestamp(),
                          'nutriments_per_100g': {
                            'energy-kcal':
                                double.tryParse(_caloriesController.text) ?? 0,
                            'fat': double.tryParse(_fatController.text),
                            'saturated-fat': double.tryParse(
                              _saturatedFatController.text,
                            ),
                            'carbohydrates': double.tryParse(
                              _carbsController.text,
                            ),
                            'sugars': double.tryParse(_sugarsController.text),
                            'fiber': double.tryParse(_fiberController.text),
                            'proteins': double.tryParse(
                              _proteinsController.text,
                            ),
                            'salt': double.tryParse(_saltController.text),
                          },
                        };

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('my_products')
                            .doc(docId)
                            .update(updatedData);
                        Navigator.pop(context); // Close edit sheet
                      }
                    },
                    child: const Text('Opslaan'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMyProductDetails(
    Map<String, dynamic> productData,
    String docId,
  ) async {
    _addRecentMyProduct(productData, docId);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        final name = productData['product_name'] ?? 'Onbekende naam';
        final brand = productData['brands'] ?? 'Onbekend merk';
        final quantity = productData['quantity'] as String?;
        final nutriments =
            productData['nutriments_per_100g'] as Map<String, dynamic>? ?? {};

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(color: textColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context); // Close details
                          _showEditMyProductSheet(
                            productData,
                            docId,
                          ); // Open edit
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final nutrimentsMap =
                              productData['nutriments_per_100g']
                                  as Map<String, dynamic>?;

                          final bool? wasAdded = await _showAddLogDialog(
                            context,
                            name,
                            nutrimentsMap, // GEWIJZIGD: Geef de Map direct door
                          );

                          // Als het product is toegevoegd, sluit dan ook de productdetails.
                          if (wasAdded == true && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Merk', brand),
                  _buildInfoRow('Hoeveelheid', quantity),
                  const Divider(height: 24),
                  Text(
                    'Voedingswaarden per 100g/ml',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Energie (kcal)',
                    nutriments['energy-kcal']?.toString(),
                  ),
                  _buildInfoRow('Vetten', nutriments['fat']?.toString()),
                  _buildInfoRow(
                    '  - Waarvan verzadigd',
                    nutriments['saturated-fat']?.toString(),
                  ),
                  _buildInfoRow(
                    'Koolhydraten',
                    nutriments['carbohydrates']?.toString(),
                  ),
                  _buildInfoRow(
                    '  - Waarvan suikers',
                    nutriments['sugars']?.toString(),
                  ),
                  _buildInfoRow('Vezels', nutriments['fiber']?.toString()),
                  _buildInfoRow('Eiwitten', nutriments['proteins']?.toString()),
                  _buildInfoRow('Zout', nutriments['salt']?.toString()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showAddLogDialog(
    BuildContext context,
    String productName,
    Map<String, dynamic>? nutriments,
  ) async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final hour = DateTime.now().hour;
    String selectedMeal;
    if (hour >= 5 && hour < 11) {
      selectedMeal = 'Ontbijt';
    } else if (hour >= 11 && hour < 15) {
      selectedMeal = 'Lunch';
    } else if (hour >= 15 && hour < 22) {
      selectedMeal = 'Avondeten';
    } else {
      selectedMeal = 'Snacks';
    }
    final List<String> mealTypes = ['Ontbijt', 'Lunch', 'Avondeten', 'Snacks'];

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Hoeveelheid voor "$productName"',
                style: TextStyle(color: textColor),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Hoeveelheid (gram of milliliter)',
                        suffixText: 'g of ml',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Voer een hoeveelheid in';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Voer een geldig getal in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMeal,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(labelText: 'Sectie'),
                      items: mealTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
                          selectedMeal = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(
                        amountController.text.replaceAll(',', '.'),
                      );
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || nutriments == null) {
                        Navigator.pop(dialogContext, false);
                        return;
                      }

                      final factor = amount / 100.0;

                      final nutrimentsJson = nutriments;

                      final calculatedNutriments = {
                        'energy-kcal':
                            (nutrimentsJson['energy-kcal_100g'] as num? ??
                                nutrimentsJson['energy-kcal'] as num? ??
                                0) *
                            factor,
                        'fat':
                            (nutrimentsJson['fat_100g'] as num? ??
                                nutrimentsJson['fat'] as num? ??
                                0) *
                            factor,
                        'saturated-fat':
                            (nutrimentsJson['saturated-fat_100g'] as num? ??
                                nutrimentsJson['saturated-fat'] as num? ??
                                0) *
                            factor,
                        'carbohydrates':
                            (nutrimentsJson['carbohydrates_100g'] as num? ??
                                nutrimentsJson['carbohydrates'] as num? ??
                                0) *
                            factor,
                        'sugars':
                            (nutrimentsJson['sugars_100g'] as num? ??
                                nutrimentsJson['sugars'] as num? ??
                                0) *
                            factor,
                        'fiber':
                            (nutrimentsJson['fiber_100g'] as num? ??
                                nutrimentsJson['fiber'] as num? ??
                                0) *
                            factor,
                        'proteins':
                            (nutrimentsJson['proteins_100g'] as num? ??
                                nutrimentsJson['proteins'] as num? ??
                                0) *
                            factor,
                        'salt':
                            (nutrimentsJson['salt_100g'] as num? ??
                                nutrimentsJson['salt'] as num? ??
                                0) *
                            factor,
                      };

                      final now = DateTime.now();
                      final todayDocId =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                      final dailyLogRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('logs')
                          .doc(todayDocId);

                      final logEntry = {
                        'product_name': productName,
                        'amount_g': amount,
                        'timestamp': Timestamp.now(),
                        'nutriments': calculatedNutriments,
                        'meal_type': selectedMeal,
                      };

                      try {
                        await dailyLogRef.set({
                          'entries': FieldValue.arrayUnion([logEntry]),
                        }, SetOptions(merge: true));

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$productName toegevoegd aan je logboek.',
                              ),
                            ),
                          );
                        }
                        // Sluit de dialoog en geef 'true' terug voor succes.
                        Navigator.pop(dialogContext, true);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Fout bij opslaan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        // Sluit de dialoog en geef 'false' terug bij een fout.
                        Navigator.pop(dialogContext, false);
                      }
                    }
                  },
                  child: const Text('Opslaan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
