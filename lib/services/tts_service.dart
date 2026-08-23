import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;

    // Ánh xạ mã ngôn ngữ sang định dạng TTS hỗ trợ (ví dụ: 'en' -> 'en-US', 'vi' -> 'vi-VN')
    String ttsLangCode = languageCode;
    if (languageCode == 'en') {
      ttsLangCode = 'en-US';
    } else if (languageCode == 'vi') {
      ttsLangCode = 'vi-VN';
    }

    await _flutterTts.setLanguage(ttsLangCode);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
