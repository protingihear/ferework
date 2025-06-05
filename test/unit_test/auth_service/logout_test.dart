import 'package:reworkmobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences.setMockInitialValues({
    'session_cookie': 'NO4Rg6x3oQ9V6-sbUGPyO67kDxWgc3vx	',
    'tt_cookie': 's:NO4Rg6x3oQ9V6-sbUGPyO67kDxWgc3vx.CzuFylhpsm94lPIC2ApqzJTlTTbYSeUYn6Jm6cZUMGU	',
  });

  print('🧪 TCU_002 - Logout dengan session valid');

  await AuthService.logout();

  print('✅ TCU_002 - Logout function dipanggil, cek console untuk hasil.');
}
