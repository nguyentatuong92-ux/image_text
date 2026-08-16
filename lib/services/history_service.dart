import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String originalText;
  final String translatedText;
  final String timestamp;

  HistoryItem({
    required this.originalText,
    required this.translatedText,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'originalText': originalText,
    'translatedText': translatedText,
    'timestamp': timestamp,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    originalText: json['originalText'],
    translatedText: json['translatedText'],
    timestamp: json['timestamp'],
  );
}

class HistoryService {
  static const String _key = 'translation_history';

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_key);
    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((item) => HistoryItem.fromJson(item)).toList();
  }

  Future<void> saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      history.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_key, encoded);
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    List<HistoryItem> history = await getHistory();

    // Thêm vào đầu danh sách
    history.insert(0, item);

    // Giới hạn 5 bản ghi
    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await saveHistory(history);
  }

  Future<void> deleteItem(int index) async {
    List<HistoryItem> history = await getHistory();
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await saveHistory(history);
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
