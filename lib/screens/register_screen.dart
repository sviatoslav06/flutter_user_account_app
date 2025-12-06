import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController =
      TextEditingController(text: "Святослав");
  final TextEditingController _lastNameController =
      TextEditingController(text: "Самолюк");
  final TextEditingController _emailController =
      TextEditingController(text: "your.email@example.com");
  final TextEditingController _groupController =
      TextEditingController(text: "ПЗ-37");
  final TextEditingController _passwordController =
      TextEditingController(text: "123456");
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: "123456");

  String? _selectedUniversity;
  String? _selectedFaculty;
  String? _selectedCourse;
  String? _selectedSubgroup;
  bool _agree = false;

  void _register() {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Погодьтесь з умовами використання')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    _registerWithEmail();
  }

  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final displayName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    if (!_agree) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Погодьтесь з умовами')));
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password required')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password must be at least 6 characters')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(displayName);
      await cred.user?.reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Реєстрація успішна!')));
      try {
        await FirebaseAnalytics.instance
            .logEvent(name: 'sign_up', parameters: {'method': 'email'});
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
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
              Image.asset('assets/images/Register.png', height: 64),
              const SizedBox(height: 10),
              const Text(
                "Приєднуйтесь",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("Створіть свій акаунт",
                  style: TextStyle(color: Colors.black54, fontSize: 16)),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Реєстрація",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: "Ім’я",
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Введіть ім\'я';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: "Прізвище",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Введіть прізвище';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Введіть email';
                          final emailReg =
                              RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                          if (!emailReg.hasMatch(v.trim()))
                            return 'Невірний email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedUniversity,
                        hint: const Text("Оберіть університет"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "КПІ",
                              child: Text("Київський Політехнічний")),
                          DropdownMenuItem(
                              value: "ЛНУ",
                              child: Text("Львівський Національний")),
                        ],
                        onChanged: (val) => setState(() {
                          _selectedUniversity = val;
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedFaculty,
                              hint: const Text("Факультет"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: "ФІОТ",
                                    child: Text("Комп’ютерних наук")),
                                DropdownMenuItem(
                                    value: "ІФНТУНГ",
                                    child: Text("Інформаційних технологій")),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedFaculty = val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedCourse,
                              hint: const Text("Курс"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedCourse = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                                controller: _groupController,
                                decoration: InputDecoration(
                                  labelText: "Група",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Введіть групу';
                                  return null;
                                }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedSubgroup,
                              hint: const Text("Підгрупа"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedSubgroup = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Пароль",
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: "Мінімум 6 символів",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Введіть пароль';
                          if (v.length < 6)
                            return 'Пароль повинен бути мінімум 6 символів';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Підтвердіть пароль",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Підтвердіть пароль';
                          if (v != _passwordController.text)
                            return 'Паролі не співпадають';
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _agree,
                            onChanged: (v) =>
                                setState(() => _agree = v ?? false),
                          ),
                          Expanded(
                            child: Wrap(
                              children: const [
                                Text("Я погоджуюсь з "),
                                Text(
                                  "умовами використання ",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text("та "),
                                Text(
                                  "політикою конфіденційності",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Зареєструватися",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Вже маєте акаунт? "),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Увійти",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
