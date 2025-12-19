import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fFinder/views/barcode_scanner.dart';

class AddDrinkPage extends StatefulWidget {
  final DateTime? selectedDate;
  const AddDrinkPage({super.key, this.selectedDate});

  @override
  State<AddDrinkPage> createState() => _AddDrinkPageState();
}

class _AddDrinkPageState extends State<AddDrinkPage> {
  List<Map<String, dynamic>> _drinkPresets = []; // lijst van drank standaarden
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrinkPresets();
  }

  Future<void> _loadDrinkPresets() async {
    // laadt de drank standaarden van firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _drinkPresets = [
          {'name': 'Water', 'amount': 200, 'kcal': 0},
        ];
      });
      return;
    }
    SecretKey? userDEK = await getUserDEKFromRemoteConfig(user.uid);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()!.containsKey('drinkPresets')) {
        final rawList = doc.data()!['drinkPresets'] as List<dynamic>;
        final presets = <Map<String, dynamic>>[];

        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final map = Map<String, dynamic>.from(item);

            // decrypt naam indien nodig
            if (userDEK != null && map['name'] is String) {
              try {
                map['name'] = await decryptValue(
                  map['name'] as String,
                  userDEK,
                );
              } catch (_) {
                // laat origineel staan bij fout
              }
            }

            // decrypt amount indien nodig
            if (userDEK != null) {
              final amountVal = map['amount'];
              if (amountVal is String) {
                try {
                  final decryptedAmount = await decryptValue(
                    amountVal,
                    userDEK,
                  );
                  map['amount'] =
                      int.tryParse(decryptedAmount) ?? decryptedAmount;
                } catch (_) {}
              } else if (amountVal is num) {
                map['amount'] = amountVal.toInt();
              }
            }

            // decrypt kcal indien nodig
            if (userDEK != null && map.containsKey('kcal')) {
              final kcalVal = map['kcal'];
              if (kcalVal is String) {
                try {
                  final decryptedKcal = await decryptValue(kcalVal, userDEK);
                  map['kcal'] = double.tryParse(decryptedKcal) ?? decryptedKcal;
                } catch (_) {}
              } else if (kcalVal is num) {
                map['kcal'] = kcalVal.toDouble();
              }
            }

            presets.add(map);
          }
        }

        setState(() {
          _drinkPresets = presets;
        });
      } else {
        setState(() {
          _drinkPresets = [
            {'name': 'Water', 'amount': 200},
          ];
        });
      }
    } catch (e) {
      setState(() {
        _drinkPresets = [
          {'name': 'Water', 'amount': 200},
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDrinkPresets() async {
    // slaat de drank standaarden op in firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    SecretKey? userDEK = await getUserDEKFromRemoteConfig(user.uid);

    final toSave = <Map<String, dynamic>>[];
    for (final preset in _drinkPresets) {
      final map = <String, dynamic>{};
      final nameVal = preset['name'];
      if (userDEK != null && nameVal is String) {
        try {
          map['name'] = await encryptValue(nameVal, userDEK);
        } catch (_) {
          map['name'] = nameVal;
        }
      } else {
        map['name'] = nameVal;
      }

      final amountVal = preset['amount'];
      if (userDEK != null) {
        try {
          if (amountVal is int) {
            map['amount'] = await encryptInt(amountVal, userDEK);
          } else if (amountVal is double) {
            map['amount'] = await encryptDouble(amountVal, userDEK);
          } else if (amountVal is String) {
            map['amount'] = await encryptValue(amountVal, userDEK);
          } else {
            map['amount'] = amountVal;
          }
        } catch (_) {
          map['amount'] = amountVal;
        }
      } else {
        map['amount'] = amountVal;
      }

      final kcalVal = preset['kcal'];
      if (userDEK != null) {
        try {
          if (kcalVal is int) {
            map['kcal'] = await encryptInt(kcalVal, userDEK);
          } else if (kcalVal is double) {
            map['kcal'] = await encryptDouble(kcalVal, userDEK);
          } else if (kcalVal is String) {
            map['kcal'] = await encryptValue(kcalVal, userDEK);
          } else {
            map['kcal'] = kcalVal;
          }
        } catch (_) {
          map['kcal'] = kcalVal;
        }
      } else {
        map['kcal'] = kcalVal;
      }

      toSave.add(map);
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'drinkPresets': toSave,
    }, SetOptions(merge: true));
  }

  Future<void> _logDrink(
    String name,
    int amount,
    String drinkTime,
    double kcal,
  ) async {
    // logt het drinken van een drankje
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je moet ingelogd zijn om te loggen.')),
      );
      return;
    }

    SecretKey? userDEK = await getUserDEKFromRemoteConfig(user.uid);

    /*final now = DateTime.now();
    final todayDocId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
*/
    final date = widget.selectedDate ?? DateTime.now();
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    String productNameField = name;
    String quantityField = '$amount ml';
    String mealTypeField = drinkTime;
    String drinkTimeField = drinkTime;
    String kcalField = kcal.toString();

    if (userDEK != null) {
      try {
        productNameField = await encryptValue(name, userDEK);
      } catch (_) {
        productNameField = name;
      }
      try {
        quantityField = await encryptInt(amount, userDEK);
      } catch (_) {
        quantityField = '$amount ml';
      }
      try {
        mealTypeField = await encryptValue(drinkTime, userDEK);
      } catch (_) {
        mealTypeField = drinkTime;
      }
      try {
        drinkTimeField = await encryptValue(drinkTime, userDEK);
      } catch (_) {
        drinkTimeField = drinkTime;
      }
      try {
        kcalField = await encryptDouble(kcal, userDEK);
      } catch (_) {
        kcalField = kcal.toString();
      }
    }

    final logEntry = {
      'product_name': productNameField,
      'quantity': quantityField,
      'meal_type': mealTypeField,
      'drinkTime': drinkTimeField,
      'timestamp': date,

      'kcal': kcalField,
      'nutriments': {
        'energy-kcal': 0,
        'fat': 0,
        'saturated-fat': 0,
        'carbohydrates': 0,
        'sugars': 0,
        'proteins': 0,
        'salt': 0,
      },
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(todayDocId)
        .set({
          'entries': FieldValue.arrayUnion([logEntry]),
        }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name ($amount ml) toegevoegd!')));
      Navigator.of(context).pop();
    }
  }

  void _showAddPresetDialog() {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final kcalController = TextEditingController();
    final customNameController = TextEditingController();
    String? selectedDrink;
    String? coffeeVariant; // voor koffie
    final drinkOptions = ['Water', 'Koffie', 'Thee', 'Frisdrank', 'Anders'];
    final coffeeVariants = [
      'Koffie zwart',
      'Espresso',
      'Ristretto',
      'Lungo',
      'Americano',
      'Koffie met melk',
      'Koffie met melk + suiker',
      'Cappuccino',
      'Latte',
      'Flat White',
      'Macchiato',
      'Latte Macchiato',
      'Iced Coffee',
      'Andere koffie',
    ];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateKcalForCoffee() {
              switch (coffeeVariant) {
                case 'Koffie zwart':
                case 'Espresso':
                case 'Ristretto':
                case 'Lungo':
                case 'Americano':
                  kcalController.text = '2';
                  break;
                case 'Koffie met melk':
                  kcalController.text = '12';
                  break;
                case 'Koffie met melk + suiker':
                  kcalController.text = '25';
                  break;
                case 'Cappuccino':
                  kcalController.text = '55';
                  break;
                case 'Latte':
                case 'Flat White':
                  kcalController.text = '45';
                  break;
                case 'Macchiato':
                  kcalController.text = '10';
                  break;
                case 'Latte Macchiato':
                  kcalController.text = '50';
                  break;
                case 'Iced Coffee':
                  kcalController.text = '60';
                  break;
                case 'Andere koffie':
                default:
                  kcalController.text = '';
                  break;
              }
            }

            return AlertDialog(
              title: Text(
                'Nieuw Drankje Toevoegen',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // maximal hoogte zodat de dialog niet buiten scherm valt
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedDrink,
                          hint: const Text('Kies een drankje'),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedDrink = value;
                              coffeeVariant = null;
                              if (value == 'Water' || value == 'Thee') {
                                kcalController.text = '0';
                              } else if (value != 'Koffie') {
                                kcalController.text = '';
                              }
                            });
                          },
                          items: drinkOptions
                              .map(
                                (drink) => DropdownMenuItem(
                                  value: drink,
                                  child: Text(
                                    drink,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          validator: (value) =>
                              value == null ? 'Kies een drankje' : null,
                        ),

                        // koffie variant dropdown
                        if (selectedDrink == 'Koffie') ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: coffeeVariant,
                            hint: const Text('Kies koffiesoort'),
                            onChanged: (value) {
                              setStateDialog(() {
                                coffeeVariant = value;
                                updateKcalForCoffee();
                              });
                            },
                            items: coffeeVariants
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(
                                      v,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            validator: (value) =>
                                value == null ? 'Kies een koffiesoort' : null,
                          ),
                        ],

                        if (selectedDrink == 'Anders')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              controller: customNameController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Naam van drankje',
                                labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              validator: (value) =>
                                  (selectedDrink == 'Anders' && value!.isEmpty)
                                  ? 'Naam is verplicht'
                                  : null,
                            ),
                          ),

                        TextFormField(
                          controller: amountController,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Hoeveelheid (ml)',
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Hoeveelheid is verplicht';
                            if (int.tryParse(value) == null)
                              return 'Voer een getal in';
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),
                        TextFormField(
                          controller: kcalController,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Kcal per 100 ml',
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            // toevoeging: barcode knop rechts
                            suffixIcon: IconButton(
                              tooltip: 'Zoek op barcode',
                              icon: Icon(
                                Icons.qr_code_scanner,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: () => _promptForBarcodeAndFillKcal(kcalController),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) return 'Kcal is verplicht';
                            if (double.tryParse(value) == null)
                              return 'Voer een getal in';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // naam bepalen
                      String name;
                      if (selectedDrink == 'Koffie' &&
                          coffeeVariant != null &&
                          coffeeVariant != 'Andere koffie') {
                        name = coffeeVariant!;
                      } else if (selectedDrink == 'Anders') {
                        name = customNameController.text;
                      } else {
                        name = selectedDrink!;
                      }

                      final amount = int.parse(amountController.text);
                      final kcalPer100 = double.parse(
                        kcalController.text.replaceAll(',', '.'),
                      );
                      final kcalForPortion = (kcalPer100 * amount) / 100.0;

                      setState(() {
                        _drinkPresets.add({
                          'name': name,
                          'amount': amount,
                          'kcal': kcalForPortion,
                        });
                      });
                      _saveDrinkPresets();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double?> _fetchKcalFromBarcode(String barcode) async {
    final url = Uri.parse(
      'https://nl.openfoodfacts.org/api/v0/product/$barcode.json',
    );
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        debugPrint('[fetchKcal] HTTP ${resp.statusCode}');
        return null;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>?;
      if (data == null) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      // Try several possible nutriments maps/keys
      final nutrimentsCandidates = <Map<String, dynamic>?>[
        product['nutriments_per_100g'] as Map<String, dynamic>?,
        product['nutriments'] as Map<String, dynamic>?,
        product['nutriments_100g'] as Map<String, dynamic>?,
      ];

      Map<String, dynamic>? nutr;
      for (final cand in nutrimentsCandidates) {
        if (cand != null) {
          nutr = cand;
          break;
        }
      }
      if (nutr == null) return null;

      // Common key variants to check (lowercased for safety)
      final keys = nutr.keys.map((k) => k.toString()).toList();
      // prefer energy-kcal_100g, then energy-kcal, then energykcal_100g, etc.
      final candidates = [
        'energy-kcal_100g',
        'energy-kcal',
        'energy-kcal_100g_value',
        'energykcal_100g',
        'energykcal',
        'energy-kcal_value',
        'energy-kcal_100g_value',
      ];

      for (final k in candidates) {
        if (nutr.containsKey(k)) {
          final v = nutr[k];
          if (v is num) return v.toDouble();
          final parsed = double.tryParse(v?.toString() ?? '');
          if (parsed != null) return parsed;
        }
      }

      // fallback: try any key that contains 'energy' and 'kcal'
      for (final key in keys) {
        final lk = key.toLowerCase();
        if (lk.contains('energy') && lk.contains('kcal')) {
          final v = nutr[key];
          if (v is num) return v.toDouble();
          final parsed = double.tryParse(v?.toString() ?? '');
          if (parsed != null) return parsed;
        }
      }

      return null;
    } catch (e) {
      debugPrint('[fetchKcal] error: $e');
      return null;
    }
  }

  Future<void> _promptForBarcodeAndFillKcal(
    TextEditingController kcalController,
  ) async {
    final barcodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Scan / plak barcode',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Form(
            key: formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barcode (EAN/GTIN)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Voer barcode in'
                        : null,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // scan knop: opent jouw barcode_scanner pagina en plakt resultaat in het veld
                IconButton(
                  tooltip: 'Scan barcode',
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () async {
                    // Pas de volgende regel aan naar de juiste scanner widget/class in jouw project.
                    // Verwacht dat de scanner via Navigator.pop(barcodeString) het resultaat teruggeeft.
                    final scanned = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const SimpleBarcodeScannerPage(),
                      ),
                    );
                    if (scanned != null && scanned.isNotEmpty) {
                      barcodeController.text = scanned;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Zoeken'),
            ),
          ],
        );
      },
    );

    if (res != true) return;
    final bc = barcodeController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zoeken...'),
        duration: Duration(seconds: 2),
      ),
    );
    final kcal = await _fetchKcalFromBarcode(bc);
    if (kcal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geen kcal-waarde gevonden voor barcode $bc')),
      );
      return;
    }
    kcalController.text = kcal.round().toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gevonden: ${kcal.round()} kcal per 100g/ml')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Drinken Toevoegen')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // rooster met vaste aantal kolommen
                  crossAxisCount: 3, // aantal kolommen
                  crossAxisSpacing: 8, // ruimte tussen kolommen
                  mainAxisSpacing: 8, // ruimte tussen rijen
                  childAspectRatio: 1, // vierkante knoppen
                ),
                itemCount: _drinkPresets.length + 1,
                itemBuilder: (context, index) {
                  if (index == _drinkPresets.length) {
                    return InkWell(
                      onTap: _showAddPresetDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.green, size: 40),
                        ),
                      ),
                    );
                  }

                  final preset = _drinkPresets[index];
                  final colors = _getColorsForDrink(
                    preset['name'],
                    isDarkMode,
                  ); // bepaal kleuren op basis van dranknaam

                  return ElevatedButton(
                    onPressed: () async {
                      final mealOptions = [
                        'Ontbijt',
                        'Lunch',
                        'Avondeten',
                        'Tussendoor',
                      ];
                      final selected = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            title: Text(
                              'Wanneer gedronken?',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: mealOptions.map((m) {
                                // maak een lijstitem voor elke maaltijdoptie
                                return ListTile(
                                  title: Text(
                                    m,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () => Navigator.of(context).pop(m),
                                );
                              }).toList(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuleren'),
                              ),
                            ],
                          );
                        },
                      );

                      if (selected != null) {
                        // als er een optie is geselecteerd
                        await _logDrink(
                          preset['name'],
                          preset['amount'],
                          selected,
                          preset['kcal'] ?? 0.0,
                        );
                      }
                    },
                    onLongPress: () {
                      final preset = _drinkPresets[index];
                      final nameController = TextEditingController(
                        text: preset['name'],
                      );
                      final amountController = TextEditingController(
                        text: preset['amount'].toString(),
                      );
                      final kcalController = TextEditingController(
                        text: preset['kcal'].toString(),
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            backgroundColor: isDark
                                ? Colors.grey[900]
                                : Colors.white,
                            title: Text(
                              'Drankje aanpassen',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Naam',
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  cursorColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                TextFormField(
                                  controller: amountController,
                                  decoration: InputDecoration(
                                    labelText: 'Hoeveelheid (ml)',
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  cursorColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                      TextFormField(
                                  controller: kcalController,
                                  decoration: InputDecoration(
                                    labelText: 'Kcal per 100 ml',
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: 'Zoek op barcode',
                                      icon: Icon(
                                        Icons.qr_code_scanner,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                      onPressed: () => _promptForBarcodeAndFillKcal(kcalController),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  cursorColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _drinkPresets.removeAt(index);
                                  });
                                  _saveDrinkPresets();
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Verwijderen',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Annuleren',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.green[700]
                                      : Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _drinkPresets[index] = {
                                      'name': nameController.text,
                                      'amount':
                                          int.tryParse(amountController.text) ??
                                          0,
                                      'kcal':
                                          double.tryParse(
                                            kcalController.text,
                                          ) ??
                                          0.0,
                                    };
                                  });
                                  final amount =
                                      int.tryParse(amountController.text) ?? 0;
                                  final kcalPer100 =
                                      double.tryParse(
                                        kcalController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0.0;
                                  final kcalForPortion =
                                      (kcalPer100 * amount) / 100.0;
                                  setState(() {
                                    _drinkPresets[index] = {
                                      'name': nameController.text,
                                      'amount': amount,
                                      'kcal': kcalForPortion,
                                    };
                                  });
                                  _saveDrinkPresets();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Opslaan'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['background'],
                      foregroundColor: colors['foreground'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      shadowColor: isDarkMode ? Colors.black : Colors.grey[400],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForDrink(preset['name']),
                          size: 30,
                          color: colors['foreground'],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          preset['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${preset['amount']} ml',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${preset['kcal'] ?? 0} kcal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: const FeedbackButton(),
    );
  }

  IconData _getIconForDrink(String name) {
    // bepaalt icoon op basis van dranknaam
    final lowerCaseName = name.toLowerCase();
    if (lowerCaseName.contains('water')) return Icons.water_drop;
    if (lowerCaseName.contains('koffie')) return Icons.coffee;
    if (lowerCaseName.contains('thee')) return Icons.emoji_food_beverage;
    if (lowerCaseName.contains('fris') || lowerCaseName.contains('soda')) {
      return Icons.local_bar;
    }
    return Icons.local_drink;
  }

  Map<String, Color> _getColorsForDrink(String name, bool isDarkMode) {
    // bepaalt kleuren op basis van dranknaam
    final lowerCaseName = name.toLowerCase();

    if (lowerCaseName.contains('water')) {
      return isDarkMode
          ? {'background': Colors.blue[900]!, 'foreground': Colors.blue[200]!}
          : {'background': Colors.blue[100]!, 'foreground': Colors.blue[800]!};
    }
    if (lowerCaseName.contains('koffie')) {
      return isDarkMode
          ? {'background': Colors.brown[800]!, 'foreground': Colors.brown[100]!}
          : {
              'background': Colors.brown[100]!,
              'foreground': Colors.brown[800]!,
            };
    }
    if (lowerCaseName.contains('thee')) {
      return isDarkMode
          ? {'background': Colors.amber[900]!, 'foreground': Colors.amber[200]!}
          : {
              'background': Colors.amber[100]!,
              'foreground': Colors.amber[800]!,
            };
    }
    if (lowerCaseName.contains('fris') || lowerCaseName.contains('soda')) {
      return isDarkMode
          ? {'background': Colors.red[900]!, 'foreground': Colors.red[200]!}
          : {'background': Colors.red[100]!, 'foreground': Colors.red[800]!};
    }
    // Default colors
    return isDarkMode
        ? {'background': Colors.grey[800]!, 'foreground': Colors.white}
        : {'background': Colors.grey[200]!, 'foreground': Colors.black};
  }
}
