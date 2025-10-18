import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginRegisterView extends StatefulWidget {
  const LoginRegisterView({super.key});

  @override
  State<LoginRegisterView> createState() => _LoginRegisterViewState();
}

class _LoginRegisterViewState extends State<LoginRegisterView> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _signInWithFacebookHandler() async {
    setState(() => _loading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        FacebookAuthProvider facebookProvider = FacebookAuthProvider();
        facebookProvider.addScope('email');
        facebookProvider.setCustomParameters({'display': 'popup'});

        userCredential = await FirebaseAuth.instance.signInWithPopup(
          facebookProvider,
        );
      } else {
        final LoginResult loginResult = await FacebookAuth.instance.login();

        if (loginResult.status != LoginStatus.success) {
          throw FirebaseAuthException(
            code: 'facebook_login_failed',
            message: loginResult.message ?? 'Facebook login mislukt',
          );
        }

        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(
              loginResult.accessToken!.tokenString,
            );

        userCredential = await FirebaseAuth.instance.signInWithCredential(
          facebookCredential,
        );
      }

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
      ).pushReplacement(MaterialPageRoute(builder: (_) => const _HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unknown error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign_in_cancelled',
          message: 'Google Sign-In is geannuleerd door de gebruiker.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: 'Kon geen idToken ophalen van Google.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<UserCredential> signInWithGitHub() async {
    if (kIsWeb) {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      return await FirebaseAuth.instance.signInWithPopup(githubProvider);
    } else {
      throw UnimplementedError(
        'GitHub login op Android/iOS moet via OAuth flow',
      );
    }
  }

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
      ).pushReplacement(MaterialPageRoute(builder: (_) => const _HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unknown error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
      ).pushReplacement(MaterialPageRoute(builder: (_) => const _HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unknown error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = cred.user;
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
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = cred.user;
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const _HomeScreen()));
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'Authentication error';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 20),
                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Login' : 'Register'),
                            ),
                      const SizedBox(height: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SignInButton(
                            Buttons.Google,
                            onPressed: _signInWithGoogleHandler,
                          ),
                          const SizedBox(height: 12),
                          SignInButton(
                            Buttons.GitHub,
                            onPressed: _signInWithGitHubHandler,
                          ),
                          if (!kIsWeb) ...[
                            const SizedBox(height: 12),
                            SignInButton(
                              Buttons.Facebook,
                              onPressed: _signInWithFacebookHandler,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? 'Create an account'
                              : 'Have an account? Login',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Logged in as ${user?.email ?? 'unknown'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginRegisterView()),
                );
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
