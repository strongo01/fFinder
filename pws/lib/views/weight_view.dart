import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:fFinder/views/feedback_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fFinder/l10n/app_localizations.dart';

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
  List<WeightEntry> _waistEntries = [];
  String _measurementType = 'weight';

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

  DateTime? _userBirthDate;
  String _userGender = 'Man';
  final Map<String, Map<int, Map<String, double>>> _lmsCache = {
    '1': {}, // man
    '2': {}, // vrouw
  };

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _targetWeightController = TextEditingController();
  final FocusNode _weightFocusNode =
      FocusNode(); // FocusNode voor het gewicht invoerveld
  final FocusNode _targetWeightFocusNode = FocusNode();
  final FocusNode _waistFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadAbsiReference().catchError((_) {});
    await _ensureCdcLmsLoaded().catchError((_) {});

    await _loadUserData().catchError((_) {});

    if ((_bmi == null) && _height > 0 && _weight > 0) {
      _recalculateBMI();
    }

    await _computeAbsi().catchError((e) {
      debugPrint('[INIT] _computeAbsi error: $e');
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _targetWeightController.dispose();
    _weightFocusNode.dispose();
    _waistFocusNode.dispose();
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

      if (data['gender'] is String) {
        if (userDEK != null) {
          try {
            _userGender = await decryptValue(data['gender'] as String, userDEK);
          } catch (_) {
            _userGender = data['gender'] as String;
          }
        } else {
          _userGender = data['gender'] as String;
        }
      }
      final String? birthDateStrEnc = data['birthDate'] as String?;
      if (birthDateStrEnc != null) {
        String birthDecoded = birthDateStrEnc;
        if (userDEK != null) {
          try {
            birthDecoded = await decryptValue(birthDateStrEnc, userDEK);
          } catch (_) {}
        }
        _userBirthDate = birthDecoded.isNotEmpty
            ? DateTime.tryParse(birthDecoded)
            : null;
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

      final tailleRaw = data['taille'] as List<dynamic>? ?? [];
      final List<WeightEntry> loadedWaists = [];
      for (final item in tailleRaw) {
        try {
          if (item is String && userDEK != null) {
            final dec = await decryptValue(item, userDEK);
            final Map<String, dynamic> m = Map<String, dynamic>.from(
              jsonDecode(dec),
            );
            final date =
                DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now();
            final w = _parseDouble(m['weight']) ?? 0.0;
            loadedWaists.add(WeightEntry(date: date, weight: w));
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
            loadedWaists.add(WeightEntry(date: date, weight: weightVal));
          }
        } catch (_) {}
      }

      _entries = loaded..sort((a, b) => a.date.compareTo(b.date));
      _waistEntries = loadedWaists..sort((a, b) => a.date.compareTo(b.date));
      _currentMonthIndex = 0;
      _weightController.text = _weight.toStringAsFixed(1);
      if (_targetWeight != null) {
        _targetWeightController.text = _targetWeight!.toStringAsFixed(1);
      }
      _waistController.text = _waist.toStringAsFixed(1);
      debugPrint('--- USER DATA LOADED ---');
      debugPrint('Gender (raw): $_userGender');
      debugPrint('Birthdate: $_userBirthDate');
      debugPrint('Age years: ${_ageYearsFromBirthDate(_userBirthDate)}');
      debugPrint('Age months: ${_ageMonthsFromBirthDate(_userBirthDate)}');

      _recalculateBMI();
      _computeAbsi();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.weightLoadErrorPrefix} $e',
          ),
        ),
      );
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
      debugPrint('[BMI] Invalid height or weight');
      setState(() => _bmi = null);
      return;
    }

    final hMeters = _height / 100;
    final bmi = _weight / (hMeters * hMeters);

    debugPrint('[BMI] height=$_height cm, weight=$_weight kg');
    debugPrint('[BMI] calculated bmi=$bmi');

    setState(() => _bmi = bmi);
  }

  Future<void> _computeAbsi() async {
    debugPrint(
      '[ABSI] compute start: waist=$_waist, bmi=$_bmi, height=$_height, weight=$_weight',
    );

    // Als bmi nog null is maar we hebben wel hoogte/gewicht, probeer deze direct te (her)berekenen
    if (_bmi == null && _height > 0 && _weight > 0) {
      debugPrint(
        '[ABSI] bmi is null maar height & weight aanwezig — (her)berekenen',
      );
      _recalculateBMI();
      debugPrint('[ABSI] after recalc bmi=$_bmi');
    }

    if (_waist <= 0 || _bmi == null || _height <= 0) {
      debugPrint(
        '[ABSI] onvoldoende data voor ABSI: waist=$_waist, bmi=$_bmi, height=$_height',
      );
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
    debugPrint('[ABSI] computed absi=$absi');

    String? rangeKey;
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
            final ref = isFemale ? entry['female'] : entry['male'];
            final mean = (ref['mean'] as num).toDouble();
            final sd = (ref['sd'] as num).toDouble();
            if (sd != 0) {
              z = (absi - mean) / sd;
              if (z <= -1.0) {
                rangeKey = 'very_low';
              } else if (z <= -0.5) {
                rangeKey = 'low';
              } else if (z <= 0.5) {
                rangeKey = 'medium';
              } else if (z <= 1.0) {
                rangeKey = 'increased';
              } else {
                rangeKey = 'high';
              }
              debugPrint('[ABSI] ref mean=$mean sd=$sd z=$z range=$rangeKey');
            } else {
              debugPrint('[ABSI] ref sd == 0, geen z-score');
            }
          } else {
            debugPrint(
              '[ABSI] geen geboortedatum in Firestore voor absi referentie',
            );
          }
        }
      } else {
        debugPrint('[ABSI] geen absi reference table geladen');
      }
    } catch (e) {
      debugPrint('[ABSI] fout bij referentie lookup: $e');
    }

    setState(() {
      _absi = absi;
      _absiZ = z;
      _absiRange = rangeKey;
    });
    debugPrint(
      '[ABSI] setState done: _absi=$_absi _absiZ=$_absiZ _absiRange=$_absiRange',
    );
  }

  Future<void> _ensureCdcLmsLoaded() async {
    if ((_lmsCache['1']?.isNotEmpty ?? false) &&
        (_lmsCache['2']?.isNotEmpty ?? false)) {
      return;
    }
    final csvString = await rootBundle.loadString('assets/cdc/bmiagerev.csv');
    final lines = const LineSplitter().convert(csvString);
    if (lines.isEmpty) throw Exception('Leeg CSV bestand');

    final header = lines.first
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .toList();
    final idxSex = header.indexWhere((h) => h.contains('sex'));
    final idxAge = header.indexWhere(
      (h) => h.contains('agemos') || h.contains('age'),
    );
    final idxL = header.indexWhere(
      (h) => h == 'l' || h.contains(' l') || h == 'l ',
    );
    final idxM = header.indexWhere(
      (h) => h == 'm' || h.contains(' m') || h == 'm ',
    );
    final idxS = header.indexWhere(
      (h) => h == 's' || h.contains(' s') || h == 's ',
    );

    if (idxSex == -1 ||
        idxAge == -1 ||
        idxL == -1 ||
        idxM == -1 ||
        idxS == -1) {
      throw Exception('CSV header heeft niet verwachte kolommen');
    }
    _lmsCache['1']?.clear();
    _lmsCache['2']?.clear();

    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length <= max(idxSex, max(idxAge, max(idxL, max(idxM, idxS))))) {
        continue;
      }
      final sex = row[idxSex].trim();
      final agemos = double.tryParse(row[idxAge].trim())?.round();
      final L = double.tryParse(row[idxL].trim());
      final M = double.tryParse(row[idxM].trim());
      final S = double.tryParse(row[idxS].trim());
      if (agemos != null && L != null && M != null && S != null) {
        _lmsCache[sex]?[agemos] = {'L': L, 'M': M, 'S': S};
      }
    }
  }

  double _bmiFromLms(double z, double L, double M, double S) {
    if (L == 0) return M * exp(S * z);
    return M * pow(1 + L * S * z, 1 / L);
  }

  int _ageYearsFromBirthDate(DateTime? bd) {
    if (bd == null) return 0;
    final now = DateTime.now();
    int years = now.year - bd.year;
    if (now.month < bd.month || (now.month == bd.month && now.day < bd.day)) {
      years--;
    }
    return years;
  }

  int _ageMonthsFromBirthDate(DateTime? bd) {
    if (bd == null) return 0;
    final now = DateTime.now();
    int months = (now.year - bd.year) * 12 + (now.month - bd.month);
    if (now.day < bd.day) months--;
    return max(0, months);
  }

  String _genderCodeFromLocalized(String gender) {
    final g = gender.trim().toLowerCase();
    final code =
        (g.contains('vrouw') || g.contains('woman') || g.startsWith('f'))
        ? '2'
        : '1';

    debugPrint('[GENDER] input="$gender" → normalized="$g" → sexCode=$code');
    return code;
  }

  Color _absiCategoryColor(String? rangeKey, bool isDark) {
    if (rangeKey == null) return isDark ? Colors.white : Colors.black;
    switch (rangeKey) {
      case 'very_low':
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'increased':
      case 'high':
      default:
        return Colors.redAccent;
    }
  }

  Future<void> _saveWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    debugPrint("--- SAVE WEIGHT TRIGGERED ---");
    _weightFocusNode.unfocus();
    _targetWeightFocusNode.unfocus();
    _waistFocusNode.unfocus();

    final waistTextForValidation = _waistController.text.trim();
    double? parsedWaistForValidation;
    if (waistTextForValidation.isNotEmpty) {
      parsedWaistForValidation = double.tryParse(
        waistTextForValidation.replaceAll(',', '.'),
      );
    } else {
      parsedWaistForValidation = _waist;
    }

    final targetTextForValidation = _targetWeightController.text.trim();
    double? parsedTargetForValidation;
    if (targetTextForValidation.isNotEmpty) {
      parsedTargetForValidation = double.tryParse(
        targetTextForValidation.replaceAll(',', '.'),
      );
    } else {
      parsedTargetForValidation = _targetWeight;
    }
    final loc = AppLocalizations.of(context)!;

    final List<String> errors = [];
    if (!(_height >= 50 && _height <= 300)) {
      errors.add(loc.heightRange);
    }
    if (!(_weight >= 20 && _weight <= 800)) {
      errors.add(loc.weightRange);
    }
    if (!(parsedWaistForValidation != null &&
        parsedWaistForValidation >= 30 &&
        parsedWaistForValidation <= 200)) {
      errors.add(loc.waistRange);
    }
    if (parsedTargetForValidation != null &&
        !(parsedTargetForValidation >= 20 &&
            parsedTargetForValidation <= 800)) {
      errors.add(loc.targetWeightRange);
    }

    if (errors.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.join(' ')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _waist = parsedWaistForValidation ?? _waist;
      _targetWeight = parsedTargetForValidation ?? _targetWeight;
      _saving = true;
    });

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

      final onlyDate = DateTime(now.year, now.month, now.day);
      final newWaistEntry = WeightEntry(date: onlyDate, weight: _waist);
      _waistEntries.removeWhere((e) => _isSameDay(e.date, newWaistEntry.date));
      _waistEntries.add(newWaistEntry);
      _waistEntries.sort((a, b) => a.date.compareTo(b.date));

      if (userDEK != null) {
        saveMap['weight'] = await encryptDouble(_weight, userDEK);
        saveMap['height'] = await encryptDouble(heightVal, userDEK);
        saveMap['waist'] = await encryptDouble(_waist, userDEK);
        if (_absi != null)
          saveMap['absi'] = await encryptDouble(_absi!, userDEK);
        if (_absiZ != null)
          saveMap['absiZ'] = await encryptDouble(_absiZ!, userDEK);
        if (_absiRange != null)
          saveMap['absiRange'] = await encryptValue(_absiRange!, userDEK);

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
        final List<dynamic> waistsToSave = [];
        for (final e in _waistEntries) {
          final m = e.toMap();
          final encDate = await encryptValue(m['date'] as String, userDEK);
          final encWeight = await encryptDouble(
            (m['weight'] as num).toDouble(),
            userDEK,
          );
          waistsToSave.add({'date': encDate, 'weight': encWeight});
        }
        saveMap['taille'] = waistsToSave;
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
        saveMap['taille'] = _waistEntries.map((e) => e.toMap()).toList();
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
        SnackBar(content: Text(AppLocalizations.of(context)!.saveSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.saveFailedPrefix} $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    _computeAbsi();
    _weightFocusNode.unfocus(); // Verberg het toetsenbord na het opslaan
    _targetWeightFocusNode.unfocus();
    _waistFocusNode.unfocus();
  }

  List<_MonthGroup> _groupEntriesByMonthFor(List<WeightEntry> entries) {
    if (entries.isEmpty) return [];
    final Map<String, List<WeightEntry>> byMonth = {};
    for (final e in entries) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => []).add(e);
    }

    final groups = <_MonthGroup>[];
    byMonth.forEach((key, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      groups.add(_MonthGroup(year: year, month: month, entries: list));
    });

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
    final loc = AppLocalizations.of(context)!;
    debugPrint('--- BMI CATEGORY CHECK ---');
    debugPrint('BMI value: $bmi');
    debugPrint('Birthdate: $_userBirthDate');
    debugPrint('Age years: ${_ageYearsFromBirthDate(_userBirthDate)}');
    debugPrint('Age months: ${_ageMonthsFromBirthDate(_userBirthDate)}');
    debugPrint('Gender: $_userGender');

    // Probeer kinder-BMI logica
    try {
      final ageYears = _ageYearsFromBirthDate(_userBirthDate);
      final ageMonths = _ageMonthsFromBirthDate(_userBirthDate);

      if (_userBirthDate != null && ageYears < 18 && ageMonths >= 24) {
        final sexCode = _genderCodeFromLocalized(_userGender);
        final lmsDataForSex = _lmsCache[sexCode];
        debugPrint('[LMS] sexCode=$sexCode');
        debugPrint('[LMS] LMS loaded for sex: ${lmsDataForSex != null}');
        debugPrint('[LMS] LMS entries count: ${lmsDataForSex?.length}');
        debugPrint('[LMS] Requested ageMonths=$ageMonths');

        if (lmsDataForSex != null && lmsDataForSex.isNotEmpty) {
          Map<String, double>? lms = lmsDataForSex[ageMonths];
          if (lms != null) {
            debugPrint('[LMS] Found LMS for month (or nearest)');
            debugPrint('[LMS] L=${lms['L']} M=${lms['M']} S=${lms['S']}');
          } else {
            debugPrint(
              '[LMS] ❌ No LMS found for this age, selecting nearest available month',
            );
            final keys = lmsDataForSex.keys.toList()..sort();
            final nearest = keys.reduce(
              (a, b) => (a - ageMonths).abs() < (b - ageMonths).abs() ? a : b,
            );
            lms = lmsDataForSex[nearest];
            debugPrint('[LMS] using nearest month=$nearest');
            debugPrint('[LMS] L=${lms!['L']} M=${lms['M']} S=${lms['S']}');
          }

          final L = lms['L']!;
          final M = lms['M']!;
          final S = lms['S']!;

          const z1 = -2.33; // 1e percentiel (ernstig ondergewicht)
          const z5 = -1.645; // 5e percentiel
          const z85 = 1.036; // 85e percentiel
          const z95 = 1.645; // 95e percentiel
          final bmi1 = _bmiFromLms(z1, L, M, S);

          final bmi5 = _bmiFromLms(z5, L, M, S);
          final bmi85 = _bmiFromLms(z85, L, M, S);
          final bmi95 = _bmiFromLms(z95, L, M, S);
          debugPrint('[BMI PERCENTILES]');
          debugPrint('BMI 1p  = $bmi1');

          debugPrint('BMI 5p  = $bmi5');
          debugPrint('BMI 85p = $bmi85');
          debugPrint('BMI 95p = $bmi95');
          debugPrint('User BMI = $bmi');

          debugPrint('[BMI RESULT] category decided for bmi=$bmi');

          if (bmi < bmi1) return loc.bmiVeryLow; // Ernstig ondergewicht
          if (bmi < bmi5) return loc.bmiLow; // Ondergewicht
          if (bmi < bmi85) return loc.bmiGood;
          if (bmi < bmi95) return loc.bmiHigh;
          return loc.bmiVeryHigh;
        }
      }
    } catch (_) {
      // Val terug op volwassen logica bij een fout
    }

    // Fallback voor volwassenen (of als kinder-BMI faalt)
    if (bmi < 16) return loc.bmiVeryLow;
    if (bmi < 18.5) return loc.bmiLow;
    if (bmi < 25) return loc.bmiGood;
    if (bmi < 30) return loc.bmiHigh;
    return loc.bmiVeryHigh;
  }

  Color _bmiCategoryColor(double bmi, bool isDark) {
    // Probeer kinder-BMI logica
    try {
      final ageYears = _ageYearsFromBirthDate(_userBirthDate);
      final ageMonths = _ageMonthsFromBirthDate(_userBirthDate);

      if (_userBirthDate != null && ageYears < 18 && ageMonths >= 24) {
        final sexCode = _genderCodeFromLocalized(_userGender);
        final lmsDataForSex = _lmsCache[sexCode];
        if (lmsDataForSex != null && lmsDataForSex.isNotEmpty) {
          Map<String, double>? lms = lmsDataForSex[ageMonths];
          if (lms == null) {
            final keys = lmsDataForSex.keys.toList()..sort();
            int nearest = keys.reduce(
              (a, b) => (a - ageMonths).abs() < (b - ageMonths).abs() ? a : b,
            );
            lms = lmsDataForSex[nearest]!;
          }

          final L = lms['L']!;
          final M = lms['M']!;
          final S = lms['S']!;
          const z1 = -2.33; // 1e percentiel (ernstig ondergewicht)

          const z5 = -1.645; // 5e percentiel (was incorrect)
          const z85 = 1.036; // 85e percentiel
          const z95 = 1.645; // 95e percentiel
          final bmi1 = _bmiFromLms(z1, L, M, S);

          final bmi5 = _bmiFromLms(z5, L, M, S);
          final bmi85 = _bmiFromLms(z85, L, M, S);
          final bmi95 = _bmiFromLms(z95, L, M, S);

          if (bmi < bmi1) return Colors.redAccent; // Ernstig ondergewicht
          if (bmi < bmi5) return Colors.orange; // Ondergewicht

          if (bmi < bmi85) return Colors.green; // Gezond
          if (bmi < bmi95) return Colors.orange; // Overgewicht
          return Colors.redAccent; // Obesitas
        }
      }
    } catch (_) {
      // Val terug op volwassen logica bij een fout
    }

    // Fallback voor volwassenen
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
    final selectedEntries = _measurementType == 'weight'
        ? _entries
        : _waistEntries;
    final unit = _measurementType == 'weight' ? 'kg' : 'cm';
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        // Gebruik de surface-kleur (stabieler) en verwijder surface tint / schaduw
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                if (_weightFocusNode.hasFocus ||
                    _targetWeightFocusNode.hasFocus ||
                    _waistFocusNode.hasFocus) {
                  _weightFocusNode.unfocus();
                  _targetWeightFocusNode.unfocus();
                  _waistFocusNode.unfocus();
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
                        loc.weightTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.weightSubtitle,
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
                                  labelText: loc.weightLabel,
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
                                    _computeAbsi();
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
                                  labelText: loc.targetWeightLabel,
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
                                    loc.weightSliderLabel,
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
                                        _computeAbsi();
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
                                    _saving ? loc.saving : loc.saveWeight,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.bmiTitle,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: primaryTextColor),
                                  ),
                                  if (_userBirthDate != null &&
                                      _ageYearsFromBirthDate(_userBirthDate) <
                                          18)
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color:
                                            secondaryTextColor ??
                                            (isDark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      tooltip: loc.bmiForChildrenTitle,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor:
                                                theme.colorScheme.surface,
                                            title: Text(
                                              loc.bmiForChildrenTitle,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: primaryTextColor,
                                                  ),
                                            ),
                                            content: Text(
                                              loc.bmiForChildrenExplanation,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: secondaryTextColor,
                                                  ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      theme.colorScheme.primary,
                                                ),
                                                child: Text(loc.close),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_bmi == null)
                                Text(
                                  loc.bmiInsufficient,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                )
                              else ...[
                                Text(
                                  '${loc.yourBmiPrefix} ${_bmi!.toStringAsFixed(1)} (${_bmiCategory(_bmi!)})',
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
                                loc.waistAbsiTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                focusNode: _waistFocusNode,
                                controller: _waistController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: loc.waistLabel,
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
                                  loc.absiInsufficient,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${loc.yourAbsiPrefix} ${_absi!.toStringAsFixed(4)}'
                                      '${_absiRange != null ? ' (${_absiRangeLabel(loc, _absiRange)})' : ''}',
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
                                          loc.absiLowRisk,
                                        ),
                                        _absiLegendItem(
                                          context,
                                          Colors.orange,
                                          loc.absiMedium,
                                        ),
                                        _absiLegendItem(
                                          context,
                                          Colors.redAccent,
                                          loc.absiHigh,
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
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(Icons.save),
                                        label: Text(
                                          _saving ? loc.saving : loc.saveWaist,
                                        ),
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

                      SizedBox(
                        height: 40,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ChoiceChip(
                                label: Text(loc.choiceWeight),
                                selected: _measurementType == 'weight',
                                onSelected: (_) {
                                  setState(() => _measurementType = 'weight');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(loc.choiceWaist),
                                selected: _measurementType == 'taille',
                                onSelected: (_) {
                                  setState(() => _measurementType = 'taille');
                                },
                              ),
                              const SizedBox(width: 12),

                              ChoiceChip(
                                label: Text(loc.choiceTable),
                                selected: _viewMode == 'table',
                                onSelected: (_) {
                                  setState(() => _viewMode = 'table');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(loc.choiceChart),
                                selected: _viewMode == 'chart',
                                onSelected: (_) {
                                  setState(() => _viewMode = 'chart');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (selectedEntries.isEmpty)
                        Text(
                          _measurementType == 'weight'
                              ? loc.noMeasurements
                              : loc.noWaistMeasurements,
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
                          entries: selectedEntries,
                          unit: unit,
                        )
                      else
                        _buildChartView(
                          theme,
                          primaryTextColor,
                          secondaryTextColor,
                          entries: selectedEntries,
                          unit: unit,
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
    if (_bmi == null) return const SizedBox.shrink();

    // Standaard drempels voor volwassenen
    double veryLowEnd = _bmiVeryLowEnd;
    double lowEnd = _bmiLowEnd;
    double goodEnd = _bmiGoodEnd;
    double highEnd = _bmiHighEnd;

    // Probeer drempels voor kinderen te berekenen
    try {
      final ageYears = _ageYearsFromBirthDate(_userBirthDate);
      final ageMonths = _ageMonthsFromBirthDate(_userBirthDate);

      if (_userBirthDate != null && ageYears < 20 && ageMonths >= 24) {
        final sexCode = _genderCodeFromLocalized(_userGender);
        final lmsDataForSex = _lmsCache[sexCode];

        if (lmsDataForSex != null && lmsDataForSex.isNotEmpty) {
          Map<String, double>? lms = lmsDataForSex[ageMonths];
          if (lms == null) {
            final keys = lmsDataForSex.keys.toList()..sort();
            int nearest = keys.reduce(
              (a, b) => (a - ageMonths).abs() < (b - ageMonths).abs() ? a : b,
            );
            lms = lmsDataForSex[nearest]!;
          }

          final L = lms['L']!;
          final M = lms['M']!;
          final S = lms['S']!;

          // Bereken BMI-waarden voor de percentielen
          veryLowEnd = _bmiFromLms(-2.33, L, M, S); // ~1e percentiel
          lowEnd = _bmiFromLms(-1.645, L, M, S); // 5e percentiel
          goodEnd = _bmiFromLms(1.036, L, M, S); // 85e percentiel
          highEnd = _bmiFromLms(1.645, L, M, S); // 95e percentiel
        }
      }
    } catch (_) {
      // Val terug op volwassen drempels bij een fout
    }

    final bmi = _clampBmi(_bmi!);
    const totalRange = _bmiMax - _bmiMin;

    // Bereken de breedte van de segmenten dynamisch
    final veryLowWidth = (veryLowEnd - _bmiMin).clamp(0, totalRange);
    final lowWidth = (lowEnd - veryLowEnd).clamp(0, totalRange);
    final goodWidth = (goodEnd - lowEnd).clamp(0, totalRange);
    final highWidth = (highEnd - goodEnd).clamp(0, totalRange);
    final veryHighWidth = (_bmiMax - highEnd).clamp(0, totalRange);

    final totalCalculatedWidth =
        veryLowWidth + lowWidth + goodWidth + highWidth + veryHighWidth;

    // Normaliseer naar flex-waarden
    final veryLowFlex = (veryLowWidth / totalCalculatedWidth * 1000).round();
    final lowFlex = (lowWidth / totalCalculatedWidth * 1000).round();
    final goodFlex = (goodWidth / totalCalculatedWidth * 1000).round();
    final highFlex = (highWidth / totalCalculatedWidth * 1000).round();
    final veryHighFlex = (veryHighWidth / totalCalculatedWidth * 1000).round();

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
                    flex: veryLowFlex,
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                  _bmiSegment(
                    flex: lowFlex,
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: goodFlex,
                    color: Colors.green.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: highFlex,
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  _bmiSegment(
                    flex: veryHighFlex,
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

  String _absiRangeLabel(AppLocalizations loc, String? rangeKey) {
    if (rangeKey == null) return '';
    switch (rangeKey) {
      case 'very_low':
        return loc.absiVeryLowRisk;
      case 'low':
        return loc.absiLowRisk;
      case 'medium':
        return loc.absiMedium;
      case 'increased':
        return loc.absiIncreasedRisk;
      case 'high':
        return loc.absiHigh;
      default:
        return rangeKey;
    }
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
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
        ),
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
        item(
          Colors.redAccent.withOpacity(0.6),
          AppLocalizations.of(context)!.bmiVeryLow,
        ),
        item(
          Colors.orange.withOpacity(0.7),
          AppLocalizations.of(context)!.bmiLow,
        ),
        item(
          Colors.green.withOpacity(0.7),
          AppLocalizations.of(context)!.bmiGood,
        ),
        item(
          Colors.orange.withOpacity(0.7),
          AppLocalizations.of(context)!.bmiHigh,
        ),
        item(
          Colors.redAccent.withOpacity(0.6),
          AppLocalizations.of(context)!.bmiVeryHigh,
        ),
      ],
    );
  }

  Widget _buildTableView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor, {
    required List<WeightEntry> entries,
    required String unit,
  }) {
    final reversed = entries.reversed.toList();

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
              builder: (ctx) {
              final dialogTheme = Theme.of(ctx);
              final onSurface = dialogTheme.colorScheme.onSurface;
              return AlertDialog(
                backgroundColor: dialogTheme.colorScheme.surface,
                title: Text(
                AppLocalizations.of(context)!.deleteConfirmTitle,
                style: dialogTheme.textTheme.titleMedium
                  ?.copyWith(color: onSurface),
                ),
                content: Text(
                AppLocalizations.of(context)!.deleteConfirmContent,
                style:
                  dialogTheme.textTheme.bodyMedium?.copyWith(color: onSurface),
                ),
                actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                  foregroundColor: dialogTheme.colorScheme.primary,
                  ),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                  foregroundColor: dialogTheme.colorScheme.error,
                  ),
                  child: Text(
                  AppLocalizations.of(context)!.deleteConfirmDelete,
                  ),
                ),
                ],
              );
              },
            );
          },
          onDismissed: (direction) async {
            await _deleteEntry(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.measurementDeleted),
              ),
            );
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
              '${e.weight.toStringAsFixed(1)} $unit',
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
              '${AppLocalizations.of(context)!.tableMeasurementsTitle} ($unit)',
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
      if (_entries.any(
        (e) => e.date == entry.date && e.weight == entry.weight,
      )) {
        _entries.removeWhere(
          (e) => e.date == entry.date && e.weight == entry.weight,
        );
        _weight = _entries.isNotEmpty ? _entries.last.weight : 0.0;
        _weightController.text = _weight.toStringAsFixed(1);
        _recalculateBMI();
        _computeAbsi();
      } else {
        _waistEntries.removeWhere(
          (e) => e.date == entry.date && e.weight == entry.weight,
        );
        _waist = _waistEntries.isNotEmpty ? _waistEntries.last.weight : _waist;
        _waistController.text = _waist.toStringAsFixed(1);
      }
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
      final List<dynamic> waistsToSave = [];
      for (final e in _waistEntries) {
        final m = e.toMap();
        final encDate = await encryptValue(m['date'] as String, userDEK);
        final encWeight = await encryptDouble(
          (m['weight'] as num).toDouble(),
          userDEK,
        );
        waistsToSave.add({'date': encDate, 'weight': encWeight});
      }
      await docRef.set({'taille': waistsToSave}, SetOptions(merge: true));
    } else {
      await docRef.set({
        'weights': _entries.map((e) => e.toMap()).toList(),
        'taille': _waistEntries.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true));
    }
  }

  Widget _buildChartView(
    ThemeData theme,
    Color primaryTextColor,
    Color? secondaryTextColor, {
    required List<WeightEntry> entries,
    required String unit,
  }) {
    final monthGroups = _groupEntriesByMonthFor(entries);

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
                  '${AppLocalizations.of(context)!.chartTitlePrefix} ${_formatMonthYear(displayedDate)} ($unit)',
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
                AppLocalizations.of(context)!.chartTooFew,
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
                '${AppLocalizations.of(context)!.chartAxesLabel} ($unit)',
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
        AppLocalizations.of(context)!.estimateNotEnoughData,
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

    final lastEntry = sorted.last;
    final lastWeight = lastEntry.weight;

    // Op streefgewicht?
    if ((lastWeight - _targetWeight!).abs() < 0.1) {
      return Text(
        AppLocalizations.of(context)!.estimateOnTarget,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (sorted.length < 2) {
      return Text(
        AppLocalizations.of(context)!.estimateNotEnoughData,
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
        AppLocalizations.of(context)!.estimateNoTrend,
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
        AppLocalizations.of(context)!.estimateStable,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    // Gebruik de trendwaarde op het laatste moment voor de projectie
    // Dit is stabieler dan de 'lastWeight' die een uitschieter kan zijn.
    final currentTrendWeight = intercept + slope * lastX;
    final remaining = _targetWeight! - currentTrendWeight;

    // Verkeerde richting?
    if ((remaining < 0 && slope >= 0) || (remaining > 0 && slope <= 0)) {
      return Text(
        AppLocalizations.of(context)!.estimateWrongDirection,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    final daysNeeded = (remaining / slope).abs();

    if (daysNeeded.isNaN || daysNeeded.isInfinite) {
      return Text(
        AppLocalizations.of(context)!.estimateInsufficientInfo,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
      );
    }

    if (daysNeeded > maxReasonableDays) {
      return Text(
        AppLocalizations.of(context)!.estimateUnlikelyWithin10Years,
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

    // De datum moet berekend worden vanaf de laatste meting, niet vanaf nu.
    final targetDate = lastEntry.date.add(Duration(days: totalDays));
    final dateStr = '${targetDate.day}-${targetDate.month}-${targetDate.year}';

    // Onzekerheidstekst
    String uncertaintyNote = '';
    if (residualStd >= 1.0) {
      uncertaintyNote =
          '\n' + AppLocalizations.of(context)!.estimateUncertaintyHigh;
    } else if (residualStd >= 0.5) {
      uncertaintyNote =
          '\n' + AppLocalizations.of(context)!.estimateUncertaintyMedium;
    } else if (residualStd >= 0.25) {
      uncertaintyNote =
          '\n' + AppLocalizations.of(context)!.estimateUncertaintyLow;
    }

    final basisLoc = recent.length >= minRecentPoints
        ? AppLocalizations.of(context)!.estimateBasisRecent
        : AppLocalizations.of(context)!.estimateBasisAll;

    return Text(
      '${AppLocalizations.of(context)!.estimateResultPrefix} $basisLoc $timeStr (rond $dateStr).$uncertaintyNote',
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
