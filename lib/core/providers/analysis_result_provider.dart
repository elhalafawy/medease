import 'package:flutter/foundation.dart';
import '../../features/upload/models/analysis_result.dart';

class AnalysisResultProvider with ChangeNotifier {
  AnalysisResult? _currentAnalysisResult;

  AnalysisResult? get currentAnalysisResult => _currentAnalysisResult;

  void setAnalysisResult(AnalysisResult result) {
    _currentAnalysisResult = result;
    notifyListeners();
  }

  void clearAnalysisResult() {
    _currentAnalysisResult = null;
    notifyListeners();
  }
} 