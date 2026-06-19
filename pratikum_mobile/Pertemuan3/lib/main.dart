import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ===============================
// MODEL DATA CATATAN
// ===============================
class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final String emailPengirim; // [FITUR 3] Tambahan properti email
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });
}

// ===============================
// ROOT APP
// ===============================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(), // Menggunakan home langsung agar mempermudah passing data dinamis
    );
  }
}

// ===============================
// HOME PAGE
// ===============================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _kategoriFilter = 'Semua'; // [FITUR 2] State untuk filter kategori

  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      emailPengirim: 'mahasiswa@kampus.ac.id',
      dibuatPada: DateTime.now(),
    ),
  ];

  // Fungsi untuk menambah catatan baru
  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahCatatanPage()),
    );

    if (hasil is Catatan) {
      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
      );
    }
  }

  // [FITUR 1] Fungsi untuk membuka detail dan menerima hasil edit
  Future<void> _bukaDetailCatatan(int index) async {
    final hasilEdit = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailCatatanPage(catatan: _catatan[index]),
      ),
    );

    // Jika kembaliannya berupa Catatan baru, berarti data diedit
    if (hasilEdit is Catatan) {
      setState(() {
        _catatan[index] = hasilEdit;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasilEdit.judul}" diperbarui')),
      );
    }
  }

  void _hapusCatatan(int index) {
    // Cari index asli jika sedang dalam mode filter
    final catatanDihapus = _catatanTampil[index];
    final originalIndex = _catatan.indexOf(catatanDihapus);

    setState(() {
      _catatan.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catatan "${catatanDihapus.judul}" dihapus')),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year.toString();
    return '$hari/$bulan/$tahun';
  }

  // [FITUR 2] Getter untuk list yang sudah difilter
  List<Catatan> get _catatanTampil {
    if (_kategoriFilter == 'Semua') return _catatan;
    return _catatan.where((c) => c.kategori == _kategoriFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          // [FITUR 2] Dropdown untuk Filter Kategori
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _kategoriFilter,
                icon: const Icon(Icons.filter_list, color: Colors.indigo),
                items: const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _kategoriFilter = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: _catatanTampil.isEmpty
          ? const _EmptyState()
          : ListView.builder(
        itemCount: _catatanTampil.length,
        itemBuilder: (context, index) {
          final c = _catatanTampil[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(
                c.judul,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${c.kategori} • ${_formatTanggal(c.dibuatPada)}'),
              onTap: () => _bukaDetailCatatan(index),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _hapusCatatan(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===============================
// EMPTY STATE
// ===============================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada catatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tekan tombol + untuk menambah catatan.'),
        ],
      ),
    );
  }
}

// ===============================
// TAMBAH / EDIT CATATAN PAGE
// ===============================
class TambahCatatanPage extends StatefulWidget {
  // [FITUR 1] Parameter opsional untuk menampung data lama saat Edit
  final Catatan? catatanLama;

  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _emailCtrl; // [FITUR 3] Controller untuk email
  late String _kategori;

  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // [FITUR 1] Mengisi form dengan data lama jika sedang mode Edit
    final lama = widget.catatanLama;
    _judulCtrl = TextEditingController(text: lama?.judul ?? '');
    _isiCtrl = TextEditingController(text: lama?.isi ?? '');
    _emailCtrl = TextEditingController(text: lama?.emailPengirim ?? '');
    _kategori = lama?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      emailPengirim: _emailCtrl.text.trim(),
      // Jika edit, pertahankan tanggal lama. Jika baru, buat tanggal sekarang.
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Judul wajib diisi';
                if (value.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi.map((kategori) {
                return DropdownMenuItem(value: kategori, child: Text(kategori));
              }).toList(),
              onChanged: (value) => setState(() => _kategori = value!),
            ),
            const SizedBox(height: 16),
            // [FITUR 3] Field Email dengan Validasi Regex
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                // Regex format email standar
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Format email tidak valid (contoh: nama@email.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Isi wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// DETAIL CATATAN PAGE
// ===============================
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({
    super.key,
    required this.catatan,
  });

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year.toString();
    return '$hari/$bulan/$tahun';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          // [FITUR 1] Tombol Edit di halaman Detail
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Catatan',
            onPressed: () async {
              // Buka halaman tambah tapi bawa data catatan lama
              final hasilEdit = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TambahCatatanPage(catatanLama: catatan),
                ),
              );

              // Jika ada hasil (berhasil disave), kembalikan ke HomePage
              if (hasilEdit != null) {
                Navigator.pop(context, hasilEdit);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(catatan.kategori)),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Menampilkan email pengirim
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  catatan.emailPengirim,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}