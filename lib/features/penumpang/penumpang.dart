import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ===================================================================
// MODEL DATA (SESUAI SKEMA SQL)
// ===================================================================

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
  final StatusBooking status;

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
  final String name;
  final String licensePlate;

  const Driver({required this.name, required this.licensePlate});
}

// ===================================================================
// DATA DUMMY
// ===================================================================

final Pengguna currentUser = const Pengguna(id: 1, nama: "Pelanggan Satu", email: "pelanggan@mail.com", password: "123", peran: PeranPengguna.pelanggan, nomorTelepon: '08123456789');
final List<Pengguna> dummySupir = [
  const Pengguna(id: 2, nama: "Yanto", email: "yanto@mail.com", password: "123", peran: PeranPengguna.supir),
  const Pengguna(id: 3, nama: "Agus", email: "agus@mail.com", password: "123", peran: PeranPengguna.supir),
  const Pengguna(id: 4, nama: "Kiki", email: "kiki@mail.com", password: "123", peran: PeranPengguna.supir),
];

final List<Rute> dummyRute = [
  const Rute(id: 1, namaRute: "Cicaheum - Ledeng", titikAwalText: "Terminal Cicaheum", koordinatAwal: LatLng(-6.908, 107.652), titikAkhirText: "Terminal Ledeng", koordinatAkhir: LatLng(-6.878, 107.600)),
  const Rute(id: 2, namaRute: "St. Hall - Dago", titikAwalText: "Stasiun Hall", koordinatAwal: LatLng(-6.913, 107.602), titikAkhirText: "Simpang Dago", koordinatAkhir: LatLng(-6.888, 107.614)),
];

final List<Angkot> dummyAngkot = [
  const Angkot(id: 101, idRute: 1, idSupir: 2, platNomor: 'D 1234 ABC', kapasitas: 12),
  const Angkot(id: 102, idRute: 2, idSupir: 3, platNomor: 'D 5678 DEF', kapasitas: 12),
  const Angkot(id: 103, idRute: 1, idSupir: 4, platNomor: 'D 9101 GHI', kapasitas: 12),
];

final List<AktivitasSupir> dummyAktivitasSupir = [
  AktivitasSupir(id: 1, idSupir: 2, status: StatusAktivitasSupir.dalam_perjalanan, lokasiTerakhir: const LatLng(-6.903, 107.619), terakhirUpdate: DateTime.now()),
  AktivitasSupir(id: 2, idSupir: 3, status: StatusAktivitasSupir.dalam_perjalanan, lokasiTerakhir: const LatLng(-6.899, 107.615), terakhirUpdate: DateTime.now()),
  AktivitasSupir(id: 3, idSupir: 4, status: StatusAktivitasSupir.tersedia, lokasiTerakhir: const LatLng(-6.905, 107.622), terakhirUpdate: DateTime.now()),
];

final List<JadwalAngkot> availableSchedules = [
  JadwalAngkot(id: 1, rute: dummyRute[0], angkot: dummyAngkot[0], supir: dummySupir[0], tarif: 7000, waktuBerangkat: DateTime.now().add(const Duration(minutes: 5)), kursiTersedia: 3),
  JadwalAngkot(id: 2, rute: dummyRute[1], angkot: dummyAngkot[1], supir: dummySupir[1], tarif: 6000, waktuBerangkat: DateTime.now().add(const Duration(minutes: 15)), kursiTersedia: 12),
  JadwalAngkot(id: 3, rute: dummyRute[0], angkot: dummyAngkot[2], supir: dummySupir[2], tarif: 7000, waktuBerangkat: DateTime.now().add(const Duration(minutes: 3)), kursiTersedia: 1),
];

final List<Booking> dummyRiwayatBooking = [
  Booking(id: 1001, pelanggan: currentUser, jadwal: availableSchedules[0], waktuBooking: DateTime(2024, 4, 8, 12, 0), jumlahKursi: 1, status: StatusBooking.menunggu_acc),
  Booking(id: 1004, pelanggan: currentUser, jadwal: availableSchedules[1], waktuBooking: DateTime(2024, 4, 9, 11, 0), jumlahKursi: 1, status: StatusBooking.diterima),
  Booking(id: 1002, pelanggan: currentUser, jadwal: availableSchedules[1], waktuBooking: DateTime(2024, 4, 8, 8, 0), jumlahKursi: 1, status: StatusBooking.selesai),
  Booking(id: 1003, pelanggan: currentUser, jadwal: availableSchedules[2], waktuBooking: DateTime(2024, 4, 7, 9, 0), jumlahKursi: 2, status: StatusBooking.dibatalkan),
];


