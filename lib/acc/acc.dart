// ignore_for_file: prefer_final_fields
import 'dart:math';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:flutter/material.dart';
import 'resizable.dart';
import 'acc_property.dart';
import 'acc_manager.dart';
import '../common/drag_and_drop/drop_zone_widget.dart';
import '../common/util/logger.dart';
import '../common/undo/undo.dart';
import '../widgets/base_widget.dart';
import '../constants/styles.dart';
import '../studio/artboard/artboard_frame.dart';
import '../model/pages.dart';
import '../model/contents.dart';
//import 'package:acc_design7/studio/pages/page_manager.dart';

class ACC with ACCProperty {
  ACC({required this.page, required this.accChild, required this.index}) {
    order.set(index);
  }

  final BaseWidget accChild;
  final int index;
  PageModel? page;
  bool isStart = false;

  OverlayEntry? entry;

  bool isHover = false;
  bool isCornered = false;
  final List<bool> isCornerHover = [false, false, false, false];
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

  // double getRealDx() {
  //   // realSize/containerSize 를 곱해서, 실좌표계로 변환한다.
  //   if (page != null) {
  //     Offset origin = page!.getPosition();
  //     return page!.getRealWidthRatio() * containerOffset.value.dx + origin.dx;
  //   }
  //   return containerOffset.value.dx;
  // }

  // double getRealDy() {
  //   if (page != null) {
  //     Offset origin = page!.getPosition();
  //     return page!.getRealHeightRatio() * containerOffset.value.dy + origin.dy;
  //   }
  //   return containerOffset.value.dy;
  // }

  // double getRealWidth() {
  //   if (page != null) {
  //     return page!.getRealWidthRatio() * containerSize.value.width;
  //   }
  //   return containerSize.value.width;
  // }

  // double getRealHeight() {
  //   if (page != null) {
  //     return page!.getRealHeightRatio() * containerSize.value.height;
  //   }
  //   return containerSize.value.height;
  // }

  void _setContainerOffset(Offset offset) {
    containerOffset.set(offset);
    accManagerHolder?.notify();
  }

  // void _setContainerSize(Size size) {
  //   containerSize.set(size);
  //   accManagerHolder?.notify();
  // }

  void _setContainerOffsetAndSize(Offset offset, Size size) {
    containerOffset.set(offset);
    containerSize.set(size);
    accManagerHolder?.notify();
  }

  Widget showOverlay(BuildContext context) {
    //logHolder.log('showOverlay:${rotate.value}');
    Size ratio = getRealRatio();
    Offset realOffset = getRealOffsetWithGivenRatio(ratio);
    Size realSize = getRealSize();
    return Visibility(
      visible: (visible && !removed.value),
      child: Positioned(
        left: realOffset.dx,
        top: realOffset.dy,
        height: realSize.height,
        width: realSize.width,
        child: Opacity(
            opacity: opacity.value, child: _accBody(context, ratio, realSize)),
      ),
    );
  }

