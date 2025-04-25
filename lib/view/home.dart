import 'package:flutter/material.dart';
import 'package:reworkmobile/view/lessonkategori.dart'; // Original import preserved
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../widgets/berita_card.dart';
import '../widgets/feature_button.dart';
import '../widgets/berita_detail.dart';
import 'package:reworkmobile/view/voice_to_text.dart';

import 'package:reworkmobile/view/Relation.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _beritaList = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBerita();
    
    _scrollController.addListener(() {
      setState(() {
        _showBackToTop = _scrollController.offset > 400;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      print("Error fetching berita: $e");
    }
  }

  void _showDetailBerita(dynamic berita) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BeritaDetail(berita: berita)),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildFeatureButtons(),
                  _buildBeritaSection(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            
            if (_showBackToTop)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.blue[700],
                  child: Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _scrollToTop,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _getUserProfileImage(),
                    child: _userProfile?.imageUrl == null ||
                            _userProfile!.imageUrl.isEmpty
                        ? Icon(Icons.person, size: 40)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _userProfile?.name ?? "Loading...",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF195728),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 80),
              Text(
                _userProfile != null
                    ? "Selamat datang, ${_userProfile!.name.split(' ').first}!"
                    : "Welcome!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
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
    );
  }

  ImageProvider<Object>? _getUserProfileImage() {
    if (_userProfile?.imageUrl != null && _userProfile!.imageUrl.isNotEmpty) {
      if (_userProfile!.imageUrl.startsWith('data:image')) {
        try {
          return MemoryImage(base64Decode(_userProfile!.imageUrl.split(',')[1]));
        } catch (e) {
          print("Error decoding base64 image: $e");
          return null;
        }
      } else {
        return NetworkImage(_userProfile!.imageUrl);
      }
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
                'label': 'Scan to Text',
                'onTap': () =>Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RelationsPage()),
                    ),
                'iconSize': 40.0,
              },
              {
                'imagePath': 'assets/voice_icon.png',
                'label': 'Voice to Text',
                'iconSize': 40.0,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VoiceToTextScreen()),
                    ),
              },
              {
                'imagePath': 'assets/lesson_icon.png',
                'label': 'Lesson',
                'iconSize': 40.0,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                           builder: (context) => Lessonkategori()), // Preserved original case
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
          Text(
            "Berita Terbaru",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
                  ? Center(child: Text("Gagal memuat berita"))
                  : _beritaList.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada berita tersedia",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _beritaList.length,
                          separatorBuilder: (context, index) => SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return BeritaCard(
                              berita: _beritaList[index],
                              onTap: () => _showDetailBerita(_beritaList[index]),
                            );
                          },
                        ),
        ],
      ),
    );
  }
}