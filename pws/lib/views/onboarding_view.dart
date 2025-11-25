import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pws/views/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController =
      PageController(); // Controller voor pageView
  int _currentIndex = 0;

  // Controllers en variabelen voor data
  final TextEditingController _firstNameController = TextEditingController();
  String _gender = 'Man';
  DateTime? _birthDate;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _sleepHours = 8.0;
  String _activityLevel = 'Weinig actief';
  String _goal = 'Afvallen';
  final TextEditingController _targetWeightController = TextEditingController();
  bool _notificationsEnabled = false;
  static const int minHeightCm = 50;
  static const int maxHeightCm = 300;
  static const int minWeightKg = 20;
  static const int maxWeightKg = 800;

  final int _totalQuestions = 10;

  String _rangeText = '';
  bool _rangeLoading = false;
  String _rangeNote = '';

  final Map<String, Map<int, Map<String, double>>> _lmsCache = {
    // cache voor LMS-waarden
    '1': {}, // man
    '2': {}, // vrouw
  };

  final List<String> activityOptions = [
    // opties voor activiteitenniveau
    'Weinig actief: je zit veel, weinig beweging per dag',
    'Licht actief: je wandelt kort (10–20 min) of lichte beweging',
    'Gemiddeld actief: 3–4x per week sporten of veel wandelen',
    'Zeer actief: elke dag intensieve training of zwaar werk',
    'Extreem actief: topsport niveau of fysiek zwaar dagelijks werk',
  ];

  final List<String> goalOptions = [
    // opties voor doelen
    'Afvallen',
    'Op gewicht blijven',
    'Aankomen (spiermassa)',
    'Aankomen (algemeen)',
  ];

  Timer? _debounceTimer; // timer voor debouncing range update

  // Opruimen van controllers
  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _ensureCdcLmsLoaded() // zorgt dat LMS-data geladen is bij start
        .then((_) {
          _updateRange();
        })
        .catchError((e) {
          print('LMS preload error: $e');
        });

    // listeners
    _heightController.addListener(
      _scheduleRangeUpdate,
    ); // update range bij veranderen lengte
    _weightController.addListener(_scheduleRangeUpdate);
  }

  void _scheduleRangeUpdate() {
    _debounceTimer?.cancel(); // annuleer vorige timer als die er is
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // wacht 300ms
      _updateRange();
    });
  }

  bool _validateCurrentPage() {
    switch (_currentIndex) {
      case 0: // Voornaam
        if (_firstNameController.text.trim().isEmpty) {
          _showError('Vul alsjeblieft je voornaam in.');
          return false;
        }
        break;
      case 2: // Geboortedatum
        if (_birthDate == null) {
          _showError('Selecteer alsjeblieft je geboortedatum.');
          return false;
        }
        break;
      case 3: // Lengte
        final heightText = _heightController.text.trim();
        if (heightText.isEmpty) {
          _showError('Vul alsjeblieft je lengte in.');
          return false;
        }
        final value = int.tryParse(heightText);
        if (value == null) {
          _showError('Voer een geldig getal in voor lengte.');
          return false;
        }
        if (value < minHeightCm || value > maxHeightCm) {
          _showError(
            'Lengte moet tussen $minHeightCm cm en $maxHeightCm cm liggen.',
          );
          return false;
        }
        break;
      case 4: // Gewicht
        final weightText = _weightController.text.trim();
        if (weightText.isEmpty) {
          _showError('Vul alsjeblieft je gewicht in.');
          return false;
        }
        final weight = double.tryParse(weightText);
        if (weight == null) {
          _showError('Vul een gewicht in.');
          return false;
        }
        if (weight <= minWeightKg || weight >= maxWeightKg) {
          _showError(
            'Uw gewicht moet tussen $minWeightKg kg en $maxWeightKg kg liggen.',
          );
          return false;
        }
        break;
      case 7: // Streefgewicht
        final targetWeightText = _targetWeightController.text.trim();
        if (targetWeightText.isEmpty) {
          _showError('Vul alsjeblieft je streefgewicht in.');
          return false;
        }
        final targetWeight = double.tryParse(targetWeightText);
        if (targetWeight == null) {
          _showError('Vul een streefgewicht in');
          return false;
        }
        if (targetWeight <= minWeightKg || targetWeight >= maxWeightKg) {
          _showError(
            'Uw streefgewicht moet tussen $minWeightKg kg en $maxWeightKg kg liggen.',
          );
          return false;
        }
        break;
    }
    return true;
  }

  // Helper om de foutmelding te tonen
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating, //snackbar zwevend maken
      ),
    );
  }

  // Functie om naar de volgende pagina te gaan
  void _nextPage() {
    if (!_validateCurrentPage()) return; // valideer huidige pagina

    if (_currentIndex < _totalQuestions - 1) {
      // Als er nog vragen over zijn
      _pageController.nextPage(
        // Ga naar de volgende pagina
        duration: const Duration(milliseconds: 300), // Animatieduur
        curve: Curves.easeInOut, // Animatie
      );
    } else {
      _finishOnboarding();
    }
  }

  // Functie om terug te gaan
  void _previousPage() {
    if (_currentIndex > 0) {
      // Als we niet op de eerste pagina zijn
      _pageController.previousPage(
        // Ga naar de vorige pagina
        duration: const Duration(milliseconds: 300), // Animatieduur
        curve: Curves.easeInOut, // Animatie
      );
    }
  }

  // Data opslaan in Firestore
  Future<void> _finishOnboarding() async {
    final user = FirebaseAuth.instance.currentUser; // Huidige gebruiker ophalen
    if (user == null) return; // Als er geen gebruiker is, stop

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'gender': _gender,
        'birthDate': _birthDate?.toIso8601String(),
        'height': double.tryParse(_heightController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0,
        'sleepHours': _sleepHours,
        'targetWeight': double.tryParse(_targetWeightController.text) ?? 0,
        'notificationsEnabled': _notificationsEnabled,
        'onboardingaf': true,
        'activityLevel': _activityLevel,
        'goal': _goal,
      }, SetOptions(merge: true));

      if (mounted) {
        //controleer of de widget nog bestaat
        Navigator.of(context).pushReplacement(
          // Ga naar home scherm
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Er ging iets mis: $e')));
    }
  }

  // Widget voor de bolletjes voortgangs dingetje
  Widget _buildProgressIndicator() {
    return Row(
      // Horizontale rij
      mainAxisAlignment: MainAxisAlignment.center, // midden uitlijnen
      children: List.generate(_totalQuestions, (index) {
        // Maak voor elk vraag een bolletje
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Groen als de vraag nu is of al geweest is
            color: index <= _currentIndex ? Colors.green : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  int _ageYearsFromBirthDate() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      years--;
    }
    return years;
  }

  int _ageMonthsFromBirthDate() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int months =
        (now.year - _birthDate!.year) * 12 + (now.month - _birthDate!.month);
    if (now.day < _birthDate!.day) months--;
    return max(0, months);
  }

  double? _parseHeightMeters() {
    final text = _heightController.text;
    final h = double.tryParse(text); // hoogte in cm
    if (h == null) return null; // niet geldig
    return h / 100.0; // omzetten naar meters
  }

  Future<void> _updateRange() async {
    final heightM = _parseHeightMeters();
    final ageYears = _ageYearsFromBirthDate();
    final ageMonths = _ageMonthsFromBirthDate();

    if (heightM == null || heightM <= 0) {
      setState(() {
        _rangeText = 'Voer eerst je lengte in (cm) om het bereik te berekenen.';
        _rangeNote = '';
        _rangeLoading = false;
      });
      return;
    }

    setState(() {
      _rangeLoading = true;
      _rangeText = '';
      _rangeNote = '';
    });

    // volwassenen of geen geboortedatum opgegeven dus dan vaste BMI range
    if (ageYears >= 18 || _birthDate == null) {
      final minWeight = 18.5 * pow(heightM, 2); // ondergrens gezond gewicht
      final maxWeight = 24.9 * pow(heightM, 2); // bovengrens gezond gewicht
      setState(() {
        _rangeText =
            'Gezond gewicht voor u: ${minWeight.toStringAsFixed(1)} kg – ${maxWeight.toStringAsFixed(1)} kg';
        _rangeNote = 'Gezond BMI: 18.5 – 24.9';
        _rangeLoading = false;
      });
      return;
    }

    // jonger dan 2 jaar geef uitleg
    if (ageMonths < 24) {
      setState(() {
        _rangeText =
            'Voor kinderen jonger dan 2 jaar wordt meestal gewicht-/lengtepercentiel gebruikt in plaats van BMI.';
        _rangeNote = 'Gebruik WHO/CDC gewicht-voor-lengte tabellen.';
        _rangeLoading = false;
      });
      return;
    }

    // kinderen 2-18 jaar
    try {
      await _ensureCdcLmsLoaded(); // zorgt dat _lmsCache gevuld is (offline)
      final sexCode = (_gender == 'Vrouw') ? '2' : '1';
      final nearestMonth = ageMonths;
      Map<String, double>? lms =
          _lmsCache[sexCode]?[nearestMonth]; // probeer exacte maand
      if (lms == null) {
        // zoek dichtstbijzijnde maand
        final keys =
            _lmsCache[sexCode]?.keys.toList() ?? []; // allebeschikbaare maanden
        if (keys.isNotEmpty) {
          // als er maanden zijn
          keys.sort(); // sorteer ze
          int nearest = keys.reduce(
            // vind dichtstbijzijnde maand
            (a, b) => ((a - nearestMonth).abs() < (b - nearestMonth).abs())
                ? a
                : b, // kies de dichtstbijzijnde
          );
          lms = _lmsCache[sexCode]?[nearest];
        }
      }

      if (lms == null) {
        setState(() {
          _rangeText =
              'LMS-gegevens niet beschikbaar voor deze leeftijd/geslacht.';
          _rangeNote = 'Controleer assets of voer handmatig streefgewicht in.';
          _rangeLoading = false;
        });
        return;
      }

      final L = lms['L']!;
      final M = lms['M']!;
      final S = lms['S']!;
      const z5 = -1.645; // 5e percentiel
      const z85 = 1.036; // 85e percentiel

      double bmi5 = _bmiFromLms(z5, L, M, S);
      double bmi85 = _bmiFromLms(z85, L, M, S);

      final weightMin = bmi5 * pow(heightM, 2);
      final weightMax = bmi85 * pow(heightM, 2);

      setState(() {
        _rangeText =
            'Gezond gewicht voor u: ${weightMin.toStringAsFixed(1)} kg – ${weightMax.toStringAsFixed(1)} kg';
        _rangeNote =
            '';
        _rangeLoading = false;
      });
      return;
    } catch (e) {
      setState(() {
        _rangeText = 'Kon LMS-data niet gebruiken: $e';
        _rangeNote =
            'Controleer of asset aanwezig is (assets/cdc/bmiagerev.csv).';
        _rangeLoading = false;
      });
      return;
    }
  }

  double _bmiFromLms(double z, double L, double M, double S) {
    // BMI berekenen vanuit LMS en z-score
    if (L == 0) return M * exp(S * z); // speciale case L=0
    return M * pow(1 + L * S * z, 1 / L); // algemene formule
  }

  Future<void> _ensureCdcLmsLoaded() async {
    // zorgt dat LMS data uit CSV is geladen
    if ((_lmsCache['1']?.isNotEmpty ?? false) &&
        (_lmsCache['2']?.isNotEmpty ?? false)) {
      return;
    }

    // asset path: assets/cdc/bmiagerev.csv
    final csvString = await rootBundle.loadString(
      'assets/cdc/bmiagerev.csv',
    ); // laad CSV bestand
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
      final row = _splitCsvLine(lines[i]);
      if (row.length <= max(idxSex, max(idxAge, max(idxL, max(idxM, idxS)))))
        continue;

      final sexRaw = row[idxSex].trim();
      final ageRaw = row[idxAge].trim();
      final lRaw = row[idxL].trim();
      final mRaw = row[idxM].trim();
      final sRaw = row[idxS].trim();

      final sex = sexRaw; // verwacht '1' of '2'
      final agemos = double.tryParse(ageRaw)?.round();
      final L = double.tryParse(lRaw);
      final M = double.tryParse(mRaw);
      final S = double.tryParse(sRaw);

      if (agemos == null || L == null || M == null || S == null) continue;

      _lmsCache[sex]?[agemos] = {'L': L, 'M': M, 'S': S};
    }

    if ((_lmsCache['1']?.isEmpty ?? true) &&
        (_lmsCache['2']?.isEmpty ?? true)) {
      throw Exception('Geen LMS-waarden ingeladen uit CSV');
    }
  }

  // eenvoudige CSV-splitter die rekening houdt met aanhalingstekens
  List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (ch == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(ch);
    }
    result.add(buffer.toString());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputTextStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // De bolletjes voortgangs dingetje
            _buildProgressIndicator(),
            const SizedBox(height: 20),

            // De vragen pagina's
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Voorkom swipen
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  // Vraag 1: Voornaam
                  _buildQuestionPage(
                    title: 'Wat is je voornaam?',
                    content: TextField(
                      controller: _firstNameController,
                      style: inputTextStyle,
                      decoration: const InputDecoration(
                        labelText: 'Voornaam',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  // Vraag 2: Geslacht
                  _buildQuestionPage(
                    title: 'Wat is je geslacht?',
                    content: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            [
                              'Man',
                              'Vrouw',
                              'Anders',
                              'Wil ik liever niet zeggen',
                            ].map((val) {
                              return SizedBox(
                                width:
                                    300, // Vaste breedte voor consistente uitlijning
                                child: RadioListTile<String>(
                                  title: Text(val, style: inputTextStyle),
                                  value: val,
                                  groupValue: _gender,
                                  onChanged: (value) {
                                    setState(() => _gender = value!);
                                    _scheduleRangeUpdate(); // Update range als geslacht verandert
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  // Vraag 3: Geboortedatum
                  _buildQuestionPage(
                    title: 'Wat is je geboortedatum?',
                    content: Column(
                      children: [
                        Text(
                          _birthDate == null
                              ? 'Geen datum gekozen'
                              : '${_birthDate!.day}-${_birthDate!.month}-${_birthDate!.year}',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // Check of het een iOS app is
                            // Op web gebruiken westandaard picker
                            final bool isIosApp =
                                !kIsWeb &&
                                defaultTargetPlatform == TargetPlatform.iOS;

                            if (isIosApp) {
                              // iOS datepicker
                              showCupertinoModalPopup(
                                context: context,
                                builder: (_) => Container(
                                  height: 250,
                                  // Zorgt voor de juiste achtergrondkleur in light/dark mode
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 180,
                                        child: CupertinoDatePicker(
                                          initialDateTime:
                                              _birthDate ?? DateTime(2000),
                                          mode: CupertinoDatePickerMode.date,
                                          use24hFormat: true,
                                          minimumDate: DateTime(1900),
                                          maximumDate: DateTime.now(),
                                          onDateTimeChanged: (val) {
                                            setState(() => _birthDate = val);
                                            _scheduleRangeUpdate(); // Update berekening bij scrollen datum (iOS)
                                          },
                                        ),
                                      ),
                                      // Knop om de picker te sluiten
                                      CupertinoButton(
                                        child: const Text('Klaar'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // Android en Web standaard picker
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _birthDate ?? DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  // Forceer dark theme voor de picker als dark mode aan staat
                                  return Theme(
                                    data: isDarkMode
                                        ? ThemeData.dark()
                                        : Theme.of(context),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() => _birthDate = picked);
                                _scheduleRangeUpdate(); // Update berekening
                              }
                            }
                          },
                          child: const Text('Kies datum'),
                        ),
                      ],
                    ),
                  ),
                  // Vraag 4: Lengte
                  _buildQuestionPage(
                    title: 'Wat is je lengte (cm)?',
                    content: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle,
                      decoration: const InputDecoration(
                        labelText: 'Lengte in cm',
                        border: OutlineInputBorder(),
                        suffixText: 'cm',
                        helperText: 'Min $minHeightCm cm - Max $maxHeightCm cm',
                      ),
                    ),
                  ),
                  // Vraag 5: Gewicht
                  _buildQuestionPage(
                    title: 'Wat is je gewicht (kg)?',
                    content: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle,
                      decoration: const InputDecoration(
                        labelText: 'Gewicht in kg',
                        border: OutlineInputBorder(),
                        suffixText: 'kg',
                        helperText: 'Min $minWeightKg kg - Max $maxWeightKg kg',
                      ),
                    ),
                  ),
                  // Vraag 6: Slaap
                  _buildQuestionPage(
                    title: 'Hoeveel uur slaap je gemiddeld?',
                    content: Column(
                      children: [
                        Text(
                          '${_sleepHours.toStringAsFixed(1)} uur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black, // Toegevoegd
                          ),
                        ),
                        Slider(
                          value: _sleepHours,
                          min: 4,
                          max: 12,
                          divisions: 16,
                          label: _sleepHours.toString(),
                          onChanged: (val) => setState(() => _sleepHours = val),
                        ),
                      ],
                    ),
                  ),
                  // Vraag 7: Actief
                  _buildQuestionPage(
                    title: 'Hoe actief ben je dagelijks?',
                    content: Column(
                      children: activityOptions.map((val) {
                        return RadioListTile<String>(
                          // Radio knop voor elke optie
                          title: Text(val, style: inputTextStyle),
                          value: val,
                          groupValue: _activityLevel,
                          onChanged: (value) {
                            setState(() => _activityLevel = value!);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  // Vraag 8: Streefgewicht
                  _buildQuestionPage(
                    title: 'Wat is je streefgewicht?',
                    content: Column(
                      children: [
                        TextField(
                          controller: _targetWeightController,
                          keyboardType: TextInputType.number,
                          style: inputTextStyle,
                          decoration: const InputDecoration(
                            labelText: 'Streefgewicht in kg',
                            border: OutlineInputBorder(),
                            suffixText: 'kg',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_rangeLoading) const CircularProgressIndicator(),
                        if (!_rangeLoading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _rangeText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (_rangeNote.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    _rangeNote,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Vraag9: Wat is je doel?
                  _buildQuestionPage(
                    title: 'Wat is je doel?',
                    content: Column(
                      children: goalOptions.map((val) {
                        return RadioListTile<String>(
                          title: Text(val, style: inputTextStyle),
                          value: val, // waarde van deze optie
                          groupValue: _goal,
                          onChanged: (value) {
                            setState(() => _goal = value!);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Vraag 10: Meldingen
                  _buildQuestionPage(
                    title: 'Wil je meldingen ontvangen?',
                    content: SwitchListTile(
                      title: Text(
                        'Meldingen inschakelen',
                        style: inputTextStyle,
                      ),
                      value: _notificationsEnabled,
                      onChanged: (val) async {
                        if (val) {
                          // Als de gebruiker het aan zet, vraag om toestemming
                          FirebaseMessaging messaging =
                              FirebaseMessaging.instance;

                          // Vraagt toestemming op iOS, Android 13+ en Web
                          NotificationSettings settings = await messaging
                              .requestPermission(
                                alert: true,
                                announcement: false,
                                badge: true,
                                carPlay: false,
                                criticalAlert: false,
                                provisional: false,
                                sound: true,
                              );

                          if (settings.authorizationStatus ==
                                  AuthorizationStatus.authorized ||
                              settings.authorizationStatus ==
                                  AuthorizationStatus.provisional) {
                            // Toestemming gekregen
                            setState(() => _notificationsEnabled = true);
                          } else {
                            // Toestemming geweigerd
                            setState(() => _notificationsEnabled = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Toestemming voor meldingen is geweigerd.',
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          // Gewoon uitzetten
                          setState(() => _notificationsEnabled = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Navigatie knoppen
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    TextButton(
                      onPressed: _previousPage,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Vorige'),
                    )
                  else
                    const SizedBox(), // Lege ruimte om layout gelijk te houden
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentIndex == _totalQuestions - 1
                          ? 'Afronden'
                          : 'Volgende',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget om elke vraag pagina zelfde te maken
  Widget _buildQuestionPage({required String title, required Widget content}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    //bouwt een pagina voor een vraag
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }
}
