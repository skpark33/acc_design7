import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import '../common/util/logger.dart';
//import '../../constants/constants.dart';

enum ModelType { page, acc, contents }

abstract class AbsModel {
  String mid = '';
  final GlobalKey key = GlobalKey();
  final ModelType type;

  AbsModel({required this.type}) {
    if (type == ModelType.page) {
      mid = "Page=";
    }
    mid += const Uuid().v4();
  }
}

// class ModelChanged extends ChangeNotifier {
//   static int changedPages = -1;

//   factory ModelChanged.sigleton() {
//     return ModelChanged();
//   }

//   ModelChanged() {
//     logHolder.log('PageModelChanged instantiate');
//   }

//   void repaintPages(int pageNo) {
//     changedPages = pageNo;
//     notifyListeners();
//   }
// }
