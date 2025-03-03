import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MethodService {
  static Future<void> createCategory(
      BuildContext context, TextEditingController nameController) async {
    final String apiUrl =
        'https://berework-production.up.railway.app/api/categories';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': nameController.text}),
      );

      if (response.statusCode == 201 && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori berhasil dibuat!')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat kategori: ${response.body}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  static Future<void> createSubCategory(BuildContext context,
      String? categoryId, String name, String video, String description) async {
    if (categoryId == null || name.isEmpty || video.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Semua field harus diisi!')),
        );
      }
      return;
    }

    final String apiUrl =
        'https://berework-production.up.railway.app/api/categories/$categoryId/subcategories';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'video': video,
          'description': description,
          'done': false,
        }),
      );

      if (response.statusCode == 201 && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SubKategori berhasil dibuat!')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat SubKategori!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final String apiUrl =
        'https://berework-production.up.railway.app/api/categories';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print(data);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static void showChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pilih Jenis Tambah'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  showCategoryForm(context);
                },
                child: Text('Tambah Kategori'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  showSubCategoryForm(context);
                },
                child: Text('Tambah SubKategori'),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showCategoryForm(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Buat Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Nama Kategori'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => createCategory(dialogContext, nameController),
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  static void showSubCategoryForm(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController videoController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<List>(
          future: fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Tambah SubKategori'),
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Gagal mengambil kategori'),
              );
            } else {
              List categories = snapshot.data ?? [];

              return AlertDialog(
                title: Text('Tambah SubKategori'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration:
                            InputDecoration(labelText: 'Pilih Kategori'),
                        items: categories
                            .map<DropdownMenuItem<String>>((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'].toString(),
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategory = value;
                        },
                      ),
                      TextField(
                        controller: nameController,
                        decoration:
                            InputDecoration(labelText: 'Nama SubKategori'),
                      ),
                      TextField(
                        controller: videoController,
                        decoration: InputDecoration(labelText: 'Video (URL)'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Deskripsi'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCategory != null &&
                          nameController.text.isNotEmpty &&
                          videoController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty) {
                        createSubCategory(
                            dialogContext,
                            selectedCategory,
                            nameController.text,
                            videoController.text,
                            descriptionController.text);
                      }
                    },
                    child: Text('Simpan'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> fetchProgress(
      String categoryId, String userId) async {
    try {
      String url =
          "https://berework-production.up.railway.app/api/categories/$categoryId/progress?userId=$userId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Data berhasil diambil: $data");
        return data; // Langsung return data JSON
      } else {
        print("Gagal mengambil data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<bool> updateStatus(
      String subCategoryId, bool done, String userId) async {
    try {
      String url =
          "https://berework-production.up.railway.app/api/subcategories/$subCategoryId/status";
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "done": done,
          "userId": userId,
        }),
      );

      if (response.statusCode == 200) {
        print("Status berhasil diupdate ✅");
        return true; // Berhasil
      } else {
        print("Gagal update status ❌: ${response.statusCode}");
        print(response.body);
        return false; // Gagal
      }
    } catch (e) {
      print("Error: $e");
      return false; // Error
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Coba ambil sebagai int dulu
    int? userIdInt = prefs.getInt('user_id');
    if (userIdInt != null) {
      return userIdInt.toString();
    }

    // Jika bukan int, coba ambil sebagai string
    String? userIdStr = prefs.getString('user_id');
    return userIdStr;
  }
}
