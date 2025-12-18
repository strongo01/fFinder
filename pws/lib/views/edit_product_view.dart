import 'package:fFinder/views/crypto_class.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductEditSheet extends StatefulWidget {
  final String barcode;
  final Map<String, dynamic>? productData;
  final bool isForMeal;
  final double? initialAmount;
  final DateTime? selectedDate;

  const ProductEditSheet({
    Key? key,
    required this.barcode,
    this.productData,
    this.isForMeal = false,
    this.initialAmount,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends State<ProductEditSheet> {
  Product? product;
  String? error;
  bool isLoading = true;
  bool isFavorite = false;
  String? servingSize;
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
  late TextEditingController productNameController;
  bool isEditingName = false;

  @override
  void initState() {
    super.initState();
    // Initialiseer controllers
    caloriesController = TextEditingController();
    fatController = TextEditingController();
    amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    ); // Voor maaltijd hoeveelheid
    saturatedFatController = TextEditingController();
    carbsController = TextEditingController();
    sugarsController = TextEditingController();
    fiberController = TextEditingController();
    proteinsController = TextEditingController();
    saltController = TextEditingController();
    productNameController = TextEditingController(
      text: widget.productData != null
          ? (widget.productData!['product_name'] as String? ?? '')
          : '',
    );

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
    productNameController.dispose();
    super.dispose();
  }

  List<String> _normalizeTags(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return <String>[];

      // 1) Probeer expliciete OFF-tags zoals "en:milk"
      final matches = RegExp(
        r'en:[^,;\/\s]+',
      ).allMatches(s).map((m) => m.group(0)!).toList();
      if (matches.isNotEmpty) return matches;

      // 2) Fallback: split op comma/semicolon/slash/whitespace
      final parts = s
          .split(RegExp(r'[,\;\/\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts;

      return <String>[s];
    }
    // Onverwachte type: fallback naar stringified single element
    return <String>[v.toString()];
  }

  String? _extractServingSize(dynamic v) {
    if (v == null) return null;
    if (v is num) return "${v.toString()} g";
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      final unitMatch = RegExp(
        r'(\d+(?:[.,]\d+)?)\s*(g|gram|gr|ml)',
        caseSensitive: false,
      ).firstMatch(s);
      if (unitMatch != null) {
        final numPart = unitMatch.group(1)!.replaceAll(',', '.');
        final unit = unitMatch.group(2)!.toLowerCase();
        if (unit == 'ml')
          return "${double.tryParse(numPart)?.toString() ?? numPart} ml";
        return "${double.tryParse(numPart)?.toString() ?? numPart} g";
      }
      final numOnly = double.tryParse(s.replaceAll(',', '.'));
      if (numOnly != null) return "${numOnly.toString()} g";
      return s;
    }
    return v.toString();
  }

  Map<String, dynamic> _mergeAndNormalizeNutriments(
    Map<String, dynamic>? per100g,
    Map<String, dynamic>? nutriments,
  ) {
    final out = <String, dynamic>{};

    String normalizeKey(String k) {
      return k
          .replaceAll('_', '-')
          .replaceAll(RegExp(r'(-|_)100g$'), '')
          .replaceAll(RegExp(r'per-100g'), '')
          .trim();
    }

    // Voeg per100g eerst toe (bewaar ook expliciete 0.0)
    if (per100g != null) {
      per100g.forEach((k, v) {
        final key = normalizeKey(k);
        if (key.isEmpty) return;
        out[key] = v;
      });
    }

    // Voeg nutriments daarna toe, maar alleen als waarde niet null.
    // Overschrijf bestaande waarde alleen als die null is of numeriek 0.
    if (nutriments != null) {
      nutriments.forEach((k, v) {
        if (v == null)
          return; // skip null zodat we geen per100g 0 overschrijven met null
        final key = normalizeKey(k);
        if (key.isEmpty) return;
        final existing = out[key];
        if (existing == null || (existing is num && existing == 0)) {
          out[key] = v;
        }
      });
    }

    return out;
  }

  Future<void> _fetchDetails() async {
    // Haal productdetails op van OpenFoodFacts of gebruik lokale data
    if (widget.productData != null) {
      try {
        final isFav = await _isFavorite(
          widget.barcode,
        ); // Zorg dat _isFavorite bereikbaar is of pas dit aan
        /* final nutriments =
            widget.productData!['nutriments_per_100g']
                as Map<String, dynamic>? ??
            {};

        _fillControllers(nutriments);*/

        final rawPer100 =
            widget.productData!['nutriments_per_100g'] as Map<String, dynamic>?;
        final rawNut =
            widget.productData!['nutriments'] as Map<String, dynamic>?;
        final mergedNutriments = _mergeAndNormalizeNutriments(
          rawPer100,
          rawNut,
        );
        _fillControllers(mergedNutriments);

        final loadedProduct = Product(
          // Maak een Product object aan
          barcode: widget.barcode,
          productName: widget.productData!['product_name'],
          brands: widget.productData!['brands'],
          quantity: widget.productData!['quantity'],
          imageFrontUrl: widget.productData!['image_front_url'],
          additives: Additives(
            [],
            _normalizeTags(widget.productData!['additives']),
          ),
          allergens: Allergens(
            [],
            _normalizeTags(widget.productData!['allergens']),
          ),
        );

        servingSize = _extractServingSize(
          widget.productData!['serving_size'] ??
              widget.productData!['serving-size'] ??
              widget.productData!['servingSize'] ??
              widget.productData!['serving_quantity'],
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
    // Haal van OpenFoodFacts
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
            servingSize = _extractServingSize(p.servingSize);
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

  Future<void> _saveEditedName() async {
    final newName = productNameController.text.trim();
    final effectiveBarcode = product?.barcode ?? widget.barcode;

    final updatedProduct = Product(
      barcode: effectiveBarcode,
      productName: newName.isEmpty ? null : newName,
      brands: product!.brands,
      quantity: product!.quantity,
      imageFrontUrl: product!.imageFrontUrl,
      imageFrontSmallUrl: product!.imageFrontSmallUrl,
      additives: product!.additives,
      allergens: product!.allergens,
      nutriments: product!.nutriments,
      servingSize: product!.servingSize,
    );

    // Update local state
    setState(() {
      product = updatedProduct;
      isEditingName = false;
    });
    FocusScope.of(context).unfocus();

    try {
      final nutrimentsData = _getNutrimentsFromControllers();
      final futures = <Future>[];
      if (isFavorite) {
        futures.add(_addFavoriteProduct(
          updatedProduct,
          editedNutriments: nutrimentsData,
        ));
      }
      futures.add(_addRecentProduct(
        updatedProduct,
        editedNutriments: nutrimentsData,
      ));
      await Future.wait(futures);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Naam opgeslagen.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: isEditingName
                                  ? TextFormField(
                                      controller: productNameController,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(color: textColor),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: UnderlineInputBorder(),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) async {
                                        await _saveEditedName();
                                      },
                                    )
                                  : GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        productNameController.text =
                                            product!.productName ?? '';
                                        setState(() => isEditingName = true);
                                      },
                                      child: Text(
                                        (product!.productName == null ||
                                                product!.productName!
                                                    .trim()
                                                    .isEmpty)
                                            ? 'Onbekende naam'
                                            : product!.productName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(color: textColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                            ),
                            // Toon vinkje alleen tijdens bewerken
                            if (isEditingName)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Opslaan naam',

                                icon: const Icon(Icons.check),
onPressed: _saveEditedName,
                              ),
                          ],
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
                              final nutrimentsData = // haal bewerkte voedingswaarden op
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
                              servingSize,
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
                  const SizedBox(height: 16),
                  Text(
                    'Voedingswaarden per 100g of ml',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _buildInfoRow('Portiegrootte', servingSize),

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
                    // Alleen tonen als voor maaltijd
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
    // haal bewerkte voedingswaarden op
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
    Product product, {
    Map<String, dynamic>? editedNutriments,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // final barcode = product.barcode;
    final barcode = product.barcode ?? widget.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) return;

    final nutriments =
        editedNutriments ??
        {
          'energy-kcal': product.nutriments?.getValue(
            Nutrient.energyKCal,
            PerSize.oneHundredGrams,
          ),
          'fat': product.nutriments?.getValue(
            Nutrient.fat,
            PerSize.oneHundredGrams,
          ),
          'saturated-fat': product.nutriments?.getValue(
            Nutrient.saturatedFat,
            PerSize.oneHundredGrams,
          ),
          'carbohydrates': product.nutriments?.getValue(
            Nutrient.carbohydrates,
            PerSize.oneHundredGrams,
          ),
          'sugars': product.nutriments?.getValue(
            Nutrient.sugars,
            PerSize.oneHundredGrams,
          ),
          'fiber': product.nutriments?.getValue(
            Nutrient.fiber,
            PerSize.oneHundredGrams,
          ),
          'proteins': product.nutriments?.getValue(
            Nutrient.proteins,
            PerSize.oneHundredGrams,
          ),
          'salt': product.nutriments?.getValue(
            Nutrient.salt,
            PerSize.oneHundredGrams,
          ),
        };

    final encryptedNutriments = <String, dynamic>{};
    for (final key in nutriments.keys) {
      encryptedNutriments[key] = await encryptDouble(
        nutriments[key] ?? 0,
        userDEK,
      );
    }

    final productData = {
      'product_name': await encryptValue(product.productName ?? '', userDEK),
      'brands': await encryptValue(product.brands ?? '', userDEK),
      'image_front_url': product.imageFrontUrl,
      'serving_size': (servingSize ?? product.servingSize) != null
          ? await encryptValue((servingSize ?? product.servingSize)!, userDEK)
          : null,
      'quantity': await encryptValue(product.quantity ?? '', userDEK),
      'timestamp': FieldValue.serverTimestamp(),
      'nutriments_per_100g': encryptedNutriments,
      'allergens': product.allergens?.names,
      'additives': product.additives?.names,
      'isMyProduct': false,
    };

    productData.removeWhere((key, value) => value == null);
    (productData['nutriments_per_100g'] as Map).removeWhere(
      (key, value) => value == null,
    );

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recents')
        .doc(barcode);

    await docRef.set(productData, SetOptions(merge: true));
  }

  Future<void> _addFavoriteProduct(
    Product product, {
    Map<String, dynamic>? editedNutriments,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    //final barcode = product.barcode;
    final barcode = product.barcode ?? widget.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) return;

    final nutriments =
        editedNutriments ??
        {
          'energy-kcal': product.nutriments?.getValue(
            Nutrient.energyKCal,
            PerSize.oneHundredGrams,
          ),
          'fat': product.nutriments?.getValue(
            Nutrient.fat,
            PerSize.oneHundredGrams,
          ),
          'saturated-fat': product.nutriments?.getValue(
            Nutrient.saturatedFat,
            PerSize.oneHundredGrams,
          ),
          'carbohydrates': product.nutriments?.getValue(
            Nutrient.carbohydrates,
            PerSize.oneHundredGrams,
          ),
          'sugars': product.nutriments?.getValue(
            Nutrient.sugars,
            PerSize.oneHundredGrams,
          ),
          'fiber': product.nutriments?.getValue(
            Nutrient.fiber,
            PerSize.oneHundredGrams,
          ),
          'proteins': product.nutriments?.getValue(
            Nutrient.proteins,
            PerSize.oneHundredGrams,
          ),
          'salt': product.nutriments?.getValue(
            Nutrient.salt,
            PerSize.oneHundredGrams,
          ),
        };

    final encryptedNutriments = <String, dynamic>{};
    for (final key in nutriments.keys) {
      encryptedNutriments[key] = await encryptDouble(
        nutriments[key] ?? 0,
        userDEK,
      );
    }

    final productData = {
      'product_name': await encryptValue(product.productName ?? '', userDEK),
      'brands': await encryptValue(product.brands ?? '', userDEK),
      'image_front_url': product.imageFrontUrl,
      'quantity': await encryptValue(product.quantity ?? '', userDEK),
      'serving_size': (servingSize ?? product.servingSize) != null
          ? await encryptValue((servingSize ?? product.servingSize)!, userDEK)
          : null,
      'timestamp': FieldValue.serverTimestamp(),
      'nutriments_per_100g': encryptedNutriments,
      'allergens': product.allergens?.names,
      'additives': product.additives?.names,
    };

    productData.removeWhere((key, value) => value == null);
    (productData['nutriments_per_100g'] as Map).removeWhere(
      (key, value) => value == null,
    );

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(barcode);

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
    String? servingSize,
  ) async {
    final amountController =
        TextEditingController(); // controller voor hoeveelheid input
    if (servingSize != null && servingSize.trim().isNotEmpty) {
      final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(servingSize);
      if (match != null) {
        amountController.text = match.group(1)!.replaceAll(',', '.');
      }
    }
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
      selectedMeal = 'Tussendoor';
    }
    final List<String> mealTypes = [
      'Ontbijt',
      'Lunch',
      'Avondeten',
      'Tussendoor',
    ];

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
                      autofocus: true, // focus op dit veld
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

                      final userDEK = await getUserDEKFromRemoteConfig(
                        user.uid,
                      );
                      if (userDEK == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kon encryptiesleutel niet ophalen.'),
                          ),
                        );
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

                      /* final now = DateTime.now();
                      final todayDocId =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
*/
                      debugPrint("SELECTEDDATE: ${widget.selectedDate}");
                      final date = widget.selectedDate ?? DateTime.now();
                      final todayDocId =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                      final dailyLogRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('logs')
                          .doc(todayDocId);

                      // Encrypt de waarden
                      final logEntry = {
                        'product_name': await encryptValue(
                          productName,
                          userDEK,
                        ),
                        'amount_g': await encryptDouble(amount, userDEK),
                        'timestamp': Timestamp.now(),
                        'nutrients': {
                          for (final key in calculatedNutriments.keys)
                            key: await encryptDouble(
                              calculatedNutriments[key] ?? 0,
                              userDEK,
                            ),
                        },
                        'meal_type': await encryptValue(selectedMeal, userDEK),
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
