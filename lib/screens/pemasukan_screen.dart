import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PemasukanScreen extends StatefulWidget {
  @override
  State<PemasukanScreen> createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> pemasukanList = [];

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
          .order('created_at', ascending: false);
      setState(() {
        pemasukanList = response;
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
    fetchData();
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
    fetchData();
  }

  Future<void> hapusPemasukan(String id) async {
    await supabase.from('pemasukan').delete().eq('id', id);
    fetchData();
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
                      decoration: InputDecoration(labelText: 'Keterangan'),
                    ),
                    TextField(
                      controller: jumlahController,
                      decoration: InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
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
                    child: Text('Batal'),
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
    return pemasukanList.fold(
      0,
      (sum, item) => sum + (item['jumlah'] as num).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _hitungTotal();

    return Scaffold(
      appBar: AppBar(title: Text("Pemasukan"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.green[50],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.attach_money, color: Colors.white),
                ),
                title: Text("Total Pemasukan"),
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
            SizedBox(height: 20),
            Expanded(
              child:
                  pemasukanList.isEmpty
                      ? Center(
                        child: Text(
                          "Belum ada data pemasukan",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.separated(
                        itemCount: pemasukanList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = pemasukanList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(
                                  Icons.wallet,
                                  color: Colors.green[900],
                                ),
                              ),
                              title: Text(
                                item['keterangan'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Rp ${item['jumlah'].toStringAsFixed(0)}",
                                style: TextStyle(color: Colors.green[800]),
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
                                    onPressed: () => hapusPemasukan(item['id']),
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
        backgroundColor: Colors.green,
        icon: Icon(Icons.add),
        label: Text("Tambah"),
        onPressed: () => _showForm(),
      ),
    );
  }
}
