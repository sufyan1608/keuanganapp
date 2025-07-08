import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _simpanProfil() {
    if (_formKey.currentState!.validate()) {
      // TODO: Simpan perubahan ke Supabase atau local state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profil", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanProfil,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text("Simpan", style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
