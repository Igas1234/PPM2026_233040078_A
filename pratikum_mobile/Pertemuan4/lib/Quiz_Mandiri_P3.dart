import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

// ===============================
// MODEL PROFIL
// ===============================
class ProfileData {
  final String nama;
  final String status;
  final String tentang;
  final String pendidikan;
  final String lokasi;
  final String kontak;
  final List<String> skills;
  final Uint8List? fotoProfilBytes;

  const ProfileData({
    required this.nama,
    required this.status,
    required this.tentang,
    required this.pendidikan,
    required this.lokasi,
    required this.kontak,
    required this.skills,
    this.fotoProfilBytes,
  });

  ProfileData copyWith({
    String? nama,
    String? status,
    String? tentang,
    String? pendidikan,
    String? lokasi,
    String? kontak,
    List<String>? skills,
    Uint8List? fotoProfilBytes,
  }) {
    return ProfileData(
      nama: nama ?? this.nama,
      status: status ?? this.status,
      tentang: tentang ?? this.tentang,
      pendidikan: pendidikan ?? this.pendidikan,
      lokasi: lokasi ?? this.lokasi,
      kontak: kontak ?? this.kontak,
      skills: skills ?? this.skills,
      fotoProfilBytes: fotoProfilBytes ?? this.fotoProfilBytes,
    );
  }
}

// ===============================
// MODEL PENGALAMAN
// ===============================
class ExperienceData {
  final String judul;
  final String deskripsi;
  final Uint8List? gambarBytes;

  const ExperienceData({
    required this.judul,
    required this.deskripsi,
    this.gambarBytes,
  });

  ExperienceData copyWith({
    String? judul,
    String? deskripsi,
    Uint8List? gambarBytes,
  }) {
    return ExperienceData(
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      gambarBytes: gambarBytes ?? this.gambarBytes,
    );
  }
}

// ===============================
// ROOT APP
// ===============================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Saya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F4FF),
      ),
      home: const HomePage(),
    );
  }
}

// ===============================
// HOME PAGE / HALAMAN UTAMA PROFIL
// ===============================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProfileData _profile = const ProfileData(
    nama: 'Rifs Ramadhani',
    status: 'Mahasiswa Teknik Informatika',
    tentang: 'Belajar Flutter!',
    pendidikan: 'Teknik Informatika - Semester 8',
    lokasi: 'Bandung, Jawa Barat',
    kontak: 'rifs@student.ac.id',
    skills: ['Flutter', 'Dart', 'Java', 'Python', 'Git'],
  );

  ExperienceData? _pengalaman;

  Future<void> _bukaEditProfil() async {
    final hasil = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(profile: _profile),
      ),
    );

    if (hasil != null) {
      setState(() {
        _profile = hasil;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
        ),
      );
    }
  }

  Future<void> _bukaEditPengalaman() async {
    final hasil = await Navigator.push<ExperienceData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditExperiencePage(
          pengalamanAwal: _pengalaman,
        ),
      ),
    );

    if (hasil != null) {
      setState(() {
        _pengalaman = hasil;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengalaman berhasil disimpan'),
        ),
      );
    }
  }

  Widget _buildProfileImage(double radius) {
    if (_profile.fotoProfilBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(_profile.fotoProfilBytes!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.deepPurple.shade100,
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.deepPurple),
                SizedBox(width: 12),
                Text(
                  'Skills',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile.skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  side: BorderSide(color: Colors.deepPurple.shade200),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.work, color: Colors.deepPurple),
                SizedBox(width: 12),
                Text(
                  'Pengalaman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_pengalaman == null)
              const Text(
                'Belum ada pengalaman. Tambahkan melalui drawer Upload Pengalaman.',
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _pengalaman!.gambarBytes != null
                        ? Image.memory(
                      _pengalaman!.gambarBytes!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 80,
                      height: 80,
                      color: Colors.deepPurple.shade100,
                      child: const Icon(
                        Icons.image,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pengalaman!.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_pengalaman!.deskripsi),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.deepPurpleAccent,
                ],
              ),
            ),
            child: const Text(
              'Menu Utama',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Widget Gallery'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Widget Gallery belum dibuat'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Pengalaman'),
            onTap: () {
              Navigator.pop(context);
              _bukaEditPengalaman();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan belum dibuat'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SizedBox(height: 24),

          Center(
            child: _buildProfileImage(42),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              _profile.nama,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              _profile.status,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(number: '12', label: 'Post'),
              _StatItem(number: '128', label: 'Teman'),
              _StatItem(number: '1.2K', label: 'Like'),
            ],
          ),

          const SizedBox(height: 24),

          _buildInfoCard(
            icon: Icons.info,
            title: 'Tentang',
            subtitle: _profile.tentang,
          ),

          _buildInfoCard(
            icon: Icons.school,
            title: 'Pendidikan',
            subtitle: _profile.pendidikan,
          ),

          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Lokasi',
            subtitle: _profile.lokasi,
          ),

          _buildInfoCard(
            icon: Icons.email,
            title: 'Kontak',
            subtitle: _profile.kontak,
          ),

          _buildSkillsCard(),

          _buildExperienceCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaEditProfil,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profil'),
      ),
    );
  }
}

// ===============================
// STAT ITEM
// ===============================
class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(label),
      ],
    );
  }
}

