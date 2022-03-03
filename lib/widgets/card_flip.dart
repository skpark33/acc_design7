import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acc_design7/common/util/logger.dart';

class TwinCardFlip extends StatefulWidget {
  final Widget firstPage;
  final Widget secondPage;
  final bool flip;
  const TwinCardFlip({
    Key? key,
    required this.firstPage,
    required this.secondPage,
    required this.flip,
  }) : super(key: key);

  @override
  _TwinCardFlipState createState() => _TwinCardFlipState();
}

class _TwinCardFlipState extends State<TwinCardFlip> {
  bool isBack = true;
  double angle = 0;

  @override
  void initState() {
    super.initState();
  }

  // void _flip() {
  //   logHolder.log('card fliped--------------------------------------', level: 6);
  //   setState(() {
  //     angle = (angle + pi) % (2 * pi);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!widget.flip) {
      angle = 0;
    } else {
      angle = (angle + pi) % (2 * pi);
    }
    logHolder.log('angle=$angle-------------------------------------', level: 6);
    return SafeArea(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            //onTap: _flip,
            child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: angle),
                duration: const Duration(seconds: 1),
                builder: (BuildContext context, double val, __) {
                  if (val >= (pi / 2)) {
                    isBack = false;
                  } else {
                    isBack = true;
                  }

                  return (Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(val),
                    child: isBack
                        ? Container(
                            child: widget.firstPage,
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: widget.secondPage,
                          ),
                  ));
                }),
          ),
        ],
      ),
    ));
  }
}
