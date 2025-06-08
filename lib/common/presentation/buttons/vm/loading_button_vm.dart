import 'package:flutter/foundation.dart';

final class LoadingButtonVM extends ChangeNotifier {
  bool _isLoading = false;
  bool _isComplete = false;

  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;

  void setLoading() {
    if (!_isLoading) {
      _isComplete = false;
      _isLoading = true;
      notifyListeners();
    }
  }

  void setCompleted() {
    if (_isLoading) {
      _isLoading = false;
      _isComplete = true;
      notifyListeners();
    }
  }
}
