import 'package:flutter/material.dart';
//import 'package:uuid/uuid.dart';
//import '../common/util/logger.dart';

enum ModelType { page, acc, contents }

abstract class AbsModel {
  int mid = 0;
  GlobalKey key = GlobalKey();
  final ModelType type;

  AbsModel({required this.type}) {
    // random uuid genearate
  }
  // AbsModel.create({required this.mid, required this.type}) {
  //   key = ValueKey(mid);
  // }
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
