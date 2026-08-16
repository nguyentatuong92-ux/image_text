import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final _modelManager = OnDeviceTranslatorModelManager();

  Future<String> translate(
    String text,
    String sourceLanguageCode,
    String targetLanguageCode,
  ) async {
    if (sourceLanguageCode == targetLanguageCode) return text;

    final TranslateLanguage sourceLanguage = _getLanguageFromCode(
      sourceLanguageCode,
    );
    final TranslateLanguage targetLanguage = _getLanguageFromCode(
      targetLanguageCode,
    );

    final onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    try {
      bool isSourceDownloaded = await _modelManager.isModelDownloaded(
        sourceLanguage.bcpCode,
      );
      bool isTargetDownloaded = await _modelManager.isModelDownloaded(
        targetLanguage.bcpCode,
      );

      if (!isSourceDownloaded)
        await _modelManager.downloadModel(sourceLanguage.bcpCode);
      if (!isTargetDownloaded)
        await _modelManager.downloadModel(targetLanguage.bcpCode);

      final result = await onDeviceTranslator.translateText(text);
      return result;
    } catch (e) {
      rethrow;
    } finally {
      onDeviceTranslator.close();
    }
  }

  TranslateLanguage _getLanguageFromCode(String code) {
    switch (code) {
      case 'vi':
        return TranslateLanguage.vietnamese;
      case 'en':
        return TranslateLanguage.english;
      default:
        return TranslateLanguage.english;
    }
  }

  Future<String> translateToVietnamese(
    String text,
    String sourceLanguageCode,
  ) async {
    return translate(text, sourceLanguageCode, 'vi');
  }
}
