import 'package:flutter/material.dart';
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
  double totalPemasukan = 0;
  double totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final supabase = Supabase.instance.client;
    try {
      final userId = supabase.auth.currentUser?.id;

      final pemasukanRaw = await supabase
          .from('pemasukan')
          .select('jumlah')
          .eq('user_id', userId);

      final pengeluaranRaw = await supabase
          .from('pengeluaran')
          .select('jumlah')
          .eq('user_id', userId);

      final pemasukanData =
          pemasukanRaw.map((e) => (e['jumlah'] ?? 0) as num).toList();
      final pengeluaranData =
          pengeluaranRaw.map((e) => (e['jumlah'] ?? 0) as num).toList();

      setState(() {
        totalPemasukan = pemasukanData.fold(0, (sum, item) => sum + item);
        totalPengeluaran = pengeluaranData.fold(0, (sum, item) => sum + item);
      });
    } catch (e) {
      print("Error fetchData: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double sisa = totalPemasukan - totalPengeluaran;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Keuangan"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    "Pemasukan",
                    totalPemasukan,
                    Colors.greenAccent.shade100,
                    Colors.green.shade700,
                    LucideIcons.arrowDownCircle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    "Pengeluaran",
                    totalPengeluaran,
                    Colors.redAccent.shade100,
                    Colors.red.shade700,
                    LucideIcons.arrowUpCircle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    "Sisa",
                    sisa,
                    Colors.blue.shade100,
                    Colors.blue.shade700,
                    LucideIcons.wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Menu Utama",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                    destination: pemasukan.PemasukanScreen(), // ✅ tanpa const
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
                    destination: CatatanScreen(), // ✅ tanpa const
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.pieChart,
                    label: "Statistik",
                    color: Colors.purple.shade100,
                    destination:
                        const StatistikScreen(), // jika konstruktor const
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.user,
                    label: "Profil",
                    color: Colors.blue.shade100,
                    destination: const ProfilScreen(), // jika konstruktor const
                  ),
                ],
              ),
            ),
          ],
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
            color: Colors.black12.withOpacity(0.1),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rp ${(value.isNaN ? 0 : value).toStringAsFixed(0)}",
            style: TextStyle(
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
        fetchData();
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
