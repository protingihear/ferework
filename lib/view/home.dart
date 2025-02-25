import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../widgets/berita_card.dart';
import '../widgets/feature_button.dart';
import '../widgets/berita_detail.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _beritaList = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;
  int _errorCode = 0;

  Future<void> _checkSavedCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_cookie');

    if (sessionId != null) {
      print("✅ Cookie tersimpan: $sessionId");
    } else {
      print("❌ Tidak ada cookie tersimpan.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBerita();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService.fetchUserProfile();
      setState(() {
        _userProfile = user;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _loadBerita() async {
    try {
      final berita = await ApiService.fetchBerita();
      setState(() {
        _beritaList = berita;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _showDetailBerita(dynamic berita) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeritaDetail(berita: berita),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Background Image
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/bgatas.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _userProfile?.imageUrl != null &&
                                      _userProfile!.imageUrl.isNotEmpty
                                  ? (_userProfile!.imageUrl
                                          .startsWith('data:image')
                                      ? Image.memory(base64Decode(_userProfile!
                                              .imageUrl
                                              .split(',')[1]))
                                          .image
                                      : NetworkImage(_userProfile!.imageUrl))
                                  : null, // No backgroundImage if _userProfile.imageUrl is null or empty
                              child: (_userProfile?.imageUrl == null ||
                                      _userProfile!.imageUrl.isEmpty)
                                  ? Icon(Icons.person, size: 40)
                                  : null, // Show icon only if no image
                            ),
                            SizedBox(width: 10),
                            Text(
                              _userProfile?.name ?? "Loading...",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          _userProfile != null
                              ? "Selamat datang, ${_userProfile!.name.split(' ').first}!"
                              : "Welcome!",
                        ),
                        Text(
                          'Yuk Jelajahi Dunia Tuli Bersama!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Bagian Fitur
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FeatureButtonRow(
                      features: [
                        {
                          'imagePath': 'assets/scan_icon.png',
                          'label': 'Scan to Text',
                          'onTap': () {
                            print("Scan to Text clicked");
                            // TODO: Navigate to Scan page
                          },
                        },
                        {
                          'imagePath': 'assets/voice_icon.png',
                          'label': 'Voice to Text',
                          'onTap': () {
                            print("Voice to Text clicked");
                            // TODO: Navigate to Voice page
                          },
                        },
                        {
                          'imagePath': 'assets/lesson_icon.png',
                          'label': 'Lesson',
                          'onTap': () {
                            print("Lesson clicked");
                            // TODO: Navigate to Lesson page
                          },
                        },
                      ],
                    ),
                  ],
                ),
              ),
              // Bagian Berita dalam Row (Horizontal Scroll)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Berita Terbaru",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _isLoading
                        ? Center(
                            child: Text(
                                "Error $_errorCode: Berita tidak dapat dimuat"))
                        : _hasError
                            ? Center(
                                child: Text(
                                    "Error $_errorCode: Berita tidak dapat dimuat"))
                            : SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _beritaList.length,
                                  itemBuilder: (context, index) {
                                    return BeritaCard(
                                      berita: _beritaList[index],
                                      onTap: () =>
                                          _showDetailBerita(_beritaList[index]),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
