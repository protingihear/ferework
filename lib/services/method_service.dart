import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori berhasil dibuat!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat kategori: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  static Future<void> createSubCategory(BuildContext context,
      String? categoryId, String name, String video) async {
    if (categoryId == null || name.isEmpty || video.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    final String apiUrl =
        'https://berework-production.up.railway.app/api/subcategories';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categoryid': categoryId,
        'name': name,
        'video': video,
        'done': false, // Sesuaikan dengan default di database
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Tutup dialog setelah sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SubKategori berhasil dibuat!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat SubKategori!')),
      );
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final String apiUrl =
        'https://berework-production.up.railway.app/api/categories';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Kategori berhasil diambil: $data"); // Debugging
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Gagal mengambil kategori, status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetchCategories: $e");
      return [];
    }
  }

  static void showChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Jenis Tambah'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showCategoryForm(context);
                },
                child: Text('Tambah Kategori'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
      builder: (context) {
        return AlertDialog(
          title: Text('Buat Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Nama Kategori'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => createCategory(context, nameController),
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
      builder: (context) {
        return FutureBuilder<List>(
          future:
              fetchCategories(), // 🔥 Fetch kategori sebelum tampilkan dialog
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Tambah SubKategori'),
                content:
                    Center(child: CircularProgressIndicator()), // ⏳ Loading
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
                            InputDecoration(labelText: "Pilih Kategori"),
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
                            InputDecoration(labelText: "Nama SubKategori"),
                      ),
                      TextField(
                        controller: videoController,
                        decoration: InputDecoration(labelText: "Video (URL)"),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: "Deskripsi"),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCategory != null &&
                          nameController.text.isNotEmpty &&
                          videoController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty) {
                        // TODO: Kirim data ke backend
                        print("Kategori ID: $selectedCategory");
                        print("Nama: ${nameController.text}");
                        print("Video: ${videoController.text}");
                        print("Deskripsi: ${descriptionController.text}");

                        Navigator.pop(context);
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
}
