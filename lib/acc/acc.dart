// ignore_for_file: prefer_final_fields
import 'dart:math';
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

  double getRealDx() {
    // realSize/containerSize 를 곱해서, 실좌표계로 변환한다.
    if (page != null) {
      Offset origin = page!.getPosition();
      return page!.getRealWidthRatio() * containerOffset.value.dx + origin.dx;
    }
    return containerOffset.value.dx;
  }

  double getRealDy() {
    if (page != null) {
      Offset origin = page!.getPosition();
      return page!.getRealHeightRatio() * containerOffset.value.dy + origin.dy;
    }
    return containerOffset.value.dy;
  }

  double getRealWidth() {
    if (page != null) {
      return page!.getRealWidthRatio() * containerSize.value.width;
    }
    return containerSize.value.width;
  }

  double getRealHeight() {
    if (page != null) {
      return page!.getRealHeightRatio() * containerSize.value.height;
    }
    return containerSize.value.height;
  }

  void _setContainerOffset(Offset offset) {
    containerOffset.set(offset);
    accManagerHolder?.notify();
  }

  void _setContainerSize(Size size) {
    containerSize.set(size);
    accManagerHolder?.notify();
  }

  void _setContainerOffsetAndSize(Offset offset, Size size) {
    containerOffset.set(offset);
    containerSize.set(size);
    accManagerHolder?.notify();
  }

  Widget showOverlay(BuildContext context) {
    //logHolder.log('showOverlay:${rotate.value}');
    return Visibility(
      visible: (visible && !removed.value),
      child: Positioned(
        left: getRealDx(),
        top: getRealDy(),
        height: getRealHeight(),
        width: getRealWidth(),
        //child:
        child: Transform.rotate(
          angle: rotate.value * (pi / 180),
          child: Stack(
            children: [
              accManagerHolder!.isCurrentIndex(index) == true
                  ? AnimatedContainer(
                      //margin: EdgeInsets.symmetric(vertical: isHover ? 10 : 3),
                      decoration: decoBox(
                          isHover,
                          radiusTopLeft.value,
                          radiusTopRight.value,
                          radiusBottomLeft.value,
                          radiusBottomRight.value),
                      duration: const Duration(milliseconds: 200),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: bgColor.value,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(radiusTopRight.value),
                          topLeft: Radius.circular(radiusTopLeft.value),
                          bottomRight: Radius.circular(radiusBottomRight.value),
                          bottomLeft: Radius.circular(radiusBottomLeft.value),
                        ),
                        border: Border.all(
                          width: 2,
                          color: isHover ? Colors.red : Colors.black12,
                        ),
                      ),
                    ),
              GestureDetector(
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
                  //accManagerHolder!.currentAccIndex = index;
                  //isInResizeEdge(details.localPosition, containerSize, resizeButtonSize);
                  if (isCorners(
                      details.localPosition,
                      Size(getRealWidth(), getRealHeight()),
                      resizeButtonSize)) {
                    isHover = false;
                    isCornered = true;
                  } else {
                    isCornered = false;
                    if (isRadius(
                        details.localPosition,
                        Size(getRealWidth(), getRealHeight()),
                        resizeButtonSize / 4)) {
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
                  logHolder.log('onPanEnd:');
                  mychangeStack.endTrans();
                  // if (accManagerHolder!.isMenuVisible()) {
                  //   accManagerHolder!.showMenu(this, context);
                  // }
                  //entry!.markNeedsBuild();
                },
                onPanUpdate: (details) {
                  if (!resizeWidget(
                      details, containerSize.value, isCornerHover)) {
                    //logHolder.log('move');
                    //translateContainerOffset(details.delta);
                    if (offsetValidationCheck(details.delta)) {
                      _setContainerOffset(Offset(
                          (containerOffset.value.dx + details.delta.dx)
                              .roundToDouble(),
                          (containerOffset.value.dy + details.delta.dy)
                              .roundToDouble()));
                      //containerOffset
                      //    .set(containerOffset.value + details.delta);
                    }
                  }
                  // OverayEntry 를 사용할 때는 setState 를 하지 않고, markNeedsBuild 를 수행한다.
                  entry!.markNeedsBuild();
                  invalidateContents();
                },
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor.value,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(radiusTopRight.value),
                        topLeft: Radius.circular(radiusTopLeft.value),
                        bottomRight: Radius.circular(radiusBottomRight.value),
                        bottomLeft: Radius.circular(radiusBottomLeft.value),
                      ),
                    ),
                    child: accChild,
                  ),
                  Visibility(
                    visible: accManagerHolder!.orderVisible,
                    child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                            height: getRealHeight(),
                            width: getRealWidth(),
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
                  // Visibility(
                  //   visible: isHover,
                  //   child: Material(
                  //     type: MaterialType.transparency,
                  //     child: Container(
                  //         height: containerSize.value.height,
                  //         width: containerSize.value.width,
                  //         color: Colors.white.withOpacity(0.5),
                  //         child: Column(
                  //           children: [
                  //             Row(children: [
                  //               IconButton(
                  //                   onPressed: () {},
                  //                   icon: const Icon(Icons
                  //                       .fit_screen_outlined)), //ac_unit, all_out, api, blur_on, center_focus_weak, fit_screen_rounded panorama_photosphere
                  //               //panorama_wide_angle, vignette_rounded
                  //               IconButton(onPressed: () {}, icon: const Icon(Icons.fit_screen_outlined)),
                  //             ]),
                  //             Row(children: [
                  //               IconButton(onPressed: () {}, icon: const Icon(Icons.fit_screen_outlined)),
                  //               IconButton(onPressed: () {}, icon: const Icon(Icons.fit_screen_outlined)),
                  //             ]),
                  //           ],
                  //         )),
                  //   ),
                  // ),
                  CustomPaint(
                    painter: ResiablePainter(
                        accManagerHolder!.isCurrentIndex(index),
                        resizable,
                        Size(getRealWidth(), getRealHeight()),
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
                        if (isCorners(
                            details.localPosition,
                            Size(getRealWidth(), getRealHeight()),
                            resizeButtonSize)) {
                          isCornered = true;
                          isHover = false;
                          entry!.markNeedsBuild();
                        } else {
                          isCornered = false;
                          if (isRadius(
                              details.localPosition,
                              Size(getRealWidth(), getRealHeight()),
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
                        //logHolder.log('Enter ${details.localPosition}');
                        isHover = true;
                        entry!.markNeedsBuild();
                      },
                      onExit: (details) {
                        //logHolder.log('Exit');
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
                // Container(
                //   key: containerKey,
                // ),
                //),
                // child: ElevatedButton.icon(
                //     onPressed: () {},
                //     icon: Icon(Icons.stop_circle_rounded),
                //     label: Text('Record')),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void invalidateContents() {
    //logHolder.log('invalidateContents');
    accChild.invalidate();
  }

  bool resizeWidget(
      DragUpdateDetails details, Size widgetSize, List<bool> isCornerHover) {
    if (details.delta.dx == 0 && details.delta.dy == 0) return false;

    //
    // Size change Check part
    //

    if (cursor == CursorType.neResize) {
      logHolder.log('left top corner');
      // 제일 왼쪽 상단 꼭지점이다.
      //containerOffset += details.delta;
      //translateContainerOffset(details.delta);
      Size afterSize = Size(
          (containerSize.value.width - details.delta.dx).roundToDouble(),
          (containerSize.value.height - details.delta.dy).roundToDouble());

      if (sizeValidationCheck(details.delta)) {
        _setContainerOffsetAndSize(
            Offset(
                (containerOffset.value.dx + details.delta.dx).roundToDouble(),
                (containerOffset.value.dy + details.delta.dy).roundToDouble()),
            afterSize);
        //containerOffset.set(containerOffset.value + details.delta);
        //containerSize.set(afterSize);
      }
      return true;
    }
    if (cursor == CursorType.seResize) {
      logHolder.log('left bottom corner');
      // 제일 왼쪽 하단 꼭지점이다.
      //setContainerOffset(Offset(containerOffset.dx + details.delta.dx, containerOffset.dy));
      Size afterSize = Size(
          (containerSize.value.width - details.delta.dx).roundToDouble(),
          (containerSize.value.height + details.delta.dy).roundToDouble());

      if (sizeValidationCheck(details.delta)) {
        _setContainerOffsetAndSize(
            Offset(
                (containerOffset.value.dx + details.delta.dx).roundToDouble(),
                containerOffset.value.dy.roundToDouble()),
            afterSize);
        //containerOffset.set(Offset(containerOffset.value.dx + details.delta.dx,
        //    containerOffset.value.dy));
        //containerSize.set(afterSize);
      }
      return true;
    }
    if (cursor == CursorType.nwResize) {
      logHolder.log('right top corner');
      // 제일 오른쪽 상단 꼭지점이다.
      Size afterSize = Size(
          (containerSize.value.width + details.delta.dx).roundToDouble(),
          (containerSize.value.height - details.delta.dy).roundToDouble());

      if (sizeValidationCheck(details.delta)) {
        _setContainerOffsetAndSize(
            Offset(containerOffset.value.dx.roundToDouble(),
                (containerOffset.value.dy + details.delta.dy).roundToDouble()),
            afterSize);
        //containerOffset.set(Offset(containerOffset.value.dx,
        //    containerOffset.value.dy + details.delta.dy));
        //containerSize.set(afterSize);
      }
      return true;
    }
    if (cursor == CursorType.swResize) {
      logHolder.log('right bottom corner');
      // 제일 오른쪽 하단 꼭지점이다.
      //containerOffset += details.delta;

      Size afterSize = Size(
          (containerSize.value.width + details.delta.dx).roundToDouble(),
          (containerSize.value.height + details.delta.dy).roundToDouble());
      if (sizeValidationCheck(details.delta)) {
        _setContainerSize(afterSize);
        //containerSize.set(afterSize);
      }
      return true;
    }

    //
    // Radius Check Part !!!!
    //

    if (cursor == CursorType.neRadius) {
      // 제일 왼쪽 상단 꼭지점이다.
      double direction =
          (details.delta.dx >= 0 && details.delta.dy >= 0) ? 1 : -1;
      double delta =
          (details.delta.dx.abs() + details.delta.dy.abs()) * pi * direction;
      //logHolder.log('dx=${details.delta.dx}, dy=${details.delta.dy}, delta = $delta');

      double newRadius = radiusTopLeft.value + delta;
      if (newRadius < 0) newRadius = 0;
      if (newRadius > 2 * pi * 90) newRadius = 2 * pi * 90;
      //logHolder.log('left top corner = $newRadius');
      radiusTopLeft.set(newRadius);
      return true;
    }

    if (cursor == CursorType.seRadius) {
      // 제일 왼쪽 하단 꼭지점이다.
      double direction =
          (details.delta.dx >= 0 && details.delta.dy <= 0) ? 1 : -1;
      double delta =
          (details.delta.dx.abs() + details.delta.dy.abs()) * pi * direction;
      //logHolder.log('dx=${details.delta.dx}, dy=${details.delta.dy}, delta = $delta');

      double newRadius = radiusBottomLeft.value + delta;
      if (newRadius < 0) newRadius = 0;
      if (newRadius > 2 * pi * 90) newRadius = 2 * pi * 90;
      //logHolder.log('left bottom corner = $newRadius');
      radiusBottomLeft.set(newRadius);
      return true;
    }
    if (cursor == CursorType.nwRadius) {
      // 제일 오른쪽 상단 꼭지점이다.
      double direction =
          (details.delta.dx <= 0 && details.delta.dy >= 0) ? 1 : -1;
      double delta =
          (details.delta.dx.abs() + details.delta.dy.abs()) * pi * direction;
      logHolder.log(
          'dx=${details.delta.dx}, dy=${details.delta.dy}, delta = $delta');

      double newRadius = radiusTopRight.value + delta;
      if (newRadius < 0) newRadius = 0;
      if (newRadius > 2 * pi * 90) newRadius = 2 * pi * 90;
      //logHolder.log('right top corner = $newRadius');
      radiusTopRight.set(newRadius);
      return true;
    }
    if (cursor == CursorType.swRadius) {
      double direction =
          (details.delta.dx <= 0 && details.delta.dy <= 0) ? 1 : -1;
      double delta =
          (details.delta.dx.abs() + details.delta.dy.abs()) * pi * direction;
      logHolder.log(
          'dx=${details.delta.dx}, dy=${details.delta.dy}, delta = $delta');

      // 제일 오른쪽 하단 꼭지점이다.
      double newRadius = radiusBottomRight.value + delta;
      if (newRadius < 0) newRadius = 0;
      if (newRadius > 2 * pi * 90) newRadius = 2 * pi * 90;
      //logHolder.log('right bottom corner = $newRadius');
      radiusBottomRight.set(newRadius);
      //accManagerHolder!.notify(); //skpark test
      return true;
    }

    return false;
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

  Future<void> next() async {
    await accChild.playManager!.next();
  }

  Future<void> prev() async {
    await accChild.playManager!.prev();
  }

  void pause() {
    accChild.playManager!.pause();
  }

  void mute() {
    accChild.playManager!.mute();
  }

  void play() {
    accChild.playManager!.play();
  }

  void setBgColor(Color color) {
    bgColor.set(color);
    setState();
    accManagerHolder!.notify();
  }

  bool offsetValidationCheck(Offset delta) {
    if (containerOffset.value.dx + delta.dx < 0) {
      return false;
    }
    if (containerOffset.value.dy + delta.dy < 0) {
      return false;
    }
    if (page != null) {
      if (containerOffset.value.dx + containerSize.value.width + delta.dx >
          page!.width.value) {
        return false;
      }
      if (containerOffset.value.dy + containerSize.value.height + delta.dy >
          page!.height.value) {
        return false;
      }
    }
    return true;
  }

  bool sizeValidationCheck(Offset delta) {
    if (containerSize.value.width + delta.dx < 0) {
      return false;
    }
    if (containerSize.value.height + delta.dy < 0) {
      return false;
    }
    if (page != null) {
      if (containerOffset.value.dx + containerSize.value.width + delta.dx >
          page!.width.value) {
        return false;
      }
      if (containerOffset.value.dy + containerSize.value.height + delta.dy >
          page!.height.value) {
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
