class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final String emailPengirim; // <-- Variabel email ditambahkan
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'email_pengirim': emailPengirim, // Mengirim email ke server
    'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
  };

  static Catatan fromJson(Map<String, dynamic> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    // Jika dari server tidak ada email, kita beri nilai default agar tidak error
    emailPengirim: (m['email_pengirim'] ?? m['emailPengirim'] ?? '-') as String,
    dibuatPada: DateTime.parse(m['dibuat_pada'] as String),
  );

  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? emailPengirim
  }) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        emailPengirim: emailPengirim ?? this.emailPengirim,
        dibuatPada: dibuatPada,
      );
}