  Transform _accBody(BuildContext context, Size ratio, Size realSize) {
    bool isSelected = accManagerHolder!.isCurrentIndex(index);
    return Transform.rotate(
      angle: rotate.value * (pi / 180),
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              accManagerHolder!.setCurrentIndex(index);
              logHolder.log('acc onTapDown : ${details.localPosition}',
                  level: 5);
              //entry!.markNeedsBuild();  // setCurrentIndex 내부에서 하므로,,안해도됨.
              if (accManagerHolder!.isMenuVisible()) {
                bool reshow = accManagerHolder!.isMenuHostChanged();
                accManagerHolder!.unshowMenu(context);
                if (reshow) {
                  accManagerHolder!.showMenu(context, this);
                }
              } else {
                accManagerHolder!.showMenu(context, this);
              }
            },
            onPanStart: (details) {
              logHolder.log('acc onPanStart : ${details.localPosition}',
                  level: 5);
              //accManagerHolder!.currentAccIndex = index;
              //isInResizeEdge(details.localPosition, containerSize, resizeButtonSize);
              if (isCorners(
                  details.localPosition, realSize, resizeButtonSize)) {
                isHover = false;
                isCornered = true;
              } else {
                isCornered = false;
                if (isRadius(
                    details.localPosition, realSize, resizeButtonSize / 4)) {
                  //isHover = false;
                } else {
                  isHover = true;
                }
              }

              logHolder.log('onPanStart : ${details.localPosition}');
              mychangeStack.startTrans();
              entry!.markNeedsBuild();
              accManagerHolder!.unshowMenu(context);
              //accManagerHolder!.showMenu(this, context);
            },
            onPanEnd: (details) {
              logHolder.log('onPanEnd:', level: 5);
              mychangeStack.endTrans();
              // if (accManagerHolder!.isMenuVisible()) {
              //   accManagerHolder!.showMenu(this, context);
              // }
              //entry!.markNeedsBuild();
              invalidateContents(); //skpak test code
            },
            onPanUpdate: (details) {
              if (!resizeWidget(
                  details, containerSize.value, isCornerHover, ratio)) {
                //logHolder.log('move');
                //translateContainerOffset(details.delta);
                if (offsetValidationCheck(details.delta)) {
                  _setContainerOffset(Offset(
                      (containerOffset.value.dx +
                              details.delta.dx / ratio.width * 1.1)
                          .roundToDouble(),
                      (containerOffset.value.dy +
                              details.delta.dy / ratio.height * 1.1)
                          .roundToDouble()));
                  //containerOffset
                  //    .set(containerOffset.value + details.delta);
                }
              }
              // OverayEntry 를 사용할 때는 setState 를 하지 않고, markNeedsBuild 를 수행한다.
              entry!.markNeedsBuild();
              //invalidateContents();
            },
            child: Stack(children: [
              glassMorphic(
                isGlass: glass.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor.value.withOpacity(glass.value
                        ? 0.5
                        : bgColor.value == Colors.transparent
                            ? 0
                            : 1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(radiusTopRight.value),
                      topLeft: Radius.circular(radiusTopLeft.value),
                      bottomRight: Radius.circular(radiusBottomRight.value),
                      bottomLeft: Radius.circular(radiusBottomLeft.value),
                    ),
                    border: _drawBorder(isSelected),
                  ),
                  child: accChild,
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
                  color: Colors.red,
                  semanticLabel: 'Primary',
                ),
              ),
              CustomPaint(
                painter: ResiablePainter(
                    accManagerHolder!.isCurrentIndex(index),
                    resizable,
                    realSize,
                    isCornered,
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
                    if (isCorners(
                        details.localPosition, realSize, resizeButtonSize)) {
                      isCornered = true;
                      isHover = false;
                      entry!.markNeedsBuild();
                    } else {
                      isCornered = false;
                      if (isRadius(details.localPosition, realSize,
                          resizeButtonSize / 3)) {
                        //isHover = false;
                        //entry!.markNeedsBuild();
                      } else {
                        //logHolder.log('Hover ${details.localPosition}');
                        if (!isHover) {
                          isHover = true;
                          entry!.markNeedsBuild();
                        }
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
                    isHover = false;
                    isCornered = false;
                    clearCornerHover();
                    entry!.markNeedsBuild();
                  },
                  child: DropZoneWidget(
                    onDroppedFile: (model) {
                      logHolder.log('contents added ${model.key}');
                      accChild.playManager!.push(this, model);
                    },
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Border _drawBorder(bool isSelected) {
    bool hasContents = false;
    if (accChild.playManager != null) {
      if (accChild.playManager!.playList.value.isNotEmpty) {
        hasContents = true;
      }
    }

    if (hasContents && !isSelected && borderWidth.value == 0) {
      return Border.all(style: BorderStyle.none);
    }

    return Border.all(
        width: isSelected
            ? 4
            : (borderWidth.value == 0)
                ? borderWidth.value
                : 2,
        color: isSelected
            ? MyColors.mainColor
            : (borderWidth.value == 0)
                ? MyColors.primaryColor
                : borderColor.value);
  }

  void invalidateContents() {
    //logHolder.log('invalidateContents');
    accChild.invalidate();
  }

  Future<void> pauseAllExceptCurrent() async {
    //logHolder.log('invalidateContents');
    await accChild.pauseAllExceptCurrent();
  }

  bool resizeWidget(DragUpdateDetails details, Size widgetSize,
      List<bool> isCornerHover, Size ratio) {
    if (details.delta.dx == 0 && details.delta.dy == 0) return false;

    //
    // Size change Check part
    //
    double dx = (details.delta.dx / ratio.width).roundToDouble();
    double dy = (details.delta.dy / ratio.height).roundToDouble();

    double w = containerSize.value.width.roundToDouble();
    double h = containerSize.value.height.roundToDouble();
    double cx = containerOffset.value.dx.roundToDouble();
    double cy = containerOffset.value.dy.roundToDouble();

    bool isSizeChange = false;
    switch (cursor) {
      case CursorType.neResize:
      case CursorType.seResize:
      case CursorType.nwResize:
      case CursorType.swResize:
        isSizeChange = true;
        break;
      default:
        isSizeChange = false;
        break;
    }

    if (isSizeChange) {
      if (!sizeValidationCheck(details.delta, cursor)) {
        return false;
      }

      Size afterSize = Size(w, h);
      Offset afterOffset = Offset(cx, cy);
      switch (cursor) {
        case CursorType.neResize:
          afterSize = Size((w - dx), (h - dy));
          afterOffset = Offset((cx + dx), (cy + dy));
          break;
        case CursorType.seResize:
          afterSize = Size((w - dx), (h + dy));
          afterOffset = Offset((cx + dx), cy);
          break;
        case CursorType.nwResize:
          afterSize = Size((w + dx), (h - dy));
          afterOffset = Offset(cx, (cy + dy));
          break;
        case CursorType.swResize:
          afterSize = Size((w + dx), (h + dy));
          break;
        default:
          break;
      }
      _setContainerOffsetAndSize(afterOffset, afterSize);
      return true;
    }

    //
    // Radius Check Part !!!!
    //
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
        break;
    }

    newRadius += (dx.abs() + dy.abs()) * pi * direction;
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
        return false;
    }
  }

  bool isCorners(Offset point, Size widgetSize, double r) {
    for (int i = 0; i < 4; i++) {
      isCornerHover[i] = false;
    }

    if (ResiablePainter.isCorner(point, Offset.zero, r / 2)) {
      cursor = CursorType.neResize;
      isCornerHover[0] = true;
      return true;
    }

    if (ResiablePainter.isCorner(point, Offset(0, widgetSize.height), r / 2)) {
      cursor = CursorType.seResize;
      isCornerHover[1] = true;
      return true;
    }

    if (ResiablePainter.isCorner(point, Offset(widgetSize.width, 0), r / 2)) {
      cursor = CursorType.nwResize;
      isCornerHover[2] = true;
      return true;
    }

    if (ResiablePainter.isCorner(
        point, Offset(widgetSize.width, widgetSize.height), r / 2)) {
      cursor = CursorType.swResize;
      isCornerHover[3] = true;
      return true;
    }

    cursor = CursorType.move;
    return false;
  }

  bool isRadius(Offset point, Size widgetSize, double r) {
    for (int i = 0; i < 4; i++) {
      isRadiusHover[i] = false;
    }

    double dx = 0;
    double dy = 0;
    if (radiusTopLeft.value > 0) {
      dx = radiusTopLeft.value / (2 * pi);
      if (dx > 90) dx = 90;
      dy = dx;
    }
    if (ResiablePainter.isCorner(
        point,
        Offset(
            widgetSize.width * (1 / 8) + dx, widgetSize.height * (1 / 8) + dy),
        r)) {
      cursor = CursorType.neRadius;
      isRadiusHover[0] = true;
      return true;
    }

    dx = dy = 0;
    if (radiusTopRight.value > 0) {
      dy = radiusTopRight.value / (2 * pi);
      if (dy > 90) dy = 90;
      dx = -dy;
    }
    if (ResiablePainter.isCorner(
        point,
        Offset(
            widgetSize.width * (7 / 8) + dx, widgetSize.height * (1 / 8) + dy),
        r)) {
      cursor = CursorType.nwRadius;
      isRadiusHover[2] = true;
      return true;
    }

    dx = dy = 0;
    if (radiusBottomLeft.value > 0) {
      dx = radiusBottomLeft.value / (2 * pi);
      if (dx > 90) dx = 90;
      dy = -dx;
    }
    if (ResiablePainter.isCorner(
        point,
        Offset(
            widgetSize.width * (1 / 8) + dx, widgetSize.height * (7 / 8) + dy),
        r)) {
      cursor = CursorType.seRadius;
      isRadiusHover[1] = true;
      return true;
    }

    dx = dy = 0;
    if (radiusBottomRight.value > 0) {
      dx = (radiusBottomRight.value / (2 * pi)) * (-1);
      if (dx < -90) dx = -90;
      dy = dx;
    }
    if (ResiablePainter.isCorner(
        point,
        Offset(
            widgetSize.width * (7 / 8) + dx, widgetSize.height * (7 / 8) + dy),
        r)) {
      cursor = CursorType.swRadius;
      isRadiusHover[3] = true;
      return true;
    }

    cursor = CursorType.move;
    return false;
  }

  void clearCornerHover() {
    for (int i = 0; i < 4; i++) {
      isCornerHover[i] = false;
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

  // bool offsetValidationCheck(Offset delta) {
  //   if (containerOffset.value.dx + delta.dx < 0) {
  //     return false;
  //   }
  //   if (containerOffset.value.dy + delta.dy < 0) {
  //     return false;
  //   }
  //   if (page != null) {
  //     if (containerOffset.value.dx + containerSize.value.width + delta.dx >
  //         page!.width.value) {
  //       return false;
  //     }
  //     if (containerOffset.value.dy + containerSize.value.height + delta.dy >
  //         page!.height.value) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }
  bool offsetValidationCheck(Offset delta) {
    if (page != null) {
      // left 꼭지점 validation Check.
      double deltaX = delta.dx; // * page!.getRealWidthRatio();
      double deltaY = delta.dy; // * page!.getRealHeightRatio();
      Offset realOffset = getRealOffset();
      double realX = realOffset.dx;
      double realY = realOffset.dy;
      Size realSize = getRealSize();
      double realHeight = realSize.height;
      double realWidth = realSize.width;
      if (realX + deltaX < page!.origin.dx) {
        return false;
      }
      // Right 꼭지점 validation Check.
      if (realX + realWidth + deltaX > page!.origin.dx + page!.realSize.width) {
        return false;
      }
      // top 꼭지점  validation Check
      if (realY + deltaY < page!.origin.dy) {
        return false;
      }
      // bottom 꼭지점 validation Check.
      if (realY + realHeight + deltaY >
          page!.origin.dy + page!.realSize.height) {
        return false;
      }
    }
    return true;
  }

  bool sizeValidationCheck(Offset delta, CursorType cursor) {
    if (page != null) {
      double deltaX = delta.dx; // * page!.getRealWidthRatio();
      double deltaY = delta.dy; // * page!.getRealHeightRatio();
      Offset realOffset = getRealOffset();
      double realX = realOffset.dx;
      double realY = realOffset.dy;
      Size realSize = getRealSize();
      double realHeight = realSize.height;
      double realWidth = realSize.width;
      if (cursor == CursorType.neResize) {
        // left-top 꼭지점 validation Check.
        if (realX + deltaX < page!.origin.dx) {
          return false;
        }
        if (realY + deltaY < page!.origin.dy) {
          return false;
        }
      } else if (cursor == CursorType.nwResize) {
        // right-top 꼭지점 validation Check.
        if (realX + realWidth + deltaX >
            page!.origin.dx + page!.realSize.width) {
          return false;
        }
        if (realY + deltaY < page!.origin.dy) {
          return false;
        }
      } else if (cursor == CursorType.seResize) {
        // left-top 꼭지점 validation Check.
        if (realX + deltaX < page!.origin.dx) {
          return false;
        }
        if (realY + realHeight + deltaY >
            page!.origin.dy + page!.realSize.height) {
          return false;
        }
      } else if (cursor == CursorType.swResize) {
        // right-bottom 꼭지점 validation Check.
        if (realX + realWidth + deltaX >
            page!.origin.dx + page!.realSize.width) {
          return false;
        }
        if (realY + realHeight + deltaY >
            page!.origin.dy + page!.realSize.height) {
          return false;
        }
      }
      // size validataion check
      if (realWidth + deltaX > page!.realSize.width) {
        return false;
      }
      if (realHeight + deltaY > page!.realSize.height) {
        return false;
      }
      if (realWidth + deltaX < 1) {
        return false;
      }
      if (realHeight + deltaY < 1) {
        return false;
      }
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
}
