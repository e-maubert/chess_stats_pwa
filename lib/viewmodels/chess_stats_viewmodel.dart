import 'package:flutter/foundation.dart';
import '../models/chess_stats.dart';
import '../services/chess_api_service.dart';

class ChessStatsViewModel extends ChangeNotifier {
  final ChessApiService _apiService = ChessApiService();
  ChessStats? _stats;
  bool _isLoading = false;
  String? _error;

  ChessStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _apiService.getPlayerStats(username);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _stats = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 