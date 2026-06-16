class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final String emailPengirim;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
      'email_pengirim': emailPengirim,
      'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
    };
  }

  static Catatan fromMap(Map<String, Object?> map) {
    return Catatan(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      kategori: map['kategori'] as String,
      emailPengirim: map['email_pengirim'] as String,
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuat_pada'] as int,
      ),
    );
  }

  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? emailPengirim,
  }) {
    return Catatan(
      id: id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      kategori: kategori ?? this.kategori,
      emailPengirim: emailPengirim ?? this.emailPengirim,
      dibuatPada: dibuatPada,
    );
  }
}