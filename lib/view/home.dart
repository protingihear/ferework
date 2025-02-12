import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/api/berita"));
      
      if (response.statusCode == 200) {
        setState(() {
          _beritaList = json.decode(response.body);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception("Gagal mengambil data");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berita tidak dapat dimuat"),
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
            // Bagian Atas dengan Background Image dan Teks
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(),
                          SizedBox(width: 10),
                          Text("naraya"),
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

            // Bagian Informasi (Menampilkan Berita dari Server)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(child: Text("Berita tidak dapat dimuat"))
                      : Column(
                          children: _beritaList.map((berita) => _buildBeritaCard(berita)).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Menampilkan Card Berita
  Widget _buildBeritaCard(dynamic berita) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (berita['foto'] != null)
              Image.memory(base64Decode(berita['foto']), height: 150, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              berita['judul'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              berita['isi'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 5),
            Text(
              "Tanggal: ${DateTime.parse(berita['tanggal']).toLocal()}",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Tombol Fitur
  Widget _buildFeatureButton(String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        // Nanti bisa diarahkan ke halaman lain
      },
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 50, height: 50),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
