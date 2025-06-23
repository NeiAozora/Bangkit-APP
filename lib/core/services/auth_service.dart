// FILE: auth_service.dart
// DEPENDENCIES: http
// 1. HAPUS mysql_client dari pubspec.yaml
// 2. TAMBAHKAN http: ^1.2.1 (atau versi terbaru) di pubspec.yaml

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- Global Instance ---
final authService = AuthService();

// --- Model dan Enum (Tidak Berubah) ---

enum UserRole {
  operator,
  supir,
  pelanggan,
}

UserRole _parseUserRole(String? role) {
  if (role == null) return UserRole.pelanggan;
  return UserRole.values.firstWhere(
    (e) => e.toString().split('.').last == role,
    orElse: () => UserRole.pelanggan,
  );
}

class AppUser {
  final int id;
  final String nama;
  final String email;
  final UserRole peran;
  final String? nomorTelepon;
  final String? fotoProfil;

  AppUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    this.nomorTelepon,
    this.fotoProfil,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      nama: map['nama'],
      email: map['email'],
      peran: _parseUserRole(map['peran']),
      nomorTelepon: map['nomor_telepon'],
      fotoProfil: map['foto_profil'],
    );
  }

  AppUser copyWith({
    int? id,
    String? nama,
    String? email,
    UserRole? peran,
    String? nomorTelepon,
    String? fotoProfil,
  }) {
    return AppUser(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      peran: peran ?? this.peran,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }
}


/// AuthService menangani otentikasi dengan berkomunikasi ke Backend API.
class AuthService {
  // URL ke server API Python Anda.
  // Gunakan 'http://10.0.2.2:5000' untuk emulator Android.
  // Gunakan 'http://127.0.0.1:5000' atau 'http://localhost:5000' untuk web.
  final String _baseUrl = 'http://127.0.0.1:5000';
  
  final StreamController<AppUser?> _userController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  Stream<AppUser?> get userStream => _userController.stream;
  AppUser? get currentUser => _currentUser;

  AuthService() {
    _userController.add(null);
    userStream.listen((user) {
      _currentUser = user;
    });
  }

  /// Melakukan sign in dengan mengirim request ke Backend API.
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        final user = AppUser.fromMap(userData);
        _userController.add(user);
        return user;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Gagal melakukan login');
      }
    } catch (e) {
      _userController.add(null);
      print("Error during sign in: $e");
      // Lempar exception agar UI bisa menampilkannya
      throw Exception('Tidak dapat terhubung ke server. Pastikan server API berjalan.');
    }
  }

  /// Mendaftarkan pengguna baru dengan mengirim request ke Backend API.
  Future<AppUser?> registerWithEmailAndPassword({
    required String nama,
    required String email,
    required String password,
    required String nomorTelepon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'nama': nama,
          'email': email,
          'password': password,
          'nomor_telepon': nomorTelepon,
        }),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        final newUser = AppUser.fromMap(userData);
        _userController.add(newUser);
        return newUser;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Gagal melakukan registrasi');
      }
    } catch (e) {
      _userController.add(null);
      print("Error during registration: $e");
      // Lempar exception agar UI bisa menampilkannya
      throw Exception('Tidak dapat terhubung ke server. Gagal melakukan registrasi.');
    }
  }

  /// Melakukan sign out pada pengguna saat ini.
  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  /// Membersihkan resource.
  void dispose() {
    _userController.close();
  }

  // CATATAN: Fungsi seperti updateProfile dan changePassword perlu dibuatkan
  // endpoint-nya terlebih dahulu di server API Python sebelum bisa digunakan di sini.
}
