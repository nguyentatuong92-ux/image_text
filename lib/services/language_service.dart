import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageService {
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  Future<String> identifyLanguage(String text) async {
    try {
      final String response = await _languageIdentifier.identifyLanguage(text);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _languageIdentifier.close();
  }
}
