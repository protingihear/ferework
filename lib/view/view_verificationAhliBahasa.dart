import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class SignLanguageExpertFormPage extends StatefulWidget {
  @override
  _SignLanguageExpertFormPageState createState() =>
      _SignLanguageExpertFormPageState();
}

class _SignLanguageExpertFormPageState
    extends State<SignLanguageExpertFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  PlatformFile? certificateFile;

  Future<void> pickCertificateFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        certificateFile = result.files.first;
      });
    }
  }

  void handleSubmit() {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        instagramController.text.isEmpty ||
        whatsappController.text.isEmpty ||
        experienceController.text.isEmpty ||
        certificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Semua data harus diisi."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Data berhasil dikirim! 🎉"),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FAF4), // Lembut mint green
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[200],
        title: Text(
          'Upgrade Role 🌿',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildTextField("Nama Lengkap", nameController, icon: Icons.person),
                SizedBox(height: 12),
                buildTextField("Alamat", addressController, icon: Icons.home, maxLines: 2),
                SizedBox(height: 12),
                buildTextField("Instagram", instagramController, icon: Icons.camera_alt),
                SizedBox(height: 12),
                buildTextField("WhatsApp", whatsappController, icon: Icons.chat, keyboardType: TextInputType.phone),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("📎 Unggah Sertifikat",
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text(certificateFile == null ? "Pilih File" : certificateFile!.name),
                  onPressed: pickCertificateFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size.fromHeight(48),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("💬 Ceritakan Pengalamanmu",
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: experienceController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Contoh: Saya telah menjadi juru bahasa isyarat selama 3 tahun...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  style: GoogleFonts.quicksand(),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size.fromHeight(50),
                  ),
                  child: Text("🌟 Kirim Pengajuan", style: GoogleFonts.quicksand(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      IconData? icon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.quicksand(),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.green[400]) : null,
        labelText: label,
        labelStyle: GoogleFonts.quicksand(),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
