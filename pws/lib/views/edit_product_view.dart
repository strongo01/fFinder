import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductEditSheet extends StatefulWidget {
  final String barcode;
  final Map<String, dynamic>? productData;
  final bool isForMeal;
  final double? initialAmount;

  const ProductEditSheet({
    Key? key,
    required this.barcode,
    this.productData,
    this.isForMeal = false,
    this.initialAmount,
  }) : super(key: key);

  @override
  State<ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends State<ProductEditSheet> {
  Product? product;
  String? error;
  bool isLoading = true;
  bool isFavorite = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController caloriesController;
  late TextEditingController fatController;
  late TextEditingController amountController;
  late TextEditingController saturatedFatController;
  late TextEditingController carbsController;
  late TextEditingController sugarsController;
  late TextEditingController fiberController;
  late TextEditingController proteinsController;
  late TextEditingController saltController;

  @override
  void initState() {
    super.initState();
    // Initialiseer controllers
    caloriesController = TextEditingController();
    fatController = TextEditingController();
    amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    saturatedFatController = TextEditingController();
    carbsController = TextEditingController();
    sugarsController = TextEditingController();
    fiberController = TextEditingController();
    proteinsController = TextEditingController();
    saltController = TextEditingController();

    // Start direct met data ophalen
    _fetchDetails();
  }

  @override
  void dispose() {
    // Hier worden ze  opgeruimd

    caloriesController.dispose();
    fatController.dispose();
    amountController.dispose();
    saturatedFatController.dispose();
    carbsController.dispose();
    sugarsController.dispose();
    fiberController.dispose();
    proteinsController.dispose();
    saltController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    // 1. Check of lokale data is meegegeven
    if (widget.productData != null) {
      try {
        final isFav = await _isFavorite(
          widget.barcode,
        ); // Zorg dat _isFavorite bereikbaar is of pas dit aan
        final nutriments =
            widget.productData!['nutriments_per_100g']
                as Map<String, dynamic>? ??
            {};

        _fillControllers(nutriments);

        final loadedProduct = Product(
          barcode: widget.barcode,
          productName: widget.productData!['product_name'],
          brands: widget.productData!['brands'],
          quantity: widget.productData!['quantity'],
          imageFrontUrl: widget.productData!['image_front_url'],
          additives: Additives(
            [],
            (widget.productData!['additives'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          ),
          allergens: Allergens(
            [],
            (widget.productData!['allergens'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          ),
        );

        if (mounted) {
          setState(() {
            product = loadedProduct;
            isLoading = false;
            isFavorite = isFav;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            error = 'Fout bij laden lokale data: $e';
            isLoading = false;
          });
        }
      }
      return;
    }

    // 2. Anders ophalen via API
    try {
      final isFav = await _isFavorite(widget.barcode);
      final config = ProductQueryConfiguration(
        widget.barcode,
        language: OpenFoodFactsLanguage.DUTCH,
        fields: [ProductField.ALL],
        version: ProductQueryVersion.v3,
      );
      final result = await OpenFoodAPIClient.getProductV3(config);

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        final p = result.product!;

        // Vul controllers handmatig vanuit het Product object
        if (caloriesController.text.isEmpty) {
          caloriesController.text =
              p.nutriments
                  ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)
                  ?.toString() ??
              '';
          fatController.text =
              p.nutriments
                  ?.getValue(Nutrient.fat, PerSize.oneHundredGrams)
                  ?.toString() ??
              '';
          saturatedFatController.text =
              p.nutriments
                  ?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams)
                  ?.toString() ??
              '';
          carbsController.text =
              p.nutriments
                  ?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams)
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
        }

        if (mounted) {
          setState(() {
            product = p;
            isLoading = false;
            isFavorite = isFav;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            error = 'Product niet gevonden.';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Fout bij ophalen: $e';
          isLoading = false;
        });
      }
    }
  }

  void _fillControllers(Map<String, dynamic> nutriments) {
    if (caloriesController.text.isNotEmpty)
      return; // Niet overschrijven als er al iets staat
    caloriesController.text = nutriments['energy-kcal']?.toString() ?? '';
    fatController.text = nutriments['fat']?.toString() ?? '';
    saturatedFatController.text = nutriments['saturated-fat']?.toString() ?? '';
    carbsController.text = nutriments['carbohydrates']?.toString() ?? '';
    sugarsController.text = nutriments['sugars']?.toString() ?? '';
    fiberController.text = nutriments['fiber']?.toString() ?? '';
    proteinsController.text = nutriments['proteins']?.toString() ?? '';
    saltController.text = nutriments['salt']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (product == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Geen productinformatie beschikbaar.')),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6, // Beginhoogte van de sheet
      minChildSize: 0.4, // Minimale hoogte van de sheet
      maxChildSize: 0.9, // Maximale hoogte van de sheet
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  16, // Voor toetsenbord
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product!.productName ?? 'Onbekende naam',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(color: textColor),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await _removeFavoriteProduct(product!.barcode!);
                            if (mounted)
                              setState(() => isFavorite = !isFavorite);
                          } else {
                            if (_formKey.currentState!.validate()) {
                              final nutrimentsData =
                                  _getNutrimentsFromControllers();
                              await _addFavoriteProduct(
                                product!,
                                editedNutriments: nutrimentsData,
                              );
                              if (mounted)
                                setState(() => isFavorite = !isFavorite);
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
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final nutrimentsData =
                                _getNutrimentsFromControllers();
                            await _addRecentProduct(
                              product!,
                              editedNutriments: nutrimentsData,
                            );

                            final bool? wasAdded = await _showAddLogDialog(
                              context,
                              product!.productName ?? 'Onbekend product',
                              nutrimentsData,
                            );
                            if (wasAdded == true && mounted) {
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
                  _buildEditableInfoRow('Vetten', fatController, isDarkMode),
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
                  _buildEditableInfoRow('Vezels', fiberController, isDarkMode),
                  _buildEditableInfoRow(
                    'Eiwitten',
                    proteinsController,
                    isDarkMode,
                  ),
                  _buildEditableInfoRow('Zout', saltController, isDarkMode),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Additieven',
                    product!.additives?.names.join(", "),
                  ),
                  _buildInfoRow(
                    'Allergenen',
                    product!.allergens?.names.join(", "),
                  ),

                  if (widget.isForMeal) ...[
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                          style: TextStyle(color: textColor),
          cursorColor: textColor, 
                      decoration: InputDecoration(
                        labelText: 'Hoeveelheid voor maaltijd',
                        suffixText: 'g',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        suffixStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('Voeg toe aan Maaltijd'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final nutrimentsData =
                              _getNutrimentsFromControllers();
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
                    const SizedBox(height: 32), // Extra ruimte onderaan
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, double?> _getNutrimentsFromControllers() {
    double? parse(TextEditingController c) =>
        double.tryParse(c.text.replaceAll(',', '.'));
    return {
      'energy-kcal': parse(caloriesController),
      'fat': parse(fatController),
      'saturated-fat': parse(saturatedFatController),
      'carbohydrates': parse(carbsController),
      'sugars': parse(sugarsController),
      'fiber': parse(fiberController),
      'proteins': parse(proteinsController),
      'salt': parse(saltController),
    };
  }

  Widget _buildInfoRow(String label, String? value) {
    // bouw een rij met niet-bewerkbare info
    if (value == null || value.trim().isEmpty) {
      // geen waarde om te tonen
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
              '$label:', // label tekst
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

  Widget _buildEditableInfoRow(
    // bouw een rij met bewerkbare voedingswaarde
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

  Future<void> _addRecentProduct(
    // voeg recent product toe
    Product product, {
    Map<String, dynamic>? editedNutriments, // bewerkte voedingswaarden
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

  /*
  Future<void> _addRecentMyProduct(
    // voeg recent eigen product toe
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
    dataToSave['isMyProduct'] = true; // markeer als eigen product

    await docRef.set(dataToSave, SetOptions(merge: true)); // sla op met merge
  }
*/
  Future<void> _addFavoriteProduct(
    // voeg favoriet product toe
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

  Future<bool?> _showAddLogDialog(
    // toon dialoog om product aan log toe te voegen
    BuildContext context,
    String productName,
    Map<String, dynamic>? nutriments,
  ) async {
    final amountController =
        TextEditingController(); // controller voor hoeveelheid input
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
