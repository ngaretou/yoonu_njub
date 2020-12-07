import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PlayerManager with ChangeNotifier {
  String _showToPlay;

  String get showToPlay {
    return _showToPlay;
  }

  set showToPlay(String value) {
    this._showToPlay = value;
    notifyListeners();
  }
}
