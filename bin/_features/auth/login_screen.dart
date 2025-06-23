import 'dart:async';
import 'package:bangkit/features/penumpang/TK';
import 'package:flutter/material.dart';
// Impor package untuk animasi teks
import 'package:animated_text_kit/animated_text_kit.dart';

// --- PENTING ---
// Jangan lupa tambahkan `animated_text_kit: ^4.2.2` ke file pubspec.yaml Anda
// dan jalankan `flutter pub get` sebelum menjalankan kode ini.

// Fungsi utama untuk menjalankan aplikasi


// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App Kuning Putih',
      // Menonaktifkan banner debug di pojok kanan atas
      debugShowCheckedModeBanner: false,
      // Mengatur tema utama aplikasi
      theme: ThemeData(
        // Warna utama yang akan digunakan, misalnya untuk tombol, border, dll.
        primarySwatch: Colors.amber, 
        // Warna dasar untuk semua halaman (Scaffold)
        scaffoldBackgroundColor: Colors.white, 
        // Font default untuk aplikasi
        fontFamily: 'Poppins',
      ),
      // Halaman pertama yang akan ditampilkan adalah SplashScreen
      home: const SplashScreen(),
    );
  }
}

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
    // Membuat timer untuk loading palsu selama 3 detik untuk memberi waktu animasi
    Timer(const Duration(seconds: 3), () {
      // Setelah 3 detik, pindah ke halaman LoginScreen.
      // pushReplacement digunakan agar pengguna tidak bisa kembali ke splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background putih, sesuai tema di MaterialApp
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan Image.asset untuk memuat logo dari folder assets
            Image.asset(
              'assets/images/logo.png', 
              height: 200, // Atur tinggi logo
              // Menambahkan penanganan error jika gambar tidak ditemukan
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, color: Colors.red, size: 80);
              },
            ),
            const SizedBox(height: 20),
            // Widget Animasi Teks
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
              totalRepeatCount: 1, // Animasi hanya berjalan sekali
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
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
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              const SizedBox(height: 60),
              // Menggunakan Image.asset untuk memuat logo
              Image.asset(
                'assets/images/logo.png',
                height: 80, // Logo lebih kecil di halaman login
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, color: Colors.red, size: 60);
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Selamat Datang!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Text(
                'Masuk untuk melanjutkan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AngkotApp()),
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 15),
              // Tautan ke Halaman Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke Halaman Register
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Daftar di sini',
                      style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                    ),
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
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar untuk tombol kembali
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Text(
                'Lengkapi data diri Anda di bawah ini',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Form Nama
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Form Nomor Telepon
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Form Password
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.amber[800]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[800]!, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Daftar
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika registrasi di sini
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('DAFTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
