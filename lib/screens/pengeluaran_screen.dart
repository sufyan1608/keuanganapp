import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({super.key});

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> pengeluaranList = [];
  List<dynamic> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('pengeluaran')
          .select()
          .eq('user_id', userId)
          .order('tanggal', ascending: false);

      setState(() {
        pengeluaranList = response;
        filteredList = pengeluaranList;
      });
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> tambahPengeluaran(
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    final userId = supabase.auth.currentUser?.id;
    await supabase.from('pengeluaran').insert({
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'user_id': userId,
    });
    await fetchData();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil ditambahkan")),
    );
  }

  Future<void> editPengeluaran(
    String id,
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    await supabase
        .from('pengeluaran')
        .update({
          'keterangan': keterangan,
          'jumlah': jumlah,
          'tanggal': tanggal.toIso8601String(),
        })
        .eq('id', id);
    await fetchData();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil diperbarui")),
    );
  }

  Future<void> hapusPengeluaran(String id) async {
    await supabase.from('pengeluaran').delete().eq('id', id);
    await fetchData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil dihapus")),
    );
  }

  void _showForm({Map<String, dynamic>? data}) {
    final keteranganController = TextEditingController(
      text: data?['keterangan'] ?? '',
    );
    final jumlahController = TextEditingController(
      text: data?['jumlah']?.toString() ?? '',
    );
    DateTime selectedDate =
        data?['tanggal'] != null
            ? DateTime.parse(data!['tanggal'].toString())
            : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keteranganController,
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jumlahController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: const Text("Pilih Tanggal"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final keterangan = keteranganController.text;
                      final jumlah =
                          double.tryParse(jumlahController.text) ?? 0;
                      if (keterangan.isNotEmpty && jumlah > 0) {
                        if (data == null) {
                          tambahPengeluaran(keterangan, jumlah, selectedDate);
                        } else {
                          editPengeluaran(
                            data['id'],
                            keterangan,
                            jumlah,
                            selectedDate,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(data == null ? 'Simpan' : 'Perbarui'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  double _hitungTotal() {
    return filteredList.fold(
      0,
      (sum, item) => sum + (item['jumlah'] as num).toDouble(),
    );
  }

  void _filterSearch(String query) {
    setState(() {
      filteredList =
          pengeluaranList
              .where(
                (item) => (item['keterangan'] ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _hitungTotal();

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text('Pengeluaran'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _filterSearch,
                decoration: InputDecoration(
                  hintText: 'Cari pengeluaran...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.red[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[700],
                    child: const Icon(Icons.money_off, color: Colors.white),
                  ),
                  title: const Text("Total Pengeluaran"),
                  subtitle: Text(
                    "Rp ${total.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    filteredList.isEmpty
                        ? const Center(
                          child: Text("Belum ada data pengeluaran"),
                        )
                        : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final tanggal = DateTime.parse(item['tanggal']);
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                ),
                                title: Text(
                                  item['keterangan'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "Rp ${item['jumlah'].toStringAsFixed(0)}\n${DateFormat('dd MMM yyyy').format(tanggal)}",
                                  style: const TextStyle(height: 1.4),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => _showForm(data: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => hapusPengeluaran(item['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
