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
  int _errorCode = 0;

  @override
  void initState() {
    super.initState();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    try {
      final uri = Uri.parse("http://localhost:5000/api/berita");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _beritaList = data;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception("Error Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorCode = 500;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $_errorCode - Berita tidak dapat dimuat"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
 void _showDetailBerita(dynamic berita) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Ubah background menjadi transparan
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    berita['judul'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            berita['foto'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(berita['foto']),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                  ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    berita['isi'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
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
                            ? Center(child: Text("Error $_errorCode: Berita tidak dapat dimuat"))
                            : SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
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
      ),
    );
  }

  // Widget untuk Menampilkan Card Berita (ROW Style)
  Widget _buildBeritaCard(dynamic berita) {
    return GestureDetector(
      onTap: () => _showDetailBerita(berita),
      child: Container(
        width: 300,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              berita['foto'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                      child: Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      berita['judul'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      berita['isi'].split(" ").take(10).join(" ") + "...",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

  Widget _buildFeatureButton(String imagePath, String label) {
    return Column(
      children: [
        Image.asset(imagePath, width: 50, height: 50),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
