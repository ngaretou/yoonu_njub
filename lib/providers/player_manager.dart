import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PlayerManager with ChangeNotifier {
  // bool _stopPlaying = false;

  // bool get stopPlaying {
  //   return _stopPlaying;
  // }

  // set stopPlaying(value) {
  //   this._stopPlaying = value;
  //   notifyListeners();
  // }

  String _showToPlay;

  String get showToPlay {
    return _showToPlay;
  }

  set showToPlay(String value) {
    this._showToPlay = value;
    notifyListeners();
  }
}
