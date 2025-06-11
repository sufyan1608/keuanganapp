import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikScreen extends StatelessWidget {
  final double pemasukan = 8000000;
  final double pengeluaran = 3500000;

  @override
  Widget build(BuildContext context) {
    double sisa = pemasukan - pengeluaran;

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistik Keuangan"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummary(pemasukan, pengeluaran, sisa),
            SizedBox(height: 20),
            Expanded(child: _buildPieChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(double pemasukan, double pengeluaran, double sisa) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Pemasukan", pemasukan, Colors.green),
        _buildStatCard("Pengeluaran", pengeluaran, Colors.red),
        _buildStatCard("Sisa", sisa, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 8),
            Text(
              "Rp ${value.toStringAsFixed(0)}",
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: pemasukan,
            title: 'Pemasukan',
            radius: 60,
            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: pengeluaran,
            title: 'Pengeluaran',
            radius: 60,
            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
