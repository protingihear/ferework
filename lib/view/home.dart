import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reworkmobile/view/LessonKategori.dart';
import 'dart:convert';

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
    fetchBerita();
    _checkSavedCookie();
  }

  Future<void> fetchBerita() async {
    try {
      final response = await http.get(
          Uri.parse("https://berework-production.up.railway.app/api/berita"));

      if (response.statusCode == 200) {
        setState(() {
          _beritaList = json.decode(response.body);
          _isLoading = false;
          _hasError = false;
          _errorCode = 0;
        });
      } else {
        throw Exception("Error Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorCode = 500; // Simpan error default 500 jika tidak diketahui
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $_errorCode - Berita tidak dapat dimuat"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Relations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
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
                          CircleAvatar(),
                          SizedBox(width: 10),
                          Text("Naraya"),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Selamat datang Naraya!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
            ),

            // Bagian Fitur
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureButton('assets/scan_icon.png', 'Scan to Text'),
                  _buildFeatureButton('assets/voice_icon.png', 'Voice to Text'),
                  _buildFeatureButton('assets/lesson_icon.png', 'Lesson'),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _hasError
                          ? Center(
                              child: Text(
                                  "Error $_errorCode: Berita tidak dapat dimuat"))
                          : SizedBox(
                              height:
                                  200, // Atur tinggi list berita agar tetap rapih
                              child: ListView.builder(
                                scrollDirection:
                                    Axis.horizontal, // **ROW MODE**
                                itemCount: _beritaList.length,
                                itemBuilder: (context, index) {
                                  return _buildBeritaCard(_beritaList[index]);
                                },
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Menampilkan Card Berita (ROW Style)
  Widget _buildBeritaCard(dynamic berita) {
    return Container(
      width: 300, // Pastikan lebar card tetap
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailBeritaScreen(berita)),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar dengan tinggi tetap
              berita['foto'] != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.memory(
                        base64Decode(berita['foto']),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: Center(
                          child:
                              Icon(Icons.image, size: 50, color: Colors.grey)),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul berita
                    Text(
                      berita['judul'],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    // Isi berita dengan batas tinggi agar tidak overflow
                    SizedBox(
                      height: 40,
                      child: Text(
                        berita['isi'].split(" ").take(10).join(" ") + "...",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Tanggal: ${DateTime.parse(berita['tanggal']).toLocal()}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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

  // Widget untuk Tombol Fitur
  Widget _buildFeatureButton(String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Lessonkategori(),
          ),
        );
      },
      child: Column(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          SizedBox(height: 5),
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class DetailBeritaScreen extends StatelessWidget {
  final dynamic berita;

  DetailBeritaScreen(this.berita);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Berita")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            berita['foto'] != null
                ? Image.memory(base64Decode(berita['foto']),
                    width: double.infinity, fit: BoxFit.cover)
                : Container(height: 200, color: Colors.grey[300]),
            SizedBox(height: 10),
            Text(
              berita['judul'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              berita['isi'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
