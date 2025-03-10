import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reworkmobile/services/method_service.dart';
import 'package:reworkmobile/view/LessonDisplay.dart';

class SubCategoryPage extends StatefulWidget {
  final String name;
  final List<dynamic> subCategory;

  const SubCategoryPage(this.name, this.subCategory, {super.key});

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  String? userId;
  List<dynamic> sortedSubCategory = [];
  List<dynamic> filteredSubCategory = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    saveUser();
    sortSubCategories();
  }

  void saveUser() async {
    userId = await MethodService.getUserId();
    setState(() {});
  }

  void sortSubCategories() {
    sortedSubCategory = List.from(widget.subCategory);
    sortedSubCategory.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    filteredSubCategory = List.from(sortedSubCategory); // Inisialisasi filter dengan daftar awal
    setState(() {});
  }

  void search(String query) {
    setState(() {
      filteredSubCategory = MethodService.searchSubCategory(query, sortedSubCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: search, // Memanggil fungsi search setiap kali teks berubah
                decoration: InputDecoration(
                  hintText: 'Cari kategori yang kamu suka!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            searchController.clear();
                            search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSubCategory.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      if (userId != null) {
                        bool result = await MethodService.updateStatus(
                          filteredSubCategory[index]['id'].toString(),
                          true,
                          userId!,
                        );

                        if (result) {
                          print("Berhasil update status!");
                        } else {
                          print("Gagal update status!");
                        }
                      } else {
                        print("User ID belum tersedia!");
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerPage(
                            videoUrl: MethodService.convertDriveLink(
                                filteredSubCategory[index]['video']),
                            title: filteredSubCategory[index]['name'],
                            description: filteredSubCategory[index]['description'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(filteredSubCategory[index]['name'].toString()),
                        trailing: IconButton(
                          icon: const Icon(
                            LucideIcons.play,
                            color: Colors.blue,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
