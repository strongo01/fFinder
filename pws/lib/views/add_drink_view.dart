import 'package:fFinder/views/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDrinkPage extends StatefulWidget {
  const AddDrinkPage({super.key});

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
          {'name': 'Water', 'amount': 200},
        ];
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()!.containsKey('drinkPresets')) {
        // als er standaarden zijn opgeslagen
        final presets = List<Map<String, dynamic>>.from(
          doc.data()!['drinkPresets'], // haal de lijst op
        );
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

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'drinkPresets': _drinkPresets, // in drinkPresets veld
    }, SetOptions(merge: true)); // voeg toe zonder te overschrijven
  }

  Future<void> _logDrink(String name, int amount, String drinkTime) async {
    // logt het drinken van een drankje
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je moet ingelogd zijn om te loggen.')),
      );
      return;
    }

    final now = DateTime.now();
    final todayDocId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    // document ID voor vandaag
    final logEntry = {
      // maak een log entry aan
      'product_name': name,
      'quantity': '$amount ml',
      'meal_type': drinkTime,
      'drinkTime': drinkTime,
      'timestamp': DateTime.now(),
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
          'entries': FieldValue.arrayUnion([
            logEntry,
          ]), // voeg entry toe aan entries array
        }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name ($amount ml) toegevoegd!')));
      Navigator.of(context).pop(); // ga terug naar vorige scherm
    }
  }

  void _showAddPresetDialog() {
    // toont dialoog om nieuwe drank standaard toe te voegen
    //final nameController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final customNameController = TextEditingController();
    String? selectedDrink;
    final drinkOptions = ['Water', 'Koffie', 'Thee', 'Frisdrank', 'Anders'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // gebruik StatefulBuilder om de diaaloog te updaten
            return AlertDialog(
              title: Text(
                'Nieuw Drankje Toevoegen',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDrink, // huidige geselecteerde drank
                      hint: const Text('Kies een drankje'),
                      onChanged: (value) {
                        // update geselecteerde drank
                        setStateDialog(() {
                          // updat de dialoog
                          selectedDrink = value;
                        });
                      },
                      items: drinkOptions
                          .map(
                            (drink) => DropdownMenuItem(
                              // maak een dropdown item voor elke optie
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
                    if (selectedDrink == 'Anders')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: customNameController,
                          decoration: const InputDecoration(
                            labelText: 'Naam van drankje',
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
                      cursorColor: isDarkMode ? Colors.white : Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Hoeveelheid (ml)',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Hoeveelheid is verplicht';
                        if (int.tryParse(value) == null) {
                          return 'Voer een getal in';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // sluit de dialoog
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final name = selectedDrink == 'Anders'
                          ? customNameController.text
                          : selectedDrink!;
                      setState(() {
                        _drinkPresets.add({
                          'name': name,
                          'amount': int.parse(amountController.text),
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
                              children: mealOptions.map((m) { // maak een lijstitem voor elke maaltijdoptie
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

                      if (selected != null) { // als er een optie is geselecteerd
                        await _logDrink(
                          preset['name'],
                          preset['amount'],
                          selected,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['background'],
                      foregroundColor: colors['foreground'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
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
