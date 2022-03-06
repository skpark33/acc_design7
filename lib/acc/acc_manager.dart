import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:flutter/services.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

import 'package:acc_design7/studio/pages/page_manager.dart';
import 'package:acc_design7/constants/constants.dart';

import '../model/contents.dart';
import '../model/pages.dart';

import '../acc/acc.dart';
import '../common/undo/undo.dart';
import '../widgets/base_widget.dart';
import '../common/util/logger.dart';
import '../acc/acc_menu.dart';
//import '../studio/properties/properties_frame.dart';

//import '../overlay/overlay.dart' as my_overlay;
ACCManager? accManagerHolder;

class ACCManager extends ChangeNotifier {
  Map<int, ACC> accMap = <int, ACC>{};
  SortedMap<int, ACC> orderMap = SortedMap<int, ACC>();
  ACCMenu accMenu = ACCMenu();
  bool orderVisible = false;
  ui.Image? needleImage;

  int accIndex = -1;
  // ignore: prefer_final_fields
  int _currentAccIndex = -1;

  //static int get currentAccIndex => _currentAccIndex;
  void setCurrentIndex(int i, {bool setAsAcc = true}) {
    _currentAccIndex = i;
    if (setAsAcc && _currentAccIndex >= 0 && pageManagerHolder != null) {
      pageManagerHolder!.setAsAcc();
    }
    setState();
  }

  bool isCurrentIndex(int index) {
    return index >= 0 && index == _currentAccIndex;
  }

  ACC? getCurrentACC() {
    if (_currentAccIndex < 0) return null;
    return accMap[_currentAccIndex];
  }

  ACC createACC(int keyIdx, BuildContext context, BaseWidget widget, PageModel page) {
    accIndex = keyIdx;
    logHolder.log("createACC($accIndex)");
    ACC acc = ACC(page: page, accChild: widget, index: accIndex);
    acc.initSizeAndPosition();
    acc.registerOverlay(context);
    accMap[accIndex] = acc;
    setCurrentIndex(accIndex);
    orderMap[acc.order.value] = acc;

    widget.setParentAcc(acc);
    return acc;
  }

  void setPrimary() {
    if (_currentAccIndex < 0) return;

    ACC acc = accMap[_currentAccIndex]!;
    bool primary = !acc.primary.value;
    if (primary == true) {
      for (int key in accMap.keys) {
        if (accMap[key]!.primary.value) {
          accMap[key]!.primary.set(false);
          accMap[key]!.setState();
        }
      }
    }
    acc.primary.set(primary);
    acc.setState();
  }

  bool isPrimary() {
    if (_currentAccIndex < 0) return false;
    ACC acc = accMap[_currentAccIndex]!;
    return acc.primary.value;
  }

  Future<void> unshowMenu(BuildContext context) async {
    accMenu.unshow(context);
  }

  Future<void> showMenu(BuildContext context, ACC? acc) async {
    if (_currentAccIndex < 0) return;
    acc ??= accMap[_currentAccIndex]!;

    Offset realOffset = acc.getRealOffset();
    double dx = realOffset.dx;
    double dy = realOffset.dy;

    Size realSize = acc.getRealSize();

    // 중앙위치를 잡는다.
    dx = dx + (realSize.width / 2.0);
    // 여기서, munu의 width/2 를 빼면 정중앙에 위치하게 된다.
    dx = dx - (accMenu.size.width / 2.0);
    // widget 의 하단에 자리를 잡는다.
    dy = dy + realSize.height;
    dy = dy + 10; // offset

    // 그런데, 아래에 자리가 없으면 어떻게 할것인가 ?

    if (await acc.getCurrentContentsType() == ContentsType.video ||
        await acc.getCurrentContentsType() == ContentsType.image) {
      accMenu.size = Size(accMenu.size.width, 68);
    } else {
      accMenu.size = Size(accMenu.size.width, 36);
    }

    accMenu.position = Offset(dx, dy);
    accMenu.setType(await acc.getCurrentContentsType());
    accMenu.show(context, acc);
    accMenu.setState();
  }

