import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengeluaranScreen extends StatefulWidget {
  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> pengeluaranList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await supabase.from('pengeluaran').select();
    setState(() {
      pengeluaranList = response;
    });
  }

  Future<void> tambahPengeluaran(String keterangan, double jumlah) async {
    await supabase.from('pengeluaran').insert({
      'keterangan': keterangan,
      'jumlah': jumlah,
      'created_at': DateTime.now().toIso8601String(),
    });
    fetchData();
  }

  Future<void> editPengeluaran(int id, String keterangan, double jumlah) async {
    await supabase
        .from('pengeluaran')
        .update({'keterangan': keterangan, 'jumlah': jumlah})
        .eq('id', id);
    fetchData();
  }

  Future<void> hapusPengeluaran(int id) async {
    await supabase.from('pengeluaran').delete().eq('id', id);
    fetchData();
  }

  void _showForm({Map<String, dynamic>? data}) {
    final TextEditingController keteranganController = TextEditingController(
      text: data?['keterangan'] ?? '',
    );
    final TextEditingController jumlahController = TextEditingController(
      text: data?['jumlah']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              data == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keteranganController,
                  decoration: InputDecoration(labelText: 'Keterangan'),
                ),
                TextField(
                  controller: jumlahController,
                  decoration: InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final keterangan = keteranganController.text;
                  final jumlah = double.tryParse(jumlahController.text) ?? 0;
                  if (keterangan.isNotEmpty && jumlah > 0) {
                    if (data == null) {
                      tambahPengeluaran(keterangan, jumlah);
                    } else {
                      editPengeluaran(data['id'], keterangan, jumlah);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(data == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
    );
  }

  double _hitungTotal() {
    return pengeluaranList.fold(
      0,
      (sum, item) => sum + (item['jumlah'] as num).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _hitungTotal();

    return Scaffold(
      appBar: AppBar(title: Text("Pengeluaran"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.red[50],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.money_off, color: Colors.white),
                ),
                title: Text("Total Pengeluaran"),
                subtitle: Text(
                  "Rp ${total.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  pengeluaranList.isEmpty
                      ? Center(
                        child: Text(
                          "Belum ada data pengeluaran",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.separated(
                        itemCount: pengeluaranList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = pengeluaranList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.red[100],
                                child: Icon(
                                  Icons.wallet,
                                  color: Colors.red[900],
                                ),
                              ),
                              title: Text(
                                item['keterangan'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Rp ${item['jumlah'].toStringAsFixed(0)}",
                                style: TextStyle(color: Colors.red[800]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => _showForm(data: item),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        icon: Icon(Icons.add),
        label: Text("Tambah"),
        onPressed: () => _showForm(),
      ),
    );
  }
}