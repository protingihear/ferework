import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onSave;

  const EditProfilePage({Key? key, required this.profile, this.onSave})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  String? selectedGender;
  File? profileImageFile;
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    bioController = TextEditingController(text: widget.profile.bio);
    emailController = TextEditingController(
        text: widget.profile.emails.isNotEmpty
            ? widget.profile.emails.first
            : '');
    passwordController = TextEditingController();
    selectedGender = widget.profile.gender;
    profileImageUrl = widget.profile.imageUrl;
  }

  Future<void> saveProfile() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email cannot be empty')),
      );
      return;
    }

    if (passwordController.text.isNotEmpty &&
        passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    File? imageFileToUpload = profileImageFile;

    if (imageFileToUpload == null && profileImageUrl.isNotEmpty) {
      File tempFile = File(profileImageUrl);
      if (await tempFile.exists()) {
        imageFileToUpload = tempFile;
      }
    }

    try {
      final updatedProfile = await ApiService.updateUserProfile(
        widget.profile.id,
        nameController.text.isNotEmpty
            ? nameController.text
            : widget.profile.name,
        bioController.text,
        selectedGender ?? 'Laki-Laki',
        emailController.text.trim(),
        passwordController.text.isNotEmpty
            ? passwordController.text.trim()
            : null,
        profileImageFile, 
        removeImage,
      );

      Navigator.pop(context, updatedProfile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  bool removeImage = false;

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() {
                    profileImageFile = null;
                    profileImageUrl = ''; // Reset URL too
                    removeImage = true;
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
    final imageFile = await ImageService.pickImage(source);
    if (imageFile != null) {
      setState(() {
        profileImageFile = imageFile;
        profileImageUrl = imageFile.path;
      });
    }
    Navigator.pop(context);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60), // Space for the back button
                // Profile Image Section
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
                      backgroundColor: Colors.grey[200],
                      child:
                          (profileImageFile == null && profileImageUrl.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                    ),
                    IconButton(
                      onPressed: showImagePicker,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                // Bio
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                      labelText: 'Bio', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                // Email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                // Gender Selection
                Row(
                  children: [
                    const Text("Gender: "),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('P'),
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
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('L'),
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
                  ],
                ),

                const SizedBox(height: 32),
                // Save Button
                ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),

          // Custom Back Button (Floating at Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.green,
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
}