void main() {
  runApp(const AngkotApp());
}

class AngkotApp extends StatelessWidget {
  const AngkotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angkot Bangkit (flutter_map)',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          surfaceTintColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87),
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// ===================================================================
// Halaman Induk (MainScreen)
// ===================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomeScreen(onProfileIconTapped: () => _onItemTapped(3)),
      BookingHistoryScreen(),
      ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// ===================================================================
// Halaman Utama (HomeScreen)
// ===================================================================
class HomeScreen extends StatefulWidget {
  final VoidCallback onProfileIconTapped;
  
  HomeScreen({super.key, required this.onProfileIconTapped});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final LatLng _userLocation = const LatLng(-6.9088, 107.6186);
  
  int? _selectedJadwalIndex;

  void _showAngkotRoute(int index) {
    setState(() {
      _selectedJadwalIndex = index;
    });
    final jadwal = availableSchedules[index];
    final aktivitas = dummyAktivitasSupir.firstWhere((a) => a.idSupir == jadwal.supir.id);
    _mapController.move(aktivitas.lokasiTerakhir, 14.0);
  }

  void _clearExistingRoute() {
    setState(() {
      _selectedJadwalIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildMapView(),
          _buildAngkotListPanel(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.amber,
      title: const Text('ANGKOT BANGKIT'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, size: 28),
          onPressed: widget.onProfileIconTapped,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildMapView() {
    List<Marker> markers = [];
    List<Polyline> polylines = [];

    markers.add(
      Marker(
        point: _userLocation,
        width: 80,
        height: 80,
        child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      ),
    );

    for (var jadwal in availableSchedules) {
      final aktivitas = dummyAktivitasSupir.firstWhere((a) => a.idSupir == jadwal.supir.id);
      markers.add(
        Marker(
          point: aktivitas.lokasiTerakhir,
          width: 80,
          height: 80,
          child: Icon(Icons.directions_bus, color: Colors.blue[800], size: 35),
        ),
      );
    }
    
    if (_selectedJadwalIndex != null) {
      final jadwal = availableSchedules[_selectedJadwalIndex!];
      final aktivitas = dummyAktivitasSupir.firstWhere((a) => a.idSupir == jadwal.supir.id);
      
      markers.add(Marker(point: jadwal.rute.koordinatAwal, child: const Icon(Icons.flag_circle, color: Colors.green, size: 35)));
      markers.add(Marker(point: jadwal.rute.koordinatAkhir, child: const Icon(Icons.flag_circle, color: Colors.red, size: 35)));
      
      polylines.add(Polyline(
        points: [jadwal.rute.koordinatAwal, aktivitas.lokasiTerakhir, jadwal.rute.koordinatAkhir],
        color: Colors.blue.withAlpha(204),
        strokeWidth: 4,
      ));
      polylines.add(Polyline(
        points: [_userLocation, aktivitas.lokasiTerakhir],
        color: Colors.amber.shade700,
        strokeWidth: 3,
        isDotted: true,
      ));
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-6.9175, 107.6191),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildAngkotListPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Colors.black.withAlpha(51),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Angkot Tersedia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: availableSchedules.length,
                itemBuilder: (context, index) {
                  return JadwalAngkotCard(
                    jadwal: availableSchedules[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailJadwalScreen(jadwal: availableSchedules[index]),
                        ),
                      );
                    },
                    onLongPress: (){
                      if (_selectedJadwalIndex == index) {
                        _clearExistingRoute();
                      } else {
                        _showAngkotRoute(index);
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================================
// Halaman & Widget Lainnya
// ===================================================================
class ProfileScreen extends StatelessWidget {
  final bool showAppBar;
  
  const ProfileScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('PROFIL'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : AppBar(
              title: const Text('PROFIL'),
              automaticallyImplyLeading: false,
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentUser.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentUser.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              _buildProfileButton(
                context,
                text: 'Ubah Profile',
                onPressed: () {
                   showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const EditProfileDialog();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildProfileButton(
                context,
                text: 'Ganti Password',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordDialog();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildProfileButton(
                context,
                text: 'Logout',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const LogoutConfirmationDialog();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.grey.withAlpha(50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ubah Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? Icon(Icons.person, size: 50, color: Colors.grey[400]) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showPicker(context),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.amber,
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email/No. Hp',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () { /* Logika Simpan */ Navigator.of(context).pop(); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ganti Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
             TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
             Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () { /* Logika Simpan */ Navigator.of(context).pop(); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Apakah anda yakin ingin logout?',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tidak'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login', // The route name of the new screen
                      (route) => false, // Predicate to remove all previous routes
                    );
                  },
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ya'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  final List<Driver> drivers = const [
    Driver(name: 'Sumarto', licensePlate: 'T - 023'),
    Driver(name: 'Sumarti', licensePlate: 'T - 065'),
    Driver(name: 'Joko', licensePlate: 'Z - 020'),
    Driver(name: 'Bowo', licensePlate: 'T - 098'),
    Driver(name: 'Zaka', licensePlate: 'T - 123'),
    Driver(name: 'Surip', licensePlate: 'T - 099'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Daftar Driver',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              return DriverChatCard(driver: drivers[index]);
            }, 
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ],
      ),
    );
  }
}

class DriverChatCard extends StatelessWidget {
  final Driver driver;
  const DriverChatCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(driver: driver),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 28, color: Colors.grey[500]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Plat Angkot : ${driver.licensePlate}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Driver driver;
  const ChatScreen({super.key, required this.driver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(id:1, idBooking: 1001, idPengirim: 1, pesan: 'Halo, posisi di mana ya?', waktuKirim: DateTime.now(), isSentByUser: true),
    ChatMessage(id:2, idBooking: 1001, idPengirim: 2, pesan: 'Halo, saya sudah dekat di perempatan', waktuKirim: DateTime.now(), isSentByUser: false),
    ChatMessage(id:3, idBooking: 1001, idPengirim: 1, pesan: 'Oke, ditunggu', waktuKirim: DateTime.now(), isSentByUser: true),
    ChatMessage(id:4, idBooking: 1001, idPengirim: 2, pesan: 'Siap', waktuKirim: DateTime.now(), isSentByUser: false),
  ];
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(id: DateTime.now().millisecondsSinceEpoch, idBooking: 1001, idPengirim: 1, pesan: text, waktuKirim: DateTime.now(), isSentByUser: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 24, color: Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Text("Driver ${widget.driver.name}", style: const TextStyle(fontSize: 18)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bubbleAlignment = message.isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isSentByUser ? Colors.amber[100] : Colors.white;
    final bubbleRadius = message.isSentByUser
      ? const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        )
      : const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: bubbleAlignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: bubbleRadius,
            ),
            child: Text(
              message.pesan,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 5,
            color: Colors.grey.withAlpha(50),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message..',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.send, color: Colors.amber.shade700),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final List<Notifikasi> notifications = [
    Notifikasi(id:1, judul: 'Angkot A Sudah Dekat!', isi: 'Angkot A akan segera tiba...', waktu: DateTime.now()),
    Notifikasi(id:2, judul: 'Angkot A Dalam Perjalanan!', isi: '...', waktu: DateTime.now().subtract(const Duration(minutes: 17))),
    Notifikasi(id:3, judul: 'Anda Sudah Sampai!', isi: 'Terima kasih telah menggunakan layanan kami', waktu: DateTime.now().subtract(const Duration(hours: 2))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(notification: notifications[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Notifikasi notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            color: Colors.amber.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateTime.now().difference(notification.waktu).inMinutes} menit yang lalu',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingHistoryScreen extends StatelessWidget {
  BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: dummyRiwayatBooking.length,
        itemBuilder: (context, index) {
          final booking = dummyRiwayatBooking[index];
          return InkWell(
            onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailScreen(booking: booking),
                  ),
                );
            },
            borderRadius: BorderRadius.circular(16),
            child: BookingHistoryCard(booking: booking),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

class BookingHistoryCard extends StatelessWidget {
  final Booking booking;

  const BookingHistoryCard({super.key, required this.booking});

  (String, Color) getStatusInfo() {
    switch (booking.status) {
      case StatusBooking.menunggu_acc:
        return ('Menunggu ACC', Colors.orange.shade300);
      case StatusBooking.diterima:
         return ('Diterima', Colors.blue.shade300);
      case StatusBooking.selesai:
        return ('Selesai', Colors.green.shade300);
      case StatusBooking.dibatalkan:
      case StatusBooking.ditolak:
        return ('Dibatalkan', Colors.red.shade300);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = getStatusInfo();
    final statusText = statusInfo.$1;
    final statusColor = statusInfo.$2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus, size: 40, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.jadwal.rute.namaRute,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.waktuBooking.day}/${booking.waktuBooking.month}/${booking.waktuBooking.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dari ${booking.jadwal.rute.titikAwalText}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
                Text(
                  'Ke ${booking.jadwal.rute.titikAkhirText}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  (String, Color) getStatusInfo() {
     switch (booking.status) {
      case StatusBooking.menunggu_acc:
        return ('Menunggu ACC', Colors.orange.shade300);
      case StatusBooking.diterima:
         return ('Diterima', Colors.blue.shade300);
      case StatusBooking.selesai:
        return ('Selesai', Colors.green.shade300);
      case StatusBooking.dibatalkan:
      case StatusBooking.ditolak:
        return ('Dibatalkan', Colors.red.shade300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMainInfoCard(),
              const SizedBox(height: 16),
              _buildSecondaryInfoCard(),
              const SizedBox(height: 16),
              _buildRouteCard(context),
              const SizedBox(height: 16),
              _buildFareCard(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 32),
              _buildActionButton(context),
              const SizedBox(height: 12),
              _buildCancelButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 50, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.jadwal.angkot.platNomor,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                booking.jadwal.rute.namaRute,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Waktu: ${booking.waktuBooking.hour}:${booking.waktuBooking.minute}'),
          const SizedBox(
            height: 20,
            child: VerticalDivider(color: Colors.grey),
          ),
          Text('${booking.jumlahKursi} Kursi Dipesan'),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteRow(Icons.circle_outlined, booking.jadwal.rute.titikAwalText, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Container(
              height: 20,
              width: 2,
              color: Colors.grey[300],
            ),
          ),
          _buildRouteRow(Icons.location_on, booking.jadwal.rute.titikAkhirText, Colors.red),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jam Operasional: ${booking.jadwal.waktuBerangkat.hour}:00 - 21:00', // Example
                style: TextStyle(color: Colors.grey[700]),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LacakAngkotScreen(jadwal: booking.jadwal)));
                },
                child: Row(
                  children: [
                     Text('Lacak Angkot', style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                     const SizedBox(width: 4),
                     Icon(Icons.location_searching, color: Colors.amber[800], size: 20),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildRouteRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildFareCard() {
     return Container(
       padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Tarif:', style: TextStyle(fontSize: 16)),
          Text('Rp ${booking.jadwal.tarif * booking.jumlahKursi}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusInfo = getStatusInfo();
    final statusText = statusInfo.$1;
    final statusColor = statusInfo.$2;

     return Container(
       padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status booking :', style: TextStyle(fontSize: 16)),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Chat Supir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(driver: Driver(name: booking.jadwal.supir.nama, licensePlate: booking.jadwal.angkot.platNomor))));
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[800],
          side: BorderSide(color: Colors.grey[400]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final bool isCancellable = booking.status == StatusBooking.menunggu_acc || booking.status == StatusBooking.diterima;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isCancellable ? () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Konfirmasi Pembatalan'),
                        content: const Text('Apakah Anda yakin ingin membatalkan booking ini?'),
                        actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Tidak'),
                            ),
                            TextButton(
                                onPressed: () {
                                    // Logika untuk membatalkan booking akan ada di sini.
                                    Navigator.of(context).pop(); 
                                    Navigator.of(context).pop(); 
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Booking berhasil dibatalkan!'))
                                    );
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Ya, Batalkan'),
                            ),
                        ],
                    );
                },
            );
        } : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: isCancellable ? Colors.red : Colors.grey,
          side: BorderSide(color: isCancellable ? Colors.red : Colors.grey),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Batalkan Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class JadwalAngkotCard extends StatelessWidget {
  final JadwalAngkot jadwal;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const JadwalAngkotCard({super.key, required this.jadwal, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus, size: 40, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jadwal.rute.namaRute, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
                      const SizedBox(height: 4),
                      Text('Driver: ${jadwal.supir.nama}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(Icons.event_seat, 'Sisa: ${jadwal.kursiTersedia} kursi'),
                _buildInfoRow(Icons.timer_outlined, 'Tiba: ${DateTime.now().difference(jadwal.waktuBerangkat).inMinutes.abs()} min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}

class DetailJadwalScreen extends StatelessWidget {
  final JadwalAngkot jadwal;

  const DetailJadwalScreen({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMainInfoCard(),
              const SizedBox(height: 16),
              _buildSecondaryInfoCard(),
              const SizedBox(height: 16),
              _buildRouteCard(context),
              const SizedBox(height: 16),
              _buildFareCard(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 50, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.angkot.platNomor,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                jadwal.rute.namaRute,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfoCard() {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Berangkat: ${jadwal.waktuBerangkat.hour}:${jadwal.waktuBerangkat.minute}'),
          const SizedBox(
            height: 20,
            child: VerticalDivider(color: Colors.grey),
          ),
          Text('${jadwal.kursiTersedia} Kursi Tersedia'),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteRow(Icons.circle_outlined, jadwal.rute.titikAwalText, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Container(
              height: 20,
              width: 2,
              color: Colors.grey[300],
            ),
          ),
          _buildRouteRow(Icons.location_on, jadwal.rute.titikAkhirText, Colors.red),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
  
  Widget _buildFareCard() {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tarif :', style: TextStyle(fontSize: 16)),
          Text('Rp ${jadwal.tarif.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KonfirmasiPemesananScreen(jadwal: jadwal),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pesan Kursi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
         SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat Supir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(driver: Driver(name: jadwal.supir.nama, licensePlate: jadwal.angkot.platNomor))));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[800],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LacakAngkotScreen extends StatelessWidget {
  final JadwalAngkot jadwal;
  const LacakAngkotScreen({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    final LatLng userPosition = const LatLng(-6.9088, 107.6186);
    final aktivitas = dummyAktivitasSupir.firstWhere((a) => a.idSupir == jadwal.supir.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Angkot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: aktivitas.lokasiTerakhir,
                initialZoom: 15,
              ),
              children: [
                 TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userPosition,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                    ),
                    Marker(
                      point: aktivitas.lokasiTerakhir,
                      width: 80,
                      height: 80,
                      child: Icon(Icons.directions_bus, color: Colors.blue[800], size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: _buildTrackingInfoCard(context),
            )
          )
        ],
      ),
    );
  }

  Widget _buildTrackingInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jadwal.rute.namaRute, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 40, color: Colors.grey),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Driver: ${jadwal.supir.nama}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Sisa Kursi: ${jadwal.kursiTersedia}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              "${DateTime.now().difference(jadwal.waktuBerangkat).inMinutes.abs()} Menit",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class KonfirmasiPemesananScreen extends StatelessWidget {
  final JadwalAngkot jadwal;
  const KonfirmasiPemesananScreen({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Konfirmasi Pemesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFareInfo(),
            const SizedBox(height: 24),
            _buildSeatInformation(),
            const Spacer(),
            _buildBookButton(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFareInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Ongkos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        Text(
          'Rp ${jadwal.tarif.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildSeatInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
          'Booking Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Route', '${jadwal.rute.namaRute}, Driver : ${jadwal.supir.nama}'),
        _buildInfoRow('Tujuan', jadwal.rute.titikAkhirText),
        _buildInfoRow('Sisa Kursi', jadwal.kursiTersedia.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildBookButton(BuildContext context) {
     return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Konfirmasi Pemesanan'),
                content: const Text('Anda akan memesan 1 kursi. Lanjutkan?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kursi berhasil dipesan!'))
                      );
                    },
                    child: const Text('Pesan'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Konfirmasi Pesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          height: 75,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', 0),
              _buildNavItem(context, Icons.receipt_long, 'Riwayat', 1),
              _buildNavItem(context, Icons.chat_bubble, 'Chat', 2),
              _buildNavItem(context, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[600];
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
