// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/model/users.dart';

Widget colorRow(
    {required BuildContext context,
    required Color value,
    required List<Color> list,
    required void Function(Color) onPressed}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ...[
        for (int i = 0; i < currentUser.maxBgColor; i++)
          currentUser.bgColorList1[i],
      ].map((bg) {
        //TinyColor tinyColor = TinyColor(bg);
        return CircleAvatar(
            radius: value == bg ? 18 : 14,
            backgroundColor: value == bg
                ? bg == Color(0x00000000)
                    ? Color(0xFFFFFFFF)
                    : MyColors.primaryColor
                : MyColors.secondaryColor,
            //backgroundColor: MyColors.secondaryColor,
            child: IconButton(
              padding: EdgeInsets.zero,
              //constraints: BoxConstraints.tight(Size(20, 20)),
              constraints: BoxConstraints(),
              iconSize: value == bg ? 34 : 24,
              icon: bg == Color(0x00000000)
                  ? Icon(Icons.clear)
                  : Icon(Icons.circle),
              color: bg == Color(0x00000000) ? Color(0xFF101010) : bg,
              onPressed: () {
                onPressed.call(bg);
              },
            ));
      }).toList()
    ],
  );
}
