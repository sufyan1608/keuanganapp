screens/pemasukan_screen.dart
import 'package:flutter/material.dart';

class Pemasukan {
  String keterangan;
  double jumlah;

  Pemasukan({required this.keterangan, required this.jumlah});
}

class PemasukanScreen extends StatefulWidget {
  @override
  State<PemasukanScreen> createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final List<Pemasukan> pemasukanList = [];

  void _showForm({Pemasukan? data, int? index}) {
    final TextEditingController keteranganController = TextEditingController(
      text: data?.keterangan ?? '',
    );
    final TextEditingController jumlahController = TextEditingController(
      text: data?.jumlah.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(data == null ? 'Tambah Pemasukan' : 'Edit Pemasukan'),
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
                    setState(() {
                      if (data == null) {
                        pemasukanList.add(
                          Pemasukan(keterangan: keterangan, jumlah: jumlah),
                        );
                      } else if (index != null) {
                        pemasukanList[index] = Pemasukan(
                          keterangan: keterangan,
                          jumlah: jumlah,
                        );
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(data == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
    );
  }

  void _hapusPemasukan(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Hapus Pemasukan"),
            content: Text("Yakin ingin menghapus pemasukan ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    pemasukanList.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pemasukan berhasil dihapus")),
                  );
                },
                child: Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  double _hitungTotal() {
    return pemasukanList.fold(0, (sum, item) => sum + item.jumlah);
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
            // Total Card
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

            // List pemasukan
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
                                child: Icon(Icons.wallet, color: Colors.green),
                              ),
                              title: Text(
                                item.keterangan,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Rp ${item.jumlah.toStringAsFixed(0)}",
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
                                    onPressed:
                                        () =>
                                            _showForm(data: item, index: index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _hapusPemasukan(index),
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