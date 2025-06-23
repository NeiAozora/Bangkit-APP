import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:mysql_client/mysql_client.dart';

// Path import dipastikan benar sesuai error log.
import 'package:bangkit/core/models/pelangan/models.dart';

// ===================================================================
// KELAS-KELAS YANG DIBUTUHKAN (TERMASUK AUTHSERVICE YANG HILANG)
// ===================================================================

/// [DEFINED] Kelas AuthServiceLokalPenumpang yang hilang kini didefinisikan.
/// Ini adalah implementasi minimal untuk menyelesaikan error 'undefined method'.
/// Anda harus menggantinya dengan implementasi AuthServiceLokalPenumpang Anda yang sebenarnya.
class AuthServiceLokalPenumpang {
  // State untuk menyimpan user yang sedang login.
  Pengguna? _currentUser;

  /// Metode 'getCurrentUser' kini didefinisikan.
  /// Metode ini yang dipanggil oleh service lain.
  Future<Pengguna?> getCurrentUser() async {
    // Dalam aplikasi nyata, ini akan memverifikasi token atau sesi.
    // Untuk tujuan debugging, kita bisa set user default jika null.
    // Logika login Anda yang sebenarnya akan mengisi _currentUser.
    if (_currentUser == null) {
        // Sebagai fallback jika tidak ada user login, kembalikan null atau user tamu.
        // Ini mencegah error pada service lain yang memanggil method ini.
    }
    return _currentUser;
  }

  // Anda bisa menambahkan metode login/logout di sini untuk mengelola _currentUser
  // Contoh:
  Future<void> login(Pengguna user) async {
    _currentUser = user;
  }
  Future<void> logout() async {
    _currentUser = null;
  }
}


/// Kelas helper untuk mengelola koneksi ke database.
class DatabaseService {
  late MySQLConnectionPool pool;

  DatabaseService() {
    pool = MySQLConnectionPool(
      host: 'your_database_host',
      port: 3306,
      userName: 'your_database_user',
      password: 'your_database_password',
      databaseName: 'your_database_name',
      maxConnections: 10,
    );
  }

  Future<void> close() async {
    await pool.close();
  }
}

// Helper untuk parsing enum dari string database dengan aman
T _parseEnum<T>(List<T> enumValues, String? value, T defaultValue) {
  if (value == null) return defaultValue;
  try {
    return enumValues.firstWhere((e) => e.toString().split('.').last == value);
  } catch (e) {
    return defaultValue; 
  }
}

// ===================================================================
// SERVICE LAYER - IMPLEMENTASI DENGAN DATABASE
// ===================================================================

/// Mengelola semua data terkait Angkot, Rute, dan Jadwal.
class AngkotService {
  final DatabaseService _db = DatabaseService();

