import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class BeritaService {
  static const String _baseUrl = 'http://20.214.51.17:5001';

  static Future<bool> uploadBerita({
    required String judul,
    required String isi,
    required DateTime tanggal,
    File? foto,
    http.Client? client,
  }) async {
    client ??= http.Client();

    try {
      final uri = Uri.parse('$_baseUrl/api/berita');
      var request = http.MultipartRequest('POST', uri);

      request.fields['judul'] = judul;
      request.fields['isi'] = isi;
      request.fields['tanggal'] = tanggal.toIso8601String();

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
      final response = await client.send(request);

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<void> updateBerita({
    required int id,
    required String judul,
    required String isi,
    required String tanggal,
    File? fotoFile,
    http.Client? client,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/berita/$id');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['judul'] = judul;
    request.fields['isi'] = isi;
    request.fields['tanggal'] = tanggal;

    if (fotoFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('foto', fotoFile.path));
    }

    final response = await (client ?? http.Client()).send(request);

    if (response.statusCode == 200) {
      print('Berita berhasil diupdate');
    } else {
      print('Gagal update berita: ${response.statusCode}');
    }
  }

  static Future<void> deleteBerita(int id, {http.Client? client}) async {
    final uri = Uri.parse('$_baseUrl/api/berita/$id');
    final response = await (client ?? http.Client()).delete(uri);

    if (response.statusCode == 200) {
      print('Berita berhasil dihapus');
    } else {
      print('Gagal menghapus berita: ${response.statusCode}');
    }
  }
}
