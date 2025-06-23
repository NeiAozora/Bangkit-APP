// File: services/booking_service.dart
// Deskripsi: Mengelola logika bisnis dan penyediaan data booking.
// Untuk saat ini menggunakan data dummy, nantinya bisa dihubungkan ke API.

import 'package:bangkit/core/models/supir/models.dart';

class BookingService {
  // --- BAGIAN DATA TIRUAN (MOCK DATA) ---
  // Data ini sekarang dikelola di dalam service.
  static final List<Booking> _mockBookings = [
    Booking(
      id: 101,
      idJadwal: 201,
      pelanggan: Pelanggan(nama: 'Budi Santoso', fotoProfilUrl: 'https://placehold.co/100x100/E5E5E5/000000?text=BS', nomorTelepon: '081234567890'),
      lokasiJemput: 'Halte Universitas Jember',
      jumlahKursi: 2,
      namaRute: 'Kampus - Terminal Tawang Alun',
      waktuBerangkat: '08:00',
      status: BookingStatus.menunggu_acc,
      pembayaranStatus: PembayaranStatus.belum_bayar,
    ),
    Booking(
      id: 102,
      idJadwal: 202,
      pelanggan: Pelanggan(nama: 'Citra Lestari', fotoProfilUrl: 'https://placehold.co/100x100/E5E5E5/000000?text=CL', nomorTelepon: '085678901234'),
      lokasiJemput: 'Depan Roxy Square',
      jumlahKursi: 1,
      namaRute: 'Terminal Arjosari - Pasar Besar',
      waktuBerangkat: '09:30',
      status: BookingStatus.menunggu_acc,
      pembayaranStatus: PembayaranStatus.sudah_bayar,
    ),
    Booking(
      id: 103,
      idJadwal: 203,
      pelanggan: Pelanggan(nama: 'Dewi Anggraini', fotoProfilUrl: 'https://placehold.co/100x100/E5E5E5/000000?text=DA', nomorTelepon: '087890123456'),
      lokasiJemput: 'Jl. Mastrip V',
      jumlahKursi: 1,
      namaRute: 'Kampus - Patrang',
      waktuBerangkat: '10:00',
      status: BookingStatus.diterima,
      pembayaranStatus: PembayaranStatus.sudah_bayar,
    ),
      Booking(
      id: 104,
      idJadwal: 204,
      pelanggan: Pelanggan(nama: 'Eko Prasetyo', fotoProfilUrl: 'https://placehold.co/100x100/E5E5E5/000000?text=EP', nomorTelepon: '089987654321'),
      lokasiJemput: 'Stasiun Jember',
      jumlahKursi: 3,
      namaRute: 'Stasiun - Terminal Pakusari',
      waktuBerangkat: '11:00',
      status: BookingStatus.selesai,
      pembayaranStatus: PembayaranStatus.sudah_bayar,
    ),
  ];

  /// Mengambil semua data booking.
  /// Menggunakan Future untuk mensimulasikan panggilan data asinkron (misal: dari API).
  Future<List<Booking>> getBookings() async {
    // Mensimulasikan delay jaringan
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockBookings);
  }

  /// Memperbarui status booking berdasarkan ID.
  Future<void> updateBookingStatus(int bookingId, BookingStatus newStatus) async {
    // Mensimulasikan delay jaringan
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _mockBookings[index].status = newStatus;
    }
  }
}
