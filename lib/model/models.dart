import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import '../common/util/logger.dart';

enum ModelType { page, acc, contents }

abstract class AbsModel {
  String mid = '';
  GlobalKey key = GlobalKey();
  final ModelType type;

  AbsModel({required this.type}) {
    mid = const Uuid().v4(); // random uuid genearate
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
