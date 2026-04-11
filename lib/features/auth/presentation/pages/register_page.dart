import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:iotani_berhasil/core/firebase/firebase_service.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun IoTani',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar untuk mulai memantau tanaman Anda',
                  style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 32),

                // Form
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama Anda',
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    hintText: 'Ulangi password Anda',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: 28),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      final confirmPassword = confirmPasswordController.text;

                      if (name.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field harus diisi.'),
                          ),
                        );
                        return;
                      }

                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password tidak cocok.'),
                          ),
                        );
                        return;
                      }

                      try {
                        final firebaseService = FirebaseService();
                        final credential = await firebaseService.signUp(
                          email: email,
                          password: password,
                        );

                        final uid = credential.user?.uid;
                        if (uid != null) {
                          await firebaseService.setUserProfile(
                            userId: uid,
                            profile: {
                              'name': name,
                              'email': email,
                              'role': 'user',
                              'createdAt': ServerValue.timestamp,
                            },
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registrasi berhasil!'),
                            ),
                          );
                          context.go('/dashboard');
                        } else {
                          throw Exception(
                            'UID tidak ditemukan setelah registrasi.',
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal daftar: $e')),
                        );
                      }
                    },
                    child: const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: AppTheme.textMedium),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Masuk di sini',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
