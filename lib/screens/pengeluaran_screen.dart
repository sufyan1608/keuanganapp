import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PengeluaranScreen extends StatefulWidget {
  @override
  _PengeluaranScreenState createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pengeluaranList = [];
  String userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  double totalPengeluaran = 0;
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    fetchPengeluaran();
  }

  Future<void> fetchPengeluaran() async {
    final response = await supabase
        .from('pengeluaran')
        .select()
        .eq('user_id', userId)
        .order('tanggal', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);
    final filtered =
        data.where((item) {
          final keterangan = item['keterangan']?.toLowerCase() ?? '';
          return keterangan.contains(searchKeyword.toLowerCase());
        }).toList();

    final total = filtered.fold<double>(
      0,
      (sum, item) => sum + (item['jumlah'] ?? 0),
    );

    setState(() {
      pengeluaranList = filtered;
      totalPengeluaran = total;
    });
  }

  void tambahPengeluaran() async {
    final TextEditingController keteranganController = TextEditingController();
    final TextEditingController jumlahController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Tambah Pengeluaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keteranganController,
                  decoration: InputDecoration(labelText: 'Keterangan'),
                ),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Jumlah'),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
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
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () async {
                  await supabase.from('pengeluaran').insert({
                    'user_id': userId,
                    'keterangan': keteranganController.text,
                    'jumlah': int.tryParse(jumlahController.text) ?? 0,
                    'tanggal': selectedDate.toIso8601String(),
                  });
                  Navigator.pop(context);
                  fetchPengeluaran();
                },
              ),
            ],
          ),
    );
  }

  void editPengeluaran(Map<String, dynamic> data) async {
    final TextEditingController keteranganController = TextEditingController(
      text: data['keterangan'],
    );
    final TextEditingController jumlahController = TextEditingController(
      text: data['jumlah'].toString(),
    );
    DateTime selectedDate = DateTime.parse(data['tanggal']);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Pengeluaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keteranganController,
                  decoration: InputDecoration(labelText: 'Keterangan'),
                ),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Jumlah'),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
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
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Update'),
                onPressed: () async {
                  await supabase
                      .from('pengeluaran')
                      .update({
                        'keterangan': keteranganController.text,
                        'jumlah': int.tryParse(jumlahController.text) ?? 0,
                        'tanggal': selectedDate.toIso8601String(),
                      })
                      .eq('id', data['id']);
                  Navigator.pop(context);
                  fetchPengeluaran();
                },
              ),
            ],
          ),
    );
  }

  void hapusPengeluaran(int id) async {
    await supabase.from('pengeluaran').delete().eq('id', id);
    fetchPengeluaran();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Pengeluaran')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan keterangan...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => searchKeyword = value);
                fetchPengeluaran();
              },
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(LucideIcons.wallet, color: Colors.white),
                ),
                title: Text('Total Pengeluaran'),
                subtitle: Text(
                  currency.format(totalPengeluaran),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: pengeluaranList.length,
                itemBuilder: (context, index) {
                  final item = pengeluaranList[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Icon(LucideIcons.wallet, color: Colors.red),
                      ),
                      title: Text(item['keterangan']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.format(item['jumlah']),
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(DateTime.parse(item['tanggal'])),
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => editPengeluaran(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => hapusPengeluaran(item['id']),
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
        onPressed: tambahPengeluaran,
        label: Text("Tambah"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
