import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ServicioImagenes {
  static const String _baseUrl = 'https://repositorio1-inf.onrender.com/api/upload'; // URL para Android Emulator
  
  final ImagePicker _picker = ImagePicker();

  /// Permite al usuario seleccionar una imagen de la galería o cámara
  Future<File?> seleccionarImagen(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error selecionando imagen: $e');
      return null;
    }
  }

  /// Sube la imagen al backend y devuelve la URL de Cloudinary
  Future<String?> subirImagen(File file, {String folder = 'general'}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/image'));
      
      // Adjuntar archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          file.path,
          filename: file.path.split('/').last,
        )
      );

      // Adjuntar carpeta de destino
      request.fields['folder'] = folder;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decodedMap = json.decode(response.body);
        return decodedMap['url'] as String?;
      } else {
        debugPrint('Error subiendo imagen: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception subiendo imagen: $e');
      return null;
    }
  }
}
