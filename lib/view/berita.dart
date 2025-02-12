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
      home: BeritaScreen(),
    );
  }
}

// Halaman Berita (ListView)
class BeritaScreen extends StatefulWidget {
  @override
  _BeritaScreenState createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  List<dynamic> _beritaList = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _errorCode;

  @override
  void initState() {
    super.initState();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/berita"));

      if (response.statusCode == 200) {
        setState(() {
          _beritaList = json.decode(response.body);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorCode = response.statusCode;
        });
      }
    } catch (e) {
      print("Error: $e");

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorCode = 5004; // Kode khusus jika error tidak diketahui
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Berita Terkini")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Gagal memuat berita",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Kode Error: $_errorCode",
                          style: TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _beritaList.length,
                  itemBuilder: (context, index) {
                    return _buildBeritaCard(context, _beritaList[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchBerita, // Refresh berita jika ditekan
        child: Icon(Icons.refresh),
      ),
    );
  }

  // Widget untuk menampilkan berita dalam Card
  Widget _buildBeritaCard(BuildContext context, dynamic berita) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(beritaId: berita['id'])),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                berita['sumber'],
                style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text(
                berita['judul'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                berita['tanggal'],
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 5),
              Text(
                berita['deskripsi'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Detail Berita
class DetailScreen extends StatefulWidget {
  final int beritaId;
  DetailScreen({required this.beritaId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _beritaDetail;
  bool _isLoading = true;
  bool _hasError = false;
  int? _errorCode;

  @override
  void initState() {
    super.initState();
    fetchBeritaDetail();
  }

  Future<void> fetchBeritaDetail() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/berita/${widget.beritaId}"));

      if (response.statusCode == 200) {
        setState(() {
          _beritaDetail = json.decode(response.body);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorCode = response.statusCode;
        });
      }
    } catch (e) {
      print("Error: $e");

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorCode = 5004; // Kode khusus jika error tidak diketahui
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Berita")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Gagal memuat berita",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Kode Error: $_errorCode",
                          style: TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _beritaDetail!['sumber'],
                        style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _beritaDetail!['judul'],
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _beritaDetail!['tanggal'],
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _beritaDetail!['deskripsi'],
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
    );
  }
}
