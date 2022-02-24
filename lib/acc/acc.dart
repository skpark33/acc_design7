// ignore_for_file: prefer_final_fields
import 'dart:math';
//import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:acc_design7/common/util/my_utils.dart';

import 'resizable.dart';
import 'acc_property.dart';
import 'acc_manager.dart';
import '../common/drag_and_drop/drop_zone_widget.dart';
import '../common/neumorphic/neumorphic.dart';
import '../common/util/logger.dart';
import '../common/undo/undo.dart';
import '../widgets/base_widget.dart';
import '../constants/styles.dart';
import '../constants/constants.dart';
import '../studio/artboard/artboard_frame.dart';
import '../model/pages.dart';
import '../model/contents.dart';

//import 'package:acc_design7/studio/pages/page_manager.dart';
class RotateCorner {
  CursorType cursor = CursorType.move;
  double dx = 0;
  double dy = 0;
}

class ACC with ACCProperty {
  ACC({required this.page, required this.accChild, required this.index}) {
    order.set(index);
  }

  final BaseWidget accChild;
  final int index;
  PageModel? page;
  //bool isStart = false;

  OverlayEntry? entry;

  bool hasContents = false;
  bool actionStart = false;
  bool isHover = false;
  bool isCornered = false;
  bool isRadiused = false;
  final List<bool> isCornerHover = [false, false, false, false, false, false, false, false];
  final List<bool> isRadiusHover = [false, false, false, false];
  CursorType cursor = CursorType.pointer;

  static double _lastOffsetX = 20;
  static double _lastOffsetY = 20;

  Offset _prevOffset = Offset.zero;
  Size _prevSize = Size.zero;

  void initSizeAndPosition() {
    Offset start = Offset(_lastOffsetX, _lastOffsetY);
    containerOffset.init(start);

    Size pageSize = page!.getRealSize();

    if (_lastOffsetX + containerSize.value.width >= pageSize.width) {
      _lastOffsetX = 20;
    } else {
      _lastOffsetX += 10;
    }
    if (_lastOffsetY + containerSize.value.height >= pageSize.height) {
      _lastOffsetY = 20;
    } else {
      _lastOffsetY += 10;
    }
    logHolder.log(
        "pageSize.height=${pageSize.height},containerSize+ =${containerSize.value.height},_lastOffsetY=$_lastOffsetY");
  }

  Widget registerOverlay(BuildContext context) {
    logHolder.log('ACCState build');
    Widget? overlayWidget;
    if (entry == null) {
      entry = OverlayEntry(builder: (context) {
        overlayWidget = showOverlay(context);
        return overlayWidget!;
      });
      final overlay = Overlay.of(context)!;
      overlay.insert(entry!, below: menuStickEntry);
    } else {
      setVisible(true);
    }
    if (overlayWidget != null) {
      return overlayWidget!;
    }
    return Container(color: Colors.red);
  }

  Offset getRealOffset() {
    if (page != null) {
      Offset origin = page!.getPosition();
      Size ratio = page!.getRealRatio();
      double dx = ratio.width * containerOffset.value.dx + origin.dx;
      double dy = ratio.height * containerOffset.value.dy + origin.dy;
      return Offset(dx, dy);
    }
    return containerOffset.value;
  }

  Size getRealRatio() {
    if (page != null) {
      return page!.getRealRatio();
    }
    return const Size(1, 1);
  }

  Offset getRealOffsetWithGivenRatio(Size ratio) {
    if (page != null) {
      Offset origin = page!.getPosition();
      double dx = ratio.width * containerOffset.value.dx + origin.dx;
      double dy = ratio.height * containerOffset.value.dy + origin.dy;
      return Offset(dx, dy);
    }
    return containerOffset.value;
  }

  Size getRealSize() {
    if (page != null) {
      Size ratio = page!.getRealRatio();
      double width = ratio.width * containerSize.value.width;
      double height = ratio.height * containerSize.value.height;
      return Size(width, height);
    }
    return containerSize.value;
  }

