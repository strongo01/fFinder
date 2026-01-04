import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';

import '../l10n/app_localizations.dart';

//dit scherm is voor inloggen en registreren en verandert ook weer dus statefulwidget
class LoginRegisterView extends StatefulWidget {
  const LoginRegisterView({super.key});

  @override
  State<LoginRegisterView> createState() => _LoginRegisterViewState();
}

class _LoginRegisterViewState extends State<LoginRegisterView> {
  //firebase en de controllers voor de invoervelden
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //variabelen voor de status van het scherm
  bool _isLogin = true; //wisselt tussen inloggen en registereren
  bool _loading = false; //laad icoon
  bool _obscurePassword = true; //wachtwoord met bolletjes
bool _agreedPrivacy = false; // of gebruiker akkoord is met privacybeleid
  final Uri _privacyUri = Uri.parse('https://sites.google.com/view/ffinderreppy/homepage');
  //functie voor inloggen met google
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }

    try {
      final googleSignIn = GoogleSignIn.instance;

      // Optioneel: initialiseer met clientId/serverClientId
      // Indien je google-services.json / GoogleService-Info.plist correct hebt,
      // is dit vaak niet nodig. Als je problemen hebt met idToken op Android,
      // voeg hier je web-client-id toe (default_web_client_id).
      // await googleSignIn.initialize(serverClientId: '<YOUR_WEB_CLIENT_ID>');
      // (zet die await in je init logic of voor je de eerste keer signIn aanroept)

      final googleUser = await googleSignIn.authenticate();

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: AppLocalizations.of(context)!.googleMissingIdToken,
        );
      }

      // Optioneel: als je een accessToken nodig hebt voor Firebase/platforms:
      String? accessToken;
      try {
        // probeer eerst te hergebruiken (authorizationForScopes).
        // Als er geen autorisatie bestaat, vraag het aan met authorizeScopes.
        final scopes = <String>[
          'openid',
          'email',
          'profile',
        ]; // zet alleen wat je echt nodig hebt
        var authorization = await googleUser.authorizationClient
            .authorizationForScopes(scopes);
        authorization ??= await googleUser.authorizationClient.authorizeScopes(
          scopes,
        );
        accessToken = authorization.accessToken;
      } catch (_) {
        // als je geen access token nodig hebt, mag je dit negeren
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on PlatformException catch (e, s) {
      if (e.code.toLowerCase().contains('cancel')) {
        throw FirebaseAuthException(
          code: 'sign_in_cancelled',
          message: AppLocalizations.of(context)!.googleSignInCancelledMessage,
        );
      }
        debugPrint('Google sign-in error: $e');
  debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  //handler voor inloggen met google
  Future<void> _signInWithGoogleHandler() async {
    setState(() => _loading = true);
    try {
      final userCredential = await signInWithGoogle();

      final user = userCredential.user;
      if (user != null) {
        final usersRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final doc = await usersRef.get();
        if (!doc.exists) {
          await usersRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = AppLocalizations.of(context)!.signInAccountExists;
          break;
        case 'sign_in_cancelled':
        case 'popup-closed-by-user':
          message = AppLocalizations.of(context)!.signInCancelled;
          break;
        default:
          message = AppLocalizations.of(context)!.unknownGoogleSignIn;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, s) {
  debugPrint('Handler error: $e');
  debugPrintStack(stackTrace: s);
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.unknownErrorEnglish),
    ),
  );
} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  //hulpfunctie voor apple sign in wat een willekeurig string maakt
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => charset[rand.nextInt(charset.length)],
    ).join();
  }

  // hulpfunctie voor apple sign in wat een sha256 maakt van de string
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // functie die apple fouten vertaalt naar normale meldingen
  String translateAppleError(BuildContext context, Object error) {
    final message = error.toString(); //converteer error naar string

    if (message.contains('AuthorizationErrorCode.canceled')) {
      return AppLocalizations.of(context)!.appleCancelled;
    }
    if (message.contains('AuthorizationErrorCode.failed')) {
      return AppLocalizations.of(context)!.appleFailed;
    }
    if (message.contains('AuthorizationErrorCode.invalidResponse')) {
      return AppLocalizations.of(context)!.appleInvalidResponse;
    }
    if (message.contains('AuthorizationErrorCode.notHandled')) {
      return AppLocalizations.of(context)!.appleNotHandled;
    }
    if (message.contains('AuthorizationErrorCode.unknown')) {
      return AppLocalizations.of(context)!.appleUnknown;
    }

    return AppLocalizations.of(context)!.appleGenericError;
  }

  // functie voor inloggen met apple
  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    // vraag om apple id credential
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: nonce,
    );

    if (appleCredential.identityToken == null) {
      //als er geen identity token is
      throw FirebaseAuthException(
        code: 'null_identity_token',
        message: AppLocalizations.of(context)!.appleNullIdentityTokenMessage,
      );
    }
    //maakt een oauth credential aan voor firebase
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken!,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    //logt in met firebase
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  //de handler voor apple sign in
  Future<void> _signInWithAppleHandler() async {
    setState(() => _loading = true); //start met laden
    try {
      final userCredential = await signInWithApple();
      //sla de gebruiker op in de firestore als die nog niet bestaat
      final user = userCredential.user;
      if (user != null) {
        final usersRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final doc = await usersRef.get();
        if (!doc.exists) {
          await usersRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return; //check of de widget nog bestaat
      //ga naar home scherm
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = AppLocalizations.of(context)!.signInAccountExists;
          break;
        default:
          message = AppLocalizations.of(context)!.unknownAppleSignIn;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      ); //snackbar is bar onderaan scherm. toon firebase foutmelding
    } catch (e) {
      if (!mounted) return;
      final translated = translateAppleError(context, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translated)),
      ); //toon vertaalde foutmelding
    } finally {
      if (mounted) setState(() => _loading = false); //stop met laden
    }
  }

  //functie voor inloggen met github
  Future<UserCredential> signInWithGitHub() async {
    GithubAuthProvider githubProvider = GithubAuthProvider();
    githubProvider.addScope('read:user');
    githubProvider.addScope('user:email');

    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(githubProvider);
    } else {
      return await FirebaseAuth.instance.signInWithProvider(githubProvider);
    }
  }

  //handler voor inloggen met github
  Future<void> _signInWithGitHubHandler() async {
    setState(() => _loading = true);
    try {
      final userCredential = await signInWithGitHub();

      final user = userCredential.user;
      if (user != null) {
        final usersRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final doc = await usersRef.get();
        if (!doc.exists) {
          await usersRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = AppLocalizations.of(context)!.signInAccountExists;
          break;
        case 'cancelled':
        case 'popup-closed-by-user':
          message = AppLocalizations.of(context)!.signInCancelled;
          break;
        default:
          message = AppLocalizations.of(context)!.unknownGitHubSignIn;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unknownGitHubSignIn),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  //de submit functie voor het formulier als je op inloggen of registeren klikt met email en wachtwoord
  Future<void> _submit() async {
    //kijkt of de velden goed zijn ingevuld
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim(); //trim() betekent zonder spaties
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        //inloggen
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = cred.user; //haal de gebruiker op
        //update eventueel ontbrekende gegevens in de database
        if (user != null) {
          final usersRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          final doc = await usersRef.get();
          final now = FieldValue.serverTimestamp();
          if (!doc.exists) {
            await usersRef.set({
              'uid': user.uid,
              'email': user.email,
              'createdAt': now,
            });
          } else {
            final data = doc.data() ?? {};
            final updates = <String, Object?>{};
            if (!data.containsKey('uid')) updates['uid'] = user.uid;
            if (!data.containsKey('email')) updates['email'] = user.email;
            if (!data.containsKey('createdAt')) updates['createdAt'] = now;
            if (updates.isNotEmpty) await usersRef.update(updates);
          }
        }
      } else {
        final errors = <String>[];
        if (password.length < 6) {
          errors.add(AppLocalizations.of(context)!.passwordErrorMinLength);
        }
        if (!password.contains(RegExp(r'[A-Z]'))) {
          errors.add(AppLocalizations.of(context)!.passwordErrorUpper);
        }
        if (!password.contains(RegExp(r'[a-z]'))) {
          errors.add(AppLocalizations.of(context)!.passwordErrorLower);
        }
        if (!password.contains(RegExp(r'[0-9]'))) {
          errors.add(AppLocalizations.of(context)!.passwordErrorDigit);
        }

        if (errors.isNotEmpty) {
          final message =
              AppLocalizations.of(context)!.passwordMissingPartsPrefix +
              errors.join(', ') +
              '.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          setState(() => _loading = false); // Stop laadindicator
          return; // Stop de functie
        }
        //registreren
        final cred = await _auth.createUserWithEmailAndPassword(
          //maak nieuwe gebruiker aan in firebase auth
          email: email,
          password: password,
        );
        final user = cred.user;
        //sla de gebruiker op in firestore
        if (user != null) {
          final usersRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          await usersRef.set({
            'uid': user.uid,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      if (!mounted) return;
      //ga naar hoofdscherm
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      //toon foutmelding van firebase
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = AppLocalizations.of(context)!.userNotFoundCreateAccount;
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = AppLocalizations.of(context)!.wrongPasswordOrEmail;
          break;
        case 'email-already-in-use':
          message = AppLocalizations.of(context)!.emailAlreadyInUse;
          break;
        case 'weak-password':
          message = AppLocalizations.of(context)!.weakPasswordMessage;
          break;
        case 'invalid-email':
          message = AppLocalizations.of(context)!.invalidEmailMessage;
          break;
        default:
          message = AppLocalizations.of(context)!.authGenericError;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unknownErrorEnglish),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.resetPasswordEnterEmailInstruction,
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.resetPasswordEmailSentTitle,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.resetPasswordEmailSentContent,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.okLabel),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = AppLocalizations.of(context)!.genericError;
      if (e.code == 'user-not-found') {
        message = AppLocalizations.of(context)!.userNotFoundForEmail;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    //ruimt de controllers o pals het scherm sluit
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // kijken of de app in dark mode staat
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Een moderne border stijl voor de invulvelden
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    //bouw het scherm
    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.scaffoldBackgroundColor
          : Colors.grey[50],
      //scaffold is de basis van het scherm
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 40,
          ),

          child: ConstrainedBox(
            //zorgt dat het formulier niet te breed wordt op grote schermen
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo en Titel
                const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin
                      ? AppLocalizations.of(context)!.loginWelcomeBack
                      : AppLocalizations.of(context)!.loginCreateAccount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? AppLocalizations.of(context)!.loginSubtitle
                      : AppLocalizations.of(context)!.registerSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // Iets lichtere tekst, maar wel leesbaar in dark mode
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //email veld
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.loginEmailLabel,
                          hintText: AppLocalizations.of(
                            context,
                          )!.loginEmailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[900]
                              : Colors.white,
                        ),
                        //validator voor email
                        validator: (v) => (v == null || v.isEmpty)
                            ? AppLocalizations.of(context)!.loginEnterEmail
                            : null,
                      ),
                      const SizedBox(height: 16),
                      //wachtwoord invoerveld met oogje om wachtwoord te tonen
                      TextFormField(
                        controller: _passwordController, //wachtwoord controller
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        obscureText:
                            _obscurePassword, //of het wachtwoord verborgen is
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.loginPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[900]
                              : Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword =
                                  !_obscurePassword, //wissel tussen tonen en verbergen
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? AppLocalizations.of(context)!.loginMin6Chars
                            : null, //validator voor wachtwoord
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: Text(
                          AppLocalizations.of(context)!.loginForgotPassword,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                //laadicoon
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  IgnorePointer(
                    ignoring: !_agreedPrivacy,
                    child: Opacity(
                      opacity: _agreedPrivacy ? 1.0 : 0.75,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _isLogin
                              ? AppLocalizations.of(context)!.loginButtonLogin
                              : AppLocalizations.of(context)!.loginButtonRegister,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                Row(
                 children: [
                   Checkbox(
                     value: _agreedPrivacy,
                     onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
                   ),
                   Expanded(
                     child: GestureDetector(
                       onTap: () async {
                         if (await canLaunchUrl(_privacyUri)) {
                           await launchUrl(_privacyUri, mode: LaunchMode.externalApplication);
                         } else {
                           // fallback: kopieer of toon link
                           if (!mounted) return;
                           showDialog(
                             context: context,
                             builder: (ctx) => AlertDialog(
                               title: Text(AppLocalizations.of(context)!.privacyPolicy),
                               content: SelectableText(_privacyUri.toString()),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.of(ctx).pop(),
                                   child: Text(AppLocalizations.of(context)!.ok),
                                 ),
                               ],
                             ),
                           );
                         }
                       },
                       child: Text(
                         AppLocalizations.of(context)!.privacyAgreement,
                         style: TextStyle(
                           decoration: TextDecoration.underline,
                           color: Theme.of(context).colorScheme.primary,
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 24),


                // Scheidingslijn
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations.of(context)!.loginOrContinueWith,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      ignoring: !_agreedPrivacy,
                      child: Opacity(
                        opacity: _agreedPrivacy ? 1.0 : 0.75,
                        child: SignInButton(
                          isDarkMode ? Buttons.GoogleDark : Buttons.Google,
                          text: AppLocalizations.of(context)!.loginWithGoogle,
                          onPressed: _signInWithGoogleHandler,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IgnorePointer(
                      ignoring: !_agreedPrivacy,
                      child: Opacity(
                        opacity: _agreedPrivacy ? 1.0 : 0.75,
                        child: SignInButton(
                          Buttons.GitHub,
                          text: AppLocalizations.of(context)!.loginWithGitHub,
                          onPressed: _signInWithGitHubHandler,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    //knop is alleen zichtbaar voor ios en macos, niet op web
                    if (!kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.macOS)) ...[
                      const SizedBox(height: 12),
                      IgnorePointer(
                        ignoring: !_agreedPrivacy,
                        child: Opacity(
                          opacity: _agreedPrivacy ? 1.0 : 0.75,
                          child: SignInButton(
                            Buttons.Apple,
                            text: AppLocalizations.of(context)!.loginWithApple,
                            onPressed: _signInWithAppleHandler,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                //tekst knop om te wisselen tussen inloggen en registeren
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? AppLocalizations.of(context)!.loginNoAccountQuestion
                          : AppLocalizations.of(
                              context,
                            )!.loginHaveAccountQuestion,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? AppLocalizations.of(
                                context,
                              )!.loginCreateAccountAction
                            : AppLocalizations.of(context)!.loginLoginAction,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
