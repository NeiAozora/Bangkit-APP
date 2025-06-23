import 'package:flutter/material.dart';

// --- BAGIAN KONSTANTA & MODEL DATA ---

// Konstanta warna utama
const Color adminPrimaryColor = Color(0xFF4CAF50); // Hijau untuk admin
const Color adminSecondaryColor = Color(0xFF212121);
const Color adminBackgroundColor = Color(0xFFF5F5F5);

// Model data sederhana untuk Rute (Trayek)
class Rute {
  final int id;
  String nama;
  String titikAwal;
  String titikAkhir;
  String jalanDilewati;
  int kapasitas;

  Rute({
    required this.id,
    required this.nama,
    required this.titikAwal,
    required this.titikAkhir,
    required this.jalanDilewati,
    required this.kapasitas,
  });
}

// Model data sederhana untuk Supir
class Supir {
  final int id;
  String nama;
  String email;
  String nomorTelepon;
  String platNomor;

  Supir({
    required this.id,
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    required this.platNomor
  });
}

// Model data sederhana untuk Laporan Booking
class LaporanBooking {
  final int id;
  final String tanggal;
  final String namaRute;
  final String namaPelanggan;
  final String status;

  LaporanBooking({
    required this.id,
    required this.tanggal,
    required this.namaRute,
    required this.namaPelanggan,
    required this.status,
  });
}

// --- BAGIAN DATA TIRUAN (MOCK DATA) ---

class MockAdminData {
  static final List<Rute> mockRutes = [
    Rute(id: 1, nama: 'Trayek A', titikAwal: 'Kampus', titikAkhir: 'Alun-alun', jalanDilewati: 'Jl. Kalimantan, Jl. Jawa', kapasitas: 12),
    Rute(id: 2, nama: 'Trayek B', titikAwal: 'Terminal Tawang Alun', titikAkhir: 'Terminal Arjosari', jalanDilewati: 'Jl. Gajah Mada', kapasitas: 14),
    Rute(id: 3, nama: 'Trayek C', titikAwal: 'Polije', titikAkhir: 'Alun-alun', jalanDilewati: 'Jl. Mastrip', kapasitas: 12),
  ];

  static final List<Supir> mockSupirs = [
    Supir(id: 1, nama: 'Sumarto', email: 'sumarto@bangkit.com', nomorTelepon: '0811111111', platNomor: 'P 1234 XY'),
    Supir(id: 2, nama: 'Joko', email: 'joko@bangkit.com', nomorTelepon: '0822222222', platNomor: 'N 5678 ZA'),
    Supir(id: 3, nama: 'Bowo', email: 'bowo@bangkit.com', nomorTelepon: '0833333333', platNomor: 'L 9012 BC'),
    Supir(id: 4, nama: 'Zaka', email: 'zaka@bangkit.com', nomorTelepon: '0844444444', platNomor: 'W 3456 DE'),
  ];

  static final List<LaporanBooking> mockLaporans = [
    LaporanBooking(id: 1, tanggal: '23/06/2025', namaRute: 'Trayek A', namaPelanggan: 'Budi', status: 'Selesai'),
    LaporanBooking(id: 2, tanggal: '23/06/2025', namaRute: 'Trayek B', namaPelanggan: 'Citra', status: 'Selesai'),
    LaporanBooking(id: 3, tanggal: '22/06/2025', namaRute: 'Trayek A', namaPelanggan: 'Dewi', status: 'Dibatalkan'),
  ];
}


// --- BAGIAN UI (HALAMAN & WIDGET) ---

// Halaman Login Admin
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: adminPrimaryColor),
              const SizedBox(height: 16),
              const Text(
                'Panel Admin Bangkit',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: adminSecondaryColor),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Admin',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminHomePage()),
                  );
                },
                child: const Text('MASUK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Utama Admin dengan Bottom Navigation
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const RuteTab(),
    const SupirTab(),
    const LaporanTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: adminPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: adminPrimaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Rute'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Supir'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Laporan'),
        ],
      ),
    );
  }
}


// --- KONTEN UNTUK SETIAP TAB ---

// 1. Tab Dashboard (PERUBAHAN: Menambahkan Total Pendapatan)
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Ringkasan Sistem', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Kartu baru untuk total pendapatan
        _buildSummaryCard('Total Pendapatan Hari Ini', 'Rp 1.250.000', Icons.monetization_on, Colors.purple),
        _buildSummaryCard('Total Rute Aktif', '12', Icons.route, Colors.blue),
        _buildSummaryCard('Total Angkot Terdaftar', '26', Icons.directions_bus, Colors.orange),
        _buildSummaryCard('Total Driver Aktif', '19', Icons.person, Colors.green),
        const SizedBox(height: 24),
        const Text('Aksi Cepat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditRutePage())),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Rute Baru'),
          style: ElevatedButton.styleFrom(
            backgroundColor: adminPrimaryColor, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16)
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}


// 2. Tab Rute (Daftar Trayek)
class RuteTab extends StatefulWidget {
  const RuteTab({super.key});

  @override
  State<RuteTab> createState() => _RuteTabState();
}

