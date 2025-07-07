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
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('pemasukan')
          .select()
          .eq('user_id', userId)
          .order('tanggal', ascending: false);

      setState(() {
        pemasukanList = response;
        filteredList = pemasukanList;
      });
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> tambahPemasukan(
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    final userId = supabase.auth.currentUser?.id;
    await supabase.from('pemasukan').insert({
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'user_id': userId,
    });
    await fetchData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pemasukan berhasil ditambahkan")),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pemasukan berhasil diperbarui")),
    );
  }

  Future<void> hapusPemasukan(String id) async {
    await supabase.from('pemasukan').delete().eq('id', id);
    await fetchData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pemasukan berhasil dihapus")));
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
            ? DateTime.tryParse(data!['tanggal'].toString()) ?? DateTime.now()
            : DateTime.now();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder:
              (context, setStateDialog) => AlertDialog(
                title: Text(
                  data == null ? 'Tambah Pemasukan' : 'Edit Pemasukan',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                    ),
                    TextField(
                      controller: jumlahController,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
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
                        Navigator.pop(context);
                      }
                    },
                    child: Text(data == null ? 'Simpan' : 'Update'),
                  ),
                ],
              ),
        );
      },
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
          pemasukanList
              .where(
                (item) =>
                    item['keterangan'] != null &&
                    item['keterangan'].toLowerCase().contains(
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
      appBar: AppBar(
        title: const Text("Pemasukan"),
        backgroundColor: Colors.green,
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
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari berdasarkan keterangan...',
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.green[50],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.attach_money, color: Colors.white),
                  ),
                  title: const Text("Total Pemasukan"),
                  subtitle: Text(
                    "Rp ${total.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    filteredList.isEmpty
                        ? const Center(
                          child: Text(
                            "Belum ada data pemasukan",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.separated(
                          itemCount: filteredList.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Icon(
                                    Icons.wallet,
                                    color: Colors.green[900],
                                  ),
                                ),
                                title: Text(
                                  item['keterangan'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Rp ${item['jumlah'].toStringAsFixed(0)}\n${DateFormat('dd MMM yyyy').format(DateTime.parse(item['tanggal']))}",
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                                isThreeLine: true,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
        onPressed: () => _showForm(),
      ),
    );
  }
}