// ===============================
// HALAMAN EDIT PROFIL
// ===============================
class EditProfilePage extends StatefulWidget {
  final ProfileData profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _statusCtrl;
  late final TextEditingController _tentangCtrl;
  late final TextEditingController _pendidikanCtrl;
  late final TextEditingController _lokasiCtrl;
  late final TextEditingController _kontakCtrl;
  late final TextEditingController _skillsCtrl;

  Uint8List? _fotoProfilBytes;

  @override
  void initState() {
    super.initState();

    _namaCtrl = TextEditingController(text: widget.profile.nama);
    _statusCtrl = TextEditingController(text: widget.profile.status);
    _tentangCtrl = TextEditingController(text: widget.profile.tentang);
    _pendidikanCtrl = TextEditingController(text: widget.profile.pendidikan);
    _lokasiCtrl = TextEditingController(text: widget.profile.lokasi);
    _kontakCtrl = TextEditingController(text: widget.profile.kontak);
    _skillsCtrl = TextEditingController(text: widget.profile.skills.join(', '));

    _fotoProfilBytes = widget.profile.fotoProfilBytes;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _statusCtrl.dispose();
    _tentangCtrl.dispose();
    _pendidikanCtrl.dispose();
    _lokasiCtrl.dispose();
    _kontakCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFotoProfil() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _fotoProfilBytes = bytes;
    });
  }

  void _simpanProfil() {
    if (!_formKey.currentState!.validate()) return;

    final skills = _skillsCtrl.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    final hasil = ProfileData(
      nama: _namaCtrl.text.trim(),
      status: _statusCtrl.text.trim(),
      tentang: _tentangCtrl.text.trim(),
      pendidikan: _pendidikanCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      kontak: _kontakCtrl.text.trim(),
      skills: skills,
      fotoProfilBytes: _fotoProfilBytes,
    );

    Navigator.pop(context, hasil);
  }

  Widget _buildPreviewFoto() {
    if (_fotoProfilBytes != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(_fotoProfilBytes!),
      );
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.deepPurple.shade100,
      child: const Icon(
        Icons.person,
        size: 48,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton.icon(
            onPressed: _simpanProfil,
            icon: const Icon(Icons.check),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: Text(
                'Foto Profil',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildPreviewFoto(),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      onPressed: _pilihFotoProfil,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: _pilihFotoProfil,
                icon: const Icon(Icons.photo_library),
                label: const Text('Ganti Foto dari Galeri'),
              ),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              'Informasi Profil',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _namaCtrl,
              label: 'Nama Lengkap',
              icon: Icons.person,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _statusCtrl,
              label: 'Status',
              icon: Icons.badge,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _tentangCtrl,
              label: 'Bio / Tentang',
              icon: Icons.info,
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _pendidikanCtrl,
              label: 'Pendidikan',
              icon: Icons.school,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _lokasiCtrl,
              label: 'Lokasi',
              icon: Icons.location_on,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _kontakCtrl,
              label: 'Kontak',
              icon: Icons.email,
            ),

            const SizedBox(height: 12),

            _inputField(
              controller: _skillsCtrl,
              label: 'Skills, pisahkan dengan koma',
              icon: Icons.star,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _simpanProfil,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// HALAMAN EDIT / UPLOAD PENGALAMAN
// ===============================
class EditExperiencePage extends StatefulWidget {
  final ExperienceData? pengalamanAwal;

  const EditExperiencePage({
    super.key,
    this.pengalamanAwal,
  });

  @override
  State<EditExperiencePage> createState() => _EditExperiencePageState();
}

class _EditExperiencePageState extends State<EditExperiencePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _judulCtrl;
  late final TextEditingController _deskripsiCtrl;

  Uint8List? _gambarBytes;

  @override
  void initState() {
    super.initState();

    _judulCtrl = TextEditingController(
      text: widget.pengalamanAwal?.judul ?? '',
    );

    _deskripsiCtrl = TextEditingController(
      text: widget.pengalamanAwal?.deskripsi ?? '',
    );

    _gambarBytes = widget.pengalamanAwal?.gambarBytes;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihGambarPengalaman() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _gambarBytes = bytes;
    });
  }

  void _simpanPengalaman() {
    if (!_formKey.currentState!.validate()) return;

    final hasil = ExperienceData(
      judul: _judulCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      gambarBytes: _gambarBytes,
    );

    Navigator.pop(context, hasil);
  }

  Widget _buildImagePickerBox() {
    if (_gambarBytes != null) {
      return InkWell(
        onTap: _pilihGambarPengalaman,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _gambarBytes!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return InkWell(
      onTap: _pilihGambarPengalaman,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.shade200,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 56,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 8),
            Text(
              'Ketuk untuk pilih gambar',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text('dari galeri perangkat kamu'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeEdit = widget.pengalamanAwal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(modeEdit ? 'Edit Pengalaman' : 'Upload Pengalaman'),
        actions: [
          TextButton.icon(
            onPressed: _simpanPengalaman,
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImagePickerBox(),

            const SizedBox(height: 24),

            const Text(
              'Informasi Pengalaman',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul pengalaman wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _deskripsiCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi pengalaman wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _simpanPengalaman,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Pengalaman'),
            ),
          ],
        ),
      ),
    );
  }
}