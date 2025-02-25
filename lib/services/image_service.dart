import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageService {
  static Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      return compressImage(File(pickedFile.path));
    }
    return null;
  }

  static Future<File> compressImage(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    final resizedImage = img.copyResize(rawImage!, width: 100);
    final compressedFile = File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 25));
    return compressedFile;
  }
}
