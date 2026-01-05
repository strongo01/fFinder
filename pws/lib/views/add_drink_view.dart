import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fFinder/views/barcode_scanner.dart';
import 'package:fFinder/l10n/app_localizations.dart';

class AddDrinkPage extends StatefulWidget {
  //statefulwidget omdat de inhoud kan veranderen
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
    // bij initialisatie van de state
    super.initState();
    _loadDrinkPresets();
  }

  Future<void> _loadDrinkPresets() async {
    // laadt de drank standaarden van firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        //als er geen gebruiker is ingelogd, laad default waarden
        _isLoading = false;
        _drinkPresets = [
          {'name': 'Water', 'amount': 200, 'kcal': 0},
        ];
      });
      return;
    }
    SecretKey? userDEK = await getUserDEKFromRemoteConfig(
      user.uid,
    ); //haal de DEK op voor de gebruiker

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()!.containsKey('drinkPresets')) {
        final rawList =
            doc.data()!['drinkPresets']
                as List<dynamic>; // rauwe lijst van presets uit firestore
        final presets =
            <
              Map<String, dynamic>
            >[]; // tijdelijke lijst voor gedecodeerde presets

        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final map = Map<String, dynamic>.from(
              item,
            ); // maak een kopie van de map

            // decrypt naam indien nodig
            if (userDEK != null && map['name'] is String) {
              try {
                map['name'] = await decryptValue(
                  map['name'] as String,
                  userDEK,
                );
              } catch (_) {
                // laat origineel dus geencrypte staan bij fout
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
        // geen presets gevonden, laad default
        setState(() {
          _drinkPresets = [
            {'name': 'Water', 'amount': 200},
          ];
        });
      }
    } catch (e) {
      // bij fout, laad default
      setState(() {
        _drinkPresets = [
          {'name': 'Water', 'amount': 200},
        ];
      });
    } finally {
      // zet loading op false
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

    final toSave = <Map<String, dynamic>>[]; // lijst van te saven presets
    for (final preset in _drinkPresets) {
      // voor elke preset
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
        //als er een DEK is, encrypt de amount
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
          // bij fout, sla op zonder encryptie
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

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'drinkPresets': toSave},
      SetOptions(merge: true),
    ); //merge omdat we andere velden niet willen overschrijven
  }

  Future<void> _logDrink( // logt het drinken van een drankje
    String name,
    int amount,
    String drinkTime,
    double kcal,
  ) async {
    // logt het drinken van een drankje
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginToLog)), //gebruiker moet inloggen om te kunnen loggen
      );
      return;
    }

    SecretKey? userDEK = await getUserDEKFromRemoteConfig(user.uid);

    final date = widget.selectedDate ?? DateTime.now();
    final todayDocId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"; // document ID voor vandaag

    String productNameField = name;
    String quantityField = '$amount ml';
    String mealTypeField = drinkTime;
    String drinkTimeField = drinkTime;
    String kcalField = kcal.toString();

    if (userDEK != null) { //als er een DEK is, encrypt de velden
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

    final logEntry = { // log entry map
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
          'entries': FieldValue.arrayUnion([logEntry]), //voegt de log entry toe aan de entries array
        }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$name ($amount ml) ${AppLocalizations.of(context)!.added}!',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showAddPresetDialog() { // toont de dialoog om een nieuwe drank preset toe te voegen
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final kcalController = TextEditingController();
    final customNameController = TextEditingController();
    String? selectedDrink;
    String? coffeeVariant; // voor koffie
    final drinkOptions = [ // beschikbare drank opties en alle lokaal vertaalde namen
      AppLocalizations.of(context)!.water,
      AppLocalizations.of(context)!.coffee,
      AppLocalizations.of(context)!.tea,
      AppLocalizations.of(context)!.soda,
      AppLocalizations.of(context)!.other,
    ];
    final coffeeVariants = [
      AppLocalizations.of(context)!.coffeeBlack,
      AppLocalizations.of(context)!.espresso,
      AppLocalizations.of(context)!.ristretto,
      AppLocalizations.of(context)!.lungo,
      AppLocalizations.of(context)!.americano,
      AppLocalizations.of(context)!.coffeeWithMilk,
      AppLocalizations.of(context)!.coffeeWithMilkSugar,
      AppLocalizations.of(context)!.cappuccino,
      AppLocalizations.of(context)!.latte,
      AppLocalizations.of(context)!.flatWhite,
      AppLocalizations.of(context)!.macchiato,
      AppLocalizations.of(context)!.latteMacchiato,
      AppLocalizations.of(context)!.icedCoffee,
      AppLocalizations.of(context)!.otherCoffee,
    ];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateKcalForCoffee() { // update kcal op basis van koffie variant
              final loc = AppLocalizations.of(context)!;
              if (coffeeVariant == null) {
                kcalController.text = '';
                return;
              }
              // stel kcal waarden in op basis van koffie variant
              if (coffeeVariant == loc.coffeeBlack ||
                  coffeeVariant == loc.espresso ||
                  coffeeVariant == loc.ristretto ||
                  coffeeVariant == loc.lungo ||
                  coffeeVariant == loc.americano) {
                kcalController.text = '2';
              } else if (coffeeVariant == loc.coffeeWithMilk) {
                kcalController.text = '12';
              } else if (coffeeVariant == loc.coffeeWithMilkSugar) {
                kcalController.text = '25';
              } else if (coffeeVariant == loc.cappuccino) {
                kcalController.text = '55';
              } else if (coffeeVariant == loc.latte ||
                  coffeeVariant == loc.flatWhite) {
                kcalController.text = '45';
              } else if (coffeeVariant == loc.macchiato) {
                kcalController.text = '10';
              } else if (coffeeVariant == loc.latteMacchiato) {
                kcalController.text = '50';
              } else if (coffeeVariant == loc.icedCoffee) {
                kcalController.text = '60';
              } else {
                // Andere koffie / default
                kcalController.text = '';
              }
            }

            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.newDrinkTitle,
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
                    key: formKey, // formulier key voor validatie
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedDrink,
                          hint: Text(AppLocalizations.of(context)!.chooseDrink),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedDrink = value;
                              coffeeVariant = null;
                              final loc = AppLocalizations.of(context)!;
                              if (value == loc.water || value == loc.tea) {
                                kcalController.text = '0';
                              } else if (value != loc.coffee) {
                                kcalController.text = '';
                              } // voor koffie, wacht op variant selectie
                            });
                          },
                          items: drinkOptions
                              .map(
                                (drink) => DropdownMenuItem( //maak dropdown items voor elke drank optie
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
                          validator: (value) => value == null
                              ? AppLocalizations.of(context)!.chooseDrink
                              : null,
                        ),

                        // koffie variant dropdown
                        if (selectedDrink ==
                            AppLocalizations.of(context)!.coffee) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: coffeeVariant,
                            hint: Text(
                              AppLocalizations.of(context)!.chooseCoffeeType,
                            ),
                            onChanged: (value) { // bij verandering, update de koffie variant en kcal
                              setStateDialog(() {
                                coffeeVariant = value;
                                updateKcalForCoffee();
                              });
                            },
                            items: coffeeVariants
                                .map(
                                  (v) => DropdownMenuItem( //maak dropdown items voor elke koffie variant
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
                            validator: (value) => value == null
                                ? AppLocalizations.of(context)!.chooseCoffeeType
                                : null,
                          ),
                        ],

                        if (selectedDrink ==
                            AppLocalizations.of(context)!.other)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              controller: customNameController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.drinkNameLabel,
                                labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              validator: (value) =>
                                  (selectedDrink ==
                                          AppLocalizations.of(context)!.other &&
                                      value!.isEmpty)
                                  ? AppLocalizations.of(context)!.nameRequired
                                  : null,
                            ),
                          ),

                        TextFormField(
                          controller: amountController,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.amountMlLabel, // hoeveelheid in ml
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) { // validatie voor amount veld
                            if (value!.isEmpty)
                              return AppLocalizations.of(
                                context,
                              )!.amountRequired;
                            if (int.tryParse(value) == null)
                              return AppLocalizations.of(context)!.enterNumber;
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
                            labelText: AppLocalizations.of(
                              context,
                            )!.kcalPer100Label,
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            // toevoeging: barcode knop rechts
                            suffixIcon: IconButton( // knop om op barcode te zoeken
                              tooltip: 'Zoek op barcode',
                              icon: Icon(
                                Icons.qr_code_scanner,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              onPressed: () =>
                                  _promptForBarcodeAndFillKcal(kcalController),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) { // validatie voor kcal veld
                            if (value!.isEmpty)
                              return AppLocalizations.of(context)!.kcalRequired;
                            if (double.tryParse(value) == null)
                              return AppLocalizations.of(context)!.enterNumber;
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
                  onPressed: () => Navigator.of(context).pop(), // sluit dialoog
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () { // voeg preset toe zonder te loggen
                    if (formKey.currentState!.validate()) {
                      // naam bepalen
                      String name;
                      final loc = AppLocalizations.of(context)!;
                      if (selectedDrink == loc.coffee &&
                          coffeeVariant != null &&
                          coffeeVariant != loc.otherCoffee) {
                        name = coffeeVariant!;
                      } else if (selectedDrink == loc.other) {
                        name = customNameController.text;
                      } else {
                        name = selectedDrink!;
                      }

                      final amount = int.parse(amountController.text);
                      final kcalPer100 = double.parse(
                        kcalController.text.replaceAll(',', '.'),
                      );
                      final kcalForPortion = (kcalPer100 * amount) / 100.0;

                      setState(() { // voeg preset toe aan lijst en sla op
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
                  child: Text(AppLocalizations.of(context)!.addButton),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    // bepaal naam en waarden
                    String name;
                    final loc = AppLocalizations.of(context)!;
                    if (selectedDrink == loc.coffee &&
                        coffeeVariant != null &&
                        coffeeVariant != loc.otherCoffee) {
                      name = coffeeVariant!;
                    } else if (selectedDrink == loc.other) {
                      name = customNameController.text;
                    } else {
                      name = selectedDrink!;
                    }

                    final amount = int.parse(amountController.text);
                    final kcalPer100 = double.parse(
                      kcalController.text.replaceAll(',', '.'),
                    );
                    final kcalForPortion = (kcalPer100 * amount) / 100.0;

                    // voeg preset toe en sla op
                    setState(() { // voeg preset toe aan lijst
                      _drinkPresets.add({
                        'name': name,
                        'amount': amount,
                        'kcal': kcalForPortion,
                      });
                    });
                    await _saveDrinkPresets();

                    // zorg dat we de pagina-context hebben (niet de dialog-context)
                    final pageContext = this.context;

                    // sluit de add-preset dialog
                    Navigator.of(context).pop();

                    // vraag wanneer gedronken (ontbijt/lunch/...)
                    final mealOptions = [
                      AppLocalizations.of(pageContext)!.breakfast,
                      AppLocalizations.of(pageContext)!.lunch,
                      AppLocalizations.of(pageContext)!.dinner,
                      AppLocalizations.of(pageContext)!.snack,
                    ];
                    final selectedMeal = await showDialog<String>(
                      context: pageContext,
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.whenDrankTitle,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: mealOptions.map((m) {
                              return ListTile(
                                title: Text(
                                  m,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                onTap: () => Navigator.of(context).pop(m),
                              );
                            }).toList(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        );
                      },
                    );

                    // als er een tijd gekozen is, log het drankje
                    if (selectedMeal != null) {
                      await _logDrink(
                        name,
                        amount,
                        selectedMeal,
                        kcalForPortion,
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.addAndLogButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double?> _fetchKcalFromBarcode(String barcode) async { // haalt kcal op van OpenFoodFacts API
    final url = Uri.parse(
      'https://nl.openfoodfacts.org/api/v0/product/$barcode.json',
    );
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 8)); // timeout na 8 seconden
      if (resp.statusCode != 200) {
        debugPrint('[fetchKcal] HTTP ${resp.statusCode}');
        return null;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>?; // decode JSON response
      if (data == null) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      // Try several possible nutriments maps/keys
      final nutrimentsCandidates = <Map<String, dynamic>?>[ // mogelijke locaties van nutriments
        product['nutriments_per_100g'] as Map<String, dynamic>?,
        product['nutriments'] as Map<String, dynamic>?,
        product['nutriments_100g'] as Map<String, dynamic>?,
      ];

      Map<String, dynamic>? nutr;
      for (final cand in nutrimentsCandidates) { // zoek naar de eerste geldige nutriments map
        if (cand != null) {
          nutr = cand;
          break;
        }
      }
      if (nutr == null) return null;

      // zoek naar energie-kcal waarde
      final keys = nutr.keys.map((k) => k.toString()).toList();
      // mogelijke keys voor energie-kcal
      final candidates = [
        'energy-kcal_100g',
        'energy-kcal',
        'energy-kcal_100g_value',
        'energykcal_100g',
        'energykcal',
        'energy-kcal_value',
        'energy-kcal_100g_value',
      ];

      for (final k in candidates) { // probeer elke candidate key
        if (nutr.containsKey(k)) {
          final v = nutr[k];
          if (v is num) return v.toDouble();
          final parsed = double.tryParse(v?.toString() ?? '');
          if (parsed != null) return parsed;
        }
      }

     // als geen candidate keys werken, probeer algemene zoekmethode
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

  Future<void> _promptForBarcodeAndFillKcal( /// toont dialoog om barcode in te voeren en vult kcal veld
    TextEditingController kcalController,
  ) async {
    final barcodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final res = await showDialog<bool>( // toont dialoog voor barcode invoer. de final res omdat we willen weten of er op zoeken is geklikt
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.scanPasteBarcode,
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
                      labelText: AppLocalizations.of(context)!.barcodeLabel,
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? AppLocalizations.of(context)!.enterBarcode
                        : null,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                IconButton(
                  tooltip: 'Scan barcode',
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () async {
               // navigeer naar barcode scanner pagina
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.searchButton),
            ),
          ],
        );
      },
    );

    if (res != true) return;
    final bc = barcodeController.text.trim(); // haal ingevoerde barcode op
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.searching),
        duration: const Duration(seconds: 2),
      ),
    );
    final kcal = await _fetchKcalFromBarcode(bc); // haal kcal op van API
    if (kcal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.noKcalFoundPrefix}$bc',
          ),
        ),
      );
      return;
    }
    kcalController.text = kcal.round().toString(); // vul kcal veld
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.foundPrefix}${kcal.round()}${AppLocalizations.of(context)!.kcalPer100Unit}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addDrinkTitle)),
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
                  if (index == _drinkPresets.length) { // laatste item is de "add preset" knop
                    return InkWell( // klikbare knop
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
                        AppLocalizations.of(context)!.breakfast,
                        AppLocalizations.of(context)!.lunch,
                        AppLocalizations.of(context)!.dinner,
                        AppLocalizations.of(context)!.snack,
                      ];
                      final selected = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.whenDrankTitle,
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
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
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
                          selected, // geselecteerde maaltijdtype
                          preset['kcal'] ?? 0.0,
                        );
                      }
                    },
                    onLongPress: () { // bewerk preset bij lang indrukken
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
                              AppLocalizations.of(context)!.editDrinkTitle,
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.nameLabel,
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.amountMlLabel,
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.kcalPer100Label,
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: AppLocalizations.of(
                                        context,
                                      )!.barcodeSearchTooltip,
                                      icon: Icon(
                                        Icons.qr_code_scanner,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      onPressed: () =>
                                          _promptForBarcodeAndFillKcal(
                                            kcalController,
                                          ),
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
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
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
                                onPressed: () { // sla bewerkte preset op
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
                                child: Text(
                                  AppLocalizations.of(context)!.saveButton,
                                ),
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
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForDrink(preset['name']),
                          size: 28,
                          color: colors['foreground'],
                        ),
                        const SizedBox(height: 6),
                        Flexible( // zorgt dat tekst niet uit knop loopt
                          fit: FlexFit.loose,
                          child: Text(
                            preset['name']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            '${preset['amount']} ml',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            '${preset['kcal'] ?? 0} kcal',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
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
    final lower = name.toLowerCase();
    final loc = AppLocalizations.of(context)!;

    bool containsAny(List<String?> keys) { // controleer of naam een van de keys bevat
      for (final k in keys) {
        if (k == null || k.isEmpty) continue;
        if (lower.contains(k.toLowerCase())) return true;
      }
      return false;
    }

    if (containsAny([loc.water, 'water'])) return Icons.water_drop;
    if (containsAny([
      loc.coffee,
      loc.icedCoffee,
      loc.latteMacchiato,
      loc.macchiato,
      loc.flatWhite,
      loc.latte,
      loc.cappuccino,
      loc.coffeeWithMilkSugar,
      loc.coffeeBlack,
      loc.espresso,
      loc.ristretto,
      loc.lungo,
      loc.americano,
      loc.coffeeWithMilk,
      'koffie',
      'coffee',
    ]))
      return Icons.coffee;
    if (containsAny([loc.tea, 'thee', 'tea'])) return Icons.emoji_food_beverage;
    if (containsAny([loc.soda, 'fris', 'soda', 'cola'])) return Icons.local_bar;

    return Icons.local_drink;
  }

  Map<String, Color> _getColorsForDrink(String name, bool isDarkMode) { // bepaal kleuren op basis van dranknaam
    final lower = name.toLowerCase();
    final loc = AppLocalizations.of(context)!;

    bool matches(List<String?> keys) {
      for (final k in keys) {
        if (k == null || k.isEmpty) continue;
        if (lower.contains(k.toLowerCase())) return true;
      }
      return false;
    }

    if (matches([loc.water, 'water'])) {
      return isDarkMode
          ? {'background': Colors.blue[900]!, 'foreground': Colors.blue[200]!}
          : {'background': Colors.blue[100]!, 'foreground': Colors.blue[800]!};
    }
    if (matches([
      loc.coffee,
      loc.icedCoffee,
      loc.latteMacchiato,
      loc.macchiato,
      loc.flatWhite,
      loc.latte,
      loc.cappuccino,
      loc.coffeeWithMilkSugar,
      loc.coffeeBlack,
      loc.espresso,
      loc.ristretto,
      loc.lungo,
      loc.americano,
      loc.coffeeWithMilk,
      'koffie',
      'coffee',
    ])) {
      return isDarkMode
          ? {'background': Colors.brown[800]!, 'foreground': Colors.brown[100]!}
          : {
              'background': Colors.brown[100]!,
              'foreground': Colors.brown[800]!,
            };
    }
    if (matches([loc.tea, 'thee', 'tea'])) {
      return isDarkMode
          ? {'background': Colors.amber[900]!, 'foreground': Colors.amber[200]!}
          : {
              'background': Colors.amber[100]!,
              'foreground': Colors.amber[800]!,
            };
    }
    if (matches([loc.soda, 'fris', 'soda', 'cola'])) {
      return isDarkMode
          ? {'background': Colors.red[900]!, 'foreground': Colors.red[200]!}
          : {'background': Colors.red[100]!, 'foreground': Colors.red[800]!};
    }

    return isDarkMode
        ? {'background': Colors.grey[800]!, 'foreground': Colors.white}
        : {'background': Colors.grey[200]!, 'foreground': Colors.black};
  }
}