  void resizeMenu(ContentsType type) {
    if (!accMenu.visible) return;

    if (type == ContentsType.video || type == ContentsType.image) {
      accMenu.size = Size(accMenu.size.width, 68);
    } else {
      accMenu.size = Size(accMenu.size.width, 36);
    }

    accMenu.setType(type);
    accMenu.setState();
  }

  bool isMenuVisible() {
    return accMenu.visible;
  }

  bool isMenuHostChanged() {
    return accMenu.accIndex != _currentAccIndex;
  }

  void reorderMap() {
    orderMap.clear();
    for (ACC acc in accMap.values) {
      if (acc.removed.value == false) {
        orderMap[acc.order.value] = acc;
        logHolder.log('oderMap[${acc.order.value}]');
      }
    }
  }

  void applyOrder(BuildContext context) {
    reorderMap();
    for (ACC acc in orderMap.values) {
      // if (acc.removed.value == true) {
      //   continue;
      // }
      // if (acc.dirty == false) {
      //  continue;
      //}
      acc.entry!.remove();
      acc.entry = null;
      acc.registerOverlay(context);
      acc.setDirty(false);
    }
    setState();
    pageManagerHolder!.setState(); // Tree 순서를 바꾸기 위해
    // List<OverlayEntry> newEntries = [];
    // for (ACC acc in orderMap.values) {
    //   newEntries.add(acc.entry!);
    //   logHolder.log('index:order=${acc.index}:${acc.order.value}');
    // }

    // if (newEntries.isNotEmpty) {
    //   final overlay = Overlay.of(context)!;
    //   overlay.rearrange(newEntries);
    // } else {
    //   logHolder.log('no newEntries');
    // }
  }

  void next(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.next(pause: true);
  }

  void pause(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.pause();
  }

  void play(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.play();
  }

  void prev(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.prev(pause: true);
  }

  void mute(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.mute();
  }

  void up(BuildContext context) {
    if (_currentAccIndex < 0) return;
    if (swapUp(_currentAccIndex)) {
      applyOrder(context);
    }
  }

  void down(BuildContext context) {
    if (_currentAccIndex < 0) return;
    if (swapDown(_currentAccIndex)) {
      applyOrder(context);
    }
  }

  void remove(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }

    mychangeStack.startTrans();
    acc.removed.set(true);
    int removedOrder = acc.order.value;
    for (ACC ele in accMap.values) {
      if (ele.removed.value == true) {
        continue;
      }

      if (ele.order.value > removedOrder) {
        ele.order.set(ele.order.value - 1);
      }
    }
    reorderMap();
    mychangeStack.endTrans();
    setState();

