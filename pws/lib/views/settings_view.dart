import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:fFinder/views/crypto_class.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'login_register_view.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../locale_notifier.dart';
import '../l10n/app_localizations.dart';

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
  String _activityKey = 'weinig_actief';
  String _goalKey = 'afvallen';
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

  final List<String> _activityOptionKeys = [
    'weinig_actief',
    'licht_actief',
    'gemiddeld_actief',
    'zeer_actief',
    'extreem_actief',
  ];

  final List<String> _goalOptionKeys = [
    'afvallen',
    'op_gewicht_blijven',
    'aankomen_spiermassa',
    'aankomen_algemeen',
  ];

  // Map key -> Dutch text (this is what will be saved to Firestore)
  String _storageActivityValue(BuildContext ctx, String key) {
    return _localizedActivityLabel(ctx, key);
  }

  String _storageGoalValue(BuildContext ctx, String key) {
    return _localizedGoalLabel(ctx, key);
  }

  double _activityFactorFromLabel(BuildContext ctx, String activityLabel) {
    final local = AppLocalizations.of(ctx)!;
    final a = activityLabel.trim();
    if (a == local.activityLow) return 1.2;
    if (a == local.activityLight) return 1.375;
    if (a == local.activityMedium) return 1.55;
    if (a == local.activityVery) return 1.725;
    if (a == local.activityExtreme) return 1.9;

    final lower = a.toLowerCase();
    if (lower.contains('weinig') ||
        lower.contains('low') ||
        lower.contains('sedentary'))
      return 1.2;
    if (lower.contains('licht') || lower.contains('light')) return 1.375;
    if (lower.contains('gemiddeld') ||
        lower.contains('medium') ||
        lower.contains('moderate'))
      return 1.55;
    if (lower.contains('zeer') ||
        lower.contains('very') ||
        lower.contains('high'))
      return 1.725;
    if (lower.contains('extreem') || lower.contains('extreme')) return 1.9;
    return 1.2;
  }

  // Map key -> localized label for display (must be defined in ARB files)
  String _localizedActivityLabel(BuildContext ctx, String key) {
    final t = AppLocalizations.of(ctx)!;
    switch (key) {
      case 'licht_actief':
        return t.activityLight;
      case 'gemiddeld_actief':
        return t.activityMedium;
      case 'zeer_actief':
        return t.activityVery;
      case 'extreem_actief':
        return t.activityExtreme;
      case 'weinig_actief':
      default:
        return t.activityLow;
    }
  }

  String _localizedGoalLabel(BuildContext ctx, String key) {
    final t = AppLocalizations.of(ctx)!;
    switch (key) {
      case 'op_gewicht_blijven':
        return t.goalMaintain;
      case 'aankomen_spiermassa':
        return t.goalGainMuscle;
      case 'aankomen_algemeen':
        return t.goalGainGeneral;
      case 'afvallen':
      default:
        return t.goalLose;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfile();
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null && code.isNotEmpty) {
      appLocale.value = Locale(code);
    }
  }

  Future<void> _setLocale(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.isEmpty) {
      await prefs.remove('locale');
      appLocale.value = null;
    } else {
      await prefs.setString('locale', code);
      appLocale.value = Locale(code);
    }
    if (mounted) setState(() {});
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
        final errorMsg =
            AppLocalizations.of(context)?.encryptionKeyLoadError ??
            'Kon encryptiesleutel niet laden';
        throw Exception(errorMsg);
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
        final activityLevelDutch = await decryptValue(
          data['activityLevel'] ?? '',
          userDEK,
        );
        final goalDutch = await decryptValue(data['goal'] ?? '', userDEK);

        String findActivityKey(String stored) {
          for (final k in _activityOptionKeys) {
            if (_storageActivityValue(context, k) == stored) return k;
          }
          return _activityOptionKeys.first;
        }

        String findGoalKey(String stored) {
          for (final k in _goalOptionKeys) {
            if (_storageGoalValue(context, k) == stored) return k;
          }
          return _goalOptionKeys.first;
        }

        final validActivityKey = findActivityKey(activityLevelDutch);
        final validGoalKey = findGoalKey(goalDutch);
        setState(() {
          _isAdmin = data['admin'] ?? false;
          _currentWeight = currentWeight > 0 ? currentWeight : _currentWeight;
          _targetWeight = targetWeight > 0 ? targetWeight : _targetWeight;
          _height = height > 0 ? height : _height;
          _waist = waist > 0 ? waist : _waist;
          _sleepHours = sleepHours > 0 ? sleepHours : _sleepHours;
          _activityKey = validActivityKey;
          _goalKey = validGoalKey;

          // Werk ook de controllers hier bij
          _weightController.text = _currentWeight.toStringAsFixed(1);
          _targetWeightController.text = _targetWeight.toStringAsFixed(1);
          _heightController.text = _height.toStringAsFixed(0);
          _waistController.text = _waist.toStringAsFixed(1);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.profileLoadFailedMessage}: $e',
          ),
        ),
      );
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
      throw Exception(AppLocalizations.of(context)!.encryptionKeyLoadSaveError);
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

        final activityLabel = _storageActivityValue(context, _activityKey);
        final activityFactor = _activityFactorFromLabel(context, activityLabel);

        double calories = bmr * activityFactor;

        final goalStored = _storageGoalValue(context, _goalKey);
        final local = AppLocalizations.of(context)!;
        if (goalStored == local.goalLose) {
          calories -= 500;
        } else if (goalStored == local.goalGainMuscle ||
            goalStored == local.goalGainGeneral) {
          calories += 300;
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
          final jsonString = await rootBundle.loadString(
            'assets/absi_reference/absi_reference.json',
          );
          final table = json.decode(jsonString) as List<dynamic>;
          final ages = table.map((e) => e['age'] as int).toList()..sort();
          final age = birthDate != null
              ? DateTime.now().year - birthDate.year
              : ages.last;
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
        'absiRange': absiRange != null
            ? await encryptValue(absiRange, userDEK)
            : null,

        'waist': await encryptDouble(_waist, userDEK),
        'sleepHours': await encryptDouble(_sleepHours, userDEK),
        'activityLevel': await encryptValue(
          _storageActivityValue(context, _activityKey),
          userDEK,
        ),
        'goal': await encryptValue(
          _storageGoalValue(context, _goalKey),
          userDEK,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.settingsSavedSuccessMessage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.settingsSaveFailedMessage}: $e',
          ),
        ),
      );
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
            AppLocalizations.of(context)!.confirmSignOutTitle,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            AppLocalizations.of(context)!.confirmSignOutMessage,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.signOut,
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

  Future<bool> _reauthenticateWithPassword(String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.deleteAccountRecentLoginError,
          ),
        ),
      );
      return false;
    }

    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        Theme.of(context);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeleteAccountTitle),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterPasswordLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.confirmButtonLabel),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: passwordController.text.trim(),
      );
      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
        cred,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.deleteAccountRecentLoginError}: ${e.message ?? e.code}',
          ),
        ),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.deleteAccountFailedMessage}: $e',
          ),
        ),
      );
      return false;
    }
  }

    Future<bool> _reauthenticateWithGoogle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final result = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final cred = result.credential;
        if (cred != null) {
          await user.reauthenticateWithCredential(cred as AuthCredential);
          return true;
        }
        return false;
      } else {
        final signIn = GoogleSignIn.instance;
        GoogleSignInAccount? googleUser;
        // probeer eerst lightweight auth
        googleUser = await signIn.attemptLightweightAuthentication();
        // fallback naar interactive auth indien nodig
        if (googleUser == null) {
          if (signIn.supportsAuthenticate()) {
            googleUser = await signIn.authenticate();
          } else {
            googleUser = await signIn.attemptLightweightAuthentication();
          }
        }
        if (googleUser == null) return false;
        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null) return false;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.deleteAccountFailedMessage}: $e'),
          ),
        );
      }
      return false;
    }
  }

    String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Probeer opnieuw te authenticeren voor Apple (web + native)
  Future<bool> _reauthenticateWithApple() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com');
        final result = await FirebaseAuth.instance.signInWithPopup(provider);
        final cred = result.credential;
        if (cred != null) {
          await user.reauthenticateWithCredential(cred as AuthCredential);
          return true;
        }
        return false;
      } else {
        final rawNonce = generateNonce();
        final nonce = sha256ofString(rawNonce);
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
          nonce: nonce,
        );
        if (appleCredential.identityToken == null) return false;
        final credential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.deleteAccountFailedMessage}: $e'),
          ),
        );
      }
      return false;
    }
  }

  // Probeer opnieuw te authenticeren voor GitHub (web). Native GitHub reauth may require custom OAuth.
  Future<bool> _reauthenticateWithGitHub() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      if (kIsWeb) {
        final provider = GithubAuthProvider();
        final result = await FirebaseAuth.instance.signInWithPopup(provider);
        final cred = result.credential;
        if (cred != null) {
          await user.reauthenticateWithCredential(cred as AuthCredential);
          return true;
        }
        return false;
      } else {
        // Native GitHub reauth usually requires a custom OAuth flow / backend.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.deleteAccountProviderReauthRequired)),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.deleteAccountFailedMessage}: $e'),
          ),
        );
      }
      return false;
    }
  }


  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _deletingAccount = true);

    try {
      // Bepaal welke providers de gebruiker heeft
final providerIds = user.providerData.map((p) => p.providerId).toList();

      bool reauthed = false;

      if (providerIds.contains('password')) {
        reauthed = await _reauthenticateWithPassword(user.email);
      } else if (providerIds.contains('google.com')) {
        reauthed = await _reauthenticateWithGoogle();
      } else if (providerIds.contains('apple.com')) {
        reauthed = await _reauthenticateWithApple();
      } else if (providerIds.contains('github.com')) {
        reauthed = await _reauthenticateWithGitHub();
      } else {
        // onbekende provider(s)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.deleteAccountProviderReauthRequired)),
          );
        }
        return;
      }

      if (!reauthed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.deleteAccountRecentLoginError)),
          );
        }
        return;
      }

      // Na succesvolle re-auth: verwijder eerst Firestore document, daarna auth account
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginRegisterView()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Als er toch nog een recent-login fout komt, toon instructie / probeer opnieuw
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.deleteAccountRecentLoginError,
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.deleteAccountFailedMessage}: ${e.message ?? e.code}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.deleteAccountFailedMessage}: $e',
          ),
        ),
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
            AppLocalizations.of(context)!.confirmDeleteAccountTitle,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.confirmDeleteAccountMessage,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.deletionCodeInstruction,
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
                  labelText: AppLocalizations.of(
                    context,
                  )!.enterDeletionCodeLabel,
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
              child: Text(AppLocalizations.of(context)!.cancelButtonLabel),
            ),
            TextButton(
              onPressed: _deletingAccount
                  ? null
                  : () {
                      if (codeController.text.trim() == code) {
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.deletionCodeMismatchError,
                            ),
                          ),
                        );
                      }
                    },
              child: Text(
                AppLocalizations.of(context)!.deleteAccountButtonLabel,
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
            AppLocalizations.of(context)!.createAnnouncementTitle,
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
                    labelText: AppLocalizations.of(context)!.titleLabel,
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
                      return AppLocalizations.of(context)!.titleValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.messageLabel,
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
                      return AppLocalizations.of(
                        context,
                      )!.messageValidationError;
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
              child: Text(AppLocalizations.of(context)!.cancelButtonLabel),
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
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.announcementPublishedSuccess,
                          ),
                        ),
                      );
                    }
                  } catch (e) {}
                }
              },
              child: Text(AppLocalizations.of(context)!.publishButtonLabel),
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
                  AppLocalizations.of(context)!.unsavedChangesTitle,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                content: Text(
                  AppLocalizations.of(context)!.unsavedChangesMessage,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      AppLocalizations.of(context)!.cancelButtonLabel,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      AppLocalizations.of(context)!.discardButtonLabel,
                    ),
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
            AppLocalizations.of(context)!.settingsTitle,
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
                                      user?.email ??
                                          AppLocalizations.of(
                                            context,
                                          )!.unknownUser,
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
                                AppLocalizations.of(context)!.mealNotifications,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              SwitchListTile(
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.enableMealNotifications,
                                ),
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
                                title: Text(
                                  AppLocalizations.of(context)!.breakfast,
                                ),
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
                                title: Text(
                                  AppLocalizations.of(context)!.lunch,
                                ),
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
                                title: Text(
                                  AppLocalizations.of(context)!.dinner,
                                ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.language,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value:
                                          (appLocale.value?.languageCode) ??
                                          Localizations.localeOf(
                                            context,
                                          ).languageCode,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'nl',
                                          child: Text('Nederlands'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'en',
                                          child: Text('English'),
                                        ),
                                      ],
                                      onChanged: (val) => _setLocale(val),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () => _setLocale(null),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.useSystemLocale,
                                    ),
                                  ),
                                ],
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
                                title: Text(
                                  AppLocalizations.of(context)!.enableGifs,
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
                        label: Text(
                          AppLocalizations.of(context)!.restartTutorial,
                        ),
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
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.tutorialRestartedMessage,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.personalInfo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.personalInfoDescription,
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.currentWeightKg,
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
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterCurrentWeight;
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterValidWeight;
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.heightCm,
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
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterHeight;
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v < 100 || v > 250) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterHeightBetween100And250;
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
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.waistCircumferenceCm,
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
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterWaistCircumference;
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null ||
                                        v <= 0 ||
                                        v < 30 ||
                                        v > 200) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterValidWaistCircumference;
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
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.targetWeightKg,
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
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterTargetWeight;
                                    }
                                    final v = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (v == null || v <= 0) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.enterValidTargetWeight;
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
                                      AppLocalizations.of(
                                        context,
                                      )!.sleepHoursPerNight,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: primaryTextColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_sleepHours.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}',
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
                                  value: _activityKey,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.activityLevel,
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
                                  items: _activityOptionKeys
                                      .map(
                                        (k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(
                                            _localizedActivityLabel(context, k),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() => _activityKey = val);
                                    _hasUnsavedChanges = true;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Doel (dropdown)
                                DropdownButtonFormField<String>(
                                  value: _goalKey,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.goal,
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
                                  items: _goalOptionKeys
                                      .map(
                                        (k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(
                                            _localizedGoalLabel(context, k),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() => _goalKey = val);
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
                                          ? AppLocalizations.of(
                                              context,
                                            )!.savingSettings
                                          : AppLocalizations.of(
                                              context,
                                            )!.saveSettings,
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
                                  AppLocalizations.of(
                                    context,
                                  )!.adminAnnouncements,
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
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.createAnnouncement,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.createAnnouncementSubtitle,
                                  ),
                                  onTap: _showCreateAnnouncementDialog,
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.edit_note),
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.manageAnnouncements,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.manageAnnouncementsSubtitle,
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
                                  title: Text(
                                    AppLocalizations.of(context)!.decryptValues,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.decryptValuesSubtitle,
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
                        AppLocalizations.of(context)!.account,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: Icon(Icons.logout, color: colorScheme.error),
                        label: Text(
                          AppLocalizations.of(context)!.signOut,
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
                              ? AppLocalizations.of(context)!.deletingAccount
                              : AppLocalizations.of(context)!.deleteAccount,
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
                        icon: Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.credits,
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
                            MaterialPageRoute(
                              builder: (_) => const CreditsView(),
                            ),
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
        title: Text(AppLocalizations.of(context)!.credits),
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
                AppLocalizations.of(context)!.appCredits,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.absiAttribution,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const Spacer(),
              Text(
                '${AppLocalizations.of(context)!.date}: ${DateFormat.yMMMMd().format(DateTime.now())}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
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
                  label: Text(AppLocalizations.of(context)!.close),
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
            AppLocalizations.of(context)!.editAnnouncement,
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
                    labelText: AppLocalizations.of(context)!.title,
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
                      return AppLocalizations.of(context)!.titleCannotBeEmpty;
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
                    labelText: AppLocalizations.of(context)!.message,
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
                      return AppLocalizations.of(context)!.messageCannotBeEmpty;
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
                AppLocalizations.of(context)!.cancel,
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
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.announcementUpdated,
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.saveChanges),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(String docId) async {
    await _announcements.doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.announcementDeleted),
        ),
      );
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
          AppLocalizations.of(context)!.manageAnnouncements,
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
                AppLocalizations.of(context)!.errorLoadingAnnouncements,
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
                AppLocalizations.of(context)!.noAnnouncementsFound,
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
              final title =
                  data['title'] ?? AppLocalizations.of(context)!.untitled;
              final message = data['message'] ?? '';
              final isActive = data['isActive'] ?? false;
              final timestamp = data['createdAt'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate())
                  : AppLocalizations.of(context)!.unknownDate;

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
                        '${AppLocalizations.of(context)!.createdAt}: $date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          isActive
                              ? AppLocalizations.of(context)!.active
                              : AppLocalizations.of(context)!.inactive,
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
                        tooltip: AppLocalizations.of(
                          context,
                        )!.editAnnouncementTooltip,
                        onPressed: () => _editAnnouncement(doc),
                      ),
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: isActive
                              ? (isDark ? Colors.white : cs.primary)
                              : (isDark ? Colors.white70 : cs.onSurfaceVariant),
                        ),
                        tooltip: isActive
                            ? AppLocalizations.of(context)!.deactivate
                            : AppLocalizations.of(context)!.activate,
                        onPressed: () => _toggleActive(doc),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: isDark ? Colors.white : cs.error,
                        ),
                        tooltip: AppLocalizations.of(
                          context,
                        )!.deleteAnnouncementTooltip,
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
      final requestsCollection = FirebaseFirestore.instance.collection(
        'decryption_requests',
      );

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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.duplicateRequestError),
          ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestSubmittedSuccess),
        ),
      );
      _encryptedController.clear(); // Clear field after submission
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.requestSubmissionFailed}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveRequest(String requestId) async {
    try {
      final approverUid = FirebaseAuth.instance.currentUser!.uid;
      final reqRef = FirebaseFirestore.instance
          .collection('decryption_requests')
          .doc(requestId);

      final reqSnap = await reqRef.get();
      if (!reqSnap.exists)
        throw Exception(AppLocalizations.of(context)!.requestNotFound);

      final data = reqSnap.data() as Map<String, dynamic>;
      final requesterUid = data['requesterUid'] as String;
      final targetUid = data['targetUid'] as String;

      if (requesterUid == approverUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.cannotApproveOwnRequest,
            ),
          ),
        );
        return;
      }

      final encryptedJson = data['encryptedJson'] as String;
      final dek = await getUserDEKFromRemoteConfig(targetUid);
      if (dek == null)
        throw Exception(AppLocalizations.of(context)!.dekNotFoundForUser);

      final decryptedValue = await decryptValue(encryptedJson, dek);

      await reqRef.update({
        'status': 'approved',
        'approvedBy': approverUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'decryptedValue': decryptedValue,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestApprovedSuccess),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.requestApprovalFailed}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      final approverUid = FirebaseAuth.instance.currentUser!.uid;
      final reqRef = FirebaseFirestore.instance
          .collection('decryption_requests')
          .doc(requestId);

      final reqSnap = await reqRef.get();
      if (!reqSnap.exists)
        throw Exception(AppLocalizations.of(context)!.requestNotFound);

      final data = reqSnap.data() as Map<String, dynamic>;
      if (data['requesterUid'] == approverUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotRejectOwnRequest),
          ),
        );
        return;
      }

      await reqRef.update({
        'status': 'rejected',
        'rejectedBy': approverUid,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestRejectedSuccess),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.requestRejectionFailed}: $e',
          ),
        ),
      );
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
        title: Text(
          AppLocalizations.of(context)!.decryptValues,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                16,
          ),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _uidController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      cursorColor: isDark ? Colors.white : cs.primary,
                      decoration: InputDecoration(
                        labelText: 'UID',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : cs.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppLocalizations.of(context)!.pleaseEnterUid
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _encryptedController,
                      maxLines: 5,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      cursorColor: isDark ? Colors.white : cs.primary,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.encryptedJson,
                        hintText: '{"nonce":"...","cipher":"...","tag":"..."}',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : cs.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppLocalizations.of(
                              context,
                            )!.pleaseEnterEncryptedJson
                          : null,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _loading
                              ? AppLocalizations.of(context)!.submit
                              : AppLocalizations.of(context)!.submitRequest,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.pendingRequests,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('decryption_requests')
                    .orderBy('requestedAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  if (snap.data!.docs.isEmpty)
                    return Text(
                      AppLocalizations.of(context)!.noPendingRequests,
                    );

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
                      final canApprove =
                          isPending && requesterUid != currentAdminUid;

                      return Card(
                        color: isDark ? Colors.grey.shade900 : theme.cardColor,
                        elevation: isDark ? 0 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.forUid}: $targetUid',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppLocalizations.of(context)!.requestedBy}: $requesterUid',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              if (encryptedJson != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.encryptedJsonLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  encryptedJson,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontFamily: 'monospace',
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                              const Divider(height: 16),
                              if (status == 'approved' &&
                                  decryptedValue != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SelectableText(
                                        decryptedValue,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    color: status == 'rejected'
                                        ? cs.error
                                        : (isDark
                                              ? Colors.yellow
                                              : Colors.orange),
                                  ),
                                ),
                              if (canApprove)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: Text(
                                          AppLocalizations.of(context)!.reject,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: cs.error,
                                        ),
                                        onPressed: () => _rejectRequest(doc.id),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: Text(
                                          AppLocalizations.of(context)!.approve,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: cs.primary,
                                          foregroundColor: cs.onPrimary,
                                        ),
                                        onPressed: () =>
                                            _approveRequest(doc.id),
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
