import 'package:bangkit/features/auth/login_screen.dart';
import 'package:bangkit/features/penumpang/penumpang.dart';

import 'package:bangkit/features/sopir/sopir.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
        // Penggunaan Material 3 untuk komponen yang lebih modern
        useMaterial3: true,
        // Skema warna utama aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107), // Warna dasar kuning
          primary: const Color(0xFFFFC107),
          secondary: const Color(0xFF212121),
          background: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Color(0xFF212121),
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107), // Warna primer
            foregroundColor: const Color(0xFF212121), // Warna teks/ikon
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF212121),
          unselectedItemColor: Colors.black54,
          elevation: 5,
        ),
      ),
      
      // Halaman pertama yang akan ditampilkan diganti dengan initialRoute
      // home: const SplashScreen(),

      // Rute awal aplikasi
      initialRoute: '/',
      // Definisi semua rute bernama dalam aplikasi
      routes: {
        '/': (context) => const SplashScreen(), // Asumsi SplashScreen adalah widget yang valid
        '/login': (context) => const LoginScreen(),
        '/penumpangHome': (context) => const AngkotApp(),
        '/sopirHome': (context) => const DriverHomePage(),
        '/adminHome': (context) => const DriverHomePage(),


      },
    );
  }
}

// Pastikan file untuk SplashScreen, LoginScreen, dan Penumpang sudah ada dan diimpor dengan benar.