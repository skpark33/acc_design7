//import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
//import 'acc_manager.dart';
//import '../util/logger.dart';

const double resizeButtonSize = 40.0;

class ResiablePainter extends CustomPainter {
  bool isSelected = false;
  bool resizable = true;
  final Size widgetSize;
  final bool isCornered;
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

    if (resizable) {
      double r = resizeButtonSize;

      var cornerBrush1 = Paint()
        ..color = Colors.pink.withOpacity(.3)
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill
        //..blendMode = BlendMode.darken
        //..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..strokeJoin = StrokeJoin.round;
      var cornerBrush2 = Paint()
        ..color = Colors.blue[500]!.withOpacity(0.5)
        // ..shader = LinearGradient(
        //   begin: Alignment.topRight,
        //   end: Alignment.bottomLeft,
        //   colors: [
        //     Colors.pink[900]!.withOpacity(0.5),
        //     Colors.pink[200]!.withOpacity(0.5),
        //   ],
        // ).createShader(Rect.fromLTRB(0, 0, r, r))
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill
        //..blendMode = BlendMode.darken
        //..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.darken
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      var radiusBrush1 = Paint()
        ..color = Colors.pink.withOpacity(.3)
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill
        //r..blendMode = BlendMode.darken
        //..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10)
        ..strokeJoin = StrokeJoin.round;
      var radiusBrush2 = Paint()
        ..color = Colors.blue
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill
        //r..blendMode = BlendMode.darken
        //..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10)
        ..strokeJoin = StrokeJoin.round;

      var radiusBrush3 = Paint()
        ..color = Colors.white
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        //r..blendMode = BlendMode.darken
        //..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10)
        ..strokeJoin = StrokeJoin.round;

      // 실제크기
      //canvas.drawRRect(RRect.fromLTRBAndCorners(0, 0, widgetSize.width, widgetSize.height), radiusBrush1);

      // 보이는 크기
      //canvas.drawRRect(RRect.fromLTRBAndCorners(0 + r, 0 + r, widgetSize.width - r, widgetSize.height - r), radiusBrush1);

      // if (isCornerHover[0]) canvas.drawCircle(const Offset(0, 0), r, cornerBrush);
      // if (isCornerHover[1]) canvas.drawCircle(Offset(0, widgetSize.height), r, cornerBrush);
      // if (isCornerHover[2]) canvas.drawCircle(Offset(widgetSize.width, 0), r, cornerBrush);
      // if (isCornerHover[3]) canvas.drawCircle(Offset(widgetSize.width, widgetSize.height), r, cornerBrush);
      if (isCornered || isHover) {
        double outCenter = -r / 2;
        double inCenter = -(r - 10) / 2;
        double inR = r - 10;
        double outR = r;
        canvas.drawArc(Rect.fromLTWH(outCenter, outCenter, outR, outR), 0,
            .5 * pi, true, isCornerHover[0] ? cornerBrush2 : cornerBrush1);
        canvas.drawArc(
            Rect.fromLTWH(outCenter, widgetSize.height + outCenter, outR, outR),
            1.5 * pi,
            .5 * pi,
            true,
            isCornerHover[1] ? cornerBrush2 : cornerBrush1);
        canvas.drawArc(
            Rect.fromLTWH(widgetSize.width + outCenter, outCenter, outR, outR),
            .5 * pi,
            .5 * pi,
            true,
            isCornerHover[2] ? cornerBrush2 : cornerBrush1);
        canvas.drawArc(
            Rect.fromLTWH(widgetSize.width + outCenter,
                widgetSize.height + outCenter, outR, outR),
            pi,
            .5 * pi,
            true,
            isCornerHover[3] ? cornerBrush2 : cornerBrush1);

        canvas.drawArc(Rect.fromLTWH(inCenter, inCenter, inR, inR), 0, .5 * pi,
            true, radiusBrush3);
        canvas.drawArc(
            Rect.fromLTWH(inCenter, widgetSize.height + inCenter, inR, inR),
            1.5 * pi,
            .5 * pi,
            true,
            radiusBrush3);
        canvas.drawArc(
            Rect.fromLTWH(widgetSize.width + inCenter, inCenter, inR, inR),
            .5 * pi,
            .5 * pi,
            true,
            radiusBrush3);
        canvas.drawArc(
            Rect.fromLTWH(widgetSize.width + inCenter,
                widgetSize.height + inCenter, inR, inR),
            pi,
            .5 * pi,
            true,
            radiusBrush3);
      }

      if (isHover) {
        //canvas.drawOval(Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height), radiusBrush1);

        double dx = 0;
        double dy = 0;

        if (radiusTopLeft > 0) {
          dx = radiusTopLeft / (2 * pi);
          if (dx > 90) dx = 90;
          dy = dx;
        }
        //logHolder.log('dx=$dx, dy=$dy');
        canvas.drawCircle(
            Offset(widgetSize.width * (1 / 8) + dx,
                widgetSize.height * (1 / 8) + dy),
            r / 3,
            isRadiusHover[0] ? radiusBrush2 : radiusBrush1);
        canvas.drawCircle(
            Offset(widgetSize.width * (1 / 8) + dx,
                widgetSize.height * (1 / 8) + dy),
            r / 4,
            radiusBrush3);

        dx = dy = 0;
        if (radiusTopRight > 0) {
          dy = radiusTopRight / (2 * pi);
          if (dy > 90) dy = 90;
          dx = -dy;
        }
        canvas.drawCircle(
            Offset(widgetSize.width * (7 / 8) + dx,
                widgetSize.height * (1 / 8) + dy),
            r / 3,
            isRadiusHover[2] ? radiusBrush2 : radiusBrush1);
        canvas.drawCircle(
            Offset(widgetSize.width * (7 / 8) + dx,
                widgetSize.height * (1 / 8) + dy),
            r / 4,
            radiusBrush3);

        dx = dy = 0;
        if (radiusBottomLeft > 0) {
          dx = radiusBottomLeft / (2 * pi);
          if (dx > 90) dx = 90;
          dy = -dx;
        }
        canvas.drawCircle(
            Offset(widgetSize.width * (1 / 8) + dx,
                widgetSize.height * (7 / 8) + dy),
            r / 3,
            isRadiusHover[1] ? radiusBrush2 : radiusBrush1);
        canvas.drawCircle(
            Offset(widgetSize.width * (1 / 8) + dx,
                widgetSize.height * (7 / 8) + dy),
            r / 4,
            radiusBrush3);

        dx = dy = 0;
        if (radiusBottomRight > 0) {
          dx = (radiusBottomRight / (2 * pi)) * (-1);
          if (dx < -90) dx = -90;
          dy = dx;
        }
        canvas.drawCircle(
            Offset(widgetSize.width * (7 / 8) + dx,
                widgetSize.height * (7 / 8) + dy),
            r / 3,
            isRadiusHover[3] ? radiusBrush2 : radiusBrush1);
        canvas.drawCircle(
            Offset(widgetSize.width * (7 / 8) + dx,
                widgetSize.height * (7 / 8) + dy),
            r / 4,
            radiusBrush3);

        //canvas.drawImage(ACCManager.needleImage!, Offset(widgetSize.width / 2, widgetSize.height / 2), radiusBrush3);
      }

      //Radius corner = Radius.circular(r * 2 / 3);
// if (isCornerHover[0]) canvas.drawRRect(RRect.fromLTRBAndCorners(0, 0, r, r, bottomRight: corner), cornerBrush);
      // if (isCornerHover[1])
      //   canvas.drawRRect(
      //       RRect.fromLTRBAndCorners(0, widgetSize.height - r, r, widgetSize.height, topRight: corner), cornerBrush);
      // if (isCornerHover[2])
      //   canvas.drawRRect(
      //       RRect.fromLTRBAndCorners(widgetSize.width - r, 0, widgetSize.width, r, bottomLeft: corner), cornerBrush);
      // if (isCornerHover[3])
      //   canvas.drawRRect(
      //       RRect.fromLTRBAndCorners(widgetSize.width - r, widgetSize.height - r, widgetSize.width, widgetSize.height,
      //           topLeft: corner),
      //       cornerBrush);

      // if (isEdgeHover[0]) canvas.drawRect(rect[0], cornerBrush);
      // if (isEdgeHover[1]) canvas.drawRect(rect[1], cornerBrush);
      // if (isEdgeHover[2]) canvas.drawRect(rect[2], cornerBrush);
      // if (isEdgeHover[3]) canvas.drawRect(rect[3], cornerBrush);
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
