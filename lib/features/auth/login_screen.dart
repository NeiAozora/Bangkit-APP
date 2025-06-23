import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:bangkit/core/services/auth_service.dart'; // Impor layanan otentikasi
//=================================================================
// Halaman Splash Screen (Tampilan Awal)
// Dibuat menjadi StatefulWidget untuk navigasi setelah delay.
//=================================================================
//=================================================================
// Halaman Splash Screen (Tampilan Awal)
//=================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk pindah ke halaman Login setelah 3 detik menggunakan RUTE BERNAMA
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Pastikan path ini benar
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.directions_bus, color: Colors.amber, size: 80);
              },
            ),
            const SizedBox(height: 20),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Booking angkot kilat',
                  textStyle: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ],
        ),
      ),
    );
  }
}

//=================================================================
// Halaman Login
//=================================================================
class LoginScreen extends StatefulWidget {
  // Konstruktor dibuat const dan TIDAK LAGI menerima AuthService.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // AuthService diinstansiasi di dalam State, bukan di-inject.
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);
    try {
      final AppUser? user = await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted && user != null) {
        // Logika navigasi berdasarkan peran (peran) pengguna
        switch (user.peran) {
          case UserRole.pelanggan:
            Navigator.pushReplacementNamed(context, '/penumpangHome', arguments: user);
            break;
          case UserRole.supir:
            Navigator.pushReplacementNamed(context, '/sopirHome', arguments: user);
            break;
          case UserRole.operator:
            Navigator.pushReplacementNamed(context, '/adminHome', arguments: user);
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/logo.png', height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_bus, size: 60, color: Colors.amber),
              ),
              const SizedBox(height: 30),
              const Text('Selamat Datang!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Text('Masuk untuk melanjutkan', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: Text('Daftar di sini', style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//=================================================================
// Halaman Register Baru
//=================================================================
class RegisterScreen extends StatefulWidget {
  // Konstruktor juga dibuat const dan tidak menerima apa-apa.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmailAndPassword(nama: _nameController.text, email: _emailController.text, password: _passwordController.text, nomorTelepon: _phoneController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil! Silakan login.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi Gagal: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.amber[800]), onPressed: () => Navigator.of(context).pop())),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Buat Akun Baru', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Text('Lengkapi data diri Anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 20),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline, color: Colors.amber[800]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('DAFTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
