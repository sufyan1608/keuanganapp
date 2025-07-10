import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? editingId;

  List<Map<String, dynamic>> _catatanList = [];

  @override
  void initState() {
    super.initState();
    _fetchCatatan();
  }

  Future<void> _fetchCatatan() async {
    final response = await supabase
        .from('catatan')
        .select()
        .order('tanggal', ascending: false);

    setState(() {
      _catatanList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _saveCatatan() async {
    final isi = _controller.text.trim();

    if (isi.isEmpty) return;

    try {
      if (editingId == null) {
        // Insert baru
        await supabase.from('catatan').insert({
          'isi': isi,
          'tanggal': selectedDate.toIso8601String(),
        });
      } else {
        // Update berdasarkan UUID
        await supabase
            .from('catatan')
            .update({'isi': isi, 'tanggal': selectedDate.toIso8601String()})
            .eq('id', editingId);

        editingId = null;
      }

      _controller.clear();
      selectedDate = DateTime.now();
      await _fetchCatatan();
    } catch (e) {
      debugPrint('Gagal menyimpan: $e');
    }
  }

  void _editCatatan(Map<String, dynamic> catatan) {
    setState(() {
      editingId = catatan['id'] as String;
      _controller.text = catatan['isi'] ?? '';
      selectedDate = DateTime.parse(catatan['tanggal']);
    });
  }

  Future<void> _hapusCatatan(String id) async {
    try {
      await supabase.from('catatan').delete().eq('id', id);
      await _fetchCatatan();
    } catch (e) {
      debugPrint('Gagal menghapus: $e');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Keuangan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Tanggal: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Pilih Tanggal"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveCatatan,
              icon: const Icon(Icons.save),
              label: Text(editingId == null ? 'Simpan' : 'Update'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child:
                  _catatanList.isEmpty
                      ? const Center(child: Text('Belum ada catatan.'))
                      : ListView.builder(
                        itemCount: _catatanList.length,
                        itemBuilder: (context, index) {
                          final item = _catatanList[index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(item['isi'] ?? ''),
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(DateTime.parse(item['tanggal'])),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => _editCatatan(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _hapusCatatan(item['id']),
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
