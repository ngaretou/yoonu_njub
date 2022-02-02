import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

bool initialvalue = false;

class PlayerManager with ChangeNotifier {
  String _showToPlay = "";

  String get showToPlay {
    return _showToPlay;
  }

  set showToPlay(String value) {
    this._showToPlay = value;
    print('set showToPlay');
    notifyListeners();
  }
}
