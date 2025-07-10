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
  final supabase = Supabase.instance.client;

  double totalPemasukan = 0;
  double totalPengeluaran = 0;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final start = selectedDateRange?.start.toIso8601String();
      final end = selectedDateRange?.end.toIso8601String();

      var pemasukanQuery = supabase
          .from('pemasukan')
          .select('jumlah, tanggal')
          .eq('user_id', userId);

      var pengeluaranQuery = supabase
          .from('pengeluaran')
          .select('jumlah, tanggal')
          .eq('user_id', userId);

      if (selectedDateRange != null) {
        pemasukanQuery = pemasukanQuery
            .gte('tanggal', start!)
            .lte('tanggal', end!);

        pengeluaranQuery = pengeluaranQuery
            .gte('tanggal', start)
            .lte('tanggal', end);
      }

      final pemasukanData = await pemasukanQuery;
      final pengeluaranData = await pengeluaranQuery;

      setState(() {
        totalPemasukan = pemasukanData.fold(
          0.0,
          (sum, item) => sum + (item['jumlah'] as num).toDouble(),
        );
        totalPengeluaran = pengeluaranData.fold(
          0.0,
          (sum, item) => sum + (item['jumlah'] as num).toDouble(),
        );
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data statistik.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sisa = totalPemasukan - totalPengeluaran;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Statistik Keuangan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
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
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: fetchData,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Diagram Pie"),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        _buildPieSection(
                          totalPemasukan,
                          'Pemasukan',
                          Colors.green,
                        ),
                        _buildPieSection(
                          totalPengeluaran,
                          'Pengeluaran',
                          Colors.red,
                        ),
                        _buildPieSection(sisa, 'Sisa', Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Grafik Batang"),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        _buildBarGroup(0, totalPemasukan, Colors.green),
                        _buildBarGroup(1, totalPengeluaran, Colors.red),
                        _buildBarGroup(2, sisa, Colors.blue),
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
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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

  PieChartSectionData _buildPieSection(
    double value,
    String title,
    Color color,
  ) {
    return PieChartSectionData(
      value: value > 0 ? value : 0.0001,
      title: title,
      color: color,
      radius: 60,
      titleStyle: const TextStyle(color: Colors.white),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value > 0 ? value : 0,
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
