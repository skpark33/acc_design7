//import 'dart:ui' as ui;
import 'dart:math';
//import 'package:acc_design7/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'acc_property.dart';
import '../constants/styles.dart';
import '../common/util/my_utils.dart';

const double resizeButtonSize = 40.0;
List<CursorType> cursorList = [
  CursorType.neResize,
  CursorType.ncResize,
  CursorType.nwResize,
  CursorType.mwResize,
  CursorType.swResize,
  CursorType.scResize,
  CursorType.seResize,
  CursorType.meResize,
];
List<CursorType> radiusList = [
  CursorType.neRadius,
  CursorType.nwRadius,
  CursorType.seRadius,
  CursorType.swRadius,
];

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

  Paint bgPaint = Paint();
  Paint fgPaint = Paint();
  Paint selectPaint = Paint();

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
      : super() {
    bgPaint.color = Colors.grey.withOpacity(.8);
    fgPaint.color = Colors.white;
    selectPaint.color = MyColors.primaryColor;

    bgPaint.style = PaintingStyle.fill;
    fgPaint.style = PaintingStyle.stroke;
    selectPaint.style = PaintingStyle.fill;

    bgPaint.strokeWidth = 2.0;
    fgPaint.strokeWidth = 2.0;
    selectPaint.strokeWidth = 2.0;

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
  }

  @override
  void paint(Canvas canvas, Size size) {
    // resize 가 가능하게 하는...외곽선과 꼭지가 나오도록 한다.
    if (!resizable) {
      return;
    }
    if (isHover || isCornered) {
      List<Offset> centerList = getCornerCenters(size);
      int i = 0;
      for (Offset center in centerList) {
        drawCircleHandle(canvas, center, resizeButtonSize / 2, isCornerHover[i]);
        i++;
      }
    }
    if (isHover || isRadiused) {
      List<Offset> angleList = [
        const Offset(1.0 * pi, 0.5 * pi),
        const Offset(1.5 * pi, 0.5 * pi),
        const Offset(0.0 * pi, 0.5 * pi),
        const Offset(0.5 * pi, 0.5 * pi),
      ];
      List<Rect> arcList =
          getRadiusRect(size, radiusTopLeft, radiusTopRight, radiusBottomRight, radiusBottomLeft);
      for (int i = 0; i < 4; i++) {
        drawArcHandle(canvas, arcList[i], angleList[i].dx, angleList[i].dy, isRadiusHover[i]);
      }
    }
  }

  void drawCircleHandle(Canvas canvas, Offset center, double radius, bool isSelected) {
    canvas.drawCircle(center, radius, isSelected ? selectPaint : bgPaint);
    canvas.drawCircle(center, radius - 2, fgPaint);
  }

  void drawArcHandle(Canvas canvas, Rect rect, double start, double end, bool isSelected) {
    canvas.drawArc(rect, start, end, true, isSelected ? selectPaint : bgPaint);
    canvas.drawArc(rect, start, end, true, fgPaint);
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

  static List<Offset> getCornerCenters(Size size) {
    double r = resizeButtonSize;
    double margin = r / 2;

    double east = margin;
    double center = size.width / 2;
    double west = size.width - margin;

    double north = margin;
    double middle = size.height / 2;
    double south = size.height - margin;

    List<Offset> centerList = [
      // 시계방향으로 나열한다.
      Offset(east, north),
      Offset(center, north),
      Offset(west, north),
      Offset(west, middle),
      Offset(west, south),
      Offset(center, south),
      Offset(east, south),
      Offset(east, middle),
    ];
    return centerList;
  }

  static List<Rect> getRadiusRect(Size size, double radiusTopLeft, double radiusTopRight,
      double radiusBottomRight, double radiusBottomLeft) {
    double r = resizeButtonSize; // size of handle
    double padding = r / 2; // mousePadding

    double left = padding;
    double top = padding;
    double right = size.width - padding - r;
    double bottom = size.height - padding - r;

    double ne = getRadiusPos(radiusTopLeft);
    double nw = getRadiusPos(radiusTopRight);
    double sw = getRadiusPos(radiusBottomRight, minus: -1);
    double se = getRadiusPos(radiusBottomLeft);

    List<Rect> arcList = [
      // left,top,width,height
      Rect.fromLTWH(left + ne, top + ne, r, r), //neResize
      Rect.fromLTWH(right - nw, top + nw, r, r), //nwResize
      Rect.fromLTWH(right + sw, bottom + sw, r, r), //swResize
      Rect.fromLTWH(left + se, bottom - se, r, r), //seResize
    ];
    return arcList;
  }
}
