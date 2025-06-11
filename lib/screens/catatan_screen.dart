import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Catatan {
  String judul;
  String deskripsi;
  DateTime tanggal;

  Catatan({
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
  });
}

class CatatanScreen extends StatefulWidget {
  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final List<Catatan> catatanList = [];

  void _showForm({Catatan? data, int? index}) {
    final TextEditingController judulController = TextEditingController(
      text: data?.judul ?? '',
    );
    final TextEditingController deskripsiController = TextEditingController(
      text: data?.deskripsi ?? '',
    );
    DateTime selectedDate = data?.tanggal ?? DateTime.now();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(data == null ? 'Tambah Catatan' : 'Edit Catatan'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: judulController,
                    decoration: InputDecoration(labelText: 'Judul'),
                  ),
                  TextField(
                    controller: deskripsiController,
                    decoration: InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Tanggal: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: Text("Pilih Tanggal"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (judulController.text.isNotEmpty &&
                      deskripsiController.text.isNotEmpty) {
                    final newCatatan = Catatan(
                      judul: judulController.text,
                      deskripsi: deskripsiController.text,
                      tanggal: selectedDate,
                    );
                    setState(() {
                      if (data == null) {
                        catatanList.add(newCatatan);
                      } else if (index != null) {
                        catatanList[index] = newCatatan;
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

  void _hapusCatatan(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Hapus Catatan"),
            content: Text("Yakin ingin menghapus catatan ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    catatanList.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Catatan berhasil dihapus")),
                  );
                },
                child: Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catatan Keuangan"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            catatanList.isEmpty
                ? Center(
                  child: Text(
                    "Belum ada catatan keuangan",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                : ListView.separated(
                  itemCount: catatanList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = catatanList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          item.judul,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(item.deskripsi),
                            SizedBox(height: 6),
                            Text(
                              "Tanggal: ${DateFormat('dd MMM yyyy').format(item.tanggal)}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed:
                                  () => _showForm(data: item, index: index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusCatatan(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: Icon(Icons.note_add),
        label: Text("Tambah"),
        onPressed: () => _showForm(),
      ),
    );
  }
}