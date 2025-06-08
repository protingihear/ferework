import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MethodService {
  static const String baseUrl = 'http://20.214.51.17:5001/api';
  static Future<void> createCategory(
      BuildContext context, TextEditingController nameController) async {
    final String apiUrl = '$baseUrl/categories';

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

  static Future<void> createSubCategory(
    BuildContext context,
    String? categoryId,
    String name,
    String video,
    String description, {
    http.Client? client,
  }) async {
    if (categoryId == null || name.isEmpty || video.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Semua field harus diisi!')),
        );
      }
      return;
    }

    final String apiUrl = '$baseUrl/categories/$categoryId/subcategories';

    client ??= http.Client(); // <- fallback default

    try {
      final response = await client.post(
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

  static Future<List<Map<String, dynamic>>> fetchCategories(
      {http.Client? client}) async {
    client ??= http.Client();

    final String apiUrl = '$baseUrl/categories';
    try {
      final response = await client.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> showChoiceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFE9FBE7), // soft green
          title: const Text(
            'Pilih Jenis Tambah',
            style: TextStyle(
              color: Color(0xFF4CAF50), // main green
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  showCategoryForm(context);
                },
                icon: const Icon(Icons.category),
                label: const Text('Tambah Kategori'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF98DFAF), // main green
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  showSubCategoryForm(context);
                },
                icon: const Icon(Icons.subtitles),
                label: const Text('Tambah SubKategori'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF98DFAF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFE9FBE7), // soft green
          title: const Text(
            'Buat Kategori Baru',
            style: TextStyle(
              color: Color(0xFF4CAF50), // main green
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Nama Kategori',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => createCategory(dialogContext, nameController),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98DFAF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan'),
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
                backgroundColor: const Color(0xFFE9FBE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Tambah SubKategori',
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                content: const Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                backgroundColor: const Color(0xFFE9FBE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Error'),
                content: const Text('Gagal mengambil kategori'),
              );
            } else {
              List categories = snapshot.data ?? [];

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFFE9FBE7),
                title: const Text(
                  'Tambah SubKategori',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Pilih Kategori',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama SubKategori',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: videoController,
                        decoration: InputDecoration(
                          labelText: 'Video (URL)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
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
                          descriptionController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF98DFAF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan'),
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
      String url = "$baseUrl/categories/$categoryId/progress?userId=$userId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("Data berhasil diambil: $data");
        return data; // Langsung return data JSON
      } else {
        // print("Gagal mengambil data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("Error: $e");
      return null;
    }
  }

  static Future<bool> updateStatus(
      String subCategoryId, bool done, String userId) async {
    try {
      String url = "$baseUrl/subcategories/$subCategoryId/status";
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
        // print("Status berhasil diupdate ✅");
        return true; // Berhasil
      } else {
        // print("Gagal update status ❌: ${response.statusCode}");
        // print(response.body);
        return false; // Gagal
      }
    } catch (e) {
      // print("Error: $e");
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

  static String convertDriveLink(String url) {
    final regex = RegExp(r"\/d\/(.*)\/view");
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      return "https://drive.google.com/uc?id=$fileId&export=download";
    }
    return url;
  }

  static List<dynamic> searchSubCategory(
      String query, List<dynamic> subCategories) {
    if (query.isEmpty) {
      return subCategories;
    }

    return subCategories
        .where((item) =>
            item['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return userMap['role'] as String?;
  }
}
