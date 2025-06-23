import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

// Import yang diperlukan dari file service dan model Anda.
// Pastikan path ini sesuai dengan struktur proyek Anda.
import 'package:bangkit/core/services/auth_service.dart';
import 'package:bangkit/core/services/penumpang_service.dart';
import 'package:bangkit/core/models/pelangan/models.dart';


// ===================================================================
// INISIALISASI SERVICE YANG DIPERBAIKI
// ===================================================================

// 'authService' sekarang adalah instance global tunggal dari auth_service.dart.
final AuthService authService = AuthService();
final AngkotService angkotService = AngkotService();
final AuthServiceLokalPenumpang authServicelokal = AuthServiceLokalPenumpang();

// Service berikut memerlukan 'authService' saat diinisialisasi.
final BookingService bookingService = BookingService(authService: authServicelokal);
final ChatService chatService = ChatService(authService: authServicelokal);
final NotificationService notificationService = NotificationService(authService: authServicelokal);


// ===================================================================
// APLIKASI UTAMA (WIDGET ROOT)
// ===================================================================


// ===================================================================
// Halaman Utama (HomeScreen)
// ===================================================================
class PenumpangHomeScreen extends StatefulWidget {
  // [PERBAIKAN]: Parameter 'onProfileIconTapped' telah dihapus sesuai permintaan.
  const PenumpangHomeScreen({super.key});

  @override
  State<PenumpangHomeScreen> createState() => _PenumpangHomeScreenState();
}

class _PenumpangHomeScreenState extends State<PenumpangHomeScreen> {
  final MapController _mapController = MapController();
  // FIXME: Dapatkan lokasi pengguna asli dari GPS, bukan hardcoded.
  final LatLng _userLocation = const LatLng(-6.9088, 107.6186);

  int? _selectedJadwalIndex;

  // State untuk menampung data dari service
  List<JadwalAngkot> _availableSchedules = [];
  List<AktivitasSupir> _driverActivities = [];

  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _loadData();
  }

  // Fungsi untuk memuat data asli dari service
  Future<void> _loadData() async {
    try {
      // Memanggil service asli untuk mendapatkan data dari database
      final results = await Future.wait([
        angkotService.getAvailableSchedules(),
        angkotService.getAllDriverActivities(),
      ]);
      if(mounted) {
      if(mounted) {
        setState(() {
          // [PERBAIKAN]: Menambahkan cast eksplisit untuk mengatasi error tipe data.
          _availableSchedules = results[0] as List<JadwalAngkot>;
          _driverActivities = results[1] as List<AktivitasSupir>;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    }
  }

  void _showAngkotRoute(int index) {
    if (index >= _availableSchedules.length) return;

    setState(() {
      _selectedJadwalIndex = index;
    });

    final jadwal = _availableSchedules[index];
    final aktivitas = _driverActivities.firstWhere(
      (a) => a.idSupir == jadwal.supir.id,
      // Fallback jika aktivitas supir tidak ditemukan, untuk mencegah error.
      orElse: () => AktivitasSupir(id: 0, idSupir: jadwal.supir.id, lokasiTerakhir: jadwal.rute.koordinatAwal, status: StatusAktivitasSupir.tidak_aktif, terakhirUpdate: DateTime.now())
    );
    _mapController.move(aktivitas.lokasiTerakhir, 14.5);
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder(
          future: _dataLoadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _availableSchedules.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Gagal memuat data. Tarik ke bawah untuk mencoba lagi.\nError: ${snapshot.error}", textAlign: TextAlign.center),
                ),
              );
            }

            return Stack(
              children: [
                _buildMapView(),
                _buildAngkotListPanel(),
              ],
            );
          },
        ),
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
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
          },
        ),
        // IconButton untuk profil dihapus.
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMapView() {
    List<Marker> markers = [
      Marker(
        point: _userLocation,
        child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      ),
      ..._driverActivities.map((aktivitas) => Marker(
            point: aktivitas.lokasiTerakhir,
            child: Icon(Icons.directions_bus, color: Colors.blue[800], size: 35),
          )),
    ];

    List<Polyline> polylines = [];

    if (_selectedJadwalIndex != null && _selectedJadwalIndex! < _availableSchedules.length) {
      final jadwal = _availableSchedules[_selectedJadwalIndex!];
      final aktivitas = _driverActivities.firstWhere((a) => a.idSupir == jadwal.supir.id, orElse: () => AktivitasSupir(id: 0, idSupir: jadwal.supir.id, lokasiTerakhir: jadwal.rute.koordinatAwal, status: StatusAktivitasSupir.tidak_aktif, terakhirUpdate: DateTime.now()));

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
              if (_availableSchedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("Tidak ada angkot yang tersedia saat ini.")),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _availableSchedules.length,
                  itemBuilder: (context, index) {
                    final jadwal = _availableSchedules[index];
                    return JadwalAngkotCard(
                      jadwal: jadwal,
                      onTap: () {
                        // Navigasi ke DetailJadwalScreen, yang definisinya ada di bawah.
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailJadwalScreen(jadwal: jadwal)));
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
// Halaman Profil (ProfileScreen)
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
      body: StreamBuilder<AppUser?>(
        stream: authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Anda tidak login."));
          }
          
          final currentUser = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: currentUser.fotoProfil != null ? NetworkImage(currentUser.fotoProfil!) : null,
                  child: currentUser.fotoProfil == null ? const Icon(Icons.person, size: 80, color: Color(0xFFBDBDBD)) : null,
                ),
                const SizedBox(height: 24),
                Text(currentUser.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(currentUser.email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 48),
                _buildProfileButton(context, text: 'Ubah Profile', onPressed: () => showDialog(context: context, builder: (c) => EditProfileDialog(currentUser: currentUser))),
                _buildProfileButton(context, text: 'Ganti Password', onPressed: () => showDialog(context: context, builder: (c) => const ChangePasswordDialog())),
                _buildProfileButton(context, text: 'Logout', onPressed: () => showDialog(context: context, builder: (c) => const LogoutConfirmationDialog())),
              ],
            ),
          );
        },
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ===================================================================
// Dialog dan Widget Lainnya
// ===================================================================