class _RuteTabState extends State<RuteTab> {
  final List<Rute> _rutes = MockAdminData.mockRutes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackgroundColor,
      body: ListView.builder(
        itemCount: _rutes.length,
        itemBuilder: (context, index) {
          final rute = _rutes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(rute.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${rute.titikAwal} - ${rute.titikAkhir}'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditRutePage(rute: rute)),
                );
                if (result != null && result is Rute) {
                  setState(() {
                    _rutes[index] = result;
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditRutePage()),
          );
          if (result != null && result is Rute) {
            setState(() {
              _rutes.add(result);
            });
          }
        },
        backgroundColor: adminPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


// 3. Tab Supir (Fitur Tambah Supir ditambahkan)
class SupirTab extends StatefulWidget {
  const SupirTab({super.key});

  @override
  State<SupirTab> createState() => _SupirTabState();
}

class _SupirTabState extends State<SupirTab> {
  final List<Supir> _supirs = MockAdminData.mockSupirs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackgroundColor,
      body: ListView.builder(
        itemCount: _supirs.length,
        itemBuilder: (context, index) {
          final supir = _supirs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person_pin_circle, size: 40),
              title: Text(supir.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Plat: ${supir.platNomor}'),
              onTap: () async {
                 final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditSupirPage(supir: supir)),
                );
                if (result != null && result is Supir) {
                  setState(() {
                    _supirs[index] = result;
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditSupirPage()),
          );
          if (result != null && result is Supir) {
            setState(() {
              _supirs.add(result);
            });
          }
        },
        backgroundColor: adminPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        heroTag: 'tambahSupir',
      ),
    );
  }
}

// 4. Tab Laporan
class LaporanTab extends StatelessWidget {
  const LaporanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final laporans = MockAdminData.mockLaporans;
    return Scaffold(
      backgroundColor: adminBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(child: Text('Filter Tanggal:', style: TextStyle(fontWeight: FontWeight.bold))),
                TextButton(
                  onPressed: () {},
                  child: const Text('23 Mei 2025'),
                ),
                const Icon(Icons.calendar_today)
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: laporans.length,
              itemBuilder: (context, index) {
                final laporan = laporans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${laporan.namaPelanggan} - ${laporan.namaRute}'),
                    subtitle: Text('Tanggal: ${laporan.tanggal}'),
                    trailing: Chip(
                      label: Text(laporan.status),
                      backgroundColor: laporan.status == 'Selesai' ? Colors.green.shade100 : Colors.red.shade100,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// --- HALAMAN FORM ---

// Halaman Tambah/Ubah Rute
class EditRutePage extends StatefulWidget {
  final Rute? rute;
  const EditRutePage({super.key, this.rute});

  @override
  State<EditRutePage> createState() => _EditRutePageState();
}

class _EditRutePageState extends State<EditRutePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _awalController;
  late TextEditingController _akhirController;
  late TextEditingController _jalanController;
  late TextEditingController _kapasitasController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.rute?.nama ?? '');
    _awalController = TextEditingController(text: widget.rute?.titikAwal ?? '');
    _akhirController = TextEditingController(text: widget.rute?.titikAkhir ?? '');
    _jalanController = TextEditingController(text: widget.rute?.jalanDilewati ?? '');
    _kapasitasController = TextEditingController(text: widget.rute?.kapasitas.toString() ?? '');
  }
  
  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final ruteBaru = Rute(
        id: widget.rute?.id ?? DateTime.now().millisecondsSinceEpoch,
        nama: _namaController.text,
        titikAwal: _awalController.text,
        titikAkhir: _akhirController.text,
        jalanDilewati: _jalanController.text,
        kapasitas: int.parse(_kapasitasController.text),
      );
      Navigator.pop(context, ruteBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rute == null ? 'Tambah Rute Baru' : 'Ubah Rute'),
        backgroundColor: adminPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_namaController, 'Nama Trayek (Contoh: Trayek A)'),
              _buildTextFormField(_awalController, 'Titik Awal'),
              _buildTextFormField(_akhirController, 'Titik Akhir'),
              _buildTextFormField(_jalanController, 'Jalan yang Dilewati'),
              _buildTextFormField(_kapasitasController, 'Kapasitas Maksimal', keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                child: const Text('SIMPAN'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}


// Halaman Tambah/Ubah Supir (BARU)
class EditSupirPage extends StatefulWidget {
  final Supir? supir;
  const EditSupirPage({super.key, this.supir});

  @override
  State<EditSupirPage> createState() => _EditSupirPageState();
}

class _EditSupirPageState extends State<EditSupirPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _platController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.supir?.nama ?? '');
    _emailController = TextEditingController(text: widget.supir?.email ?? '');
    _teleponController = TextEditingController(text: widget.supir?.nomorTelepon ?? '');
    _platController = TextEditingController(text: widget.supir?.platNomor ?? '');
    _passwordController = TextEditingController(); // Password selalu kosong di awal
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final supirBaru = Supir(
        id: widget.supir?.id ?? DateTime.now().millisecondsSinceEpoch,
        nama: _namaController.text,
        email: _emailController.text,
        nomorTelepon: _teleponController.text,
        platNomor: _platController.text,
      );
      // Di aplikasi nyata, data password akan dikirim ke server di sini.
      Navigator.pop(context, supirBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supir == null ? 'Tambah Supir Baru' : 'Ubah Data Supir'),
        backgroundColor: adminPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_namaController, 'Nama Lengkap Supir'),
              _buildTextFormField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              _buildTextFormField(_teleponController, 'Nomor Telepon', keyboardType: TextInputType.phone),
              _buildTextFormField(_platController, 'Plat Nomor Angkot'),
              _buildTextFormField(_passwordController, 'Password', isPassword: true, isRequired: widget.supir == null),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                child: const Text('SIMPAN'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {TextInputType? keyboardType, bool isPassword = false, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label tidak boleh kosong';
          }
          if (isPassword && isRequired && value!.length < 6) {
            return 'Password minimal 6 karakter';
          }
          return null;
        },
      ),
    );
  }
}