  void _setContainerOffset(Offset offset) {
    // 자석기능
    double dx = offset.dx;
    double dy = offset.dy;
    if (dx <= magnetic) {
      dx = 0;
    }
    if (dy <= magnetic) {
      dy = 0;
    }

    double pw = page!.width.value.toDouble();
    double ph = page!.height.value.toDouble();

    if (dx + containerSize.value.width > pw - magnetic) {
      dx = pw - containerSize.value.width;
    }
    if (dy + containerSize.value.height > ph - magnetic) {
      dy = ph - containerSize.value.height;
    }

    containerOffset.set(Offset(dx, dy));
    accManagerHolder?.notify();
  }

  void _setContainerOffsetAndSize(Offset offset, Size size) {
    double dx = offset.dx;
    double dy = offset.dy;
    if (dx <= magnetic) {
      dx = 0;
    }
    if (dy <= magnetic) {
      dy = 0;
    }
    double w = size.width;
    double h = size.height;
    double pw = page!.width.value.toDouble();
    double ph = page!.height.value.toDouble();
    if (w >= pw - magnetic) {
      w = pw;
    }
    if (h >= ph - magnetic) {
      h = ph;
    }

    if (dx + w > pw - magnetic) {
      w = pw - dx;
    }
    if (dy + h > ph - magnetic) {
      h = ph - dy;
    }

    containerOffset.set(Offset(dx, dy));
    containerSize.set(Size(w, h));
    accManagerHolder?.notify();
  }

  void _showACCMenu(BuildContext context) {
    if (accManagerHolder!.isMenuVisible()) {
      bool reshow = accManagerHolder!.isMenuHostChanged();
      accManagerHolder!.unshowMenu(context);
      if (reshow) {
        accManagerHolder!.showMenu(context, this);
      }
    } else {
      accManagerHolder!.showMenu(context, this);
    }
  }

