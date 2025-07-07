import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatatanScreen extends StatefulWidget {
  @override
  _CatatanScreenState createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _catatanController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> catatanList = [];
  int? editingId;

  bool showOnlyImportant = false;
  bool showOnlyIncomplete = false;

  @override
  void initState() {
    super.initState();
    fetchCatatan();
  }

  Future<void> fetchCatatan() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('catatan')
        .select()
        .eq('user_id', user.id)
        .order('tanggal', ascending: false);

    setState(() {
      catatanList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> tambahAtauEditCatatan() async {
    final user = supabase.auth.currentUser;
    final isi = _catatanController.text.trim();
    if (user == null || isi.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan tidak boleh kosong')));
      return;
    }

    if (editingId == null) {
      // Tambah
      await supabase.from('catatan').insert({
        'user_id': user.id,
        'isi': isi,
        'tanggal': selectedDate.toIso8601String(),
        'penting': false,
        'selesai': false,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan berhasil ditambahkan')));
    } else {
      // Edit
      await supabase
          .from('catatan')
          .update({'isi': isi, 'tanggal': selectedDate.toIso8601String()})
          .eq('id', editingId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan berhasil diperbarui')));
      editingId = null;
    }

    _catatanController.clear();
    selectedDate = DateTime.now();
    fetchCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Hapus Catatan"),
            content: Text("Yakin ingin menghapus catatan ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Hapus"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await supabase.from('catatan').delete().eq('id', id);
      fetchCatatan();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catatan berhasil dihapus')));
    }
  }

  void mulaiEdit(Map<String, dynamic> item) {
    setState(() {
      _catatanController.text = item['isi'];
      selectedDate = DateTime.parse(item['tanggal']);
      editingId = item['id'];
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        catatanList.where((item) {
          if (showOnlyImportant && item['penting'] != true) return false;
          if (showOnlyIncomplete && item['selesai'] == true) return false;
          return true;
        }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Catatan"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _catatanController,
              decoration: InputDecoration(
                labelText: 'Catatan',
                suffixIcon: IconButton(
                  icon: Icon(editingId == null ? Icons.send : Icons.save),
                  onPressed: tambahAtauEditCatatan,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                Spacer(),
                TextButton(
                  onPressed: _selectDate,
                  child: Text("Pilih Tanggal"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: showOnlyImportant,
                      onChanged: (val) {
                        setState(() {
                          showOnlyImportant = val!;
                        });
                      },
                    ),
                    Text("Penting"),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showOnlyIncomplete,
                      onChanged: (val) {
                        setState(() {
                          showOnlyIncomplete = val!;
                        });
                      },
                    ),
                    Text("Belum Selesai"),
                  ],
                ),
              ],
            ),
            Divider(),
            Expanded(
              child:
                  filteredList.isEmpty
                      ? Center(child: Text("Belum ada catatan"))
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final DateTime tanggal = DateTime.parse(
                            item['tanggal'],
                          );
                          return Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  if (item['penting'] == true)
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  SizedBox(width: 4),
                                  Expanded(child: Text(item['isi'] ?? '')),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tanggal: ${DateFormat('dd MMM yyyy').format(tanggal)}",
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: item['selesai'] ?? false,
                                        onChanged: (val) async {
                                          await supabase
                                              .from('catatan')
                                              .update({'selesai': val})
                                              .eq('id', item['id']);
                                          fetchCatatan();
                                        },
                                      ),
                                      Text(
                                        item['selesai'] == true
                                            ? "Selesai"
                                            : "Belum Selesai",
                                      ),
                                      Spacer(),
                                      TextButton.icon(
                                        onPressed: () async {
                                          await supabase
                                              .from('catatan')
                                              .update({
                                                'penting':
                                                    !(item['penting'] ?? false),
                                              })
                                              .eq('id', item['id']);
                                          fetchCatatan();
                                        },
                                        icon: Icon(
                                          Icons.star,
                                          color:
                                              item['penting'] == true
                                                  ? Colors.orange
                                                  : Colors.grey,
                                        ),
                                        label: Text("Penting"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => mulaiEdit(item),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => hapusCatatan(item['id']),
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
    );
  }
}
