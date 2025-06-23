import 'package:latlong2/latlong.dart';

enum PeranPengguna { operator, supir, pelanggan }
enum StatusBooking { menunggu_acc, diterima, ditolak, selesai, dibatalkan }
enum StatusAktivitasSupir { tersedia, dalam_perjalanan, istirahat, tidak_aktif }

class Pengguna {
  final int id;
  final String nama;
  final String email;
  final String password;
  final PeranPengguna peran;
  final String? nomorTelepon;
  final String? fotoProfil;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.peran,
    this.nomorTelepon,
    this.fotoProfil,
  });
}

class Rute {
  final int id;
  final String namaRute;
  final String titikAwalText;
  final LatLng koordinatAwal;
  final String titikAkhirText;
  final LatLng koordinatAkhir;

  const Rute({
    required this.id,
    required this.namaRute,
    required this.titikAwalText,
    required this.koordinatAwal,
    required this.titikAkhirText,
    required this.koordinatAkhir,
  });
}

class Angkot {
  final int id;
  final int idRute;
  final int idSupir;
  final String platNomor;
  final int kapasitas;
  final bool statusAktif;

  const Angkot({
    required this.id,
    required this.idRute,
    required this.idSupir,
    required this.platNomor,
    required this.kapasitas,
    this.statusAktif = true,
  });
}

class AktivitasSupir {
  final int id;
  final int idSupir;
  final StatusAktivitasSupir status;
  final LatLng lokasiTerakhir;
  final DateTime terakhirUpdate;

  const AktivitasSupir({
    required this.id,
    required this.idSupir,
    required this.status,
    required this.lokasiTerakhir,
    required this.terakhirUpdate,
  });
}

class JadwalAngkot {
  final int id;
  final Rute rute;
  final Angkot angkot;
  final Pengguna supir;
  final double tarif;
  final DateTime waktuBerangkat;
  final int kursiTersedia;

  JadwalAngkot({
    required this.id,
    required this.rute,
    required this.angkot,
    required this.supir,
    required this.tarif,
    required this.waktuBerangkat,
    required this.kursiTersedia,
  });
}

class Booking {
  final int id;
  final Pengguna pelanggan;
  final JadwalAngkot jadwal;
  final DateTime waktuBooking;
  final int jumlahKursi;
  StatusBooking status;

  Booking({
    required this.id,
    required this.pelanggan,
    required this.jadwal,
    required this.waktuBooking,
    required this.jumlahKursi,
    required this.status,
  });
}

class ChatMessage {
  final int id;
  final int idBooking;
  final int idPengirim;
  final String pesan;
  final DateTime waktuKirim;
  final bool isSentByUser;

  const ChatMessage({
    required this.id,
    required this.idBooking,
    required this.idPengirim,
    required this.pesan,
    required this.waktuKirim,
    required this.isSentByUser,
  });
}

class Notifikasi {
  final int id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool dibaca;

  const Notifikasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
  });
}

class Driver {
  final int id; // Tambahkan ID
  final String name;
  final String licensePlate;

  const Driver({required this.id, required this.name, required this.licensePlate});
}