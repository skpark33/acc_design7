// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import '../common/undo/undo.dart';

enum CursorType {
  pointer,
  move,
  neResize,
  nwResize,
  seResize,
  swResize,
  neRadius,
  nwRadius,
  seRadius,
  swRadius,
}

enum AnimeType {
  none,
  carousel,
  flip,
}

//class ACCProperty extends ChangeNotifier {
class ACCProperty {
  bool _dirty = false;
  bool _visible = true;
  bool _resizable = true;

  UndoAble<AnimeType> _animeType = UndoAble<AnimeType>(AnimeType.none);
  UndoAble<double> _radiusTopLeft = UndoAble<double>(0);
  UndoAble<double> _radiusTopRight = UndoAble<double>(0);
  UndoAble<double> _radiusBottomLeft = UndoAble<double>(0);
  UndoAble<double> _radiusBottomRight = UndoAble<double>(0);
  UndoAble<bool> _removed = UndoAble<bool>(false);
  UndoAble<bool> _primary = UndoAble<bool>(false);
  UndoAble<bool> _fullscreen = UndoAble<bool>(false);
  UndoAble<Offset> _containerOffset = UndoAble<Offset>(const Offset(100, 100));
  UndoAble<Size> _containerSize = UndoAble<Size>(const Size(400, 400));
  UndoAble<double> _rotate = UndoAble<double>(0);
  UndoAble<double> _opacity = UndoAble<double>(1);
  UndoAble<bool> _sourceRatio = UndoAble<bool>(false);
  //UndoAbleList<ContentsModel> _contents = UndoAbleList<ContentsModel>([]);

  bool get visible => _visible;
  bool get resizable => _resizable;
  bool get dirty => _dirty;
  UndoAble<AnimeType> get animeType => _animeType;
  UndoAble<double> get radiusTopLeft => _radiusTopLeft;
  UndoAble<double> get radiusTopRight => _radiusTopRight;
  UndoAble<double> get radiusBottomLeft => _radiusBottomLeft;
  UndoAble<double> get radiusBottomRight => _radiusBottomRight;
  UndoAble<bool> get removed => _removed;
  UndoAble<bool> get primary => _primary;
  UndoAble<bool> get fullscreen => _fullscreen;
  UndoAble<Offset> get containerOffset => _containerOffset;
  UndoAble<Size> get containerSize => _containerSize;
  UndoAble<double> get rotate => _rotate;
  UndoAble<double> get opacity => _opacity;
  UndoAble<bool> get sourceRatio => _sourceRatio;
  //UndoAbleList<ContentsModel> get contents => _contents;

  UndoAble<int> _order = UndoAble<int>(0);
  UndoAble<int> get order => _order;

  UndoAble<Color> _bgColor = UndoAble<Color>(Colors.transparent);
  UndoAble<Color> get bgColor => _bgColor;

  void setDirty(bool p) {
    _dirty = p;
  }

  void setVisible(bool p) {
    _visible = p;
  }

  void setResizable(bool p) {
    _resizable = p;
  }

  bool isFullscreen() {
    return fullscreen.value;
  }
}
