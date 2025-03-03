import 'package:flutter/material.dart';
import 'package:reworkmobile/services/method_service.dart';
import 'package:reworkmobile/view/LessonSubKategori.dart';

class Lessonkategori extends StatefulWidget {
  @override
  _LessonkategoriState createState() => _LessonkategoriState();
}

class _LessonkategoriState extends State<Lessonkategori> {
  String? userId;

  @override
  void initState() {
    super.initState();
    saveUser();
  }

  void saveUser() async {
    userId = await MethodService.getUserId();
    setState(() {});
  }

  final Future<List<Map<String, dynamic>>> lessons =
      MethodService.fetchCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MY LESSON',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => MethodService.showChoiceDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card utama di atas
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/background_lesson1.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black45, // Warna gelap
                      BlendMode.darken, // Efek gelap
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(26.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Niatkan Belajar Untuk Kemajuan Bangsa',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign Language Learning',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Learn more',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List dari pelajaran
            FutureBuilder<List<Map<String, dynamic>>>(
              future: lessons,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Tampilkan loading jika masih fetching data
                } else if (snapshot.hasError) {
                  return Text(
                      "Error: ${snapshot.error}"); // Tampilkan error jika ada masalah
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("Tidak ada data."); // Jika list kosong
                } else {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var lesson = snapshot.data![index];

                        return FutureBuilder<Map<String, dynamic>?>(
                          future: MethodService.fetchProgress(
                              lesson['id'].toString(), userId!),
                          builder: (context, progressSnapshot) {
                            if (progressSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var progress =
                                progressSnapshot.data?['progress'] ?? 0.0;

                            return GestureDetector(
                              onTap: () {
                                print("Card ditekan: ${lesson['name']}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SubCategoryPage(
                                          lesson['name'],
                                          lesson['subcategories'])),
                                );
                              },
                              child: Card(
                                color: Colors.green.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                child: ListTile(
                                  leading: Icon(Icons.book,
                                      color: Colors.white, size: 32),
                                  title: Text(
                                    lesson['name'] ?? 'Judul tidak tersedia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jumlah kata: ${lesson['subcategories']?.length}',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: (progress / 100).clamp(0.0,
                                            1.0), // Biar gak lebih dari 1.0
                                        backgroundColor: Colors.white38,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

extension on Future<List<Map<String, dynamic>>> {
  get length => null;
}
