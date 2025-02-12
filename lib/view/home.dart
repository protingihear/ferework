import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
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
                          Text(
                            "Naraya",
                            style: TextStyle(
  color: Color(0xFF195728), 
  fontSize: 16, 
  fontWeight: FontWeight.bold,
),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Selamat datang, Naraya!',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Yuk Jelajahi Dunia Tuli Bersama!',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bagian Fitur di Tengah
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureButton(context, 'assets/scan_icon.png', 'Scan to Text'),
                  _buildFeatureButton(context, 'assets/voice_icon.png', 'Voice to Text'),
                  _buildFeatureButton(context, 'assets/lesson_icon.png', 'Lesson'),
                ],
              ),
            ),

            // Bagian Informasi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 200,
                color: Colors.grey[300], // Placeholder warna
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        // Nanti diisi navigasi ke halaman lain
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label belum tersedia')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100, // Lebih besar
            height: 100, // Lebih besar
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20), // Lebih melengkung
            ),
            child: Center(
              child: Image.asset(imagePath, width: 50, height: 50), // Perbesar ikon
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
