// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/model/users.dart';
import 'package:acc_design7/common/colorPicker/my_color_indicator.dart';

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
        return MyColorIndicator(
          color: bg == Color(0x00000000) ? Color(0xFFFFFFFF) : bg,
          onSelect: () {
            onPressed.call(bg);
          },
          isSelected: value == bg,
          useUnselectedIcon: bg == Color(0x00000000),
          width: 25,
          height: 25,
          borderRadius: 0,
          hasBorder: true,
          borderColor:
              bg == Color(0x00000000) ? Colors.black : MyColors.primaryColor,
          elevation: 5,
        );
        // CircleAvatar(
        //     radius: value == bg ? 18 : 14,
        //     backgroundColor: value == bg
        //         ? bg == Color(0x00000000)
        //             ? Color(0xFFFFFFFF)
        //             : MyColors.primaryColor
        //         : MyColors.secondaryColor,
        //     child: IconButton(
        //       padding: EdgeInsets.zero,
        //       //constraints: BoxConstraints.tight(Size(20, 20)),
        //       constraints: BoxConstraints(),
        //       iconSize: value == bg ? 34 : 24,
        //       icon: bg == Color(0x00000000)
        //           ? Icon(Icons.clear)
        //           : Icon(Icons.circle),
        //       color: bg == Color(0x00000000) ? Color(0xFF101010) : bg,
        //       onPressed: () {
        //         onPressed.call(bg);
        //       },
        //     ));
      }).toList()
    ],
  );
}
