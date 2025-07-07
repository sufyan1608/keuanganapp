import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  double totalPemasukan = 0;
  double totalPengeluaran = 0;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    var pemasukanQuery = supabase
        .from('pemasukan')
        .select('jumlah, tanggal')
        .eq('user_id', userId);
    var pengeluaranQuery = supabase
        .from('pengeluaran')
        .select('jumlah, tanggal')
        .eq('user_id', userId);

    if (selectedDateRange != null) {
      final start = selectedDateRange!.start.toIso8601String();
      final end = selectedDateRange!.end.toIso8601String();
      pemasukanQuery = pemasukanQuery.gte('tanggal', start).lte('tanggal', end);
      pengeluaranQuery = pengeluaranQuery
          .gte('tanggal', start)
          .lte('tanggal', end);
    }

    final pemasukanData = await pemasukanQuery;
    final pengeluaranData = await pengeluaranQuery;

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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        initialDateRange: selectedDateRange,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDateRange = picked;
                        });
                        await fetchData();
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      selectedDateRange == null
                          ? 'Pilih Rentang Tanggal'
                          : '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: fetchData,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
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
                      value: totalPemasukan > 0 ? totalPemasukan : 0,
                      title: 'Pemasukan',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: totalPengeluaran > 0 ? totalPengeluaran : 0,
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
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Grafik Batang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalPemasukan > 0 ? totalPemasukan : 0,
                          color: Colors.green,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalPengeluaran > 0 ? totalPengeluaran : 0,
                          color: Colors.red,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: sisa > 0 ? sisa : 0,
                          color: Colors.blue,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Pemasukan');
                            case 1:
                              return const Text('Pengeluaran');
                            case 2:
                              return const Text('Sisa');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
