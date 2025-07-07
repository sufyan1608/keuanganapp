import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
      await supabase.from('catatan').insert({
        'user_id': user.id,
        'isi': isi,
        'tanggal': selectedDate.toIso8601String(),
        'penting': false,
        'selesai': false,
      });
    } else {
      await supabase
          .from('catatan')
          .update({'isi': isi, 'tanggal': selectedDate.toIso8601String()})
          .eq('id', editingId);
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
          (_) => AlertDialog(
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
      lastDate: DateTime(2100),
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
      appBar: AppBar(
        title: const Text("Catatan"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _catatanController,
                      decoration: InputDecoration(
                        labelText: 'Tulis catatan...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            editingId == null ? Icons.send : Icons.save,
                          ),
                          onPressed: tambahAtauEditCatatan,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 8),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        Spacer(),
                        TextButton(
                          onPressed: _selectDate,
                          child: Text("Ubah Tanggal"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: showOnlyImportant,
                  onChanged: (val) => setState(() => showOnlyImportant = val!),
                ),
                Text("Penting"),
                SizedBox(width: 20),
                Checkbox(
                  value: showOnlyIncomplete,
                  onChanged: (val) => setState(() => showOnlyIncomplete = val!),
                ),
                Text("Belum Selesai"),
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
                          final tanggal = DateTime.parse(item['tanggal']);
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  Expanded(
                                    child: Text(
                                      item['isi'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(tanggal),
                                    style: TextStyle(color: Colors.grey[600]),
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
                                        icon: Icon(
                                          Icons.star,
                                          color:
                                              item['penting'] == true
                                                  ? Colors.orange
                                                  : Colors.grey,
                                        ),
                                        label: Text("Penting"),
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
