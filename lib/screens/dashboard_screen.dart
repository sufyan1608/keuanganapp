import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'pemasukan_screen.dart';
import 'pengeluaran_screen.dart';
import 'catatan_screen.dart';
import 'profil_screen.dart';
import 'laporan_keuangan.dart';

class DashboardScreen extends StatelessWidget {
  final double pemasukan = 5000000;
  final double pengeluaran = 2100000;

  @override
  Widget build(BuildContext context) {
    double sisa = pemasukan - pengeluaran;

    return Scaffold(
      appBar: AppBar(title: Text("Hai, aku!"), backgroundColor: Colors.teal),
      backgroundColor: Color(0xFFF4F7FE),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard(
                  "pemasukan",
                  pemasukan,
                  Colors.teal.shade100,
                  Colors.teal,
                ),
                _buildInfoCard(
                  "Pengeluaran",
                  pengeluaran,
                  Colors.red.shade100,
                  Colors.red,
                ),
                _buildInfoCard(
                  "Sisa",
                  sisa,
                  Colors.green.shade100,
                  Colors.green,
                ),
              ],
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.wallet,
                    label: "Pemasukan",
                    color: Colors.teal.shade100,
                    destination: PemasukanScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.creditCard,
                    label: "Pengeluaran",
                    color: Colors.red.shade100,
                    destination: PengeluaranScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.clipboardList,
                    label: "Catatan",
                    color: Colors.amber.shade100,
                    destination: CatatanScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.pieChart,
                    label: "Statistik",
                    color: Colors.purple.shade100,
                    destination: PlaceholderScreen(title: "Statistik"),
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.user,
                    label: "Profil",
                    color: Colors.blue.shade100,
                    destination: ProfilScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    icon: LucideIcons.book,
                    label: "Laporan",
                    color: const Color.fromARGB(255, 192, 251, 187),
                    destination: LaporanKeuanganPage(),
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
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Rp ${value.toStringAsFixed(0)}",
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Halaman $title")),
    );
  }
}
