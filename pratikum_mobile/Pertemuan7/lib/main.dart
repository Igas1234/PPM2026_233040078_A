import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'catatan.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  databaseFactory = databaseFactoryFfiWeb;

  runApp(const MyApp());
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            final catatanAwal = settings.arguments as Catatan?;

            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(
                catatanAwal: catatanAwal,
              ),
            );

          case '/detail':
            final catatan = settings.arguments as Catatan;

            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: catatan,
              ),
            );
        }

        return null;
      },
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
  late Future<List<Catatan>> _futureCatatan;

  String _filterKategori = 'Semua';

  final List<String> _kategoriFilter = const [
    'Semua',
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _futureCatatan = DbHelper.instance.getAll();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (!mounted) return;

    _muatUlang();

    if (hasil == 'tambah') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil ditambahkan'),
        ),
      );
    }
  }

  Future<void> _bukaDetailCatatan(Catatan catatan) async {
    final hasil = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: catatan,
    );

    if (!mounted) return;

    if (hasil == 'edit') {
      _muatUlang();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil diedit'),
        ),
      );
    }
  }

  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus catatan?'),
          content: Text(
            'Catatan "${catatan.judul}" akan dihapus permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin != true) return;

    await DbHelper.instance.delete(catatan.id!);

    if (!mounted) return;

    _muatUlang();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan "${catatan.judul}" dihapus'),
      ),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year.toString();

    return '$hari/$bulan/$tahun';
  }

  List<Catatan> _filterData(List<Catatan> data) {
    if (_filterKategori == 'Semua') {
      return data;
    }

    return data.where((catatan) {
      return catatan.kategori == _filterKategori;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButton<String>(
              value: _filterKategori,
              underline: const SizedBox(),
              items: _kategoriFilter.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filterKategori = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Terjadi error:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final semuaCatatan = snapshot.data ?? [];
          final catatanTampil = _filterData(semuaCatatan);

          if (catatanTampil.isEmpty) {
            return _EmptyState(filterKategori: _filterKategori);
          }

          return ListView.builder(
            itemCount: catatanTampil.length,
            itemBuilder: (context, index) {
              final c = catatanTampil[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    c.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${c.kategori} • ${c.emailPengirim} • ${_formatTanggal(c.dibuatPada)}',
                  ),
                  onTap: () {
                    _bukaDetailCatatan(c);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _konfirmasiHapus(c);
                    },
                  ),
                ),
              );
            },
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
  final String filterKategori;

  const _EmptyState({
    required this.filterKategori,
  });

  @override
  Widget build(BuildContext context) {
    final pesan = filterKategori == 'Semua'
        ? 'Belum ada catatan'
        : 'Belum ada catatan kategori $filterKategori';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            pesan,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan tombol + untuk menambah catatan.',
          ),
        ],
      ),
    );
  }
}

// ===============================
// TAMBAH / EDIT CATATAN PAGE
// ===============================
class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanAwal;

  const TambahCatatanPage({
    super.key,
    this.catatanAwal,
  });

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _kategori = 'Kuliah';

  final _kategoriOpsi = const [
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  bool _menyimpan = false;

  bool get _modeEdit => widget.catatanAwal != null;

  @override
  void initState() {
    super.initState();

    if (_modeEdit) {
      final catatan = widget.catatanAwal!;

      _judulCtrl.text = catatan.judul;
      _isiCtrl.text = catatan.isi;
      _emailCtrl.text = catatan.emailPengirim;
      _kategori = catatan.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _emailValid(String email) {
    final regex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    return regex.hasMatch(email);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _menyimpan = true;
    });

    try {
      if (_modeEdit) {
        final catatanEdit = widget.catatanAwal!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          emailPengirim: _emailCtrl.text.trim(),
        );

        await DbHelper.instance.update(catatanEdit);
      } else {
        final catatanBaru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          emailPengirim: _emailCtrl.text.trim(),
          dibuatPada: DateTime.now(),
        );

        await DbHelper.instance.insert(catatanBaru);
      }

      if (!mounted) return;

      Navigator.pop(context, _modeEdit ? 'edit' : 'tambah');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _menyimpan = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Catatan' : 'Tambah Catatan'),
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
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
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

                if (!_emailValid(value.trim())) {
                  return 'Format email tidak valid';
                }

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
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _kategori = value!;
                });
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
                if (value == null || value.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(
                _menyimpan
                    ? 'Menyimpan...'
                    : _modeEdit
                    ? 'Simpan Perubahan'
                    : 'Simpan',
              ),
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

  Future<void> _editCatatan(BuildContext context) async {
    final hasil = await Navigator.pushNamed(
      context,
      '/tambah',
      arguments: catatan,
    );

    if (hasil == 'edit') {
      if (!context.mounted) return;

      Navigator.pop(context, 'edit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            onPressed: () {
              _editCatatan(context);
            },
            icon: const Icon(Icons.edit),
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    catatan.emailPengirim,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _editCatatan(context);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Catatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}