class EditProfileDialog extends StatefulWidget {
  final AppUser currentUser;
  const EditProfileDialog({super.key, required this.currentUser});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.nama);
    _emailController = TextEditingController(text: widget.currentUser.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
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
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _submitUpdate() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // FIXME: Logika upload gambar harus diimplementasikan di sini.
    // Anda harus meng-upload `_image` ke server/storage Anda,
    // lalu dapatkan URL-nya. Untuk saat ini, kita kirim path lokal (tidak akan bekerja di app asli).
    final String? imagePath = _image?.path; 

    try {
      final success = await authService.updateProfile(
        nama: _nameController.text,
        email: _emailController.text,
        fotoProfilPath: imagePath, // FIXME: Ini harusnya URL setelah upload.
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
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
                    backgroundImage: _image != null 
                      ? FileImage(_image!) 
                      : (widget.currentUser.fotoProfil != null ? NetworkImage(widget.currentUser.fotoProfil!) : null) as ImageProvider?,
                    child: (_image == null && widget.currentUser.fotoProfil == null) ? Icon(Icons.person, size: 50, color: Colors.grey[400]) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showPicker(context),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nama Pengguna', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
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
                  onPressed: _submitUpdate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)) : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak sama')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
        final success = await authService.changePassword(_newPasswordController.text);
        if(success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah.')));
          Navigator.of(context).pop();
        }
    } catch(e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        }
    } finally {
        if(mounted) {
            setState(() => _isLoading = false);
        }
    }
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
            const Text('Ganti Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              obscureText: true,
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitChangePassword,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan', style: TextStyle(color: Colors.white))),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Apakah anda yakin ingin logout?', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black54, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Tidak'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    authService.signOut();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Driver>>(
        future: chatService.getActiveChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Gagal memuat chat: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada percakapan."));
          }
          final drivers = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              // FIXME: 'bookingId' tidak bisa didapatkan dari sini.
              // Service `getActiveChats` hanya mengembalikan List<Driver>.
              // Seharusnya service mengembalikan data yang menyertakan `bookingId`
              // agar bisa memulai chat yang benar. Untuk sementara, ID palsu (0) digunakan.
              return DriverChatCard(driver: drivers[index], bookingId: 0); 
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        },
      ),
    );
  }
}

