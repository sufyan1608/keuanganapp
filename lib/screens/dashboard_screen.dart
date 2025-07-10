import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pemasukan_screen.dart' as pemasukan;
import 'pengeluaran_screen.dart' as pengeluaran;
import 'catatan_screen.dart';
import 'profil_screen.dart';
import 'statistik_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  double totalPemasukan = 0;
  double totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final pemasukanRaw = await supabase
          .from('pemasukan')
          .select('jumlah')
          .eq('user_id', user.id);

      final pengeluaranRaw = await supabase
          .from('pengeluaran')
          .select('jumlah')
          .eq('user_id', user.id);

      final pemasukanData =
          pemasukanRaw.map((e) => (e['jumlah'] ?? 0) as num).toList();
      final pengeluaranData =
          pengeluaranRaw.map((e) => (e['jumlah'] ?? 0) as num).toList();

      setState(() {
        totalPemasukan = pemasukanData.fold(0, (sum, item) => sum + item);
        totalPengeluaran = pengeluaranData.fold(0, (sum, item) => sum + item);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memuat data')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double sisa = totalPemasukan - totalPengeluaran;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dashboard Keuangan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight + 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        "Pemasukan",
                        totalPemasukan,
                        Colors.green.shade50,
                        Colors.green.shade700,
                        LucideIcons.arrowDownCircle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoCard(
                        "Pengeluaran",
                        totalPengeluaran,
                        Colors.red.shade50,
                        Colors.red.shade700,
                        LucideIcons.arrowUpCircle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoCard(
                        "Sisa",
                        sisa,
                        Colors.blue.shade50,
                        Colors.blue.shade700,
                        LucideIcons.wallet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Menu Utama",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: LucideIcons.wallet,
                        label: "Pemasukan",
                        color: Colors.greenAccent.shade100,
                        destination: pemasukan.PemasukanScreen(),
                      ),
                      _buildMenuCard(
                        context,
                        icon: LucideIcons.creditCard,
                        label: "Pengeluaran",
                        color: Colors.redAccent.shade100,
                        destination: pengeluaran.PengeluaranScreen(),
                      ),
                      _buildMenuCard(
                        context,
                        icon: LucideIcons.clipboardList,
                        label: "Catatan",
                        color: Colors.amber.shade100,
                        destination: const CatatanScreen(),
                      ),
                      _buildMenuCard(
                        context,
                        icon: LucideIcons.pieChart,
                        label: "Statistik",
                        color: Colors.purple.shade100,
                        destination: const StatistikScreen(),
                      ),
                      _buildMenuCard(
                        context,
                        icon: LucideIcons.user,
                        label: "Profil",
                        color: Colors.blue.shade100,
                        destination: const ProfilScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    double value,
    Color bgColor,
    Color valueColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: valueColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rp ${(value.isNaN ? 0 : value).toStringAsFixed(0)}",
            style: GoogleFonts.poppins(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget destination,
  }) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
        fetchData(); // Refresh data setelah kembali dari menu lain
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 28,
              child: Icon(icon, color: Colors.black87, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
