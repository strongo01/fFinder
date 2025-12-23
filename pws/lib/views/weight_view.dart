import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightView extends StatefulWidget {
  const WeightView({super.key});

  @override
  State<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends State<WeightView> {
  bool _loading = true;
  bool _saving = false;

  double _weight = 72;

  double? _targetWeight;
  double _height = 180;
  double? _bmi;
  double _waist = 85.0; // cm
  double? _absi;
  double? _absiZ;
  String? _absiRange;
  List<dynamic> _absiReferenceTable = [];
  List<WeightEntry> _entries = [];

  String _viewMode = 'table';
  final TextEditingController _waistController = TextEditingController();
  int _currentMonthIndex = 0;

  static const double _bmiMin = 10.0;
  static const double _bmiVeryLowEnd = 16.0;
  static const double _bmiLowEnd = 18.5;
  static const double _bmiGoodEnd = 25.0;
  static const double _bmiHighEnd = 30.0;
  static const double _bmiMax = 40.0;

  double _clampBmi(double bmi) {
    return bmi.clamp(_bmiMin, _bmiMax);
  }

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _targetWeightController = TextEditingController();
  final FocusNode _weightFocusNode =
      FocusNode(); // FocusNode voor het gewicht invoerveld
  final FocusNode _targetWeightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAbsiReference();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _targetWeightController.dispose();
    _weightFocusNode.dispose();
    _waistController.dispose();
    _targetWeightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAbsiReference() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/absi_reference/absi_reference.json',
      );
      _absiReferenceTable = json.decode(jsonString) as List<dynamic>;
    } catch (_) {
      _absiReferenceTable = [];
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    SecretKey? userDEK;
    try {
      userDEK = await getUserDEKFromRemoteConfig(user.uid);
    } catch (_) {
      userDEK = null;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};

      if (userDEK != null && data['weight'] is String) {
        try {
          final dec = await decryptValue(data['weight'] as String, userDEK);
          _weight = double.tryParse(dec.replaceAll(',', '.')) ?? _weight;
        } catch (_) {
          _weight = _parseDouble(data['weight']) ?? _weight;
        }
      } else {
        _weight = _parseDouble(data['weight']) ?? _weight;
      }

      if (userDEK != null && data['height'] is String) {
        try {
          final dec = await decryptValue(data['height'] as String, userDEK);
          _height = double.tryParse(dec.replaceAll(',', '.')) ?? _height;
        } catch (_) {
          _height = _parseDouble(data['height']) ?? _height;
        }
      } else {
        _height = _parseDouble(data['height']) ?? _height;
      }

      if (userDEK != null && data['waist'] is String) {
        try {
          final dec = await decryptValue(data['waist'] as String, userDEK);
          _waist = double.tryParse(dec.replaceAll(',', '.')) ?? _waist;
        } catch (_) {
          _waist = _parseDouble(data['waist']) ?? _waist;
        }
      } else {
        _waist = _parseDouble(data['waist']) ?? _waist;
      }

      if (userDEK != null && data['targetWeight'] is String) {
        try {
          final dec = await decryptValue(
            data['targetWeight'] as String,
            userDEK,
          );
          _targetWeight = double.tryParse(dec.replaceAll(',', '.'));
        } catch (_) {
          _targetWeight = _parseDouble(data['targetWeight']);
        }
      } else {
        _targetWeight = _parseDouble(data['targetWeight']);
      }

      final weightsRaw = data['weights'] as List<dynamic>? ?? [];
      final List<WeightEntry> loaded = [];
      for (final item in weightsRaw) {
        try {
          if (item is String && userDEK != null) {
            final dec = await decryptValue(item, userDEK);
            final Map<String, dynamic> m = Map<String, dynamic>.from(
              jsonDecode(dec),
            );
            final date =
                DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now();
            final w = _parseDouble(m['weight']) ?? 0.0;
            loaded.add(WeightEntry(date: date, weight: w));
          } else if (item is Map<String, dynamic>) {
            final dateField = item['date'];
            DateTime date;
            if (dateField is String) {
              if (userDEK != null) {
                try {
                  final decDate = await decryptValue(dateField, userDEK);
                  date = DateTime.parse(decDate);
                } catch (_) {
                  date = DateTime.tryParse(dateField) ?? DateTime.now();
                }
              } else {
                date = DateTime.tryParse(dateField) ?? DateTime.now();
              }
            } else {
              date = DateTime.now();
            }

            final weightField = item['weight'];
            double weightVal = 0.0;
            if (weightField is String) {
              if (userDEK != null) {
                try {
                  final decW = await decryptValue(weightField, userDEK);
                  weightVal = double.tryParse(decW.replaceAll(',', '.')) ?? 0.0;
                } catch (_) {
                  weightVal = _parseDouble(weightField) ?? 0.0;
                }
              } else {
                weightVal = _parseDouble(weightField) ?? 0.0;
              }
            } else if (weightField is num) {
              weightVal = weightField.toDouble();
            }
            loaded.add(WeightEntry(date: date, weight: weightVal));
          }
        } catch (_) {}
      }

      _entries = loaded..sort((a, b) => a.date.compareTo(b.date));
      _currentMonthIndex = 0;
      _weightController.text = _weight.toStringAsFixed(1);
      if (_targetWeight != null) {
        _targetWeightController.text = _targetWeight!.toStringAsFixed(1);
      }
      _waistController.text = _waist.toStringAsFixed(1);
      _recalculateBMI();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kon gewicht niet laden: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _parseDouble(dynamic value) {
    // Hulpmethode om double te parsen. parsen betekent omzetten van tekst naar een getal
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  void _recalculateBMI() {
    if (_height <= 0 || _weight <= 0) {
      setState(() => _bmi = null);
      setState(() {
        _absi = null;
        _absiZ = null;
        _absiRange = null;
      });
      return;
    }
    final hMeters = _height / 100;
    final bmi = _weight / (hMeters * hMeters);
    setState(() => _bmi = bmi);
    _computeAbsi();
  }

  Future<void> _computeAbsi() async {
    if (_waist <= 0 || _bmi == null || _height <= 0) {
      setState(() {
        _absi = null;
        _absiZ = null;
        _absiRange = null;
      });
      return;
    }

    final heightM = _height / 100.0;
    final waistM = _waist / 100.0;
    final absi = waistM / (pow(_bmi!, 2.0 / 3.0) * pow(heightM, 0.5));

    String? range;
    double? z;
    // try compute z-score if reference table available and birthDate/gender loaded in _loadUserData
    try {
      if (_absiReferenceTable.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final data = doc.data() ?? {};
          String gender = (data['gender'] is String)
              ? (data['gender'] as String)
              : 'Man';
          DateTime? birthDate;
          if (data['birthDate'] is String) {
            String birthStr = data['birthDate'] as String;
            try {
              // try decrypt if encrypted
              final userDEK = await getUserDEKFromRemoteConfig(user.uid);
              if (userDEK != null) {
                try {
                  birthStr = await decryptValue(birthStr, userDEK);
                } catch (_) {}
              }
            } catch (_) {}
            birthDate = birthStr.isNotEmpty
                ? DateTime.tryParse(birthStr)
                : null;
          }

          if (birthDate != null) {
            final ages =
                _absiReferenceTable.map((e) => e['age'] as int).toList()
                  ..sort();
            final age = DateTime.now().year - birthDate.year;
            final clampedAge = ages.contains(age) ? age : ages.last;
            final entry = _absiReferenceTable.firstWhere(
              (e) => e['age'] == clampedAge,
            );
            final isFemale = (gender).toLowerCase() == 'vrouw';
            final data = isFemale ? entry['female'] : entry['male'];
            final mean = (data['mean'] as num).toDouble();
            final sd = (data['sd'] as num).toDouble();
            if (sd != 0) {
              z = (absi - mean) / sd;
              if (z <= -1.0) {
                range = 'zeer_laag risico';
              } else if (z <= -0.5) {
                range = 'laag risico';
              } else if (z <= 0.5) {
                range = 'gemiddeld risico';
              } else if (z <= 1.0) {
                range = 'verhoogd risico';
              } else {
                range = 'hoog';
              }
            }
          }
        }
      }
    } catch (_) {}

    setState(() {
      _absi = absi;
      _absiZ = z;
      _absiRange = range;
    });
  }

  Color _absiCategoryColor(String? range, bool isDark) {
    if (range == null) return isDark ? Colors.white : Colors.black;
    switch (range) {
      case 'zeer_laag risico':
      case 'laag risico':
        return Colors.green;
      case 'gemiddeld risico':
        return Colors.orange;
      case 'verhoogd risico':
      case 'hoog':
      default:
        return Colors.redAccent;
    }
  }

  Future<void> _saveWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _weightFocusNode.unfocus();
    _targetWeightFocusNode.unfocus();

    setState(() => _saving = true);
    SecretKey? userDEK;
    try {
      userDEK = await getUserDEKFromRemoteConfig(user.uid);
    } catch (_) {
      userDEK = null;
    }
    try {
      final now = DateTime.now();
      final newEntry = WeightEntry(
        date: DateTime(now.year, now.month, now.day),
        weight: _weight,
      );

      _entries.removeWhere((e) => _isSameDay(e.date, newEntry.date));
      _entries.add(newEntry);
      _entries.sort((a, b) => a.date.compareTo(b.date));

      _currentMonthIndex = 0;

      final waistText = _waistController.text.trim();
      if (waistText.isNotEmpty) {
        final parsed = double.tryParse(waistText.replaceAll(',', '.'));
        if (parsed != null && parsed > 0) {
          _waist = parsed;
        }
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data() ?? {};

      String activityLevel =
          (data['activityLevel'] as String?) ?? 'Weinig actief';
      String goal = (data['goal'] as String?) ?? 'Op gewicht blijven';
      if (userDEK != null) {
        try {
          if (data['activityLevel'] is String) {
            final dec = await decryptValue(
              data['activityLevel'] as String,
              userDEK,
            );
            activityLevel = dec;
          }
        } catch (_) {}
        try {
          if (data['goal'] is String) {
            final dec = await decryptValue(data['goal'] as String, userDEK);
            goal = dec;
          }
        } catch (_) {}
      }

      String gender = 'Man';
      if (data['gender'] is String) {
        if (userDEK != null) {
          try {
            gender = await decryptValue(data['gender'] as String, userDEK);
          } catch (_) {
            gender = data['gender'] as String;
          }
        } else {
          gender = data['gender'] as String;
        }
      }
      final String? birthDateStrEnc = data['birthDate'] as String?;
      DateTime? birthDate;
      if (birthDateStrEnc != null) {
        String birthDecoded = birthDateStrEnc;
        if (userDEK != null) {
          try {
            birthDecoded = await decryptValue(birthDateStrEnc, userDEK);
          } catch (_) {}
        }
        birthDate = birthDecoded.isNotEmpty
            ? DateTime.tryParse(birthDecoded)
            : null;
      }

      double heightVal;
      if (userDEK != null && data['height'] is String) {
        String heightDec = data['height'] as String;
        try {
          heightDec = await decryptValue(data['height'] as String, userDEK);
        } catch (_) {}
        heightVal = double.tryParse(heightDec.replaceAll(',', '.')) ?? _height;
      } else {
        heightVal = _parseDouble(data['height']) ?? _height;
      }
      final targetWeightVal = _targetWeight ?? _weight;

      // Recompute goals if possible
      double? bmi;
      double? calorieGoal;
      double? proteinGoal;
      double? fatGoal;
      double? carbGoal;

      if (heightVal > 0 && _weight > 0 && birthDate != null) {
        final heightCm = heightVal;
        final weightKg = _weight;
        final heightM = heightCm / 100;
        bmi = weightKg / (heightM * heightM);

        final age = DateTime.now().year - birthDate.year;
        double bmr;
        if (gender == 'Vrouw') {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
        } else {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
        }

        final activity = activityLevel.split(':')[0].trim();
        double activityFactor;
        switch (activity) {
          case 'Weinig actief':
            activityFactor = 1.2;
            break;
          case 'Licht actief':
            activityFactor = 1.375;
            break;
          case 'Gemiddeld actief':
            activityFactor = 1.55;
            break;
          case 'Zeer actief':
            activityFactor = 1.725;
            break;
          case 'Extreem actief':
            activityFactor = 1.9;
            break;
          default:
            activityFactor = 1.2;
        }

        double calories = bmr * activityFactor;
        switch (goal) {
          case 'Afvallen':
            calories -= 500;
            break;
          case 'Aankomen (spiermassa)':
          case 'Aankomen (algemeen)':
            calories += 300;
            break;
          case 'Op gewicht blijven':
          default:
            break;
        }
        calorieGoal = calories;
        proteinGoal = weightKg;
        final fatCalories = calorieGoal * 0.30;
        fatGoal = fatCalories / 9;
        final proteinCalories = proteinGoal * 4;
        final carbCalories = calorieGoal - fatCalories - proteinCalories;
        carbGoal = carbCalories / 4;
      }

      // Build save map with optional encryption
      final Map<String, dynamic> saveMap = {};

      if (userDEK != null) {
        saveMap['weight'] = await encryptDouble(_weight, userDEK);
        saveMap['height'] = await encryptDouble(heightVal, userDEK);
        saveMap['waist'] = await encryptDouble(_waist, userDEK);
       if (_absi != null) saveMap['absi'] = await encryptDouble(_absi!, userDEK);
       if (_absiZ != null) saveMap['absiZ'] = await encryptDouble(_absiZ!, userDEK);
       if (_absiRange != null) saveMap['absiRange'] = await encryptValue(_absiRange!, userDEK);
    
        saveMap['bmi'] = await encryptDouble(bmi ?? 0, userDEK);
        saveMap['calorieGoal'] = await encryptDouble(calorieGoal ?? 0, userDEK);
        saveMap['proteinGoal'] = await encryptDouble(proteinGoal ?? 0, userDEK);
        saveMap['fatGoal'] = await encryptDouble(fatGoal ?? 0, userDEK);
        saveMap['carbGoal'] = await encryptDouble(carbGoal ?? 0, userDEK);
        saveMap['activityLevel'] = await encryptValue(activityLevel, userDEK);
        saveMap['goal'] = await encryptValue(goal, userDEK);
        saveMap['targetWeight'] = await encryptDouble(targetWeightVal, userDEK);
        // weights list: encrypt each entry
        final List<dynamic> weightsToSave = [];
        for (final e in _entries) {
          final m = e.toMap();
          // encrypt both date and weight
          final encDate = await encryptValue(m['date'] as String, userDEK);
          final encWeight = await encryptDouble(
            (m['weight'] as num).toDouble(),
            userDEK,
          );
          weightsToSave.add({'date': encDate, 'weight': encWeight});
        }
        saveMap['weights'] = weightsToSave;
      } else {
        // store plaintext
        saveMap['weight'] = _weight;
        saveMap['height'] = heightVal;
        saveMap['waist'] = _waist;
       if (_absi != null) saveMap['absi'] = _absi;
       if (_absiZ != null) saveMap['absiZ'] = _absiZ;
       if (_absiRange != null) saveMap['absiRange'] = _absiRange;
     
        saveMap['bmi'] = bmi;
        saveMap['calorieGoal'] = calorieGoal;
        saveMap['proteinGoal'] = proteinGoal;
        saveMap['fatGoal'] = fatGoal;
        saveMap['carbGoal'] = carbGoal;
        saveMap['activityLevel'] = activityLevel;
        saveMap['goal'] = goal;
        saveMap['targetWeight'] = targetWeightVal;
        saveMap['weights'] = _entries.map((e) => e.toMap()).toList();
      }

      // keep notificationsEnabled and other booleans untouched if present
      if (data.containsKey('notificationsEnabled')) {
        saveMap['notificationsEnabled'] = data['notificationsEnabled'];
      }

      await docRef.set(saveMap, SetOptions(merge: true));

      setState(() {
        _bmi = bmi;
        _height = heightVal;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gewicht + doelen opgeslagen')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opslaan mislukt: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    _weightFocusNode.unfocus(); // Verberg het toetsenbord na het opslaan
    _targetWeightFocusNode.unfocus();
  }

  List<_MonthGroup> _groupEntriesByMonth() {
    // groepeer entries per maand
    if (_entries.isEmpty) return [];

    final Map<String, List<WeightEntry>> byMonth = {};
    for (final e in _entries) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => []).add(e);
    }

    final groups = <_MonthGroup>[]; // lijst van maandgroepen
    byMonth.forEach((key, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      groups.add(_MonthGroup(year: year, month: month, entries: list));
    });

    // sorteer op maand (oudste eerst), dan omdraaien zodat index 0 = nieuwste maand
    groups.sort((a, b) {
      final da = DateTime(a.year, a.month);
      final db = DateTime(b.year, b.month);
      return da.compareTo(db);
    });
    return groups.reversed.toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _bmiCategory(double bmi) {
    if (bmi < 16) return 'Veel te laag';
    if (bmi < 18.5) return 'Laag';
    if (bmi < 25) return 'Goed';
    if (bmi < 30) return 'Te hoog';
    return 'Veel te hoog';
  }

  Color _bmiCategoryColor(double bmi, bool isDark) {
    if (bmi < 16) return Colors.redAccent;
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                if (_weightFocusNode.hasFocus ||
                    _targetWeightFocusNode.hasFocus) {
                  _weightFocusNode.unfocus();
                  _targetWeightFocusNode.unfocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Je gewicht',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pas je gewicht aan en bekijk je BMI.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: _weightController,
                                focusNode: _weightFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Gewicht (kg)',
                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.monitor_weight,
                                    color: secondaryTextColor,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final v = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (v != null && v > 0) {
                                    setState(() => _weight = v);
                                    _recalculateBMI();
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _targetWeightController,
                                focusNode: _targetWeightFocusNode,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Streefgewicht (kg)',
                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.flag_outlined,
                                    color: secondaryTextColor,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final v = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (v != null && v > 0) {
                                    setState(() => _targetWeight = v);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              if (_targetWeight != null && _entries.length >= 2)
                                _buildTargetWeightEstimate(
                                  theme,
                                  primaryTextColor,
                                  secondaryTextColor,
                                ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gewicht slider',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: colorScheme.primary,
                                      inactiveTrackColor: colorScheme.primary
                                          .withOpacity(0.3),
                                      thumbColor: colorScheme.primary,
                                      overlayColor: colorScheme.primary
                                          .withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: _weight.clamp(30, 200),
                                      min: 30,
                                      max: 200,
                                      divisions: 170,
                                      label: _weight.toStringAsFixed(1),
                                      onChanged: (v) {
                                        setState(() {
                                          _weight = v;
                                          _weightController.text = _weight
                                              .toStringAsFixed(1);
                                        });
                                        _recalculateBMI();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.black
                                        : colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    _saving ? 'Opslaan...' : 'Gewicht opslaan',
                                  ),
                                  onPressed: _saving ? null : _saveWeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'BMI',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_bmi == null)
                                Text(
                                  'Onvoldoende gegevens om BMI te berekenen. Vul je lengte en gewicht in.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                )
                              else ...[
                                Text(
                                  'Jouw BMI: ${_bmi!.toStringAsFixed(1)} (${_bmiCategory(_bmi!)})',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _bmiCategoryColor(_bmi!, isDark),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildBmiBar(theme, isDark),
                                const SizedBox(height: 12),
                                _buildBmiLegend(theme, isDark),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Taille / ABSI',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _waistController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Tailleomtrek (cm)',
                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.straighten,
                                    color: secondaryTextColor,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final v = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (v != null && v > 0) {
                                    setState(() => _waist = v);
                                    _computeAbsi();
                                  } else {
                                    setState(() {
                                      _absi = null;
                                      _absiZ = null;
                                      _absiRange = null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_absi == null)
                                Text(
                                  'Onvoldoende gegevens om ABSI te berekenen. Vul taille, lengte en gewicht in.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jouw ABSI: ${_absi!.toStringAsFixed(4)}'
                                      '${_absiRange != null ? ' (${_absiRange})' : ''}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: _absiCategoryColor(
                                              _absiRange,
                                              isDark,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                                    _absiLegendItem(
                                          context,
                                          Colors.green,
                                          'Laag risico',
                                        ),
                                        _absiLegendItem(
                                          context,
                                          Colors.orange,
                                          'Gemiddeld risico',
                                        ),
                                        _absiLegendItem(
                                          context,
                                          Colors.redAccent,
                                          'Hoog risico',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? Colors.black
                                              : colorScheme.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: _saving
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.save),
                                        label: Text(
                                            _saving ? 'Opslaan...' : 'Taille opslaan'),
                                        onPressed: _saving ? null : _saveWeight,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Tabel'),
                            selected: _viewMode == 'table',
                            onSelected: (_) {
                              setState(() => _viewMode = 'table');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Grafiek (per maand)'),
                            selected: _viewMode == 'chart',
                            onSelected: (_) {
                              setState(() => _viewMode = 'chart');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_entries.isEmpty)
                        Text(
                          'Nog geen metingen opgeslagen.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                        )
                      else if (_viewMode == 'table')
                        _buildTableView(
                          theme,
                          primaryTextColor,
                          secondaryTextColor,
                        )
                      else
                        _buildChartView(
                          theme,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: const FeedbackButton(),
      ),
    );
  }

  Widget _buildBmiBar(ThemeData theme, bool isDark) {
    //  BMI-balk bouwen
    if (_bmi == null) return const SizedBox.shrink();
    final bmi = _clampBmi(_bmi!); // clamp de BMI binnen het bereik

    const totalRange = _bmiMax - _bmiMin;
    final veryLowWidth = _bmiVeryLowEnd - _bmiMin; // 10–16
    final lowWidth = _bmiLowEnd - _bmiVeryLowEnd; // 16–18.5
    final goodWidth = _bmiGoodEnd - _bmiLowEnd; // 18.5–25
    final highWidth = _bmiHighEnd - _bmiGoodEnd; // 25–30
    final veryHighWidth = _bmiMax - _bmiHighEnd; // 30–40

    final veryLowFlex = veryLowWidth / totalRange;
    final lowFlex = lowWidth / totalRange;
    final goodFlex = goodWidth / totalRange;
    final highFlex = highWidth / totalRange;
    final veryHighFlex = veryHighWidth / totalRange;

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final bmiPos =
              ((bmi - _bmiMin) / totalRange).clamp(0.0, 1.0) * totalWidth;

          return Stack(
            children: [
              Row(
                children: [
                  _bmiSegment(
                    flex: (veryLowFlex * 1000).round(),
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                  _bmiSegment(
                    flex: (lowFlex * 1000).round(),
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (goodFlex * 1000).round(),
                    color: Colors.green.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (highFlex * 1000).round(),
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: (veryHighFlex * 1000).round(),
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                ],
              ),
              Positioned(
                left: bmiPos,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _absiLegendItem(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: textColor)),
      ],
    );
  }

  Widget _bmiSegment({required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        color: color,
      ),
    );
  }

  Widget _buildBmiLegend(ThemeData theme, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    Widget item(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        item(Colors.redAccent.withOpacity(0.6), 'Veel te laag'),
        item(Colors.orange.withOpacity(0.7), 'Laag'),
        item(Colors.green.withOpacity(0.7), 'Goed'),
        item(Colors.orange.withOpacity(0.7), 'Te hoog'),
        item(Colors.redAccent.withOpacity(0.6), 'Veel te hoog'),
      ],
    );
  }

  Widget _buildTableView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor,
  ) {
    final reversed = _entries.reversed.toList();

    final rows = <Widget>[];
    for (var i = 0; i < reversed.length; i++) {
      final e = reversed[i];
      rows.add(
        Dismissible(
          key: Key('${e.date.toIso8601String()}_${e.weight}_$i'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Verwijderen?'),
                content: const Text(
                  'Weet je zeker dat je deze meting wilt verwijderen?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Annuleren'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Verwijderen'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            await _deleteEntry(e);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Meting verwijderd')));
          },
          child: ListTile(
            dense: true,
            title: Text(
              _formatDate(e.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: primaryTextColor,
              ),
            ),
            trailing: Text(
              '${e.weight.toStringAsFixed(1)} kg',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: primaryTextColor,
              ),
            ),
            subtitle: Text(
              _formatShortMonth(e.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Tabel metingen',
              style: TextStyle(color: primaryTextColor),
            ),
          ),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }

  Future<void> _deleteEntry(WeightEntry entry) async {
    setState(() {
      _entries.removeWhere(
        (e) => e.date == entry.date && e.weight == entry.weight,
      );
      _weight = _entries.isNotEmpty ? _entries.last.weight : 0.0;
      _weightController.text = _weight.toStringAsFixed(1);
      _recalculateBMI();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    SecretKey? userDEK;
    try {
      userDEK = await getUserDEKFromRemoteConfig(user.uid);
    } catch (_) {
      userDEK = null;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    if (userDEK != null) {
      final List<dynamic> weightsToSave = [];
      for (final e in _entries) {
        final m = e.toMap();
        final encDate = await encryptValue(m['date'] as String, userDEK);
        final encWeight = await encryptDouble(
          (m['weight'] as num).toDouble(),
          userDEK,
        );
        weightsToSave.add({'date': encDate, 'weight': encWeight});
      }
      await docRef.set({'weights': weightsToSave}, SetOptions(merge: true));
    } else {
      await docRef.set({
        'weights': _entries.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true));
    }
  }

  Widget _buildChartView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor,
  ) {
    final monthGroups = _groupEntriesByMonth();
    if (monthGroups.isEmpty) {
      return Text(
        'Nog geen metingen voor een grafiek.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    // zorg dat index binnen bereik blijft
    if (_currentMonthIndex >= monthGroups.length) {
      _currentMonthIndex = 0;
    }

    final current = monthGroups[_currentMonthIndex];
    final monthEntries = current.entries;

    final canGoPrev = _currentMonthIndex < monthGroups.length - 1;
    final canGoNext = _currentMonthIndex > 0;

    final displayedDate = DateTime(current.year, current.month, 1);

    double? minWeight;
    double? maxWeight;
    if (monthEntries.length >= 2) {
      minWeight = monthEntries
          .map((e) => e.weight)
          .reduce((a, b) => a < b ? a : b);
      maxWeight = monthEntries
          .map((e) => e.weight)
          .reduce((a, b) => a > b ? a : b);
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // titel + pijltjes, altijd tonen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: canGoPrev
                      ? () {
                          setState(() {
                            _currentMonthIndex++;
                          });
                        }
                      : null,
                ),
                Text(
                  'Grafiek – ${_formatMonthYear(displayedDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryTextColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext
                      ? () {
                          setState(() {
                            _currentMonthIndex--;
                          });
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (monthEntries.length < 2) ...[
              // te weinig metingen: geen grafiek, wél navigatie
              Text(
                'Nog te weinig metingen in deze maand voor een grafiek.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ] else ...[
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    entries: monthEntries,
                    minWeight: minWeight!,
                    maxWeight: maxWeight!,
                    lineColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Horizontaal: dagen van de maand, Verticaal: gewicht (kg)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightEstimate(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor,
  ) {
    if (_entries.length < 2 || _targetWeight == null) {
      return Text(
        'Niet genoeg data om een trend te berekenen.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    // ===== CONFIG =====
    const int lookbackMonths = 1;
    const int minRecentPoints = 3;
    const double slopeThreshold = 0.001; // kg/dag (≈ 1g/dag)
    const int maxReasonableDays = 3650; // 10 jaar
    const double halfLifeDays = 14; // exponentiële halfwaardetijd

    final now = DateTime.now();
    final cutoffDate = DateTime(now.year, now.month - lookbackMonths, now.day);

    // Sorteer alle metingen
    final allSorted = _entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Gebruik recente data indien mogelijk
    final recent = allSorted.where((e) => e.date.isAfter(cutoffDate)).toList();

    final sorted = recent.length >= minRecentPoints ? recent : allSorted;

    final lastWeight = sorted.last.weight;

    // Op streefgewicht?
    if ((lastWeight - _targetWeight!).abs() < 0.01) {
      return Text(
        'Goed zo! Je bent op je streefgewicht.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (sorted.length < 2) {
      return Text(
        'Niet genoeg data om een trend te berekenen.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final firstDate = sorted.first.date;
    final n = sorted.length;

    // x = dagen sinds eerste meting (fractioneel)
    final xs = List<double>.generate(n, (i) {
      final ms = sorted[i].date.difference(firstDate).inMilliseconds;
      return ms / Duration.millisecondsPerDay;
    });
    final ys = List<double>.generate(n, (i) => sorted[i].weight.toDouble());

    // ===== Exponentiële gewichten =====
    // Recentere punten krijgen meer gewicht
    final lastX = xs.last;
    final lambda = log(2) / halfLifeDays;

    final ws = List<double>.generate(n, (i) {
      final ageDays = lastX - xs[i];
      return exp(-lambda * ageDays);
    });

    final wSum = ws.reduce((a, b) => a + b);

    // Gewogen gemiddelden
    final meanX =
        List.generate(n, (i) => ws[i] * xs[i]).reduce((a, b) => a + b) / wSum;
    final meanY =
        List.generate(n, (i) => ws[i] * ys[i]).reduce((a, b) => a + b) / wSum;

    double num = 0.0;
    double den = 0.0;

    for (int i = 0; i < n; i++) {
      final dx = xs[i] - meanX;
      final dy = ys[i] - meanY;
      num += ws[i] * dx * dy;
      den += ws[i] * dx * dx;
    }

    if (den == 0) {
      return Text(
        'Nog geen trend te berekenen.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final slope = num / den; // kg per dag
    final intercept = meanY - slope * meanX;

    // ===== Residuals (onzekerheid) =====
    double varNum = 0.0;
    for (int i = 0; i < n; i++) {
      final pred = intercept + slope * xs[i];
      final res = ys[i] - pred;
      varNum += ws[i] * res * res;
    }
    final residualStd = sqrt(varNum / wSum);

    // Stabiel?
    if (slope.abs() < slopeThreshold) {
      return Text(
        'Je gewicht is redelijk stabiel, geen betrouwbare trend.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final remaining = _targetWeight! - lastWeight;

    // Verkeerde richting?
    if ((remaining > 0 && slope <= 0) || (remaining < 0 && slope >= 0)) {
      return Text(
        'Met de huidige trend beweeg je van je streefgewicht af.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final daysNeeded = (remaining / slope).abs();

    if (daysNeeded.isNaN || daysNeeded.isInfinite) {
      return Text(
        'Er is onvoldoende trendinformatie om een realistische inschatting te maken.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    if (daysNeeded > maxReasonableDays) {
      return Text(
        'Op basis van de huidige trend is het onwaarschijnlijk dat je je streefgewicht binnen 10 jaar bereikt.',
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final totalDays = daysNeeded.ceil();
    final weeks = totalDays ~/ 7;
    final daysLeft = totalDays % 7;

    String timeStr = '';
    if (weeks > 0) {
      timeStr += '$weeks ${weeks == 1 ? 'week' : 'weken'}';
    }
    if (daysLeft > 0) {
      if (timeStr.isNotEmpty) timeStr += ' en ';
      timeStr += '$daysLeft dag${daysLeft == 1 ? '' : 'en'}';
    }
    if (timeStr.isEmpty) timeStr = 'minder dan een dag';

    final targetDate = DateTime.now().add(Duration(days: totalDays));
    final dateStr = '${targetDate.day}-${targetDate.month}-${targetDate.year}';

    // Onzekerheidstekst
    String uncertaintyNote = '';
    if (residualStd >= 1.0) {
      uncertaintyNote =
          '\nLet op: zeer grote schommelingen maken deze schatting onbetrouwbaar.';
    } else if (residualStd >= 0.5) {
      uncertaintyNote =
          '\nLet op: flinke schommelingen maken deze schatting onzeker.';
    } else if (residualStd >= 0.25) {
      uncertaintyNote = '\nOpmerking: enige variatie — schatting kan afwijken.';
    }

    final basisStr = recent.length >= minRecentPoints
        ? 'op basis van de afgelopen maand'
        : 'op basis van alle metingen';

    return Text(
      'Als je zo doorgaat ($basisStr), bereik je je streefgewicht over ongeveer '
      '$timeStr (rond $dateStr).$uncertaintyNote',
      style: theme.textTheme.bodySmall?.copyWith(
        color: secondaryTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  String _formatShortMonth(DateTime date) {
    const months = [
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return months[date.month - 1];
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] as String? ?? '';
    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    final dynamic rawWeight = map['weight'];
    double weight;

    if (rawWeight is num) {
      weight = rawWeight.toDouble();
    } else if (rawWeight is String) {
      weight = double.tryParse(rawWeight.replaceAll(',', '.')) ?? 0.0;
    } else {
      weight = 0.0;
    }

    return WeightEntry(date: date, weight: weight);
  }

  Map<String, dynamic> toMap() {
    final d = date;
    final onlyDate = DateTime(d.year, d.month, d.day);
    return {'date': onlyDate.toIso8601String(), 'weight': weight};
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final Color lineColor;

  _WeightChartPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const double leftPad = 32;
    const double rightPad = 8;
    const double topPad = 8;
    const double bottomPad = 32;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final first = entries.first.date;
    final last = entries.last.date;
    final startDay = first.day.toDouble();
    final endDay = last.day.toDouble();
    final dayRange = (endDay - startDay).clamp(1, 31);

    final wRange = (maxWeight - minWeight).abs().clamp(1, 100);

    final paintAxis = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();

    final List<Offset> points = [];

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final dayPos = (e.date.day - startDay) / dayRange;
      final weightPos = (e.weight - minWeight) / wRange;

      final dx = leftPad + dayPos * chartWidth;
      final dy = topPad + (1 - weightPos) * chartHeight;

      points.add(Offset(dx, dy));

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final origin = Offset(leftPad, topPad + chartHeight);
    final xEnd = Offset(leftPad + chartWidth, topPad + chartHeight);
    final yEnd = Offset(leftPad, topPad);

    canvas.drawLine(origin, xEnd, paintAxis);
    canvas.drawLine(origin, yEnd, paintAxis);

    canvas.drawPath(path, paintLine);

    const double pointRadius = 4;
    for (final p in points) {
      canvas.drawCircle(p, pointRadius + 1.5, paintAxis);
      canvas.drawCircle(p, pointRadius, paintPoint);
    }

    final textStyle = TextStyle(color: Colors.grey.shade700, fontSize: 10);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final p = points[i];

      final label = e.date.day.toString();
      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      final offset = Offset(p.dx - textPainter.width / 2, origin.dy + 2);
      textPainter.paint(canvas, offset);
    }

    final Set<String> usedWeightLabels = {};
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final p = points[i];

      final label = e.weight.toStringAsFixed(1);
      if (usedWeightLabels.contains(label)) continue;
      usedWeightLabels.add(label);

      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      final offset = Offset(
        leftPad - textPainter.width - 4,
        p.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight ||
        oldDelegate.lineColor != lineColor;
  }
}

class _MonthGroup {
  final int year;
  final int month;
  final List<WeightEntry> entries;

  _MonthGroup({required this.year, required this.month, required this.entries});
}