class DriverChatCard extends StatelessWidget {
  final Driver driver;
  final int bookingId;
  const DriverChatCard({super.key, required this.driver, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (bookingId == 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak dapat memulai chat, ID Booking tidak ditemukan.")));
            return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(driver: driver, bookingId: bookingId,))); 
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 28, color: Colors.grey[500])),
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
  final int bookingId; 

  const ChatScreen({super.key, required this.driver, required this.bookingId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = authService.currentUser; // Get from synchronous property
      final messages = await chatService.getChatMessages(widget.bookingId);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _messages.addAll(messages);
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat pesan: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _currentUser == null) return;
    
    final messageText = text;
    _textController.clear();
    
    final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        idBooking: widget.bookingId,
        idPengirim: _currentUser!.id,
        pesan: messageText,
        waktuKirim: DateTime.now(),
        isSentByUser: true);

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      await chatService.sendMessage(
        bookingId: widget.bookingId, 
        pesan: messageText, 
        penerimaId: widget.driver.id
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim pesan.")));
        // Optional: remove the message or show a failure icon
        setState(() {
          _messages.remove(tempMessage);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver ${widget.driver.name}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: true, // Show latest messages at the bottom
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = _messages.length - 1 - index;
                      return _buildMessageBubble(_messages[reversedIndex], _currentUser?.id ?? 0);
                    },
                  ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, int currentUserId) {
    final bool isSentByUser = message.idPengirim == currentUserId;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isSentByUser ? Colors.amber[100] : Colors.white,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Text(message.pesan, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 5, color: Colors.grey.withAlpha(50))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
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
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: FutureBuilder<List<Notifikasi>>(
        future: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat notifikasi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada notifikasi baru."));
          }
          final notifications = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(notification: notifications[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        },
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Icon(Icons.notifications, color: Colors.amber.shade700, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(notification.isi, style: TextStyle(color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('${DateTime.now().difference(notification.waktu).inMinutes} menit yang lalu', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Booking>>(
        future: bookingService.getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat riwayat: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada riwayat booking."));
          }
          final bookings = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailScreen(booking: booking)));
                },
                borderRadius: BorderRadius.circular(16),
                child: BookingHistoryCard(booking: booking),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        },
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
    final (statusText, statusColor) = getStatusInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
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
                    Expanded(child: Text(booking.jadwal.rute.namaRute, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${booking.waktuBooking.day}/${booking.waktuBooking.month}/${booking.waktuBooking.year}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Text('Dari ${booking.jadwal.rute.titikAwalText}', style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                Text('Ke ${booking.jadwal.rute.titikAkhirText}', style: TextStyle(color: Colors.grey[800], fontSize: 14)),
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
    final statusInfo = getStatusInfo();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Booking'),
      ),
      body: SingleChildScrollView(
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
            _buildStatusCard(statusInfo),
            const SizedBox(height: 32),
            _buildActionButton(context),
            const SizedBox(height: 12),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 50, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.jadwal.angkot.platNomor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(booking.jadwal.rute.namaRute, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Waktu: ${booking.waktuBooking.hour}:${booking.waktuBooking.minute}'),
          const SizedBox(height: 20, child: VerticalDivider(color: Colors.grey)),
          Text('${booking.jumlahKursi} Kursi Dipesan'),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteRow(Icons.circle_outlined, booking.jadwal.rute.titikAwalText, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Container(height: 20, width: 2, color: Colors.grey[300]),
          ),
          _buildRouteRow(Icons.location_on, booking.jadwal.rute.titikAkhirText, Colors.red),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jam Operasional: ${booking.jadwal.waktuBerangkat.hour}:00 - 21:00', style: TextStyle(color: Colors.grey[700])),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Tarif:', style: TextStyle(fontSize: 16)),
          Text('Rp ${booking.jadwal.tarif * booking.jumlahKursi}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusCard((String, Color) statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status booking :', style: TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusInfo.$2, borderRadius: BorderRadius.circular(12)),
            child: Text(statusInfo.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
            driver: Driver(
              id: booking.jadwal.supir.id,
              name: booking.jadwal.supir.nama,
              licensePlate: booking.jadwal.angkot.platNomor
            ),
            bookingId: booking.id,
          )));
        },
        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[800], side: BorderSide(color: Colors.grey[400]!), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tidak')),
                  TextButton(
                    onPressed: () {
                      bookingService.cancelBooking(booking.id).then((success) {
                        if (success && context.mounted) {
                          Navigator.of(context).pop(); 
                          Navigator.of(context).pop(); 
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil dibatalkan!')));
                        }
                      });
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Ya, Batalkan'),
                  ),
                ],
              );
            },
          );
        } : null,
        style: OutlinedButton.styleFrom(foregroundColor: isCancellable ? Colors.red : Colors.grey, side: BorderSide(color: isCancellable ? Colors.red : Colors.grey), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
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
      ),
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 50, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jadwal.angkot.platNomor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(jadwal.rute.namaRute, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Berangkat: ${jadwal.waktuBerangkat.hour}:${jadwal.waktuBerangkat.minute}'),
          const SizedBox(height: 20, child: VerticalDivider(color: Colors.grey)),
          Text('${jadwal.kursiTersedia} Kursi Tersedia'),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteRow(Icons.circle_outlined, jadwal.rute.titikAwalText, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Container(height: 20, width: 2, color: Colors.grey[300]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 10, offset: const Offset(0, 4))]),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => KonfirmasiPemesananScreen(jadwal: jadwal)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
               // FIXME: Memulai chat dari sini tidak memiliki `bookingId`.
               // Service `sendMessage` memerlukan `bookingId`. 
               // Desain aplikasi mungkin perlu direvisi agar chat hanya bisa dimulai dari riwayat booking.
               // Untuk sementara, navigasi tetap dilakukan dengan ID palsu.
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                driver: Driver(
                  id: jadwal.supir.id,
                  name: jadwal.supir.nama,
                  licensePlate: jadwal.angkot.platNomor
                ), 
                bookingId: 0,
              )));
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[800], side: BorderSide(color: Colors.grey[400]!), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
    // FIXME: Dapatkan lokasi pengguna asli dari GPS.
    final LatLng userPosition = const LatLng(-6.9088, 107.6186); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Angkot'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: StreamBuilder<AktivitasSupir>(
              stream: angkotService.trackAngkot(jadwal.supir.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text("Menghubungkan ke server..."));
                }
                if(!snapshot.hasData) {
                  return const Center(child: Text("Mencari lokasi supir..."));
                }
                if(snapshot.hasError) {
                    return Center(child: Text("Gagal melacak: ${snapshot.error}"));
                }
                
                final aktivitas = snapshot.data!;

                return FlutterMap(
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
                        Marker(point: userPosition, child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40)),
                        Marker(point: aktivitas.lokasiTerakhir, child: Icon(Icons.directions_bus, color: Colors.blue[800], size: 40)),
                      ],
                    ),
                  ],
                );
              }
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(50), blurRadius: 10, spreadRadius: 2)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(jadwal.rute.namaRute, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
            child: Text("${DateTime.now().difference(jadwal.waktuBerangkat).inMinutes.abs()} Menit",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class KonfirmasiPemesananScreen extends StatefulWidget {
  final JadwalAngkot jadwal;
  const KonfirmasiPemesananScreen({super.key, required this.jadwal});

  @override
  State<KonfirmasiPemesananScreen> createState() => _KonfirmasiPemesananScreenState();
}

class _KonfirmasiPemesananScreenState extends State<KonfirmasiPemesananScreen> {
  int _jumlahKursi = 1;
  bool _isLoading = false;

  void _increment() {
    if (_jumlahKursi < widget.jadwal.kursiTersedia) {
      setState(() {
        _jumlahKursi++;
      });
    }
  }

  void _decrement() {
    if (_jumlahKursi > 1) {
      setState(() {
        _jumlahKursi--;
      });
    }
  }
  
  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);

    // FIXME: Lokasi jemput harus didapatkan dari map atau input user.
    // Untuk saat ini, lokasi pengguna yang hardcoded digunakan sebagai placeholder.
    final LatLng lokasiJemput = const LatLng(-6.9088, 107.6186);

    try {
      final success = await bookingService.createBooking(
        jadwalId: widget.jadwal.id, 
        jumlahKursi: _jumlahKursi,
        lokasiJemput: lokasiJemput,
      );
      if(success && mounted){
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kursi berhasil dipesan!')));
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memesan: $e")));
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pemesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFareInfo(),
            const Divider(height: 32),
            _buildSeatInformation(),
            const Divider(height: 32),
            _buildSeatSelector(),
            const Spacer(),
            _buildBookButton(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFareInfo() {
    return _buildInfoRow(
      'Total Ongkos', 
      'Rp ${(widget.jadwal.tarif * _jumlahKursi).toStringAsFixed(0)}',
      isHeader: true,
    );
  }
  
  Widget _buildSeatInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informasi Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        _buildInfoRow('Rute', '${widget.jadwal.rute.namaRute}, Driver : ${widget.jadwal.supir.nama}'),
        _buildInfoRow('Tujuan', widget.jadwal.rute.titikAkhirText),
        _buildInfoRow('Sisa Kursi', widget.jadwal.kursiTersedia.toString()),
      ],
    );
  }

  Widget _buildSeatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jumlah Kursi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pilih jumlah kursi yang akan dipesan', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: Row(
                children: [
                  IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
                  Text(_jumlahKursi.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHeader = false}) {
    final valueStyle = isHeader 
        ? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold) 
        : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    final labelStyle = isHeader 
        ? const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
        : TextStyle(fontSize: 16, color: Colors.grey[700]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(width: 16),
          Flexible(child: Text(value, style: valueStyle, textAlign: TextAlign.right)),
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
              content: Text('Anda akan memesan $_jumlahKursi kursi. Lanjutkan?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog konfirmasi
                    _submitBooking();
                  },
                  child: const Text('Pesan'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text('Konfirmasi Pesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: Colors.transparent, boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20, spreadRadius: 5)]),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
