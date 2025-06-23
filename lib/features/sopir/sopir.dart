import 'package:bangkit/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../admin/admin.dart'; // Impor file admin.dart untuk navigasi

// Konstanta warna utama bisa disimpan di sini untuk kemudahan akses dalam file ini.
const Color primaryColor = Color(0xFFFFC107);
const Color secondaryColor = Color(0xFF212121);
const Color accentColor = Color(0xFFFFD60A);


// --- BAGIAN MODEL DATA (Disesuaikan dengan Skema SQL) ---

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
  final String lokasiJemput; // Diambil dari POINT
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


// --- BAGIAN DATA TIRUAN (MOCK DATA Diperbarui) ---
class MockData {
  static final List<Booking> mockBookings = [
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
}


// --- BAGIAN UI (HALAMAN & WIDGET) ---

// Halaman Utama Sopir
class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;
  
  static final List<Widget> _widgetOptions = <Widget>[
    const BerandaTab(),
    const PesananTab(),
    ProfilTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Beranda Sopir';
      case 1:
        return 'Daftar Pesanan';
      case 2:
        return 'Profil Saya';
      default:
        return 'Bangkit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Tab Beranda
class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  AktivitasStatus _statusSopir = AktivitasStatus.tersedia;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: accentColor.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status Aktivitas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                DropdownButton<AktivitasStatus>(
                  value: _statusSopir,
                  onChanged: (AktivitasStatus? newValue) {
                    setState(() {
                      _statusSopir = newValue!;
                    });
                  },
                  underline: const SizedBox(),
                  items: AktivitasStatus.values
                      .map<DropdownMenuItem<AktivitasStatus>>((AktivitasStatus value) {
                    return DropdownMenuItem<AktivitasStatus>(
                      value: value,
                      child: Text(
                        value.name.replaceAll('_', ' ').replaceFirstMapped(
                          RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase()
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        const Text('Laporan Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: [
            _buildSummaryCard('Total Pendapatan', 'Rp 250.000', Icons.account_balance_wallet_outlined, context),
            _buildSummaryCard('Total Penumpang', '35 Orang', Icons.groups_outlined, context),
            _buildSummaryCard('Total Perjalanan', '8 Kali', Icons.route_outlined, context),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Informasi Angkot & Rute', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.route, color: primaryColor, size: 40),
            title: const Text('Rute Aktif Saat Ini'),
            subtitle: const Text('Terminal Arjosari - Pasar Besar'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.directions_bus_filled, color: primaryColor, size: 40),
            title: const Text('Plat Nomor Angkot'),
            subtitle: const Text('N 1234 ABC'),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.black54, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: secondaryColor
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tab Pesanan
class PesananTab extends StatefulWidget {
  const PesananTab({super.key});

  @override
  State<PesananTab> createState() => _PesananTabState();
}

class _PesananTabState extends State<PesananTab> {
  late List<Booking> bookings;

  @override
  void initState() {
    super.initState();
    bookings = List.from(MockData.mockBookings);
  }

  void _updateBookingStatus(int bookingId, BookingStatus newStatus) {
    setState(() {
      final index = bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        bookings[index].status = newStatus;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final pesananMenunggu = bookings.where((b) => b.status == BookingStatus.menunggu_acc).toList();
    final pesananDiterima = bookings.where((b) => b.status == BookingStatus.diterima).toList();
    final pesananLainnya = bookings.where((b) => b.status != BookingStatus.menunggu_acc && b.status != BookingStatus.diterima).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: secondaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Diterima'),
              Tab(text: 'Riwayat'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookingList(pesananMenunggu, 'Tidak ada pesanan baru.'),
                _buildBookingList(pesananDiterima, 'Belum ada pesanan yang diterima.'),
                _buildBookingList(pesananLainnya, 'Riwayat pesanan masih kosong.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookingList, String emptyMessage) {
    if (bookingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: bookingList.length,
      itemBuilder: (context, index) {
        final booking = bookingList[index];
        return BookingCard(
          booking: booking,
          onAccept: () => _updateBookingStatus(booking.id, BookingStatus.diterima),
          onReject: () => _updateBookingStatus(booking.id, BookingStatus.ditolak),
          onFinish: () => _updateBookingStatus(booking.id, BookingStatus.selesai),
        );
      },
    );
  }
}

// Tab Profil
class ProfilTab extends StatelessWidget {
  ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          children: [
             CircleAvatar(
              radius: 50,
              backgroundImage: const NetworkImage('https://placehold.co/150x150/FFC107/000000?text=Sopir'),
              onBackgroundImageError: (exception, stackTrace) {},
              backgroundColor: primaryColor,
            ),
            const SizedBox(height: 12),
            const Text('Ahmad Fauzan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('ahmad.fauzan@sopir.bangkit.com', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Ubah Profil'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Ganti Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
               const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Riwayat Perjalanan'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () {
               Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                );
            },
          ),
        ),
      ],
    );
  }
}

// Widget BookingCard
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onFinish;

  const BookingCard({
    super.key,
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(booking.pelanggan.fotoProfilUrl),
                  onBackgroundImageError: (exception, stackTrace) {},
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.pelanggan.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rute: ${booking.namaRute}', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.location_on_outlined, 'Jemput', booking.lokasiJemput),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.access_time, 'Waktu', booking.waktuBerangkat),
            const SizedBox(height: 4),
            _buildPaymentStatus(booking.pembayaranStatus),
            if (booking.status == BookingStatus.menunggu_acc || booking.status == BookingStatus.diterima)
            const Divider(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildPaymentStatus(PembayaranStatus status) {
    final bool isPaid = status == PembayaranStatus.sudah_bayar;
    return Row(
      children: [
        Icon(
          isPaid ? Icons.check_circle : Icons.error,
          color: isPaid ? Colors.green : Colors.orange,
          size: 18,
        ),
        const SizedBox(width: 8),
        const Text('Pembayaran: ', style: TextStyle(fontWeight: FontWeight.w600)),
        Text(
          isPaid ? 'Sudah Bayar' : 'Belum Bayar',
          style: TextStyle(color: isPaid ? Colors.green : Colors.orange),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    if (booking.status == BookingStatus.menunggu_acc) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Tolak'),
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Terima'),
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    if (booking.status == BookingStatus.diterima) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.message_outlined),
              label: const Text('Chat'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: secondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Selesaikan'),
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusChip(BookingStatus status) {
    String text;
    Color color;
    switch (status) {
      case BookingStatus.menunggu_acc:
        text = 'Menunggu';
        color = Colors.orange;
        break;
      case BookingStatus.diterima:
        text = 'Diterima';
        color = Colors.green;
        break;
      case BookingStatus.ditolak:
        text = 'Ditolak';
        color = Colors.red;
        break;
      case BookingStatus.selesai:
        text = 'Selesai';
        color = Colors.blue;
        break;
      case BookingStatus.dibatalkan:
        text = 'Dibatalkan';
        color = Colors.grey;
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      side: BorderSide.none,
    );
  }
}
