import 'package:flutter/material.dart';
import 'package:reworkmobile/view/lesson/LessonKategori.dart';
import 'package:reworkmobile/view/scan%20to%20text/scan_to_text.dart';
import 'package:reworkmobile/view/home/berita/view_all_berita.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/berita_card.dart';
import '../../widgets/feature_button.dart';
import '../../widgets/berita_detail.dart';
import 'package:reworkmobile/view/voice%20to%20text/voice_to_text.dart';

const Color kGreenSoft = Color(0xFFE8F5E9);
const Color kGreenMid = Color(0xFF81C784);
const Color kGreenDark = Color(0xFF388E3C);
const Color kGreenLightAccent = Color(0xFFB3E5FC);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _beritaList = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;
  final List<String> _greetingsEmojis = ['🎉', '✨', '🦄', '💫', '🎈'];

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

  String _getRandomEmoji() {
    _greetingsEmojis.shuffle();
    return _greetingsEmojis.first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kGreenSoft,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFeatureButtons(screenWidth),
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
            color: kGreenMid.withOpacity(0.85),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: kGreenLightAccent,
                    backgroundImage: _getUserProfileImage(),
                    child: _userProfile?.imageUrl == null ||
                            _userProfile!.imageUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 30, color: kGreenDark)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _userProfile?.name ?? "\u{1F464} Memuat...",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _userProfile != null
                    ? "\u{1F44B} Hai, ${_userProfile!.name.split(' ').first}!"
                    : "\u{1F44B} Selamat Datang!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Yuk jelajahi dunia tuli bersama ${_getRandomEmoji()}',
                style: const TextStyle(
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
          : NetworkImage(_userProfile!.imageUrl) as ImageProvider;
    }
    return null;
  }

  Widget _buildFeatureButtons(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FeatureButton(
            imagePath: 'assets/scan_icon.png',
            label: 'Scan to Text',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignDetectionPage()),
            ),
            width: screenWidth * 0.26,
            color: kGreenLightAccent,
          ),
          FeatureButton(
            imagePath: 'assets/voice_icon.png',
            label: 'Voice to Text',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VoiceToTextScreen()),
            ),
            width: screenWidth * 0.26,
            color: kGreenLightAccent,
          ),
          FeatureButton(
            imagePath: 'assets/lesson_icon.png',
            label: 'Lesson',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Lessonkategori()),
            ),
            width: screenWidth * 0.26,
            color: kGreenLightAccent,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "📰 Berita Terbaru",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kGreenDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllBeritaPage()),
                  );
                },
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? const Center(
                      child: Text(
                        "😢 Gagal memuat berita. Coba lagi ya!",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _beritaList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 300,
                            child: BeritaCard(
                              berita: _beritaList[index],
                              onTap: () =>
                                  _showDetailBerita(_beritaList[index]),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
