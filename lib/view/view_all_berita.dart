import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reworkmobile/services/api_service.dart';
import 'package:reworkmobile/view/view_add_berita.dart';
import 'package:reworkmobile/widgets/berita_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllBeritaPage extends StatefulWidget {
  const AllBeritaPage({Key? key}) : super(key: key);

  @override
  State<AllBeritaPage> createState() => _AllBeritaPageState();
}

class _AllBeritaPageState extends State<AllBeritaPage> {
  late Future<List<dynamic>> _beritaList;
  List<dynamic> _allBerita = [];
  List<dynamic> _filteredBerita = [];
  final TextEditingController _searchController = TextEditingController();

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return userMap['role'] as String?;
  }

  @override
  void initState() {
    super.initState();
    _beritaList = ApiService.fetchBerita();

    _beritaList.then((data) {
      setState(() {
        _allBerita = data;
        _filteredBerita = data;
      });
    });

    _searchController.addListener(_filterBerita);
  }

  void _filterBerita() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredBerita = _allBerita;
      });
    } else {
      setState(() {
        _filteredBerita = _allBerita.where((berita) {
          final judul = (berita['judul'] ?? '').toString().toLowerCase();
          final isi = (berita['isi'] ?? '').toString().toLowerCase();
          return judul.contains(query) || isi.contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const softGreen = Color(0xFFD0F0C0);
    const mainGreen = Color(0xFF98DFAF);

    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator sambil nunggu role
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roleUser = snapshot.data;

        return Scaffold(
          backgroundColor: softGreen,
          appBar: AppBar(
            title: const Text("Berita Terkini"),
            backgroundColor: mainGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButton: roleUser == 'ahli_bahasa'
              ? FloatingActionButton(
                  backgroundColor: mainGreen,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewAddBeritaPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berita...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  ),
                ),
              ),

              // List berita
              Expanded(
                child: _filteredBerita.isEmpty
                    ? const Center(child: Text("Berita tidak ditemukan."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBerita.length,
                        itemBuilder: (context, index) {
                          final berita = _filteredBerita[index];
                          final judul = berita['judul'] ?? '';
                          final isi = berita['isi'] ?? '';
                          final tanggal = berita['tanggal'] ?? '';
                          final fotoBase64 = berita['foto'];
                          final kategori = "derikadem"; // Dummy kategori

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BeritaDetail(berita: berita),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (fotoBase64 != null && fotoBase64.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        bottomLeft: Radius.circular(18),
                                      ),
                                      child: Image.memory(
                                        base64Decode(fotoBase64),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          bottomLeft: Radius.circular(18),
                                        ),
                                      ),
                                      child:
                                          const Icon(Icons.image, color: Colors.white),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: mainGreen.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  kategori,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                tanggal.split("T").first,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            judul,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isi.length > 80
                                                ? '${isi.substring(0, 80)}...'
                                                : isi,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
