import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reworkmobile/services/method_service.dart';

class SubCategoryPage extends StatefulWidget {
  final String name;
  final List<dynamic> subCategory;

  const SubCategoryPage(this.name, this.subCategory, {super.key});

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
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
                decoration: InputDecoration(
                  hintText: 'Cari kategori yang kamu suka!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.subCategory.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      print("aduh kamu nih megang-megang sembarangan");

                      if (userId != null) {
                        bool result = await MethodService.updateStatus(
                          widget.subCategory[index]['id'].toString(), true, userId!,
                        );

                        if (result) {
                          print("Berhasil update status!");
                        } else {
                          print("Gagal update status!");
                        }
                      } else {
                        print("User ID belum tersedia!");
                      }
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
                        title: Text(widget.subCategory[index]['name'].toString()),
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
