// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../common/util/logger.dart';
import '../common/undo/undo.dart';
//import '../constants/styles.dart';
//import 'models.dart';

enum PageType {
  circled,
  fixed,
}

// ignore: camel_case_types
class PageModel {
  final int id; //page number
  final GlobalKey key = GlobalKey();

  UndoAble<int> width = UndoAble<int>(1920);
  UndoAble<int> height = UndoAble<int>(1080);

  // final UndoMonitorAble<int> _pageNo = UndoMonitorAble<int>(0);
  // UndoMonitorAble<int> get pageNo => _pageNo;
  final UndoAble<int> _pageNo = UndoAble<int>(0);
  UndoAble<int> get pageNo => _pageNo;
  void setPageNo(int val) {
    _pageNo.set(val);
  }

  UndoAble<String> description = UndoAble<String>('');
  UndoAble<String> shortCut = UndoAble<String>('');
  UndoAble<Color> bgColor = UndoAble<Color>(Colors.white);
  UndoAble<bool> used = UndoAble<bool>(true);
  UndoAble<bool> isCircle = UndoAble<bool>(true);

  final UndoAble<bool> _isRemoved = UndoAble<bool>(false);
  UndoAble<bool> get isRemoved => _isRemoved;
  void setIsRemoved(bool val) {
    _isRemoved.set(val);
  }

  PageModel({required this.id});

  double getRatio() {
    return height.value / width.value;
  }

  void printIt() {
    logHolder.log(
        'id=[$id],width=[$width.value],height=[$height.value],pageNo=[$pageNo.value],description=[$description.value],shortCut=[$shortCut.value], bgColor=[$bgColor.value]');
  }

  Offset getPosition() {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      return box.localToGlobal(Offset.zero); //this is global position
    }
    return Offset.zero;
  }

  Size getSize() {
    return Size(width.value.toDouble(), height.value.toDouble());
  }

  Size getRealSize() {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      return box.size; //this is global position
    }
    return Size(100, 100);
  }

  double getRealWidthRatio() {
    Size size = getRealSize();
    return size.width / width.value;
  }

  double getRealHeightRatio() {
    Size size = getRealSize();
    return size.height / height.value;
  }
}