  /// Mengambil daftar jadwal angkot yang tersedia dari database.
  Future<List<JadwalAngkot>> getAvailableSchedules() async {
    try {
      const query = """
        SELECT 
          j.id AS id_jadwal, j.tarif, j.waktu_berangkat, j.tanggal, j.kursi_tersedia,
          r.id AS id_rute, r.nama_rute, r.titik_awal, ST_AsText(r.koordinat_awal) AS koordinat_awal_text, r.titik_akhir, ST_AsText(r.koordinat_akhir) AS koordinat_akhir_text,
          a.id AS id_angkot, a.plat_nomor, a.kapasitas, a.status_aktif, a.id_supir,
          s.id AS id_pengguna, s.nama, s.email, s.peran, s.nomor_telepon
        FROM jadwal_angkot j
        JOIN rute r ON j.id_rute = r.id
        JOIN angkot a ON j.id_angkot = a.id
        JOIN pengguna s ON a.id_supir = s.id
        WHERE j.tanggal >= CURDATE() AND j.kursi_tersedia > 0
        ORDER BY j.waktu_berangkat;
      """;
      
      final results = await _db.pool.execute(query);
      
      List<JadwalAngkot> schedules = [];
      for (final row in results.rows) {
        final map = row.assoc();

        final kaStr = map['koordinat_awal_text'] as String? ?? 'POINT(0 0)';
        final kakhStr = map['koordinat_akhir_text'] as String? ?? 'POINT(0 0)';
        final ka = kaStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
        final kakh = kakhStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
        final rute = Rute(
            id: map['id_rute'] as int,
            namaRute: map['nama_rute'] as String,
            titikAwalText: map['titik_awal'] as String,
            koordinatAwal: LatLng(double.tryParse(ka[1]) ?? 0, double.tryParse(ka[0]) ?? 0),
            titikAkhirText: map['titik_akhir'] as String,
            koordinatAkhir: LatLng(double.tryParse(kakh[1]) ?? 0, double.tryParse(kakh[0]) ?? 0),
        );

        final supir = Pengguna(
            id: map['id_pengguna'] as int,
            nama: map['nama'] as String,
            email: map['email'] as String,
            password: '', 
            peran: _parseEnum(PeranPengguna.values, map['peran'] as String?, PeranPengguna.pelanggan),
            nomorTelepon: map['nomor_telepon'] as String?,
        );

        final angkot = Angkot(
            id: map['id_angkot'] as int,
            idRute: map['id_rute'] as int,
            idSupir: map['id_supir'] as int,
            platNomor: map['plat_nomor'] as String,
            kapasitas: map['kapasitas'] as int,
            statusAktif: (map['status_aktif'] as int? ?? 0) == 1,
        );

        final tanggal = map['tanggal'] as DateTime;
        final waktu = map['waktu_berangkat'] as Duration;
        final waktuBerangkat = DateTime(tanggal.year, tanggal.month, tanggal.day).add(waktu);

        schedules.add(JadwalAngkot(
            id: map['id_jadwal'] as int,
            rute: rute,
            angkot: angkot,
            supir: supir,
            tarif: (map['tarif'] as num).toDouble(),
            waktuBerangkat: waktuBerangkat,
            kursiTersedia: map['kursi_tersedia'] as int,
        ));
      }
      return schedules;
    } catch (e) {
      return [];
    }
  }

