import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;

class CloudinaryService {
  static const String cloudName    = 'doacnp4uv';
  static const String apiKey       = '188892661967173';
  static const String uploadPreset = 'afrilegacy_preset'; // ✅ preset original

  /// [folder] : 'afrilegacy/avatars' | 'afrilegacy/images' | 'afrilegacy/audio' | 'afrilegacy/models'
  static Future<String?> uploadFile(File file, String folder) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
      );

      final ext       = p.extension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder']        = folder;           // ex: 'afrilegacy/avatars'
      request.fields['public_id']     = '$timestamp$ext'; // nom unique
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body     = await response.stream.bytesToString();
      final json     = jsonDecode(body);

      if (response.statusCode == 200) {
        return json['secure_url'] as String;
      }
      print('[Cloudinary] ${response.statusCode}: ${json['error']?['message']}');
      return null;
    } catch (e) {
      print('[Cloudinary] Exception: $e');
      return null;
    }
  }
}