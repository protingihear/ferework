import 'package:reworkmobile/services/comumnity_service.dart';

void main() async {
  print('🧪 TCU_011 - Fetch Communities');

  try {
    final communities = await ComumnityService.fetchCommunities();

    if (communities.isNotEmpty) {
      print('✅ TCU_011 - Berhasil ambil ${communities.length} komunitas');
    } else {
      print('✅ TCU_011 - Request berhasil, tapi tidak ada komunitas');
    }
  } catch (e) {
    print('❌ TCU_011 - Gagal ambil komunitas: $e');
  }
}