  /// Mengambil aktivitas terakhir dari semua supir.
  Future<List<AktivitasSupir>> getAllDriverActivities() async {
    try {
      const query = "SELECT id, id_supir, status, ST_AsText(lokasi_terakhir) as lokasi_terakhir_text, terakhir_update FROM aktivitas_supir;";
      final results = await _db.pool.execute(query);
      
      return results.rows.map((row) {
        final map = row.assoc();
        final ltStr = map['lokasi_terakhir_text'] as String? ?? 'POINT(0 0)';
        final lt = ltStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
        return AktivitasSupir(
          id: map['id'] as int,
          idSupir: map['id_supir'] as int,
          status: _parseEnum(StatusAktivitasSupir.values, map['status'] as String?, StatusAktivitasSupir.tidak_aktif),
          lokasiTerakhir: LatLng(double.tryParse(lt[1]) ?? 0, double.tryParse(lt[0]) ?? 0),
          terakhirUpdate: map['terakhir_update'] as DateTime,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Lacak posisi satu angkot dengan polling ke database secara periodik.
  Stream<AktivitasSupir> trackAngkot(int idSupir) {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      try {
        const query = "SELECT id, id_supir, status, ST_AsText(lokasi_terakhir) as lokasi_terakhir_text, terakhir_update FROM aktivitas_supir WHERE id_supir = :idSupir;";
        final results = await _db.pool.execute(query, {"idSupir": idSupir});
        if (results.rows.isNotEmpty) {
          final map = results.rows.first.assoc();
          final ltStr = map['lokasi_terakhir_text'] as String? ?? 'POINT(0 0)';
          final lt = ltStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
          return AktivitasSupir(
            id: map['id'] as int,
            idSupir: map['id_supir'] as int,
            status: _parseEnum(StatusAktivitasSupir.values, map['status'] as String?, StatusAktivitasSupir.tidak_aktif),
            lokasiTerakhir: LatLng(double.tryParse(lt[1]) ?? 0, double.tryParse(lt[0]) ?? 0),
            terakhirUpdate: map['terakhir_update'] as DateTime,
          );
        }
        return null;
      } catch (e) {
        return null;
      }
    }).asyncMap((event) async => await event).where((event) => event != null).cast<AktivitasSupir>();
  }
}


/// Mengelola semua data dan logika terkait Booking.
class BookingService {
  final DatabaseService _db = DatabaseService();
  final AuthServiceLokalPenumpang authService; 

  BookingService({required this.authService});

  Future<JadwalAngkot?> _getJadwalDetail(int jadwalId) async {
    const query = """
       SELECT 
          j.id AS id_jadwal, j.tarif, j.waktu_berangkat, j.tanggal, j.kursi_tersedia,
          r.id AS id_rute, r.nama_rute, r.titik_awal, ST_AsText(r.koordinat_awal) AS koordinat_awal_text, r.titik_akhir, ST_AsText(r.koordinat_akhir) AS koordinat_akhir_text,
          a.id AS id_angkot, a.plat_nomor, a.kapasitas, a.status_aktif, a.id_supir,
          s.id AS id_pengguna, s.nama, s.email, s.peran, s.nomor_telepon
        FROM jadwal_angkot j
        JOIN rute r ON j.id_rute = r.id
        JOIN angkot a ON j.id_angkot = a.id
        JOIN pengguna s ON a.id_supir = s.id
      WHERE j.id = :jadwalId;
    """;
    final result = await _db.pool.execute(query, {"jadwalId": jadwalId});
    if (result.rows.isEmpty) return null;

    final map = result.rows.first.assoc();
    final kaStr = map['koordinat_awal_text'] as String? ?? 'POINT(0 0)';
    final kakhStr = map['koordinat_akhir_text'] as String? ?? 'POINT(0 0)';
    final ka = kaStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    final kakh = kakhStr.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    final rute = Rute(id: map['id_rute'] as int, namaRute: map['nama_rute'] as String, titikAwalText: map['titik_awal'] as String, koordinatAwal: LatLng(double.tryParse(ka[1]) ?? 0, double.tryParse(ka[0]) ?? 0), titikAkhirText: map['titik_akhir'] as String, koordinatAkhir: LatLng(double.tryParse(kakh[1]) ?? 0, double.tryParse(kakh[0]) ?? 0));
    final supir = Pengguna(id: map['id_pengguna'] as int, nama: map['nama'] as String, email: map['email'] as String, password: '', peran: _parseEnum(PeranPengguna.values, map['peran'] as String?, PeranPengguna.pelanggan), nomorTelepon: map['nomor_telepon'] as String?);
    final angkot = Angkot(id: map['id_angkot'] as int, idRute: map['id_rute'] as int, idSupir: map['id_supir'] as int, platNomor: map['plat_nomor'] as String, kapasitas: map['kapasitas'] as int, statusAktif: (map['status_aktif'] as int? ?? 0) == 1);
    final tanggal = map['tanggal'] as DateTime;
    final waktu = map['waktu_berangkat'] as Duration;
    final waktuBerangkat = DateTime(tanggal.year, tanggal.month, tanggal.day).add(waktu);
    return JadwalAngkot(id: map['id_jadwal'] as int, rute: rute, angkot: angkot, supir: supir, tarif: (map['tarif'] as num).toDouble(), waktuBerangkat: waktuBerangkat, kursiTersedia: map['kursi_tersedia'] as int);
  }
  
  Future<List<Booking>> getBookingHistory() async {
     final currentUser = await authService.getCurrentUser();
     if (currentUser == null) return [];
     
     try {
      const query = "SELECT *, id as id_booking FROM booking WHERE id_pelanggan = :userId ORDER BY tanggal_booking DESC";
      final bookingResults = await _db.pool.execute(query, {"userId": currentUser.id});
      
      final List<Booking> bookings = [];
      
      for (final row in bookingResults.rows) {
        final bookingData = row.assoc();
        final jadwalId = bookingData['id_jadwal'] as int;
        
        final jadwal = await _getJadwalDetail(jadwalId);
        
        if (jadwal != null) {
          bookings.add(Booking(
            id: bookingData['id_booking'] as int,
            pelanggan: currentUser,
            jadwal: jadwal,
            waktuBooking: bookingData['waktu_booking'] as DateTime,
            jumlahKursi: bookingData['jumlah_kursi'] as int,
            status: _parseEnum(StatusBooking.values, bookingData['status'] as String?, StatusBooking.dibatalkan),
          ));
        }
      }
      return bookings;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createBooking({required int jadwalId, required int jumlahKursi, required LatLng lokasiJemput}) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return false;

    try {
      return await _db.pool.transactional((conn) async {
        final jadwalRes = await conn.execute("SELECT kursi_tersedia FROM jadwal_angkot WHERE id = :id FOR UPDATE", {"id": jadwalId});
        final kursiTersedia = jadwalRes.rows.first.typedColAt<int>(0)!;

        if (kursiTersedia < jumlahKursi) return false;

        final lokasiJemputWKT = 'POINT(${lokasiJemput.longitude} ${lokasiJemput.latitude})';
        await conn.execute(
          "INSERT INTO booking (id_pelanggan, id_jadwal, tanggal_booking, waktu_booking, lokasi_jemput, jumlah_kursi, status) VALUES (:userId, :jadwalId, NOW(), CURTIME(), ST_PointFromText(:lokasi, 4326), :jumlahKursi, 'menunggu_acc')",
          {"userId": currentUser.id, "jadwalId": jadwalId, "lokasi": lokasiJemputWKT, "jumlahKursi": jumlahKursi}
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return false;

    try {
      await _db.pool.execute(
        "UPDATE booking SET status = 'dibatalkan' WHERE id = :id AND id_pelanggan = :userId AND status IN ('menunggu_acc', 'diterima')",
        {"id": bookingId, "userId": currentUser.id}
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Mengelola semua data dan logika terkait Chat.
class ChatService {
  final DatabaseService _db = DatabaseService();
  final AuthServiceLokalPenumpang authService;

  ChatService({required this.authService});

  Future<List<ChatMessage>> getChatMessages(int bookingId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return [];

    try {
      const query = "SELECT * FROM chat WHERE id_booking = :bookingId ORDER BY waktu_kirim ASC";
      final results = await _db.pool.execute(query, {"bookingId": bookingId});
      
      return results.rows.map((row) {
        final map = row.assoc();
        return ChatMessage(
          id: map['id'] as int,
          idBooking: map['id_booking'] as int,
          idPengirim: map['id_pengirim'] as int,
          pesan: map['pesan'] as String,
          waktuKirim: map['waktu_kirim'] as DateTime,
          isSentByUser: (map['id_pengirim'] as int) == currentUser.id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage({required int bookingId, required int penerimaId, required String pesan}) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return false;

    try {
      const query = "INSERT INTO chat (id_booking, id_pengirim, id_penerima, pesan) VALUES (:bookingId, :pengirimId, :penerimaId, :pesan)";
      await _db.pool.execute(query, {"bookingId": bookingId, "pengirimId": currentUser.id, "penerimaId": penerimaId, "pesan": pesan});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Driver>> getActiveChats() async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return [];

    try {
      const query = """
        SELECT DISTINCT s.id as id_supir, s.nama as nama_supir, a.plat_nomor
        FROM booking b
        JOIN jadwal_angkot j ON b.id_jadwal = j.id
        JOIN angkot a ON j.id_angkot = a.id
        JOIN pengguna s ON a.id_supir = s.id
        WHERE b.id_pelanggan = :userId AND b.status IN ('menunggu_acc', 'diterima');
      """;
      final results = await _db.pool.execute(query, {"userId": currentUser.id});
      return results.rows.map((row) {
        final map = row.assoc();
        return Driver(id: map['id_supir'] as int, name: map['nama_supir'] as String, licensePlate: map['plat_nomor'] as String);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Mengelola data Notifikasi
class NotificationService {
  final DatabaseService _db = DatabaseService();
  final AuthServiceLokalPenumpang authService;

  NotificationService({required this.authService});
  
  Future<List<Notifikasi>> getNotifications() async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return [];

    try {
      const query = "SELECT * FROM notifikasi WHERE id_pengguna = :userId ORDER BY created_at DESC";
      final results = await _db.pool.execute(query, {"userId": currentUser.id});
      
      return results.rows.map((row) {
        final map = row.assoc();
        return Notifikasi(
          id: map['id'] as int,
          judul: map['judul'] as String,
          isi: map['isi'] as String,
          waktu: map['created_at'] as DateTime,
          dibaca: (map['status_dibaca'] as int? ?? 0) == 1,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