    accManagerHolder!.unshowMenu(context);
  }

  void realRemove(int index, BuildContext context) {
    ACC? acc = accMap[index];
    if (acc == null) {
      return;
    }
    // int removedOrder = acc.order.value;
    // for (ACC ele in accMap.values) {
    //   if (acc.removed.value == true) {
    //     continue;
    //   }

    //   if (ele.order.value > removedOrder) {
    //     ele.order.set(ele.order.value - 1);
    //   }
    // }

    acc.entry!.remove();
    accMap.remove(index);
    //orderMap.clear();
    reorderMap();
    setState();
  }

  bool swapUp(int index) {
    int len = accMap.length;
    len--;
    if (len <= 0) {
      return false; // 자기 혼자 밖에 없다. 올리고 내리고 할일이 없다.
    }
    ACC target = accMap[index]!;

    int oldOrder = target.order.value;
    int newOrder = -1;

    for (int order in orderMap.keys) {
      // if (orderMap[order]!.removed.value == true) {
      //   continue;
      // }
      if (order > oldOrder) {
        newOrder = order;
        break;
      }
    }
    if (newOrder <= 0) {
      return false; // 이미 top 이다.
    }

    logHolder.log('swapUp($index) : oldOder=$oldOrder, newOrder=$newOrder');

    // acc 중에 newOrder 값을 가지고 있는 놈을 찾아서 oldOrder 와 치환해준다.
    ACC? friend = orderMap[newOrder];
    if (friend != null) {
      mychangeStack.startTrans();
      friend.order.set(oldOrder);
      friend.setDirty(true);
      target.order.set(newOrder);
      target.setDirty(true);
      mychangeStack.endTrans();
      return true;
    }
    logHolder.log('newOrder not founded');
    return false;
  }

  bool swapDown(int index) {
    int len = accMap.length;
    len--;
    if (len <= 0) {
      return false; // 자기 혼자 밖에 없다. 올리고 내리고 할일이 없다.
    }

    ACC target = accMap[index]!;

    int oldOrder = target.order.value;
    if (oldOrder == 0) {
      return false;
    }
    int newOrder = -1;

    for (int order in orderMap.keys) {
      // if (orderMap[order]!.removed.value == true) {
      //   continue;
      // }
      if (order >= oldOrder) {
        break;
      }
      newOrder = order;
    }

    if (newOrder < 0) {
      return false; // 이미 bottom 이다.
    }

    // acc 중에 newOrder 값을 가지고 있는 놈을 찾아서 oldOrder 와 치환해준다.
    ACC? friend = orderMap[newOrder];
    if (friend != null) {
      mychangeStack.startTrans();
      friend.order.set(oldOrder);
      friend.setDirty(true);
      target.order.set(newOrder);
      target.setDirty(true);
      mychangeStack.endTrans();
      return true;
    }

    return false;
  }

  void setState() {
    //reorderMap();
    for (ACC acc in accMap.values) {
      acc.setState();
    }
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> notifyAsync() async {
    notifyListeners();
  }

  void undo(ACC? acc, BuildContext context) {
    mychangeStack.undo();
    accManagerHolder!.setState();
    accManagerHolder!.unshowMenu(context);
  }

  void redo(ACC? acc, BuildContext context) {
    mychangeStack.redo();
    accManagerHolder!.setState();
    accManagerHolder!.unshowMenu(context);
  }

  void nextACC(BuildContext context) {
    _currentAccIndex++;
    if (_currentAccIndex >= accMap.length) {
      _currentAccIndex = 0;
    }
    accManagerHolder!.unshowMenu(context);
    setState();
  }

  void setACCOrderVisible(bool visible) {
    orderVisible = visible;
    accManagerHolder!.setState();
  }

  Future<void> getNeedleImage() async {
    needleImage = await loadUiImage('needle.png');
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void showPages(BuildContext context, int modelId) {
    for (ACC acc in accMap.values) {
      if (acc.removed.value == true) {
        continue;
      }
      if (acc.page!.id == modelId) {
        if (!acc.visible) {
          acc.setVisible(true);
          acc.setState();
        }
      } else {
        if (acc.visible) {
          acc.setVisible(false);
          acc.setState();
        }
      }
    }
    accMenu.unshow(context);
  }

  void toggleFullscreen(BuildContext context) {
    if (_currentAccIndex < 0) return;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return;
    }
    acc.toggleFullscreen();
    accManagerHolder!.setState();
    accManagerHolder!.unshowMenu(context);
  }

  bool isFullscreen() {
    if (_currentAccIndex < 0) return false;
    ACC? acc = accMap[_currentAccIndex];
    if (acc == null) {
      return false;
    }
    return acc.isFullscreen();
  }

  /*
List<ACC> accList = accManagerHolder!.getAccList(model.id);
        List<Node> accNodes = [];
        for (ACC acc in accList) {
          String accNo = acc.order.value.toString().padLeft(2, '0');
          acc.accChild.playManager.getNodes();

          accNodes
              .add(Node(key: '$accPrefix${acc.order.value}', label: 'Frame $accNo', data: model));
        }
        */
  List<Node> toNodes(PageModel model) {
    List<Node> accNodes = [];
    for (ACC acc in orderMap.values) {
      if (acc.page!.id == model.id) {
        String accNo = acc.index.toString().padLeft(2, '0');
        List<Node> conNodes = acc.accChild.playManager!.toNodes(model);
        accNodes.add(Node(
            key: '$accPrefix$accNo',
            label: 'Frame $accNo',
            data: model,
            expanded: accManagerHolder != null && accManagerHolder!.isCurrentIndex(acc.index),
            children: conNodes));
      }
    }
    return accNodes;
  }
}
