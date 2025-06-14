import 'package:flutter/material.dart';
import 'package:reworkmobile/view/lesson/update%20page/view_update_kategori.dart';
import 'package:reworkmobile/services/method_service.dart';
import 'package:reworkmobile/view/lesson/LessonSubKategori.dart';

const softGreen = Color(0xFFD0F0C0);
const mainGreen = Color(0xFF98DFAF);
const Color kGreenSoft = Color(0xFFE8F5E9);
const Color kGreenLightAccent = Color(0xFFB3E5FC);

class Lessonkategori extends StatefulWidget {
  @override
  _LessonkategoriState createState() => _LessonkategoriState();
}

class _LessonkategoriState extends State<Lessonkategori> {
  String? userId;
  String? userRole;
  late Future<List<Map<String, dynamic>>> lessons;

  @override
  void initState() {
    super.initState();
    saveUser();
    lessons = MethodService.fetchCategories();
  }

  void saveUser() async {
    userId = await MethodService.getUserId();
    userRole = await MethodService.getUserRole();
    setState(() {});
  }

  Future<void> refreshLessons() async {
    setState(() {
      lessons = MethodService.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenSoft,
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
      ),
      floatingActionButton: userRole == 'ahli_bahasa'
          ? FloatingActionButton(
              backgroundColor: kGreenLightAccent,
              foregroundColor: Colors.white,
              onPressed: () {
                MethodService.showChoiceDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: refreshLessons,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/background_lesson1.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black45,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Niatkan Belajar Untuk Kemajuan Bangsa',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sign Language Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Learn more',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: lessons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Tidak ada data.");
                  } else {
                    List<Map<String, dynamic>> sortedLessons =
                        List.from(snapshot.data!);
                    sortedLessons.sort(
                        (a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedLessons.length,
                        itemBuilder: (context, index) {
                          var lesson = sortedLessons[index];

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: MethodService.fetchProgress(
                                lesson['id'].toString(), userId ?? ''),
                            builder: (context, progressSnapshot) {
                              var progress =
                                  progressSnapshot.data?['progress'] ?? 0.0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubCategoryPage(
                                          lesson['name'],
                                          lesson['subcategories'],
                                        ),
                                      )).then((value) {
                                    if (value == true) {
                                      refreshLessons();
                                    }
                                  });
                                },
                                child: Card(
                                  color: Colors.green.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.book,
                                            color: Colors.white, size: 32),
                                        title: Text(
                                          lesson['name'] ??
                                              'Judul tidak tersedia',
                                          style: const TextStyle(
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
                                              style: const TextStyle(
                                                  color: Colors.white70),
                                            ),
                                            const SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value: (progress / 100)
                                                  .clamp(0.0, 1.0),
                                              backgroundColor: Colors.white38,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(
                                                Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        trailing: userRole == 'ahli_bahasa'
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  UpdateCategoryPage(
                                                                    categoryId:
                                                                        lesson['id']
                                                                            .toString(),
                                                                    initialName:
                                                                        lesson[
                                                                            'name'],
                                                                  ))).then(
                                                          (value) {
                                                        if (value == true) {
                                                          refreshLessons();
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color:
                                                            Colors.redAccent),
                                                    onPressed: () async {
                                                      final confirm =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Hapus Kategori'),
                                                          content: const Text(
                                                              'Yakin ingin menghapus kategori ini?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Batal'),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      false),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Hapus'),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      true),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirm == true) {
                                                        try {
                                                          await MethodService
                                                              .deleteCategory(
                                                                  lesson['id']
                                                                      .toString());
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  '✅ Kategori berhasil dihapus'),
                                                            ),
                                                          );
                                                          refreshLessons();
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  '❌ Gagal hapus kategori: $e'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              )
                                            : null,
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
