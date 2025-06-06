import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class BeritaService {
  static const String _baseUrl =
      'http://20.214.51.17:5001';

  static Future<bool> uploadBerita({
    required String judul,
    required String isi,
    required DateTime tanggal,
    File? foto,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/berita');
      var request = http.MultipartRequest('POST', uri);

      // Field biasa
      request.fields['judul'] = judul;
      request.fields['isi'] = isi;
      request.fields['tanggal'] = tanggal.toIso8601String();

      // Jika ada foto, tambahkan ke request
      if (foto != null) {
        final mimeType = lookupMimeType(foto.path);
        final multipartFile = await http.MultipartFile.fromPath(
          'foto',
          foto.path,
          contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
          filename: basename(foto.path),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        // print("✅ Berita berhasil ditambahkan");
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        // print("❌ Gagal tambah berita: $respStr");
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
