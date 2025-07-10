import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PemasukanScreen extends StatefulWidget {
  const PemasukanScreen({super.key});

  @override
  State<PemasukanScreen> createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> pemasukanList = [];
  List<dynamic> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('pemasukan')
          .select()
          .eq('user_id', user.id)
          .order('tanggal', ascending: false);

      setState(() {
        pemasukanList = response;
        filteredList = pemasukanList;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memuat data")));
      }
    }
  }

  Future<void> tambahPemasukan(
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('pemasukan').insert({
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'user_id': user.id,
    });

    await fetchData();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pemasukan berhasil ditambahkan")),
      );
    }
  }

  Future<void> editPemasukan(
    String id,
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    await supabase
        .from('pemasukan')
        .update({
          'keterangan': keterangan,
          'jumlah': jumlah,
          'tanggal': tanggal.toIso8601String(),
        })
        .eq('id', id);

    await fetchData();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pemasukan berhasil diperbarui")),
      );
    }
  }

  Future<void> hapusPemasukan(String id) async {
    await supabase.from('pemasukan').delete().eq('id', id);
    await fetchData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pemasukan berhasil dihapus")),
      );
    }
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
                  data == null ? 'Tambah Pemasukan' : 'Edit Pemasukan',
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
                          tambahPemasukan(keterangan, jumlah, selectedDate);
                        } else {
                          editPemasukan(
                            data['id'],
                            keterangan,
                            jumlah,
                            selectedDate,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          pemasukanList.where((item) {
            final keterangan = item['keterangan'] ?? '';
            return keterangan.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _hitungTotal();

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Pemasukan'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
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
                  hintText: 'Cari pemasukan...',
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
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[700],
                    child: const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text("Total Pemasukan"),
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
                        ? const Center(child: Text("Belum ada data pemasukan"))
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
                                  backgroundColor: Colors.green[100],
                                  child: const Icon(Icons.wallet),
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
                                          () => hapusPemasukan(item['id']),
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
