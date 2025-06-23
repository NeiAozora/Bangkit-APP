// File: models/booking_models.dart
// Deskripsi: Berisi semua model data dan enum yang digunakan dalam aplikasi.

// Model untuk data Pengguna (Pelanggan)
class Pelanggan {
  final String nama;
  final String fotoProfilUrl;
  final String nomorTelepon;

  Pelanggan({
    required this.nama,
    required this.fotoProfilUrl,
    required this.nomorTelepon,
  });
}

// Enum untuk status booking yang berbeda
enum BookingStatus { menunggu_acc, diterima, ditolak, selesai, dibatalkan }

// Enum untuk status pembayaran
enum PembayaranStatus { belum_bayar, sudah_bayar }

// Enum untuk status aktivitas sopir
enum AktivitasStatus { tersedia, dalam_perjalanan, istirahat, tidak_aktif }

// Model untuk data Booking
class Booking {
  final int id;
  final Pelanggan pelanggan;
  final int idJadwal;
  final String lokasiJemput;
  final int jumlahKursi;
  BookingStatus status;
  PembayaranStatus pembayaranStatus;

  // Informasi ini seharusnya didapat dari join dengan tabel jadwal_angkot dan rute
  final String namaRute;
  final String waktuBerangkat;

  Booking({
    required this.id,
    required this.pelanggan,
    required this.idJadwal,
    required this.lokasiJemput,
    required this.jumlahKursi,
    required this.namaRute,
    required this.waktuBerangkat,
    this.status = BookingStatus.menunggu_acc,
    this.pembayaranStatus = PembayaranStatus.belum_bayar,
  });
}
