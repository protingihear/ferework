import 'package:flutter/material.dart';
import 'package:reworkmobile/services/method_service.dart'; 

const Color kGreenSoft = Color(0xFFE8F5E9);
const Color kGreenMid = Color(0xFF81C784);
const Color kGreenDark = Color(0xFF388E3C);
const Color kGreenLightAccent = Color(0xFFB3E5FC);

class UpdateCategoryPage extends StatefulWidget {
  final String categoryId;
  final String initialName;

  const UpdateCategoryPage({
    super.key,
    required this.categoryId,
    required this.initialName,
  });

  @override
  State<UpdateCategoryPage> createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  Future<void> _updateCategory() async {
    setState(() => _isLoading = true);
    try {
      final result = await MethodService.updateCategory(widget.categoryId, _nameController.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Berhasil update: ${result['category']['name']}')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal update kategori: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenSoft,
      appBar: AppBar(
        title: const Text('Edit Kategori'),
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kGreenMid),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kGreenLightAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateCategory,
                icon: const Icon(Icons.save),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenMid,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
