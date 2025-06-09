import 'package:flutter/material.dart';
import 'package:reworkmobile/services/method_service.dart';

const Color kGreenSoft = Color(0xFFE8F5E9);
const Color kGreenMid = Color(0xFF81C784);
const Color kGreenDark = Color(0xFF388E3C);
const Color kGreenLightAccent = Color(0xFFB3E5FC);

class EditSubcategoryPage extends StatefulWidget {
  final Map<String, dynamic> subcategory;

  const EditSubcategoryPage({super.key, required this.subcategory});

  @override
  State<EditSubcategoryPage> createState() => _EditSubcategoryPageState();
}

class _EditSubcategoryPageState extends State<EditSubcategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.subcategory['name'] ?? '';
    _videoController.text = widget.subcategory['video'] ?? '';
    _descController.text = widget.subcategory['description'] ?? '';
  }

  void _updateSubcategory() async {
    setState(() => _isLoading = true);

    final success = await MethodService.updateSubCategory(
      id: widget.subcategory['id'].toString(),
      name: _nameController.text,
      video: _videoController.text,
      description: _descController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subkategori berhasil diperbarui")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui subkategori")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenSoft,
      appBar: AppBar(
        title: const Text('Edit Subkategori'),
        backgroundColor: kGreenMid,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _videoController,
                  decoration: const InputDecoration(
                    labelText: 'Link Video',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _updateSubcategory,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
