import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static Future<String> translate(String text, String from, String to) async {
    final uri = Uri.parse('http://10.10.0.80:5050/translate');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': from,
          'target': to,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('translatedText')) {
          return json['translatedText'];
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to translate (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }
}
