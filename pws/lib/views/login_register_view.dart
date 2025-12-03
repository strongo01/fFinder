import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'home_screen.dart';

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
  //functie voor inloggen met google
  Future<UserCredential> signInWithGoogle() async {
    //als het platform web is
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider(); //google provider aanmaken
      googleProvider.addScope('email'); //scopes toevoegen
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      }); //aanpassen van parameters

      try {
        final result = await FirebaseAuth.instance.signInWithPopup(
          //inloggen met popup
          googleProvider,
        );
        return result;
      } catch (e) {
        rethrow;
      }
    }
    //logica voor ios en android (dus geen web)
    try {
      final signIn = GoogleSignIn.instance;

      GoogleSignInAccount? googleUser;
      // hij probeert inteloggen als de gebruiker al een keertje is ingelogd
      googleUser = await signIn.attemptLightweightAuthentication();
      //als dat niet zo is laat hij het inlogscherm zien als popup
      if (googleUser == null) {
        if (signIn.supportsAuthenticate()) {
          //kijken of het platform popup ondersteunt
          googleUser = await signIn.authenticate();
        } else {
          googleUser = await signIn.attemptLightweightAuthentication();
        }
      }
      //als je het scherm wegklikt
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign_in_cancelled',
          message: 'Google Sign-In is geannuleerd door de gebruiker.',
        );
      }
      //haalt de autehtnicatie tokens op
      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: 'Kon geen idToken ophalen van Google.',
        );
      }
      //maakt een credential aan voor firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      //logt in met firebase
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return result;
    } catch (e) {
      rethrow;
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
  String translateAppleError(Object error) {
    final message = error.toString(); //converteer error naar string

    if (message.contains('AuthorizationErrorCode.canceled')) {
      return 'Je hebt de Apple-inlog geannuleerd.';
    }
    if (message.contains('AuthorizationErrorCode.failed')) {
      return 'Apple inloggen is mislukt. Probeer het later opnieuw.';
    }
    if (message.contains('AuthorizationErrorCode.invalidResponse')) {
      return 'Ongeldig antwoord ontvangen van Apple.';
    }
    if (message.contains('AuthorizationErrorCode.notHandled')) {
      return 'Apple kon de aanvraag niet verwerken.';
    }
    if (message.contains('AuthorizationErrorCode.unknown')) {
      return 'Er is een onbekende fout opgetreden bij Apple.';
    }

    return 'Er is een fout opgetreden tijdens het inloggen met Apple.';
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
        message: 'Apple returned a null identityToken',
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
          message =
              'Er bestaat al een account met dit e-mailadres. Log in met een andere methode.';
          break;
        default:
          message =
              'Er is een onbekende fout opgetreden bij het inloggen met Apple.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      ); //snackbar is bar onderaan scherm. toon firebase foutmelding
    } catch (e) {
      if (!mounted) return;
      final translated = translateAppleError(e);
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
          message =
              'Er bestaat al een account met dit e-mailadres. Log in met een andere methode.';
          break;
        case 'cancelled':
        case 'popup-closed-by-user':
          message = 'Het inloggen is geannuleerd.';
          break;
        default:
          message =
              'Er is een onbekende fout opgetreden bij het inloggen met GitHub.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Er is een onbekende fout opgetreden bij het inloggen met GitHub.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
          message =
              'Er bestaat al een account met dit e-mailadres. Log in met een andere methode.';
          break;
        case 'sign_in_cancelled':
        case 'popup-closed-by-user':
          message = 'Het inloggen is geannuleerd.';
          break;
        default:
          message =
              'Er is een onbekende fout opgetreden bij het inloggen met Google.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Er is een onbekende fout opgetreden.')),
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
          errors.add('minimaal 6 tekens');
        }
        if (!password.contains(RegExp(r'[A-Z]'))) {
          errors.add('één hoofdletter');
        }
        if (!password.contains(RegExp(r'[a-z]'))) {
          errors.add('één kleine letter');
        }
        if (!password.contains(RegExp(r'[0-9]'))) {
          errors.add('één cijfer');
        }

        if (errors.isNotEmpty) {
          final message = 'Je wachtwoord mist: ${errors.join(', ')}.';
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
          message =
              'Geen account gevonden voor dit e-mailadres. Klik onderaan om een account te maken.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message =
              'Onjuist wachtwoord of e-mailadres. Probeer het opnieuw. Heeft u nog geen account, klik dan onderaan om er een aan te maken.';
          break;
        case 'email-already-in-use':
          message = 'Dit e-mailadres is al in gebruik. Probeer in te loggen.';
          break;
        case 'weak-password':
          message = 'Het wachtwoord moet uit minimaal 6 tekens bestaan.';
          break;
        case 'invalid-email':
          message = 'Het ingevoerde e-mailadres is ongeldig.';
          break;
        default:
          message =
              'Er is een authenticatiefout opgetreden. Probeer het later opnieuw.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unknown error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voer je e-mailadres in om je wachtwoord te resetten.'),
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
            'E-mail verzonden',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: Text(
            'Er is een e-mail verzonden om je wachtwoord te resetten. Let op: deze e-mail kan in je spamfolder terechtkomen. Afzender: noreply@pwsmt-fd851.firebaseapp.com',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Er is een fout opgetreden.';
      if (e.code == 'user-not-found') {
        message = 'Geen account gevonden voor dit e-mailadres.';
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
          padding: const EdgeInsets.all(24),
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
                  _isLogin ? 'Welkom terug!' : 'Maak een account',
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
                      ? 'Log in om verder te gaan'
                      : 'Registreer om te beginnen',
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
                          labelText: 'Email',
                          hintText: 'naam@voorbeeld.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[900]
                              : Colors.white,
                        ),
                        //validator voor email
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter email' : null,
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
                          labelText: 'Password',
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
                            ? 'Min 6 chars'
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
                        child: const Text('Wachtwoord vergeten?'),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                //laadicoon
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
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
                      _isLogin ? 'Login' : 'Registreer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Scheidingslijn
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Of ga verder met',
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
                  mainAxisSize: MainAxisSize
                      .min, //zorgt dat de kolom niet te veel ruimte inneemt
                  children: [
                    SignInButton(
                      isDarkMode
                          ? Buttons.GoogleDark
                          : Buttons
                                .Google, //Buttons.Google is een standaard google knop van de package
                      text: "Inloggen met Google",
                      onPressed: _signInWithGoogleHandler,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SignInButton(
                      Buttons
                          .GitHub, //Buttons.GitHub is een standaard github knop van de package
                      text: "Inloggen met GitHub",
                      onPressed: _signInWithGitHubHandler,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    //knop is alleen zichtbaar voor ios en macos, niet op web
                    if (!kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.macOS)) ...[
                      const SizedBox(height: 12),
                      SignInButton(
                        Buttons.Apple,
                        text: "Inloggen met Apple",
                        onPressed: _signInWithAppleHandler,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                      _isLogin ? 'Nog geen account?' : 'Heb je al een account?',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? 'Maak een account' : 'Login',
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
