import 'dart:convert';
import 'dart:math';

import 'package:fFinder/views/crypto_class.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'login_register_view.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  //fallback
  double _currentWeight = 72;
  double _targetWeight = 68;
  double _height = 180;
  double _waist = 85;
  double _sleepHours = 8.0;
  String _activityLevel = 'Weinig actief';
  String _goal = 'Afvallen';
  bool _hasUnsavedChanges = false;

  bool _mealNotificationsEnabled = false;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);
  final NotificationService _notificationService = NotificationService();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _deletingAccount = false;
  bool _isAdmin = false;

  final List<String> _activityOptions = [
    'Weinig actief: zittend werk, nauwelijks beweging, geen sport',
    'Licht actief: 1–3x per week lichte training of dagelijks 30–45 min wandelen',
    'Gemiddeld actief: 3–5x per week sporten of een actief beroep (horeca, zorg, postbezorger)',
    'Zeer actief: 6–7x per week intensieve training of fysiek zwaar werk (bouw, magazijn)',
    'Extreem actief: topsporttraining 2× per dag of extreem fysiek zwaar werk (militair, bosbouw)',
  ];

  final List<String> _goalOptions = [
    // opties voor doelen
    'Afvallen',
    'Op gewicht blijven',
    'Aankomen (spiermassa)',
    'Aankomen (algemeen)',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfile();
  }

  Future<void> _loadSettings() async {
    // Laad instellingen uit SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mealNotificationsEnabled =
          prefs.getBool('mealNotificationsEnabled') ?? false;
      _breakfastTime = TimeOfDay(
        hour: prefs.getInt('breakfastHour') ?? 7,
        minute: prefs.getInt('breakfastMinute') ?? 0,
      );
      _lunchTime = TimeOfDay(
        hour: prefs.getInt('lunchHour') ?? 12,
        minute: prefs.getInt('lunchMinute') ?? 0,
      );
      _dinnerTime = TimeOfDay(
        hour: prefs.getInt('dinnerHour') ?? 19,
        minute: prefs.getInt('dinnerMinute') ?? 0,
      );
    });
  }

  Future<void> _updateNotificationSchedule() async {
    await _notificationService.scheduleMealReminders(
      areEnabled: _mealNotificationsEnabled,
      breakfastTime: _breakfastTime,
      lunchTime: _lunchTime,
      dinnerTime: _dinnerTime,
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimePicked,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (newTime != null) {
      onTimePicked(newTime);
    }
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userDEK = await getUserDEKFromRemoteConfig(user.uid);
      if (userDEK == null) {
        throw Exception("Kon de encryptiesleutel niet laden.");
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        final currentWeight = await decryptDouble(data['weight'], userDEK);
        final targetWeight = await decryptDouble(data['targetWeight'], userDEK);
        final height = await decryptDouble(data['height'], userDEK);
        final waist = await decryptDouble(data['waist'], userDEK);
     
        final sleepHours = await decryptDouble(data['sleepHours'], userDEK);
        final activityLevel = await decryptValue(
          data['activityLevel'] ?? '',
          userDEK,
        );
        final goal = await decryptValue(data['goal'] ?? '', userDEK);

        // Controleer of de opgeslagen waarden nog geldig zijn. Zo niet, gebruik de eerste optie als fallback.
        final validActivityLevel = _activityOptions.contains(activityLevel)
            ? activityLevel
            : _activityOptions.first;

        final validGoal = _goalOptions.contains(goal)
            ? goal
            : _goalOptions.first;

        setState(() {
          _isAdmin = data['admin'] ?? false;
          _currentWeight = currentWeight > 0 ? currentWeight : _currentWeight;
          _targetWeight = targetWeight > 0 ? targetWeight : _targetWeight;
          _height = height > 0 ? height : _height;
          _waist = waist > 0 ? waist : _waist;
          _sleepHours = sleepHours > 0 ? sleepHours : _sleepHours;
          _activityLevel = validActivityLevel;
          _goal = validGoal;

          // Werk ook de controllers hier bij
          _weightController.text = _currentWeight.toStringAsFixed(1);
          _targetWeightController.text = _targetWeight.toStringAsFixed(1);
          _heightController.text = _height.toStringAsFixed(0);
          _waistController.text = _waist.toStringAsFixed(1);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kon profiel niet laden: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validatie en opslaan
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDEK = await getUserDEKFromRemoteConfig(user.uid);
    if (userDEK == null) {
      throw Exception("Kon de encryptiesleutel niet laden voor opslaan.");
    }

    setState(() => _saving = true);

    try {
      _currentWeight = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );
      _targetWeight = double.parse(
        _targetWeightController.text.replaceAll(',', '.'),
      );
      _height = double.parse(_heightController.text.replaceAll(',', '.'));
      _waist = double.parse(_waistController.text.replaceAll(',', '.'));

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      final gender = await decryptValue(data['gender'], userDEK);
      final birthDateStrEncrypted = data['birthDate'];
      String? birthDateStr;
      if (birthDateStrEncrypted != null) {
        birthDateStr = await decryptValue(birthDateStrEncrypted, userDEK);
      }

      DateTime? birthDate;
      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        birthDate = DateTime.tryParse(birthDateStr);
      }

      double? bmi;
      double? calorieGoal;
      double? proteinGoal;
      double? fatGoal;
      double? carbGoal;
      double? absi;
      double? absiZ;
     String? absiRange;

      if (_height > 0 && _currentWeight > 0 && birthDate != null) {
        //  Berekeningen
        final heightCm = _height;
        final weightKg = _currentWeight;

        // BMI
        final heightM = heightCm / 100;
        bmi = weightKg / (heightM * heightM);

        // BMR
        final age = DateTime.now().year - birthDate.year;
        double bmr;
        if (gender == 'Vrouw') {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
        } else {
          bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
        }

        final activity = _activityLevel.split(':')[0].trim();
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

        // Doel toepassen
        switch (_goal) {
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

        // Macro’s
        proteinGoal = weightKg; // 1 g/kg
        final fatCalories = calorieGoal * 0.30;
        fatGoal = fatCalories / 9;
        final proteinCalories = proteinGoal * 4;
        final carbCalories = calorieGoal - fatCalories - proteinCalories;
        carbGoal = carbCalories / 4;
      }

      if (_waist > 0 && bmi != null && bmi > 0 && _height > 0) {
        final heightM = _height / 100.0;
        final waistM = _waist / 100.0;
        absi = waistM / (pow(bmi, 2.0 / 3.0) * pow(heightM, 0.5));

        // probeer referentietabel te laden en z-score te berekenen
        try {
          final jsonString = await rootBundle
              .loadString('assets/absi_reference/absi_reference.json');
          final table = json.decode(jsonString) as List<dynamic>;
          final ages = table.map((e) => e['age'] as int).toList()..sort();
          final age = birthDate != null ? DateTime.now().year - birthDate.year : ages.last;
          final clampedAge = ages.contains(age) ? age : ages.last;
          final entry = table.firstWhere((e) => e['age'] == clampedAge);
          final isFemale = (gender).toLowerCase() == 'vrouw';
          final data = isFemale ? entry['female'] : entry['male'];
          final mean = (data['mean'] as num).toDouble();
          final sd = (data['sd'] as num).toDouble();
          if (sd != 0) {
            absiZ = (absi - mean) / sd;
            if (absiZ <= -1.0) {
              absiRange = 'zeer_laag risico';
            } else if (absiZ <= -0.5) {
              absiRange = 'laag risico';
            } else if (absiZ <= 0.5) {
              absiRange = 'gemiddeld risico';
            } else if (absiZ <= 1.0) {
              absiRange = 'verhoogd risico';
            } else {
              absiRange = 'hoog';
            }
          }
        } catch (e) {
          // als referentietabel niet beschikbaar is, laat z en range null
          debugPrint('Kon ABSI referentie niet laden: $e');
        }
      }

      // Alles naar Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'weight': await encryptDouble(_currentWeight, userDEK),
        'targetWeight': await encryptDouble(_targetWeight, userDEK),
        'height': await encryptDouble(_height, userDEK),
        'absi': absi != null ? await encryptDouble(absi, userDEK) : null,
       'absiZ': absiZ != null ? await encryptDouble(absiZ, userDEK) : null,
       'absiRange': absiRange != null ? await encryptValue(absiRange, userDEK) : null,
       
        'waist': await encryptDouble(_waist, userDEK),
        'sleepHours': await encryptDouble(_sleepHours, userDEK),
        'activityLevel': await encryptValue(_activityLevel, userDEK),
        'goal': await encryptValue(_goal, userDEK),
        'bmi': bmi != null ? await encryptDouble(bmi, userDEK) : null,
        'calorieGoal': calorieGoal != null
            ? await encryptDouble(calorieGoal, userDEK)
            : null,
        'proteinGoal': proteinGoal != null
            ? await encryptDouble(proteinGoal, userDEK)
            : null,
        'fatGoal': fatGoal != null
            ? await encryptDouble(fatGoal, userDEK)
            : null,
        'carbGoal': carbGoal != null
            ? await encryptDouble(carbGoal, userDEK)
            : null,
      }, SetOptions(merge: true));

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Instellingen opgeslagen')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opslaan mislukt: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginRegisterView()),
      (route) => false,
    );
  }

  Future<void> _confirmSignOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            'Uitloggen',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Weet je zeker dat je wilt uitloggen?',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          actions: [
            TextButton(
              child: const Text('Annuleren'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Uitloggen',
                style: TextStyle(color: colorScheme.error),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _signOut();
    }
  }

  String _generateDeletionCode() {
    // Genereer een eenvoudige 6-cijferige code
    final random = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return random.toString().padLeft(6, '0');
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _deletingAccount = true);

    try {
      // User-doc verwijderen
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Auth-account verwijderen
      await user.delete();

      if (!mounted) return;
      // Naar login scherm
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginRegisterView()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Bijv. recent login vereist
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'requires-recent-login'
                ? 'Log opnieuw in en probeer het nog eens om je account te verwijderen.'
                : 'Verwijderen mislukt: ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verwijderen mislukt: $e')));
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final code = _generateDeletionCode();
    final TextEditingController codeController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_deletingAccount,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Account verwijderen',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weet je zeker dat je je account wilt verwijderen? '
                'Dit kan niet ongedaan worden gemaakt.',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                'Typ onderstaande code over om te bevestigen:',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  code,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                cursorColor: isDark ? Colors.white : Colors.black,
                decoration: InputDecoration(
                  labelText: 'Voer de 6-cijferige code in',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[500]! : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _deletingAccount
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: _deletingAccount
                  ? null
                  : () {
                      if (codeController.text.trim() == code) {
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Code klopt niet, probeer het opnieuw.',
                            ),
                          ),
                        );
                      }
                    },
              child: Text(
                'Verwijderen',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _showCreateAnnouncementDialog() async {
    final titleController = TextEditingController(); // Controller voor de titel
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nieuw bericht publiceren',
            style: TextStyle(
              color: Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Titel',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color:
                          Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  cursorColor:
                      Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Titel mag niet leeg zijn.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bericht',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color:
                          Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  cursorColor:
                      Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bericht mag niet leeg zijn.';
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final title = titleController.text.trim();
                  final message = messageController.text.trim();
                  try {
                    await FirebaseFirestore.instance
                        .collection('announcements')
                        .add({
                          'title': title,
                          'message': message,
                          'createdAt': FieldValue.serverTimestamp(),
                          'isActive': true,
                        });
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bericht succesvol gepubliceerd!'),
                        ),
                      );
                    }
                  } catch (e) {}
                }
              },
              child: const Text('Publiceren'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final cardColor = theme.cardColor;

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) {
              final theme = Theme.of(context);
            final isDark = theme.colorScheme.brightness == Brightness.dark;
             
              return AlertDialog(
               title: Text(
                  'Niet-opgeslagen wijzigingen',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                content: Text(
                  'Je hebt wijzigingen aangebracht die nog niet zijn opgeslagen. '
                  'Weet je zeker dat je wilt afsluiten zonder op te slaan?',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Blijven'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Afsluiten'),
                  ),
                ],
              );
            },
          );
          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Instellingen',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          backgroundColor: isDark ? Colors.black : Colors.white,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gebruikersinformatie
                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: isDark ? 0 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                child: Text(
                                  (user?.email?.substring(0, 1).toUpperCase() ??
                                      '?'),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // e‑mail
                                    Text(
                                      user?.email ?? 'Onbekende gebruiker',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: primaryTextColor,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Card(
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maaltijdherinneringen',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              SwitchListTile(
                                title: const Text('Herinneringen inschakelen'),
                                value: _mealNotificationsEnabled,
                                onChanged: (bool value) async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                    'mealNotificationsEnabled',
                                    value,
                                  );
                                  setState(() {
                                    _mealNotificationsEnabled = value;
                                  });
                                  await _updateNotificationSchedule();
                                },
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Ontbijt'),
                                trailing: Text(_breakfastTime.format(context)),
                                onTap: () => _pickTime(
                                  context,
                                  _breakfastTime,
                                  (newTime) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setInt(
                                      'breakfastHour',
                                      newTime.hour,
                                    );
                                    await prefs.setInt(
                                      'breakfastMinute',
                                      newTime.minute,
                                    );
                                    setState(() => _breakfastTime = newTime);
                                    await _updateNotificationSchedule();
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text('Lunch'),
                                trailing: Text(_lunchTime.format(context)),
                                onTap: () => _pickTime(context, _lunchTime, (
                                  newTime,
                                ) async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setInt('lunchHour', newTime.hour);
                                  await prefs.setInt(
                                    'lunchMinute',
                                    newTime.minute,
                                  );
                                  setState(() => _lunchTime = newTime);
                                  await _updateNotificationSchedule();
                                }),
                              ),
                              ListTile(
                                title: const Text('Avondeten'),
                                trailing: Text(_dinnerTime.format(context)),
                                onTap: () => _pickTime(context, _dinnerTime, (
                                  newTime,
                                ) async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setInt(
                                    'dinnerHour',
                                    newTime.hour,
                                  );
                                  await prefs.setInt(
                                    'dinnerMinute',
                                    newTime.minute,
                                  );
                                  setState(() => _dinnerTime = newTime);
                                  await _updateNotificationSchedule();
                                }),
                              ),
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
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .get(),
                            builder: (context, snapshot) {
                              bool gifEnabled = true;
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                gifEnabled = data['gif'] == true;
                              }
                              return SwitchListTile(
                                title: const Text(
                                  'Mascotte animatie (GIF) tonen',
                                ),
                                value: gifEnabled,
                                onChanged: (val) async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user?.uid)
                                      .set({
                                        'gif': val,
                                      }, SetOptions(merge: true));
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset uitleg'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                                'tutorialFoodAf': false,
                                'tutorialHomeAf': false,
                              }, SetOptions(merge: true));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Uitleg is opnieuw gestart!'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Persoonlijke gegevens',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pas je gewicht, lengte, doel en activiteit aan.',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Huidig gewicht
                                TextFormField(
                                  controller: _weightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Huidig gewicht (kg)',
                                    labelStyle: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.monitor_weight,
                                      color: secondaryTextColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vul je huidige gewicht in';
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v <= 0) {
                                      return 'Voer een geldig gewicht in';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Lengte
                                TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Lengte (cm)',
                                    labelStyle: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.height,
                                      color: secondaryTextColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vul je lengte in';
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v < 100 || v > 250) {
                                      return 'Voer een lengte tussen 100 en 250 cm in';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
TextFormField(
                                  controller: _waistController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
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
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vul je tailleomtrek in';
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v <= 0 || v < 30 || v > 200) {
                                      return 'Voer een tailleomtrek tussen 30 en 200 cm in';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Doelgewicht
                                TextFormField(
                                  controller: _targetWeightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Doelgewicht (kg)',
                                    labelStyle: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.flag,
                                      color: secondaryTextColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vul je doelgewicht in';
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v <= 0) {
                                      return 'Voer een geldig doelgewicht in';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Slaapuren (slider)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Slaap (uur per nacht)',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: primaryTextColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_sleepHours.toStringAsFixed(1)} uur',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
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
                                        value: _sleepHours,
                                        min: 4,
                                        max: 12,
                                        divisions: 16,
                                        label: _sleepHours.toStringAsFixed(1),
                                        onChanged: (v) {
                                          setState(() {
                                            _sleepHours = v;
                                            _hasUnsavedChanges = true;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Activiteitsniveau (dropdown)
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _activityLevel,
                                  decoration: InputDecoration(
                                    labelText: 'Activiteitsniveau',
                                    labelStyle: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.directions_run,
                                      color: secondaryTextColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  dropdownColor: cardColor,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  items: _activityOptions
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() => _activityLevel = val);
                                    _hasUnsavedChanges = true;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Doel (dropdown)
                                DropdownButtonFormField<String>(
                                  value: _goal,
                                  decoration: InputDecoration(
                                    labelText: 'Doel',
                                    labelStyle: TextStyle(
                                      color: secondaryTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.flag_circle,
                                      color: secondaryTextColor,
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  dropdownColor: cardColor,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  items: _goalOptions
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() => _goal = val);
                                    _hasUnsavedChanges = true;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Opslaan-knop
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
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(
                                      _saving
                                          ? 'Opslaan...'
                                          : 'Instellingen opslaan',
                                    ),
                                    onPressed: _saving ? null : _saveProfile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (_isAdmin)
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Acties',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.campaign),
                                  title: const Text('Nieuw bericht maken'),
                                  subtitle: const Text(
                                    'Publiceer een bericht voor alle gebruikers.',
                                  ),
                                  onTap: _showCreateAnnouncementDialog,
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.edit_note),
                                  title: const Text('Berichten beheren'),
                                  subtitle: const Text(
                                    'Bekijk, deactiveer of verwijder berichten.',
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ManageAnnouncementsView(),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.edit_note),
                                  title: const Text('Decrypten'),
                                  subtitle: const Text(
                                    'Decrypt waardes voor gebruiker als ze account willen overzetten naar andere email.',
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DecryptView(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Account / uitloggen
                      Text(
                        'Account',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: Icon(Icons.logout, color: colorScheme.error),
                        label: Text(
                          'Uitloggen',
                          style: TextStyle(color: colorScheme.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.error),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: colorScheme.error,
                        ),
                        onPressed: _confirmSignOut,
                      ),
                      const SizedBox(height: 50),
                      OutlinedButton.icon(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red.shade700,
                        ),
                        label: Text(
                          _deletingAccount
                              ? 'Account verwijderen...'
                              : 'Account verwijderen',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade700),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.red.shade700,
                        ),
                        onPressed: _deletingAccount
                            ? null
                            : _confirmDeleteAccount,
                      ),

                      const SizedBox(height: 12),


                      OutlinedButton.icon(
                        icon: Icon(Icons.info_outline, color: colorScheme.primary),
                        label: Text(
                          'Credits',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreditsView()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class CreditsView extends StatelessWidget {
  const CreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final textColor = cs.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ABSI Data Attribution',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Body Shape Index (ABSI) referentietabel is gebaseerd op:\n\n'
                'Y. Krakauer, Nir; C. Krakauer, Jesse (2015).\n'
                'Table S1 - A New Body Shape Index Predicts Mortality Hazard Independently of Body Mass Index.\n'
                'PLOS ONE. Dataset.\n'
                'https://doi.org/10.1371/journal.pone.0039504.s001\n\n'
                'Deze dataset wordt gebruikt voor het berekenen van ABSI Z-scores en categorieën in deze app.',
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const Spacer(),
              Text(
                'Datum: ${DateFormat.yMMMMd().format(DateTime.now())}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: textColor.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Sluiten'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ManageAnnouncementsView extends StatefulWidget {
  const ManageAnnouncementsView({super.key});

  @override
  State<ManageAnnouncementsView> createState() =>
      _ManageAnnouncementsViewState();
}

class _ManageAnnouncementsViewState extends State<ManageAnnouncementsView> {
  final CollectionReference _announcements = FirebaseFirestore.instance
      .collection('announcements');

  Future<void> _toggleActive(DocumentSnapshot doc) async {
    await _announcements.doc(doc.id).update({
      'isActive': !doc['isActive'],
    }); // Toggle the isActive field
  }

  Future<void> _editAnnouncement(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final messageController = TextEditingController(text: data['message']);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          title: Text(
            'Bericht bewerken',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Titel',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : cs.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Titel mag niet leeg zijn.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Bericht',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : cs.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bericht mag niet leeg zijn.';
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
              child: Text(
                'Annuleren',
                style: TextStyle(color: isDark ? Colors.white : cs.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.black : cs.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _announcements.doc(doc.id).update({
                    'title': titleController.text.trim(),
                    'message': messageController.text.trim(),
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bericht bijgewerkt.')),
                    );
                  }
                }
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(String docId) async {
    await _announcements.doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bericht verwijderd.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        title: Text(
          'Berichten Beheren',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: StreamBuilder(
        stream: _announcements
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Er is een fout opgetreden.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Geen berichten gevonden.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            );
          }

          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Geen titel';
              final message = data['message'] ?? '';
              final isActive = data['isActive'] ?? false;
              final timestamp = data['createdAt'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate())
                  : 'Onbekende datum';

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                color: isDark ? Colors.black : theme.cardColor,
                surfaceTintColor: Colors.transparent,
                elevation: isDark ? 0 : 2,
                child: ListTile(
                  title: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gemaakt op: $date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          isActive ? 'Actief' : 'Inactief',
                          style: TextStyle(
                            color: isActive
                                ? cs.onPrimaryContainer
                                : (isDark ? Colors.white : cs.onSurfaceVariant),
                          ),
                        ),
                        backgroundColor: isActive
                            ? cs.primaryContainer
                            : (isDark ? Colors.black : cs.surfaceVariant),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: isDark ? Colors.white : cs.primary,
                        ),
                        tooltip: 'Bewerken',
                        onPressed: () => _editAnnouncement(doc),
                      ),
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: isActive
                              ? (isDark ? Colors.white : cs.primary)
                              : (isDark ? Colors.white70 : cs.onSurfaceVariant),
                        ),
                        tooltip: isActive ? 'Deactiveren' : 'Activeren',
                        onPressed: () => _toggleActive(doc),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: isDark ? Colors.white : cs.error,
                        ),
                        tooltip: 'Verwijderen',
                        onPressed: () => _deleteAnnouncement(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DecryptView extends StatefulWidget {
  const DecryptView({super.key});

  @override
  State<DecryptView> createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _encryptedController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _uidController.dispose();
    _encryptedController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final targetUid = _uidController.text.trim();
      final encryptedJson = _encryptedController.text.trim();
      final requesterUid = FirebaseAuth.instance.currentUser!.uid;
      final requestsCollection = FirebaseFirestore.instance.collection('decryption_requests');

      // 1. Check for duplicate pending requests
      final existing = await requestsCollection
          .where('targetUid', isEqualTo: targetUid)
          .where('encryptedJson', isEqualTo: encryptedJson)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Er bestaat al een openstaande aanvraag voor deze waarde.')),
        );
        return;
      }

      // 2. Create new pending request
      await requestsCollection.add({
        'targetUid': targetUid,
        'encryptedJson': encryptedJson,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'requesterUid': requesterUid,
        'fieldKey': 'custom', // You can make this dynamic if needed
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decryptie-aanvraag ingediend voor goedkeuring.')),
      );
      _encryptedController.clear(); // Clear field after submission
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Indienen van aanvraag mislukt: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveRequest(String requestId) async {
    try {
      final approverUid = FirebaseAuth.instance.currentUser!.uid;
      final reqRef = FirebaseFirestore.instance.collection('decryption_requests').doc(requestId);

      final reqSnap = await reqRef.get();
      if (!reqSnap.exists) throw Exception('Aanvraag niet gevonden.');

      final data = reqSnap.data() as Map<String, dynamic>;
      final requesterUid = data['requesterUid'] as String;
      final targetUid = data['targetUid'] as String;

      if (requesterUid == approverUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Je kunt je eigen aanvraag niet goedkeuren.')),
        );
        return;
      }

      final encryptedJson = data['encryptedJson'] as String;
      final dek = await getUserDEKFromRemoteConfig(targetUid);
      if (dek == null) throw Exception('Kon encryptiesleutel niet ophalen.');

      final decryptedValue = await decryptValue(encryptedJson, dek);

      await reqRef.update({
        'status': 'approved',
        'approvedBy': approverUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'decryptedValue': decryptedValue,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aanvraag goedgekeurd.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goedkeuren mislukt: $e')));
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      final approverUid = FirebaseAuth.instance.currentUser!.uid;
      final reqRef = FirebaseFirestore.instance.collection('decryption_requests').doc(requestId);

      final reqSnap = await reqRef.get();
      if (!reqSnap.exists) throw Exception('Aanvraag niet gevonden.');

      final data = reqSnap.data() as Map<String, dynamic>;
      if (data['requesterUid'] == approverUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Je kunt je eigen aanvraag niet afkeuren.')),
        );
        return;
      }

      await reqRef.update({
        'status': 'rejected',
        'rejectedBy': approverUid,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aanvraag afgekeurd.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Afkeuren mislukt: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final currentAdminUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : cs.background,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : cs.background,
        title: Text('Decrypten', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _uidController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      cursorColor: isDark ? Colors.white : cs.primary,
                      decoration: InputDecoration(
                        labelText: 'UID',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : cs.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vul een UID in' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _encryptedController,
                      maxLines: 5,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      cursorColor: isDark ? Colors.white : cs.primary,
                      decoration: InputDecoration(
                        labelText: 'Versleutelde JSON (nonce/cipher/tag)',
                        hintText: '{"nonce":"...","cipher":"...","tag":"..."}',
                        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : cs.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Plak de versleutelde JSON' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.black : cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _loading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send),
                        label: Text(_loading ? 'Indienen...' : 'Aanvraag indienen'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Openstaande aanvragen', style: theme.textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('decryption_requests').orderBy('requestedAt', descending: true).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  if (snap.data!.docs.isEmpty) return const Text('Geen aanvragen gevonden.');

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snap.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] as String;
                      final requesterUid = data['requesterUid'] as String;
                      final targetUid = data['targetUid'] as String;
                      final decryptedValue = data['decryptedValue'] as String?;
                      final encryptedJson = data['encryptedJson'] as String?;

                      final isPending = status == 'pending';
                      final canApprove = isPending && requesterUid != currentAdminUid;

                      return Card(
                        color: isDark ? Colors.grey.shade900 : theme.cardColor,
                        elevation: isDark ? 0 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Voor UID: $targetUid', style: theme.textTheme.labelLarge?.copyWith(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(height: 4),
                              Text('Aangevraagd door: $requesterUid', style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black87)),
                              if (encryptedJson != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Versleutelde waarde:',
                                  style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  encryptedJson,
                                  style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'monospace'),
                                  maxLines: 3,
                                ),
                              ],
                              const Divider(height: 16),
                              if (status == 'approved' && decryptedValue != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: SelectableText(decryptedValue, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                                  ],
                                )
                              else
                                Text('Status: $status', style: TextStyle(color: status == 'rejected' ? cs.error : (isDark ? Colors.yellow : Colors.orange))),
                              if (canApprove)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text('Afkeuren'),
                                        style: TextButton.styleFrom(foregroundColor: cs.error),
                                        onPressed: () => _rejectRequest(doc.id),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Goedkeuren'),
                                        style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
                                        onPressed: () => _approveRequest(doc.id),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}