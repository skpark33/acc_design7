//import 'dart:math';
//import 'dart:math';

// ignore_for_file: must_be_immutable

import 'package:acc_design7/constants/styles.dart';
import 'package:flutter/material.dart';
import '../util/logger.dart';

class HoverButton extends StatefulWidget {
  final void Function() onPressed;
  final void Function() onEnter;
  final void Function() onExit;
  final double width;
  final double height;
  Icon? icon;
  final String text;
  final double normalSize = 24;
  final double hoverSize = 28;

  IconData? iconData;
  Widget? iconWidget;
  Color? iconColor;
  Color? iconHoverColor;

  bool useIconData = false;
  bool useIconWidget = false;

  HoverButton({
    Key? key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.icon,
    required this.onEnter,
    required this.onExit,
    this.text = '',
    normalSize = 24,
    hoverSize = 28,
  }) : super(key: key);

  HoverButton.withIconData({
    Key? key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.iconData,
    required this.iconColor,
    required this.iconHoverColor,
    required this.onEnter,
    required this.onExit,
    this.text = '',
    normalSize = 24,
    hoverSize = 28,
  })  : useIconData = true,
        super(key: key);

  HoverButton.withIconWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.iconWidget,
    required this.onEnter,
    required this.onExit,
    this.text = '',
    normalSize = 24,
    hoverSize = 28,
  })  : useIconWidget = true,
        super(key: key);

  @override
  _ButtonHoverState createState() =>
      // ignore: no_logic_in_create_state
      _ButtonHoverState(
          // width: width,
          // height: height,
          // onPressed: onPressed,
          // onEnter: onEnter,
          // onExit: onExit,
          // text: text
          );
}

class _ButtonHoverState extends State<HoverButton> {
  // final void Function() onPressed;
  // final void Function() onEnter;
  // final void Function() onExit;
  // final double width;
  // final double height;
  // final String text;

  _ButtonHoverState(
      //{
      // required this.width,
      // required this.height,
      // required this.onPressed,
      // required this.onEnter,
      // required this.onExit,
      // required this.text
      //}
      );

  bool isHover = false;
  bool isClicked = false;
  @override
  Widget build(BuildContext context) {
    double radius = widget.width * 0.05;
    if (radius < 1) {
      radius = 1;
    }
    return GestureDetector(
      onTapDown: (details) {
        if (widget.text.isNotEmpty) {
          logHolder.log('onTabDown');
          setState(() {
            isClicked = true;
          });
          widget.onPressed.call();
        }
      },
      // onTapCancel: () {
      //   logHolder.log('onTapCancel');
      //   setState(() {
      //     isClicked = false;
      //   });
      // },
      child: MouseRegion(
        onEnter: (f) {
          setState(() {
            isHover = true;
          });
          widget.onEnter.call();
        },
        onExit: (f) {
          setState(() {
            isHover = false;
            isClicked = false;
          });
          widget.onExit.call();
        },
        child: AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: isHover ? 10 : 5),
          //margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            //border: isClicked ? Border.all(color: Colors.red, width: 1, style: BorderStyle.solid) : null,
            boxShadow: [
              BoxShadow(
                blurRadius: 7,
                spreadRadius: 0.5,
                color: isClicked
                    ? Colors.pink.withOpacity(0.5)
                    : Colors.transparent,
                //color: Colors.pink.withOpacity(0.1),
              )
            ],
            color: Colors.transparent,
          ),
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          //height: isHover ? height : height * 0.8,
          height: widget.height * 0.8,
          child: addElement(),
        ),
      ),
    );
  }

  Widget _iconButton() {
    return IconButton(
      icon: widget.useIconData
          ? Icon(widget.iconData!,
              color: isHover ? widget.iconHoverColor : widget.iconColor!)
          : widget.icon!,
      iconSize: isHover ? widget.hoverSize : widget.normalSize,
      padding: const EdgeInsets.all(0),
      onPressed: () {
        setState(() {
          isClicked = true;
        });
        widget.onPressed.call();
      },
    );
  }

  Widget addElement() {
    return Center(
      child: widget.text.isEmpty
          ? widget.useIconWidget
              ? widget.iconWidget!
              : _iconButton()
          : Row(
              children: [
                _iconButton(),
                Text(widget.text, style: MyTextStyles.body1)
              ],
            ),
    );
  }
}
