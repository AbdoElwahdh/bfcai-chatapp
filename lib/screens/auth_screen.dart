// Auth screen: Login & Signup combined screen.
// Clean UI + Safe null-handling + short English comments only.

import 'package:flutter/material.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import '../utils/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  bool _isLogin = true; // Toggle login/signup
  bool _loading = false; // Show loader during auth

  String _email = "";
  String _username = "";
  String _password = "";

  // Submit login or signup
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmail(_email, _password);
      } else {
        await _auth.signUpWithEmail(_email, _password, _username);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Build a reusable text field
  Widget _buildField({
    required String label,
    required bool isPassword,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: label == "Email"
            ? const Icon(Icons.email_outlined)
            : label == "Password"
                ? const Icon(Icons.lock_outline)
                : const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: isPassword,
      keyboardType: keyboard,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // App Icon
              const Icon(Icons.chat_bubble_outline,
                  size: 60, color: AppColors.primary),

              const SizedBox(height: 12),

              // Screen title
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              // Card container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username (signup only)
                      if (!_isLogin)
                        _buildField(
                          label: "Username",
                          isPassword: false,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? "Enter valid username"
                              : null,
                          onSaved: (v) => _username = v ?? "",
                        ),

                      if (!_isLogin) const SizedBox(height: 12),

                      // Email
                      _buildField(
                        label: "Email",
                        isPassword: false,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains("@"))
                            ? "Enter valid email"
                            : null,
                        onSaved: (v) => _email = v ?? "",
                      ),

                      const SizedBox(height: 12),

                      // Password
                      _buildField(
                        label: "Password",
                        isPassword: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? "Min 6 characters"
                            : null,
                        onSaved: (v) => _password = v ?? "",
                      ),

                      const SizedBox(height: 18),

                      // Submit button
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(_isLogin ? "Login" : "Sign Up"),
                              ),
                            ),

                      const SizedBox(height: 10),

                      // Switch login/signup
                      TextButton(
                        onPressed: () {
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? "Create new account"
                              : "Already have an account?",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
