import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register_view.dart';

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
  double _sleepHours = 8.0;
  String _activityLevel = 'Weinig actief';
  String _goal = 'Afvallen';

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _deletingAccount = false; 

  final List<String> _activityOptions = [
    // opties voor activiteitenniveau
    'Weinig actief: je zit veel, weinig beweging per dag',
    'Licht actief: je wandelt kort (10–20 min) of lichte beweging',
    'Gemiddeld actief: 3–4x per week sporten of veel wandelen',
    'Zeer actief: elke dag intensieve training of zwaar werk',
    'Extreem actief: topsport niveau of fysiek zwaar dagelijks werk',
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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        _currentWeight = (data['weight'] as num?)?.toDouble() ?? _currentWeight;
        _targetWeight =
            (data['targetWeight'] as num?)?.toDouble() ?? _targetWeight;
        _height = (data['height'] as num?)?.toDouble() ?? _height;
        _sleepHours = (data['sleepHours'] as num?)?.toDouble() ?? _sleepHours;

        _activityLevel = (data['activityLevel'] as String?) ?? _activityLevel;
        _goal = (data['goal'] as String?) ?? _goal;
      }

      // controllers 
      _weightController.text = _currentWeight.toStringAsFixed(1);
      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      _heightController.text = _height.toStringAsFixed(0);
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
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
     
      _currentWeight = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );
      _targetWeight = double.parse(
        _targetWeightController.text.replaceAll(',', '.'),
      );
      _height = double.parse(_heightController.text.replaceAll(',', '.'));

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      final String gender = (data['gender'] as String?) ?? 'Man';
      final String? birthDateStr = data['birthDate'] as String?;
      DateTime? birthDate;
      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        birthDate = DateTime.tryParse(birthDateStr);
      }

      double? bmi;
      double? calorieGoal;
      double? proteinGoal;
      double? fatGoal;
      double? carbGoal;

      if (_height > 0 && _currentWeight > 0 && birthDate != null) {
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

      // 4. Alles wegschrijven naar Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'weight': _currentWeight,
        'targetWeight': _targetWeight,
        'height': _height,
        'sleepHours': _sleepHours,
        'activityLevel': _activityLevel,
        'goal': _goal,
        'bmi': bmi,
        'calorieGoal': calorieGoal,
        'proteinGoal': proteinGoal,
        'fatGoal': fatGoal,
        'carbGoal': carbGoal,
      }, SetOptions(merge: true));

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
          title: Text('Uitloggen', style: TextStyle(color: isDark ? Colors.white: Colors.black),),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verwijderen mislukt: $e')),
      );
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
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
                      color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
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
                            content:
                                Text('Code klopt niet, probeer het opnieuw.'),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark
        ? Colors.grey[300]
        : Colors.grey[700];
    final cardColor = theme.cardColor;

    return Scaffold(
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
                              ),
                              const SizedBox(height: 16),

                              // Slaapuren (slider)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Slaap (uur per nacht)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: primaryTextColor,
                                    ),
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
                                        setState(() => _sleepHours = v);
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
                    const SizedBox(height: 12),
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
                      onPressed:
                          _deletingAccount ? null : _confirmDeleteAccount,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
