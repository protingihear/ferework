import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:reworkmobile/services/berita_service.dart';

void main() async {
  print('🧪 TCU_007 - Upload berita dengan gambar dari internet');

  try {
    // Step 1: Download gambar dan simpan di direktori lokal sementara
    final imageUrl =
        'https://preview.redd.it/mas-amba-nyobain-snack-indo-v0-8vfq12nltche1.jpeg?width=554&format=pjpg&auto=webp&s=c76285ad34b29f212ea2731a45298a75255d3b06';

    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode != 200) {
      throw Exception('Gagal download gambar. Status: ${response.statusCode}');
    }

    final filePath = '${Directory.current.path}/mas_amba.jpeg';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Step 2: Upload berita
    final success = await BeritaService.uploadBerita(
      judul: 'Mas Amba Nyobain Snack Indo',
      isi: 'Berita heboh hari ini, Mas Amba nyobain ciki lokal!',
      tanggal: DateTime.now(),
      foto: file,
    );

    if (success) {
      print('✅ TCU_007 - Berita berhasil diupload dengan gambar');
    } else {
      print('❌ TCU_007 - Gagal upload berita dengan gambar');
    }
  } catch (e) {
    print('❌ TCU_007 - Error saat test: $e');
  }
}
