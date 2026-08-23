import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import '../services/translation_service.dart';
import '../services/language_service.dart';
import '../services/image_picker_service.dart';
import '../services/image_cropper_service.dart';
import '../services/history_service.dart';
import '../services/tts_service.dart';
import '../services/smart_action_service.dart';
import 'package:intl/intl.dart';

class AppProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final TranslationService _translationService = TranslationService();
  final LanguageService _languageService = LanguageService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageCropperService _imageCropperService = ImageCropperService();
  final HistoryService _historyService = HistoryService();
  final TtsService _ttsService = TtsService();
  final SmartActionService _smartActionService = SmartActionService();

  File? _image;
  String _originalText = '';
  String _translatedText = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  bool _isProcessing = false;
  String? _errorMessage;
  List<HistoryItem> _history = [];
  List<DetectedEntity> _detectedEntities = [];
  bool _showImageInResult = true;

  File? get image => _image;
  String get originalText => _originalText;
  String get translatedText => _translatedText;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  List<HistoryItem> get history => _history;
  List<DetectedEntity> get detectedEntities => _detectedEntities;
  bool get showImageInResult => _showImageInResult;

  AppProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _history = await _historyService.getHistory();
    notifyListeners();
  }

  /// Cho phép cập nhật văn bản thủ công sau khi nhận diện hoặc dịch
  void updateResultText(String newText) {
    _translatedText = newText;
    _detectedEntities = _smartActionService.detectEntities(newText);
    notifyListeners();
  }

  Future<void> pickAndProcessImage(ImageSource source) async {
    _errorMessage = null;
    try {
      final pickedFile = await _imagePickerService.pickImage(source);
      if (pickedFile == null) return;

      // Cắt ảnh sau khi chọn
      final croppedFile = await _imageCropperService.cropImage(pickedFile.path);
      if (croppedFile == null) return;

      _image = File(croppedFile.path);
      _isProcessing = true;
      _originalText = '';
      _translatedText = '';
      notifyListeners();

      // 1. OCR
      final inputImage = InputImage.fromFile(_image!);
      _originalText = await _ocrService.recognizeText(inputImage);

      if (_originalText.trim().isEmpty) {
        _errorMessage = "Không tìm thấy văn bản trong vùng ảnh đã chọn.";
        _isProcessing = false;
        notifyListeners();
        return;
      }

      // 2. Language ID
      _sourceLanguage = await _languageService.identifyLanguage(_originalText);

      // 3. Smart Entity Detection
      _detectedEntities = _smartActionService.detectEntities(_originalText);

      // 4. Translation (to Vietnamese by default)
      _targetLanguage = 'vi';
      _translatedText = await _translationService.translate(
        _originalText,
        _sourceLanguage,
        _targetLanguage,
      );

      // 4. Lưu vào lịch sử
      await _addToHistory(_originalText, _translatedText);

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _isProcessing = false;
      _errorMessage = "Đã xảy ra lỗi: $e";
      notifyListeners();
    }
  }

  /// Cho phép cắt lại ảnh hiện tại
  Future<void> recropAndProcessImage() async {
    if (_image == null) return;
    _errorMessage = null;

    try {
      final croppedFile = await _imageCropperService.cropImage(_image!.path);
      if (croppedFile == null) return;

      _image = File(croppedFile.path);
      _isProcessing = true;
      _originalText = '';
      _translatedText = '';
      notifyListeners();

      // Thực hiện lại OCR và dịch
      final inputImage = InputImage.fromFile(_image!);
      _originalText = await _ocrService.recognizeText(inputImage);

      if (_originalText.trim().isEmpty) {
        _errorMessage = "Không tìm thấy văn bản trong vùng ảnh đã chọn.";
        _isProcessing = false;
        notifyListeners();
        return;
      }

      final langCode = await _languageService.identifyLanguage(_originalText);
      _sourceLanguage = langCode;

      // Smart Entity Detection
      _detectedEntities = _smartActionService.detectEntities(_originalText);

      _targetLanguage = 'vi';
      _translatedText = await _translationService.translate(
        _originalText,
        _sourceLanguage,
        _targetLanguage,
      );

      // Lưu vào lịch sử
      await _addToHistory(_originalText, _translatedText);

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _isProcessing = false;
      _errorMessage = "Đã xảy ra lỗi khi cắt lại: $e";
      notifyListeners();
    }
  }

  Future<void> _addToHistory(String original, String translated) async {
    final newItem = HistoryItem(
      originalText: original,
      translatedText: translated,
      timestamp: DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now()),
    );
    await _historyService.addHistoryItem(newItem);
    await _loadHistory();
  }

  Future<void> deleteHistoryItem(int index) async {
    await _historyService.deleteItem(index);
    await _loadHistory();
  }

  Future<void> clearAllHistory() async {
    await _historyService.clearHistory();
    await _loadHistory();
  }

  void loadFromHistory(HistoryItem item) {
    _originalText = item.originalText;
    _translatedText = item.translatedText;
    _image = null; // Khi xem từ lịch sử có thể không cần hiển thị ảnh cũ
    notifyListeners();
  }

  Future<void> toggleTranslationLanguage() async {
    if (_originalText.isEmpty) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Đảo ngược ngôn ngữ đích
      _targetLanguage = _targetLanguage == 'vi' ? 'en' : 'vi';

      _translatedText = await _translationService.translate(
        _originalText,
        _sourceLanguage,
        _targetLanguage,
      );

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _isProcessing = false;
      _errorMessage = "Lỗi khi chuyển đổi ngôn ngữ: $e";
      notifyListeners();
    }
  }

  void clear() {
    _image = null;
    _originalText = '';
    _translatedText = '';
    _errorMessage = null;
    _isProcessing = false;
    _detectedEntities = [];
    _ttsService.stop();
    notifyListeners();
  }

  Future<void> performSmartAction(DetectedEntity entity) async {
    await _smartActionService.performAction(entity);
  }

  void toggleResultImageView() {
    _showImageInResult = !_showImageInResult;
    notifyListeners();
  }

  Future<void> speakResult() async {
    final textToSpeak = _translatedText.isNotEmpty
        ? _translatedText
        : _originalText;
    final langCode = _translatedText.isNotEmpty
        ? _targetLanguage
        : _sourceLanguage;
    await _ttsService.speak(textToSpeak, langCode);
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _languageService.dispose();
    _ttsService.stop();
    super.dispose();
  }
}
