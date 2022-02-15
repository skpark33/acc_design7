// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../constants/styles.dart';

Widget basicButton(
    {required void Function() onPressed,
    required String name,
    required IconData iconData,
    AlignmentGeometry alignment = Alignment.bottomRight}) {
  return Container(
    height: MySizes.buttonHeight,
    alignment: alignment,
    child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          elevation: 4.0,
          side: BorderSide(width: 1.0, color: MyColors.buttonBorder),
          backgroundColor: MyColors.buttonBG,
          padding: EdgeInsets.fromLTRB(
            MySizes.buttonHeight / 4,
            MySizes.buttonHeight / 4,
            MySizes.buttonHeight / 3,
            MySizes.buttonHeight / 3,
          ),
        ),
        onPressed: onPressed,
        child: Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                size: MySizes.buttonHeight / 2, //MySizes.imageIcon,
                color: MyColors.buttonFG,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                name,
                style: MyTextStyles.buttonText,
              ),
            ])),
  );
}

IconButton logoIconButton(
    {required void Function() onPressed, double iconSize = MySizes.imageIcon}) {
  return IconButton(
      iconSize: iconSize,
      padding: EdgeInsets.zero,
      icon: const ImageIcon(
        AssetImage(
          "assets/logo.png",
        ),
        //size: IconSizes.imageIcon,
      ),
      onPressed: onPressed //context.read<MenuController>().controlMenu,
      );
}

Widget logoIcon({Color color = MyColors.mainColor, double size = 40}) {
  return ImageIcon(
    AssetImage(
      "assets/logo.png",
    ),
    color: color,
    size: size,
  );
}

Widget logoIcon2({Color color = MyColors.mainColor, double size = 40}) {
  return ImageIcon(
    AssetImage(
      "assets/publish.png",
    ),
    color: color,
    size: size,
  );
}
