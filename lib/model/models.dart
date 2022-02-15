import 'package:flutter/material.dart';
import '../common/util/logger.dart';

class ModelChanged extends ChangeNotifier {
  static int changedPages = -1;

  factory ModelChanged.sigleton() {
    return ModelChanged();
  }

  ModelChanged() {
    logHolder.log('PageModelChanged instantiate');
  }

  void repaintPages(int pageNo) {
    changedPages = pageNo;
    notifyListeners();
  }
}
