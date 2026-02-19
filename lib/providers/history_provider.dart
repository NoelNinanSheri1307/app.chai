import 'package:flutter/material.dart';
import '../models/history_item_model.dart';

class HistoryProvider extends ChangeNotifier {
  final List<HistoryItem> _history = [];

  List<HistoryItem> get history => List.unmodifiable(_history);

  void addHistoryItem(HistoryItem item) {
    _history.insert(0, item);
    notifyListeners();
  }

  void removeHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
