screens/pengeluaran_screen.dart
import 'package:flutter/material.dart';

class Pengeluaran {
  String keterangan;
  double jumlah;

  Pengeluaran({required this.keterangan, required this.jumlah});
}

class PengeluaranScreen extends StatefulWidget {
  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final List<Pengeluaran> pengeluaranList = [];

  void _showForm({Pengeluaran? data, int? index}) {
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
                    setState(() {
                      if (data == null) {
                        pengeluaranList.add(
                          Pengeluaran(keterangan: keterangan, jumlah: jumlah),
                        );
                      } else if (index != null) {
                        pengeluaranList[index] = Pengeluaran(
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

  void _hapusPengeluaran(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Hapus Pengeluaran"),
            content: Text("Yakin ingin menghapus pengeluaran ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    pengeluaranList.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pengeluaran berhasil dihapus")),
                  );
                },
                child: Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  double _hitungTotal() {
    return pengeluaranList.fold(0, (sum, item) => sum + item.jumlah);
  }

  @override
  Widget build(BuildContext context) {
    final total = _hitungTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text("Pengeluaran"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total Card
            Card(
              color: Colors.red[50],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
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

            // List pengeluaran
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
                                  Icons.money_off_csred,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(
                                item.keterangan,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Rp ${item.jumlah.toStringAsFixed(0)}",
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
                                    onPressed:
                                        () =>
                                            _showForm(data: item, index: index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _hapusPengeluaran(index),
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
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.add),
        label: Text("Tambah"),
        onPressed: () => _showForm(),
      ),
    );
  }
}