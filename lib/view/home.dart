import 'package:flutter/material.dart';
import 'package:reworkmobile/view/LessonKategori.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../widgets/berita_card.dart';
import '../widgets/feature_button.dart';
import '../widgets/berita_detail.dart';
import 'package:reworkmobile/view/voice_to_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _beritaList = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBerita();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService.fetchUserProfile();
      setState(() => _userProfile = user);
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
      MaterialPageRoute(builder: (context) => BeritaDetail(berita: berita)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildFeatureButtons(),
              _buildBeritaSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bgatas.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFD1F2EB),
                    backgroundImage: _getUserProfileImage(),
                    child: _userProfile?.imageUrl == null ||
                            _userProfile!.imageUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 30, color: Color(0xFF27AE60))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _userProfile?.name ?? "Loading...",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(), // <-- Ini penting biar teks pindah ke bawah
              Text(
                _userProfile != null
                    ? "👋 Hai, ${_userProfile!.name.split(' ').first}!"
                    : "👋 Selamat Datang!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Yuk jelajahi dunia tuli bersama 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider<Object>? _getUserProfileImage() {
    if (_userProfile?.imageUrl != null && _userProfile!.imageUrl.isNotEmpty) {
      return _userProfile!.imageUrl.startsWith('data:image')
          ? MemoryImage(base64Decode(_userProfile!.imageUrl.split(',')[1]))
          : NetworkImage(_userProfile!.imageUrl);
    }
    return null;
  }

  Widget _buildFeatureButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FeatureButtonRow(
            features: [
              {
                'imagePath': 'assets/scan_icon.png',
                'label': '📷 Scan',
                'onTap': () {}
              },
              {
                'imagePath': 'assets/voice_icon.png',
                'label': '🎤 Voice',
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VoiceToTextScreen()),
                    ),
              },
              {
                'imagePath': 'assets/lesson_icon.png',
                'label': '📘 Belajar',
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Lessonkategori()),
                    ),
              },
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📰 Berita Terbaru",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27AE60))),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? const Center(child: Text("Gagal memuat berita"))
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _beritaList.length,
                        itemBuilder: (context, index) {
                          return BeritaCard(
                            berita: _beritaList[index],
                            onTap: () => _showDetailBerita(_beritaList[index]),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
