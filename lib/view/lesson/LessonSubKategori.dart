import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reworkmobile/services/method_service.dart';
import 'package:reworkmobile/view/lesson/LessonDisplay.dart';
import 'package:reworkmobile/view/lesson/update%20page/view_update_subcategory.dart';

class SubCategoryPage extends StatefulWidget {
  final String name;
  final List<dynamic> subCategory;

  const SubCategoryPage(this.name, this.subCategory, {super.key});

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  String? userId;
  String? userRole;
  List<dynamic> sortedSubCategory = [];
  List<dynamic> filteredSubCategory = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    sortSubCategories();
  }

  void loadUserInfo() async {
    userId = await MethodService.getUserId();
    userRole = await MethodService.getUserRole();
    setState(() {});
  }

  void sortSubCategories() {
    sortedSubCategory = List.from(widget.subCategory);
    sortedSubCategory
        .sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    filteredSubCategory = List.from(sortedSubCategory);
    setState(() {});
  }

  void search(String query) {
    setState(() {
      filteredSubCategory =
          MethodService.searchSubCategory(query, sortedSubCategory);
    });
  }

  Future<void> deleteSubcategory(String id) async {
    try {
      await MethodService.deleteSubcategory(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Subkategori dihapus')),
      );
      setState(() {
        filteredSubCategory.removeWhere((item) => item['id'].toString() == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal hapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.name,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                onChanged: search,
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
                  final sub = filteredSubCategory[index];

                  return Container(
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
                      title: Text(sub['name'].toString()),
                      onTap: () async {
                        if (userId != null) {
                          await MethodService.updateStatus(
                            sub['id'].toString(),
                            true,
                            userId!,
                          );
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerPage(
                              videoUrl:
                                  MethodService.convertDriveLink(sub['video']),
                              title: sub['name'],
                              description: sub['description'],
                            ),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.play,
                                color: Colors.blue),
                            onPressed: () {
                              // Bisa kosong karena sudah ada onTap di atas
                            },
                          ),
                          if (userRole == 'ahli_bahasa') ...[
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditSubcategoryPage(
                                      subcategory: sub,
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    sortSubCategories();
                                    Navigator.pop(
                                        context, true);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Subkategori'),
                                    content: const Text(
                                        'Yakin ingin menghapus ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await deleteSubcategory(sub['id'].toString())
                                      .then((_) {
                                    Navigator.pop(context,true);
                                  });
                                }
                              },
                            ),
                          ]
                        ],
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
