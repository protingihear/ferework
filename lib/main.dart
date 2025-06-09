import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:reworkmobile/firebase_options.dart';
import 'view/animation/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// Handler notifikasi saat app dalam background atau terminated
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   print('🔕 Pesan diterima di background/terminated: ${message.messageId}');
// }

// Future<void> _requestNotificationPermission() async {
//   NotificationSettings settings =
//       await FirebaseMessaging.instance.requestPermission();

//   print('📲 Permission status: ${settings.authorizationStatus}');
//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     print('✅ Notifikasi diizinkan');
//   } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
//     print('❌ Notifikasi ditolak oleh user');
//   } else if (settings.authorizationStatus ==
//       AuthorizationStatus.provisional) {
//     print('⚠️ Notifikasi diizinkan secara sementara');
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Set handler untuk background messages
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // // Minta izin notifikasi (khusus Android 13+ dan iOS)
  // await _requestNotificationPermission();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
       textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),  // Set Poppins globally
      ),

      title: 'iHear',
     // Optional: Dark theme like YouTubessss
      home: const SplashScreen(), // Start with SplashScreen

    );
  }
}