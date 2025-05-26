import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reworkmobile/services/api_service.dart';

class SignLanguageExpertFormPage extends StatefulWidget {
  @override
  _SignLanguageExpertFormPageState createState() =>
      _SignLanguageExpertFormPageState();
}

class _SignLanguageExpertFormPageState
    extends State<SignLanguageExpertFormPage> {
  final TextEditingController redeemCodeController = TextEditingController();

  void handleRedeem() async {
    final code = redeemCodeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kode tidak boleh kosong."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (code == "IHear Ahli Bahasa") {
      try {
        await ApiService.updateUserRole("ahli_bahasa");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kode berhasil diredeem! 🎉"),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Redeem Code sudah pernah digunakan"),
          backgroundColor: Colors.redAccent,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kode tidak valid."),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FAF4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[200],
        title: Text(
          'Redeem Code 🌿',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: redeemCodeController,
                  decoration: InputDecoration(
                    labelText: "Redeem Code",
                    labelStyle: GoogleFonts.quicksand(),
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    prefixIcon: Icon(Icons.vpn_key, color: Colors.green[400]),
                  ),
                  style: GoogleFonts.quicksand(),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: handleRedeem,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size.fromHeight(50),
                  ),
                  child: Text("🔓 Redeem Now",
                      style: GoogleFonts.quicksand(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