  Widget showOverlay(BuildContext context) {
    Size ratio = getRealRatio();
    Offset realOffset = getRealOffsetWithGivenRatio(ratio);
    Size realSize = getRealSize();
    bool isAccSelected = accManagerHolder!.isCurrentIndex(index);
    double mouseMargin = resizeButtonSize / 2;
    Size marginSize = Size(realSize.width + resizeButtonSize, realSize.height + resizeButtonSize);

    //logHolder.log('showOverlay:$marginSize', level: 6);

    return Visibility(
        visible: (visible && !removed.value),
        child: Positioned(
          // left: realOffset.dx,
          // top: realOffset.dy,
          // height: realSize.height,
          // width: realSize.width,
          left: realOffset.dx - mouseMargin,
          top: realOffset.dy - mouseMargin,
          height: realSize.height + resizeButtonSize,
          width: realSize.width + resizeButtonSize,

          child: GestureDetector(
            onPanDown: (details) {
              accManagerHolder!.setCurrentIndex(index);
              logHolder.log('onPanDown:${details.localPosition}', level: 5);
              _showACCMenu(context);
            },
            onTap: () {
              logHolder.log('onTap', level: 6);
            },
            onTapUp: (details) {
              logHolder.log('onTapUp', level: 6);
            },
            onTapDown: (details) {
              // accManagerHolder!.setCurrentIndex(index);
              // logHolder.log('onTapDown:${details.localPosition}', level: 5);
              // _showACCMenu(context);
            },
            onPanStart: (details) {
              actionStart = true;
              logHolder.log('onPanStart:${details.localPosition}', level: 5);
              //if (isCorners(details.localPosition, realSize, resizeButtonSize)) {
              if (isCorners(details.localPosition, marginSize, resizeButtonSize)) {
                isHover = false;
                isCornered = true;
                isRadiused = false;
                //} else if (isRadius(details.localPosition, realSize, resizeButtonSize / 4)) {
              } else if (isRadius(details.localPosition, marginSize, resizeButtonSize / 2)) {
                isRadiused = true;
                isHover = false;
                isCornered = false;
              } else {
                isCornered = false;
                isRadiused = false;
                isHover = true;
              }
              logHolder.log('onPanStart : ${details.localPosition}');
              mychangeStack.startTrans();
              entry!.markNeedsBuild();
              accManagerHolder!.unshowMenu(context);
            },
            onPanUpdate: (details) {
              double dx = (details.delta.dx / ratio.width);
              double dy = (details.delta.dy / ratio.height);
              if (!resizeWidget(dx, dy, ratio, isAccSelected)) {
                if (_validationCheck(false, dx, dy, cursor, isAccSelected, ratio)) {
                  _setContainerOffset(
                      Offset((containerOffset.value.dx + dx), (containerOffset.value.dy + dy)));
                }
              }
              entry!.markNeedsBuild();
              //invalidateContents();
            },
            onPanEnd: (details) {
              actionStart = false;
              logHolder.log('onPanEnd:', level: 5);
              mychangeStack.endTrans();
              invalidateContents();
            },
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(mouseMargin),
                  child: Transform.rotate(
                    angle: contentRotate.value ? 0 : rotate.value * (pi / 180),
                    child: Opacity(
                      opacity: opacity.value,
                      child: Stack(children: [
                        glassMorphic(
                          isGlass: glass.value,
                          child: myNeumorphicButton(
                            boxShape: _getBoxShape(),
                            borderColor: _getBorderColor(),
                            borderWidth: borderWidth.value,
                            intensity: intensity.value,
                            lightSource: lightSource.value,
                            depth: depth.value,
                            bgColor: bgColor.value.withOpacity(glass.value
                                ? 0.5
                                : bgColor.value == Colors.transparent
                                    ? 0
                                    : 1),
                            onPressed: () {},
                            child: Transform.rotate(
                              angle: contentRotate.value ? rotate.value * (pi / 180) : 0,
                              child: accChild,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: accManagerHolder!.orderVisible,
                          child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                  height: realSize.height,
                                  width: realSize.width,
                                  color: Colors.white.withOpacity(0.5),
                                  child: Center(
                                      child: Text(
                                    '${order.value}',
                                    style: MyTextStyles.h3Eng,
                                  )))),
                        ),
                        Visibility(
                          visible: primary.value,
                          child: const Icon(
                            Icons.star,
                            color: MyColors.mainColor,
                            semanticLabel: 'Primary',
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: ResiablePainter(
                      isAccSelected, //accManagerHolder!.isCurrentIndex(index),
                      bgColor.value,
                      borderColor.value,
                      resizable,
                      realSize,
                      isCornered,
                      isRadiused,
                      isHover,
                      isCornerHover,
                      isRadiusHover,
                      radiusTopLeft.value,
                      radiusTopRight.value,
                      radiusBottomLeft.value,
                      radiusBottomRight.value),
                  child: MouseRegion(
                    onHover: (details) {
                      //logHolder.log('Hover ${details.localPosition}',
                      //    level: 5);
                      //if (isCorners(details.localPosition, realSize, resizeButtonSize)) {
                      if (isCorners(details.localPosition, marginSize, resizeButtonSize)) {
                        isCornered = true;
                        isRadiused = false;
                        isHover = false;
                        entry!.markNeedsBuild();
                        //} else if (isRadius(details.localPosition, realSize, resizeButtonSize / 4)) {
                      } else if (isRadius(
                          details.localPosition, marginSize, resizeButtonSize / 2)) {
                        isCornered = false;
                        isRadiused = true;
                        isHover = false;
                        entry!.markNeedsBuild();
                      } else {
                        isCornered = false;
                        isRadiused = false;
                        if (!isHover) {
                          isHover = true;
                          entry!.markNeedsBuild();
                        }
                      }
                    },
                    onEnter: (details) {
                      //logHolder.log('Enter ${details.localPosition}',
                      //    level: 5);
                      isHover = true;
                      entry!.markNeedsBuild();
                    },
                    onExit: (details) {
                      //logHolder.log('Exit', level: 5);
                      if (!actionStart) {
                        isHover = false;
                        isCornered = false;
                        isRadiused = false;
                        clearCornerHover();
                        entry!.markNeedsBuild();
                      }
                    },
                    child: DropZoneWidget(
                      onDroppedFile: (model) {
                        logHolder.log('contents added ${model.key}');
                        accChild.playManager!.push(this, model);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  NeumorphicBoxShape _getBoxShape() {
    switch (boxType.value) {
      case BoxType.rountRect:
        return NeumorphicBoxShape.roundRect(BorderRadius.only(
            topLeft: Radius.circular(radiusTopLeft.value),
            topRight: Radius.circular(radiusTopRight.value),
            bottomLeft: Radius.circular(radiusBottomLeft.value),
            bottomRight: Radius.circular(radiusBottomRight.value)));
      case BoxType.cicle:
        return const NeumorphicBoxShape.circle();
      case BoxType.rect:
        return const NeumorphicBoxShape.rect();
      case BoxType.stadium:
        return const NeumorphicBoxShape.stadium();
      case BoxType.beveled:
        return NeumorphicBoxShape.beveled(BorderRadius.only(
            topLeft: Radius.circular(radiusTopLeft.value),
            topRight: Radius.circular(radiusTopRight.value),
            bottomLeft: Radius.circular(radiusBottomLeft.value),
            bottomRight: Radius.circular(radiusBottomRight.value)));
      default:
        break;
    }
    return defaultBoxShape;
  }

  Color _getBorderColor() {
    if (accChild.playManager != null) {
      if (accChild.playManager!.playList.value.isNotEmpty) {
        hasContents = true;
      }
    }

    if (hasContents && borderWidth.value == 0) {
      return Colors.transparent;
    }

    return (borderWidth.value == 0) ? MyColors.primaryColor : borderColor.value;
  }

  void invalidateContents() {
    //logHolder.log('invalidateContents');
    accChild.invalidate();
  }

  Future<void> pauseAllExceptCurrent() async {
    //logHolder.log('invalidateContents');
    await accChild.pauseAllExceptCurrent();
  }

  bool resizeWidget(double dx, double dy, Size ratio, bool isAccSelected) {
    if (dx == 0 && dy == 0) return false;

    switch (cursor) {
      case CursorType.neResize:
      case CursorType.ncResize:
      case CursorType.nwResize:
      case CursorType.mwResize:
      case CursorType.swResize:
      case CursorType.scResize:
      case CursorType.seResize:
      case CursorType.meResize:
        return _sizeChanged(dx, dy, ratio, isAccSelected);
      default:
        break;
    }
    return _radiusChanged(dx, dy);
  }

  bool _sizeChanged(double dx, double dy, Size ratio, bool isAccSelected) {
    double w = containerSize.value.width;
    double h = containerSize.value.height;
    double cx = containerOffset.value.dx;
    double cy = containerOffset.value.dy;

    if (!_validationCheck(true, dx, dy, cursor, isAccSelected, ratio)) {
      return true;
    }

    Size afterSize = Size(w, h);
    Offset afterOffset = Offset(cx, cy);

    List<Size> afterSizeList = [
      Size((w - dx), (h - dy)),
      Size(w, (h - dy)),
      Size((w + dx), (h - dy)),
      Size((w + dx), h),
      Size((w + dx), (h + dy)),
      Size(w, (h + dy)),
      Size((w - dx), (h + dy)),
      Size((w - dx), h)
    ];

    List<Offset> afterOffsetList = [
      Offset((cx + dx), (cy + dy)),
      Offset(cx, (cy + dy)),
      Offset(cx, (cy + dy)),
      Offset(cx, cy),
      Offset(cx, cy),
      Offset(cx, cy),
      Offset((cx + dx), cy),
      Offset((cx + dx), cy),
    ];

    int i = 0;
    for (CursorType c in cursorList) {
      if (cursor == c) {
        afterSize = afterSizeList[i];
        afterOffset = afterOffsetList[i];
        break;
      }
      i++;
    }

    if (afterSize.width * ratio.width > minAccSize &&
        afterSize.height * ratio.height > minAccSize) {
      _setContainerOffsetAndSize(
          Offset(afterOffset.dx, afterOffset.dy), Size(afterSize.width, afterSize.height));
    }
    return true;
  }

  bool _radiusChanged(double dx, double dy) {
    double direction = 1;
    double newRadius = 0;
    switch (cursor) {
      case CursorType.neRadius:
        direction = (dx >= 0 && dy >= 0) ? 1 : -1;
        newRadius = radiusTopLeft.value;
        break;
      case CursorType.seRadius:
        direction = (dx >= 0 && dy <= 0) ? 1 : -1;
        newRadius = radiusBottomLeft.value;
        break;
      case CursorType.nwRadius:
        direction = (dx <= 0 && dy >= 0) ? 1 : -1;
        newRadius = radiusTopRight.value;
        break;
      case CursorType.swRadius:
        direction = (dx <= 0 && dy <= 0) ? 1 : -1;
        newRadius = radiusBottomRight.value;
        break;
      default:
        return false;
    }

    //newRadius += (dx.abs() + dy.abs()) * pi * direction;
    newRadius += asin(dy.abs() / sqrt(dx * dx + dy * dy)) * (180 / pi) * direction;
    logHolder.log("newRadius=$newRadius", level: 6);
    if (newRadius > pi * 180) {
      return true;
    }
    if (newRadius < 0) newRadius = 0;
    if (newRadius > pi * 180) newRadius = pi * 180;

    switch (cursor) {
      case CursorType.neRadius:
        radiusTopLeft.set(newRadius);
        return true;
      case CursorType.seRadius:
        radiusBottomLeft.set(newRadius);
        return true;
      case CursorType.nwRadius:
        radiusTopRight.set(newRadius);
        return true;
      case CursorType.swRadius:
        radiusBottomRight.set(newRadius);
        return true;
      default:
        break;
    }
    return false;
  }

  bool isCorners(Offset point, Size widgetSize, double r) {
    for (int i = 0; i < 8; i++) {
      isCornerHover[i] = false;
    }
    List<Offset> centerList = ResiablePainter.getCornerCenters(widgetSize);
    int len = centerList.length;
    for (int i = 0; i < len; i++) {
      if (ResiablePainter.isCorner(point, centerList[i], r / 2)) {
        cursor = cursorList[i];
        isCornerHover[i] = true;
        return true;
      }
    }
    cursor = CursorType.move;
    return false;
  }

  bool isRadius(Offset point, Size widgetSize, double r) {
    for (int i = 0; i < 4; i++) {
      isRadiusHover[i] = false;
    }
    List<Rect> rectList = ResiablePainter.getRadiusRect(widgetSize, radiusTopLeft.value,
        radiusTopRight.value, radiusBottomRight.value, radiusBottomLeft.value);

    int i = 0;
    for (Rect rect in rectList) {
      if (ResiablePainter.isCorner(point, Offset(rect.left + r, rect.top + r), r)) {
        cursor = radiusList[i];
        isRadiusHover[i] = true;
        return true;
      }
      i++;
    }
    cursor = CursorType.move;
    return false;
  }

  void clearCornerHover() {
    for (int i = 0; i < 8; i++) {
      isCornerHover[i] = false;
    }
    for (int i = 0; i < 4; i++) {
      isRadiusHover[i] = false;
    }
  }

  void setState() {
    entry!.markNeedsBuild();
  }

  Future<ContentsType> getCurrentContentsType() {
    return accChild.playManager!.getCurrentContentsType();
  }

  Future<PlayState> getCurrentPlayState() {
    return accChild.playManager!.getCurrentPlayState();
  }

  Future<bool> getCurrentMute() {
    return accChild.playManager!.getCurrentMute();
  }

  Future<void> next({bool pause = false}) async {
    await accChild.playManager!.next(pause: pause);
  }

  Future<void> prev({bool pause = false}) async {
    await accChild.playManager!.prev(pause: pause);
  }

  Future<void> pause() async {
    await accChild.playManager!.pause();
  }

  Future<void> mute() async {
    await accChild.playManager!.mute();
  }

  Future<void> play() async {
    await accChild.playManager!.play();
  }

  void setBgColor(Color color) {
    bgColor.set(color);
    setState();
    accManagerHolder!.notify();
  }

  bool _validationCheck(
      bool isSizeCheck, double dx, double dy, CursorType cursor, bool isAccSelected, Size ratio) {
    if (page == null) {
      return true;
    }

    Offset realOffset = getRealOffset();
    double realX = realOffset.dx;
    double realY = realOffset.dy;
    Size realSize = getRealSize();
    double realHeight = realSize.height; //-resizeButtonSize;
    double realWidth = realSize.width; //-resizeButtonSize;

    //CursorType newCursor = resetCornerPosition(rotate.value, cursor);

    double pageLeft = page!.origin.dx;
    double pageTop = page!.origin.dy;
    double pageRight = pageLeft + page!.realSize.width;
    double pageBottom = pageTop + page!.realSize.height;

    double border = borderWidth.value;
    double borderW = border * ratio.width;
    double borderH = border * ratio.height;

    double left = realX + dx + borderW;
    double top = realY + dy + borderH;
    double right = left + realWidth - (borderW * 2);
    double bottom = top + realHeight - (borderH * 2);

    List<bool> sizeConditions = [
      (dx < 0 && left < pageLeft) || (dy < 0 && top < pageTop), // neResize
      (dy < 0 && top < pageTop), // ncResize
      (dx > 0 && right > pageRight) || (dy < 0 && top < pageTop), // nwResize
      (dx > 0 && right > pageRight), // mwResize
      (dx > 0 && right > pageRight) || (dy > 0 && bottom > pageBottom), // swResize
      (dy > 0 && bottom > pageBottom), // scResize
      (dx < 0 && left < pageLeft) || (dy > 0 && bottom > pageBottom), // seResize
      (dx < 0 && left < pageLeft) // meResize
    ];

    int i = 0;
    if (isSizeCheck) {
      for (CursorType c in cursorList) {
        if (cursor == c) {
          if (sizeConditions[i]) {
            return false;
          }
        }
        i++;
      }

      // size validataion check
      switch (cursor) {
        case CursorType.nwResize:
        case CursorType.mwResize:
          if (realWidth + dx > page!.realSize.width) {
            return false;
          }
          break;
        case CursorType.scResize:
        case CursorType.seResize:
          if (realHeight + dy > page!.realSize.height) {
            return false;
          }
          break;
        case CursorType.swResize:
          if ((realWidth + dx > page!.realSize.width) ||
              (realHeight + dy > page!.realSize.height)) {
            return false;
          }
          break;
        default:
          break;
      }
      if (realWidth + dx < minAccSize) {
        return false;
      }
      if (realHeight + dy < minAccSize) {
        return false;
      }
    } else {
      List<bool> offsetConditions = [
        (dx < 0 && left < pageLeft),
        (dy < 0 && top < pageTop),
        (dx > 0 && right > pageRight),
        (dy > 0 && bottom > pageBottom),
      ];
      for (bool condition in offsetConditions) {
        if (condition) {
          return false;
        }
      }
      i++;
    }
    return true;
  }

  void toggleFullscreen() {
    fullscreen.set(!fullscreen.value);

    if (fullscreen.value) {
      Size pageSize = page!.getSize();

      _prevOffset = containerOffset.value;
      _prevSize = containerSize.value;
      _setContainerOffsetAndSize(const Offset(0, 0), pageSize);
      //containerOffset.set(start);
      //containerSize.set(pageSize);
    } else {
      _setContainerOffsetAndSize(_prevOffset, _prevSize);
      //containerOffset.set(_prevOffset);
      //containerSize.set(_prevSize);
    }
  }

  bool isFullscreen() {
    if (page != null) {
      if (containerSize.value.width.round() == page!.width.value &&
          containerSize.value.height.round() == page!.height.value) {
        fullscreen.set(true);
      } else {
        fullscreen.set(false);
      }
    }
    return fullscreen.value;
  }
}
