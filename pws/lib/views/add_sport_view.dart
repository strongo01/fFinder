import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crypto_class.dart';

// MET-waardes per sport
const Map<String, double> _metValues = {
  'Hardlopen': 9.8,
  'Fietsen': 7.5,
  'Zwemmen': 8.0,
  'Wandelen': 3.5,
  'Fitness': 6.0,
  'Voetbal': 7.0,
  'Tennis': 7.3,
  'Yoga': 2.5,
};

// Overig → snelle vuistregel (normaal)
const double _defaultOverigMET = 5.0;

class AddSportPage extends StatefulWidget {
  final DateTime? selectedDate;
  const AddSportPage({super.key, this.selectedDate});

  @override
  State<AddSportPage> createState() => _AddSportPageState();
}

class _AddSportPageState extends State<AddSportPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSport;
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _customSportController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _caloriesManuallyEdited = false;
  double _overigIntensityMET = 5.0;

  final List<String> _sports = [
    'Hardlopen',
    'Fietsen',
    'Zwemmen',
    'Wandelen',
    'Fitness',
    'Voetbal',
    'Tennis',
    'Yoga',
    'Overig',
  ];
  Future<void> _updateCaloriesLive() async {
    if (_caloriesManuallyEdited) return;
    if (_selectedSport == null) return;
    if (_durationController.text.isEmpty) return;

    final duration = double.tryParse(_durationController.text);
    if (duration == null || duration <= 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) return;

    try {
      final weightKg = await _getDecryptedWeight(user.uid, userDEK);

      final met = _selectedSport == 'Overig'
          ? _overigIntensityMET
          : (_metValues[_selectedSport] ?? _defaultOverigMET);

      final calories = met * weightKg * (duration / 60);

      // 👇 live invullen
setState(() {
  _caloriesController.text = calories.toStringAsFixed(0);
});

    } catch (_) {
      // stil falen (geen UI-spam)
    }
  }

  Future<double> _getDecryptedWeight(String uid, SecretKey userDEK) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final encryptedWeight = doc['weight'];
    debugPrint('Encrypted weight: $encryptedWeight');
    return await decryptDouble(encryptedWeight, userDEK);
  }

  Future<void> _saveSport() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Niet ingelogd.';
        _isLoading = false;
      });
      return;
    }

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) {
      setState(() {
        _error = 'Encryptiesleutel niet gevonden.';
        _isLoading = false;
      });
      return;
    }

    try {
      final sportName = _selectedSport == 'Overig'
          ? _customSportController.text.trim()
          : _selectedSport ?? '';

      final durationMin = double.parse(_durationController.text);
      //final weightKg = await _getDecryptedWeight(user.uid, userDEK);

      //final met = _selectedSport == 'Overig'
        //  ? _overigIntensityMET
          //: (_metValues[_selectedSport] ?? _defaultOverigMET);

      final caloriesToSave = double.parse(_caloriesController.text);

      // calorieveld automatisch vullen (zonder UI-wijziging)
      _caloriesController.text = caloriesToSave.toStringAsFixed(0);

      final encryptedSport = await encryptValue(sportName, userDEK);
      final encryptedDuration = await encryptDouble(durationMin, userDEK);
      final encryptedCalories = await encryptDouble(caloriesToSave, userDEK);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sports')
          .add({
            'sport': encryptedSport,
            'duration_min': encryptedDuration,
            'calories_burned': encryptedCalories,
            'timestamp': widget.selectedDate ?? DateTime.now(),
          });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Fout bij opslaan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _customSportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final inputFillColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    //final subtitleColor = isDarkMode ? Colors.white70 : Colors.black87;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sport toevoegen'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : null,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nieuwe sportactiviteit',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _selectedSport,
                          items: _sports
                              .map(
                                (sport) => DropdownMenuItem(
                                  value: sport,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.sports,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        sport,
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Sport',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            prefixIcon: Icon(
                              Icons.directions_run,
                              color: textColor,
                            ),
                            labelStyle: TextStyle(color: textColor),
                          ),
                          dropdownColor: cardColor,
                          onChanged: (value) {
                            setState(() {
                              _selectedSport = value;
                              _caloriesManuallyEdited = false;
                            });
                            _updateCaloriesLive();
                          },

                          validator: (value) =>
                              value == null ? 'Kies een sport' : null,
                        ),
                        if (_selectedSport == 'Overig') ...[
                          const SizedBox(height: 18),
                          TextFormField(
                          controller: _customSportController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Naam van sport',
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            prefixIcon: Icon(Icons.edit, color: textColor),
                            labelStyle: TextStyle(color: textColor),
                          ),
                          validator: (value) {
                            if (_selectedSport == 'Overig' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Voer een sportnaam in';
                            }
                            return null;
                          },
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<double>(
                          value: _overigIntensityMET,
                          items: [
                            DropdownMenuItem(
                            value: 2.5,
                            child: Text('Licht', style: TextStyle(color: textColor)),
                            ),
                            DropdownMenuItem(
                            value: 5.0,
                            child: Text('Normaal', style: TextStyle(color: textColor)),
                            ),
                            DropdownMenuItem(
                            value: 7.5,
                            child: Text('Zwaar', style: TextStyle(color: textColor)),
                            ),
                            DropdownMenuItem(
                            value: 10.0,
                            child: Text('Zeer zwaar', style: TextStyle(color: textColor)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                            _overigIntensityMET = value!;
                            _caloriesManuallyEdited = false;
                            });
                            _updateCaloriesLive();
                          },
                          decoration: InputDecoration(
                            labelText: 'Intensiteit',
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            labelStyle: TextStyle(color: textColor),
                          ),
                          dropdownColor: cardColor,
                          style: TextStyle(color: textColor),
                          ),
                        ],
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Duur (minuten)',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            prefixIcon: Icon(Icons.timer, color: textColor),
                            labelStyle: TextStyle(color: textColor),
                          ),
                          onChanged: (_) {
                            _caloriesManuallyEdited = false;
                            _updateCaloriesLive();
                          },

                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Voer een geldige duur in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Calorieën verbrand',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            prefixIcon: Icon(
                              Icons.local_fire_department,
                              color: textColor,
                            ),
                            labelStyle: TextStyle(color: textColor),
                          ),
                          onChanged: (_) {
                            _caloriesManuallyEdited = true;
                          },

                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null ||
                                double.parse(value) < 0) {
                              return 'Voer een geldig aantal calorieën in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Opslaan',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                            onPressed: _isLoading ? null : _saveSport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Overzicht direct onder de Card
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SportsOverviewList(
                    userId: user.uid,
                    isDarkMode: isDarkMode,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kleine widget voor het sportoverzicht
class SportsOverviewList extends StatelessWidget {
  final String userId;
  final bool isDarkMode;
  const SportsOverviewList({
    super.key,
    required this.userId,
    required this.isDarkMode,
  });

  Future<SecretKey?> _getUserDEK() async {
    return await getUserDEKFromRemoteConfig(userId);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black87;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black12;

    return FutureBuilder<SecretKey?>(
      future: _getUserDEK(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final userDEK = snapshot.data;
        if (userDEK == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Encryptiesleutel niet gevonden.',
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('sports')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Nog geen sportactiviteiten.',
                    style: TextStyle(color: textColor),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                return FutureBuilder(
                  future: Future.wait([
                    decryptValue(data['sport'], userDEK),
                    decryptDouble(data['duration_min'], userDEK),
                    decryptDouble(data['calories_burned'], userDEK),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snap) {
                    if (!snap.hasData) {
                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: borderColor),
                        ),
                        elevation: 2,
                        child: const ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Laden...'),
                        ),
                      );
                    }
                    final sport = snap.data![0] as String;
                    final duration = snap.data![1] as double;
                    final calories = snap.data![2] as double;
                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: borderColor),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          Icons.sports,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          sport,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          'Duur: ${duration.toStringAsFixed(0)} min\n'
                          'Calorieën: ${calories.toStringAsFixed(0)}',
                          style: TextStyle(color: subtitleColor),
                        ),
                        trailing: timestamp != null
                            ? Text(
                                '${timestamp.toDate().day.toString().padLeft(2, '0')}-'
                                '${timestamp.toDate().month.toString().padLeft(2, '0')}-'
                                '${timestamp.toDate().year}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
