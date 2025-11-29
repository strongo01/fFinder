import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDrinkPage extends StatefulWidget {
  const AddDrinkPage({super.key});

  @override
  State<AddDrinkPage> createState() => _AddDrinkPageState();
}

class _AddDrinkPageState extends State<AddDrinkPage> {
  List<Map<String, dynamic>> _drinkPresets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrinkPresets();
  }

  Future<void> _loadDrinkPresets() async {
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
        final presets = List<Map<String, dynamic>>.from(
          doc.data()!['drinkPresets'],
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'drinkPresets': _drinkPresets,
    }, SetOptions(merge: true));
  }

  Future<void> _logDrink(String name, int amount) async {
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

    final logEntry = {
      'product_name': name,
      'quantity': '$amount ml',
      'meal_type': 'Drinken',
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
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final customNameController = TextEditingController();
    String? selectedDrink;
    final drinkOptions = ['Water', 'Koffie', 'Thee', 'Frisdrank', 'Anders'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nieuw Drankje Toevoegen'),
              content: Form(
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
                        });
                      },
                      items: drinkOptions
                          .map(
                            (drink) => DropdownMenuItem(
                              value: drink,
                              child: Text(drink),
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
                      decoration: const InputDecoration(
                        labelText: 'Hoeveelheid (ml)',
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
                  onPressed: () => Navigator.of(context).pop(),
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
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
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
                  final colors = _getColorsForDrink(preset['name'], isDarkMode);

                  return ElevatedButton(
                    onPressed: () =>
                        _logDrink(preset['name'], preset['amount']),
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
    );
  }

  IconData _getIconForDrink(String name) {
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
