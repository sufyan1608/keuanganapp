import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  double totalPemasukan = 0;
  double totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    final pemasukanData = await supabase
        .from('pemasukan')
        .select('jumlah')
        .eq('user_id', userId);

    final pengeluaranData = await supabase
        .from('pengeluaran')
        .select('jumlah')
        .eq('user_id', userId);

    setState(() {
      totalPemasukan = pemasukanData
          .map((e) => (e['jumlah'] as num).toDouble())
          .fold(0, (a, b) => a + b);
      totalPengeluaran = pengeluaranData
          .map((e) => (e['jumlah'] as num).toDouble())
          .fold(0, (a, b) => a + b);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sisa = totalPemasukan - totalPengeluaran;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Keuangan'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSummaryCard("Pemasukan", totalPemasukan, Colors.green),
                _buildSummaryCard("Pengeluaran", totalPengeluaran, Colors.red),
                _buildSummaryCard("Sisa", sisa, Colors.blue),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Diagram Pie",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: totalPemasukan,
                      title: 'Pemasukan',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: totalPengeluaran,
                      title: 'Pengeluaran',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: sisa > 0 ? sisa : 0,
                      title: 'Sisa',
                      color: Colors.blue,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend("Pemasukan", Colors.green),
                _buildLegend("Pengeluaran", Colors.red),
                _buildLegend("Sisa", Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Rp ${value.toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}