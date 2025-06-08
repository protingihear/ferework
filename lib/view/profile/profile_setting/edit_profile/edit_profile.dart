import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/user_profile.dart';
import '../../../../services/api_service.dart';
import '../../../../services/image_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController bioController;
  String? selectedGender;
  File? profileImageFile;
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    bioController = TextEditingController(text: widget.profile.bio);
    selectedGender = widget.profile.gender;
    profileImageUrl = widget.profile.imageUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Uint8List? imageBytes;
    String? finalBase64Image;

    if (profileImageFile != null) {
      imageBytes = await profileImageFile!.readAsBytes();
      final base64 = base64Encode(imageBytes);

      // Ambil base64 dari image lama (kalau ada)
      String? oldBase64;
      if (profileImageUrl.startsWith('data:image')) {
        oldBase64 = profileImageUrl.split(',')[1];
      }

      // Kirim gambar hanya jika berubah
      if (base64 != oldBase64) {
        finalBase64Image = base64;
      }
    } else if (profileImageUrl.isEmpty) {
      // User menghapus gambar
      finalBase64Image = "";
    }

    try {
      final fullName = nameController.text.trim();
      final nameParts = fullName.split(' ');

      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updated = await ApiService.updateUserProfile(
        firstname: firstName,
        lastname: lastName,
        bio: bioController.text,
        gender: selectedGender ?? 'Laki-Laki',
        base64Image:
            finalBase64Image,
      );

      showSnackbar("Berhasil disimpan!");
      Navigator.pop(context, updated);
    } catch (e) {
      showSnackbar('Gagal menyimpan: $e');
    }
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Foto dengan Kamera'),
                onTap: () => pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Pilih dari Galeri'),
                onTap: () => pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Hapus Foto'),
                onTap: () {
                  setState(() {
                    profileImageFile = null;
                    profileImageUrl = '';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final imageFile = await ImageService.pickImage(source);
      if (imageFile != null) {
        setState(() {
          profileImageFile = imageFile;
          profileImageUrl = imageFile.path;
        });
      } else {
        showSnackbar("Tidak ada gambar yang dipilih.");
      }
    } catch (e) {
      showSnackbar("Gagal memilih gambar: $e");
    } finally {
      Navigator.pop(context);
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final greenSoft = Colors.green[100];
    final borderRadius = BorderRadius.circular(20);

    return Scaffold(
      backgroundColor: greenSoft,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundImage: profileImageFile != null
                            ? FileImage(profileImageFile!)
                            : (profileImageUrl.isNotEmpty &&
                                    profileImageUrl.startsWith('http'))
                                ? NetworkImage(profileImageUrl)
                                : (profileImageUrl.startsWith('data:image'))
                                    ? MemoryImage(base64Decode(
                                        profileImageUrl.split(',')[1]))
                                    : null,
                        backgroundColor: Colors.white,
                        child: (profileImageFile == null &&
                                profileImageUrl.isEmpty)
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: Colors.teal,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: showImagePicker,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildRoundedTextField(
                    controller: nameController,
                    label: 'Nama',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildRoundedTextField(
                    controller: bioController,
                    label: 'Bio',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bio tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: borderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Gender:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Laki-Laki'),
                                value: 'Laki-Laki',
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Perempuan'),
                                value: 'Perempuan',
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    ),
                    label: const Text('Simpan', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.teal,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(20),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
