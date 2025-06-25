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

  Future<void> tambahCatatan() async {
    final user = supabase.auth.currentUser;
    if (user == null || _catatanController.text.trim().isEmpty) return;

    await supabase.from('catatan').insert({
      'user_id': user.id,
      'isi': _catatanController.text,
      'tanggal': selectedDate.toIso8601String(),
    });

    _catatanController.clear();
    fetchCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    await supabase.from('catatan').delete().eq('id', id);
    fetchCatatan();
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.send),
                  onPressed: tambahCatatan,
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: catatanList.length,
                itemBuilder: (context, index) {
                  final item = catatanList[index];
                  final DateTime tanggal = DateTime.parse(item['tanggal']);
                  return Card(
                    child: ListTile(
                      title: Text(item['isi'] ?? ''),
                      subtitle: Text(
                        "Tanggal: ${DateFormat('dd MMM yyyy').format(tanggal)}",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusCatatan(item['id']),
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