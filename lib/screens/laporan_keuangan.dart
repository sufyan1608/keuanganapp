import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CatatanKeuanganPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class CatatanKeuanganPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Color(0xFF7B84AD),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "laporan keuangan",
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTab("pemasukan", false),
                      _buildTab("pengeluaran", false),
                      _buildTab("catatan keuangan", true),
                    ],
                  ),
                ],
              ),
            ),

            // Laporan dan siklus
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFFF2F3F7),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("siklus laporan kamu saat ini"),
                      TextButton(
                        onPressed: () {},
                        child: Text("ubah siklus"),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "1 Mei - 28 Mei 2025",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Filter waktu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTab("bulan ini", true),
                      _buildTab("bulan lalu", false),
                      _buildTab("3 bulan", false),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Selisih", style: TextStyle(color: Colors.black54)),
                  Text("-Rp 43.000", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  Divider(height: 30, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.green),
                              SizedBox(width: 5),
                              Text("pemasukan", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          Text("Rp 2.500.000", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.red),
                              SizedBox(width: 5),
                              Text("pengeluaran", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          Text("-Rp 2.543.000", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
