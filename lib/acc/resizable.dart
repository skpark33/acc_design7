//import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
//import 'acc_manager.dart';
import '../constants/styles.dart';
import '../common/util/my_utils.dart';

const double resizeButtonSize = 40.0;

class ResiablePainter extends CustomPainter {
  bool isSelected = false;
  bool resizable = true;
  final Size widgetSize;
  final bool isCornered;
  final bool isRadiused;
  final bool isHover;
  final List<bool> isCornerHover;
  final List<bool> isRadiusHover;

  Offset delta = Offset.zero;
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  //final List<bool> isEdgeHover;
  //final List<Rect> rect;
  //Size _realSize = const Size(0, 0);

  ResiablePainter(
      this.isSelected,
      this.resizable,
      this.widgetSize,
      this.isCornered,
      this.isRadiused,
      this.isHover,
      this.isCornerHover,
      this.isRadiusHover,
      this.radiusTopLeft,
      this.radiusTopRight,
      this.radiusBottomLeft,
      this.radiusBottomRight)
      : super();

  @override
  void paint(Canvas canvas, Size size) {
    // resize 가 가능하게 하는...외곽선과 꼭지가 나오도록 한다.

    if (!resizable) {
      return;
    }

    // shader example !!!!
    // ..shader = LinearGradient(
    //   begin: Alignment.topRight,
    //   end: Alignment.bottomLeft,
    //   colors: [
    //     Colors.pink[900]!.withOpacity(0.5),
    //     Colors.pink[200]!.withOpacity(0.5),
    //   ],
    // ).createShader(Rect.fromLTRB(0, 0, r, r))

    // blus example !!!
    //..blendMode = BlendMode.darken
    //  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    var radiusBrush = Paint()
      //..color = Colors.pink.withOpacity(.3)
      //..color = MyColors.primaryColor
      ..color = Colors.white.withOpacity(.3)
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    var cornerBrush = Paint()
      //..color = Colors.pink.withOpacity(.3)
      //..color = MyColors.primaryColor
      ..color = Colors.grey
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    var selectBrush = Paint()
      ..color = MyColors.active
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    var borderBrush = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    double r = resizeButtonSize;

    if (isCornered || isHover) {
      const Radius radius = Radius.circular(5);
      double half = r / 15;
      double thick = half * 3;
      double length = r * 3 / 4;

      double arcR = r * 5 / 4;
      double left = -arcR / 2;
      double right = widgetSize.width - arcR / 2;
      double top = -arcR / 2;
      double bottom = widgetSize.height - arcR / 2;

      List<Rect> cornerArcList = [
        // left,top,width,height
        Rect.fromLTWH(left, top, arcR, arcR), //neResize
        Rect.fromLTWH(right, top, arcR, arcR), //nwResize
        Rect.fromLTWH(right, bottom, arcR, arcR), //swResize
        Rect.fromLTWH(left, bottom, arcR, arcR), //seResize
      ];

      left = -half;
      right = widgetSize.width + half - length;
      top = -half;
      bottom = widgetSize.height + half - thick;

      List<Rect> barList = [
        // left,top,width,height
        Rect.fromLTWH(left, top, length, thick), //neResize
        Rect.fromLTWH(right, top, length, thick), //nwResize
        Rect.fromLTWH(right, bottom, length, thick), //swResize
        Rect.fromLTWH(left, bottom, length, thick), //seResize
      ];

      right = widgetSize.width + half - thick;
      bottom = widgetSize.height + half - length;

      List<Rect> stickList = [
        // left,top,width,height
        Rect.fromLTWH(left, top, thick, length), //neResize
        Rect.fromLTWH(right, top, thick, length), //nwResize
        Rect.fromLTWH(right, bottom, thick, length), //swResize
        Rect.fromLTWH(left, bottom, thick, length), //seResize
      ];

      double east = -half;
      double west = widgetSize.width + half - thick;
      double north = -half;
      double south = widgetSize.height + half - thick;
      double middle = (widgetSize.height - length) / 2;
      double center = (widgetSize.width - length) / 2;

      List<Rect> middleList = [
        // left,top,width,height
        Rect.fromLTWH(east, middle, thick, length), //east-middle
        Rect.fromLTWH(center, north, length, thick), //north-center
        Rect.fromLTWH(west, middle, thick, length), //weast-middle
        Rect.fromLTWH(center, south, length, thick), //source-center
      ];
      // List<Rect> middleArcList = [
      //   // left,top,width,height
      //   Rect.fromLTWH(east, middle, arcR, arcR), //neResize
      //   Rect.fromLTWH(center, north, arcR, arcR), //nwResize
      //   Rect.fromLTWH(west, middle, arcR, arcR), //swResize
      //   Rect.fromLTWH(center, south, arcR, arcR), //seResize
      // ];

      List<Offset> angleList = [
        const Offset(0.0 * pi, 0.5 * pi),
        const Offset(0.5 * pi, 0.5 * pi),
        const Offset(1.0 * pi, 0.5 * pi),
        const Offset(1.5 * pi, 0.5 * pi),
      ];

      for (int i = 0; i < 4; i++) {
        if (isCornerHover[i]) {
          canvas.drawRRect(RRect.fromRectAndRadius(barList[i], radius), selectBrush);
          canvas.drawRRect(RRect.fromRectAndRadius(stickList[i], radius), selectBrush);
          canvas.drawRRect(RRect.fromRectAndRadius(middleList[i], radius), selectBrush);
          canvas.drawArc(cornerArcList[i], angleList[i].dx, angleList[i].dy, true, selectBrush);
          //canvas.drawArc(middleArcList[i], angleList[i].dx, angleList[i].dy, true, selectBrush);
        } else {
          canvas.drawRRect(RRect.fromRectAndRadius(barList[i], radius), cornerBrush);
          canvas.drawRRect(RRect.fromRectAndRadius(stickList[i], radius), cornerBrush);
          canvas.drawRRect(RRect.fromRectAndRadius(middleList[i], radius), cornerBrush);
        }
      }
    }

    if (isHover || isRadiused) {
      List<Offset> angleList = [
        const Offset(1.0 * pi, 0.5 * pi),
        const Offset(1.5 * pi, 0.5 * pi),
        const Offset(0.0 * pi, 0.5 * pi),
        const Offset(0.5 * pi, 0.5 * pi),
      ];

      double left = widgetSize.width * (1 / 8) - r / 4;
      double top = widgetSize.height * (1 / 8) - r / 4;
      double right = widgetSize.width * (7 / 8) - r * 3 / 4;
      double bottom = widgetSize.height * (7 / 8) - r * 3 / 4;

      double ne = getRadiusPos(radiusTopLeft);
      double nw = getRadiusPos(radiusTopRight);
      double sw = getRadiusPos(radiusBottomRight, minus: -1);
      double se = getRadiusPos(radiusBottomLeft);

      List<Rect> bigArcList = [
        // left,top,width,height
        Rect.fromLTWH(left + ne, top + ne, r, r), //neResize
        Rect.fromLTWH(right - nw, top + nw, r, r), //nwResize
        Rect.fromLTWH(right + sw, bottom + sw, r, r), //swResize
        Rect.fromLTWH(left + se, bottom - se, r, r), //seResize
      ];

      for (int i = 0; i < 4; i++) {
        canvas.drawArc(bigArcList[i], angleList[i].dx, angleList[i].dy, true,
            isRadiusHover[i] ? selectBrush : radiusBrush);
        canvas.drawArc(
            bigArcList[i].translate(-2, -2), angleList[i].dx, angleList[i].dy, true, borderBrush);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static bool isCorner(Offset point, Offset center, double radius) {
    // x2 + y2 = r2  이것이 원의 공식.   따라서 점이 원안에 있으려면  x2 + y2 <= r2 이다.
    // 그런데,  이것은 center 가  0,0 일때 얘기이고, 지금은 center 가 0,0 이 아니니까...
    // (x-center_x)^2 + (y - center_y)^2 < radius^2  이것이 된다.

    // 편차값을 구한다. (center 를  0,0 으로 만들어준다.)
    double R = radius;
    double dx = (point.dx - center.dx).abs();
    double dy = (point.dy - center.dy).abs();

    // 일단 편차가 반지름보다 크면, 굳이 제곱을 해볼 필요도 없기 때문에 걸러준다.
    if (dx > R) return false;
    if (dy > R) return false;

    // x+y 가 반지름보다도 작으면, 원을 벗어날 수가 없다. (내접 사각형을 생각해보라)
    if (dx + dy <= R) return true;

    // 마지막으로 위대한 피타고라스 선생의 공식을 적용한다.
    if (pow(dx, 2) + pow(dy, 2) > pow(R, 2)) return false;
    return true;
  }
}
