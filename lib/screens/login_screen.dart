import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  GoogleSignIn? _googleSignIn;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn();
    }
  }

  void _login() {
    _signInWithEmail();
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset('assets/images/Login.png', height: 64),
              const SizedBox(height: 10),
              const Text(
                "StudyPlanner",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Увійдіть до свого акаунту",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Вхід",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: "your.email@example.com",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Пароль",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: const Icon(Icons.visibility_off_outlined),
                        hintText: "Введіть пароль",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                              },
                            ),
                            const Text("Запам’ятати мене"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Забули пароль?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Увійти",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("або"),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text("Увійти через Google"),
                      onPressed: _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.facebook,
                          size: 24, color: Colors.indigo),
                      label: const Text("Увійти через Facebook"),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ще немає акаунту? "),
                        GestureDetector(
                          onTap: _goToRegister,
                          child: const Text(
                            "Зареєструватися",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')));
      return;
    }

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      try {
        await FirebaseAnalytics.instance
            .logEvent(name: 'login', parameters: {'method': 'email'});
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithRedirect(provider);
        return;
      }

      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      try {
        await FirebaseAnalytics.instance
            .logEvent(name: 'login', parameters: {'method': 'google'});
      } catch (_) {}
    } on FirebaseAuthException catch (e, st) {
      debugPrint(
          'FirebaseAuthException during Google sign-in: ${e.code} ${e.message}');
      debugPrint(st.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Google sign-in failed: ${e.message ?? e.code}')));
    } catch (e, st) {
      debugPrint('Exception during Google sign-in: $e');
      debugPrint(st.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }
}
