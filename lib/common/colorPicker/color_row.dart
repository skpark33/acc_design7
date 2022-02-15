// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/model/users.dart';
import 'package:acc_design7/common/colorPicker/widgets/color_picker.dart';

Widget colorRow(
    {required BuildContext context,
    required Color value,
    required List<Color> list,
    required void Function(Color) onPressed}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // IconButton(
      //   // 스포이드  spoid
      //   constraints: BoxConstraints(),
      //   iconSize: isSnippetStatus() ? 34 : 28,
      //   padding: EdgeInsets.only(right: 5),
      //   icon: Icon(Icons.colorize_rounded),
      //   color: isSnippetStatus()
      //       ? MyColors.primaryColor
      //       : MyColors.mediumIcon,
      //   onPressed: () {
      //     // setState(() {
      //     //   if (!isSnippetStatus()) {
      //     //     cursorManagerHolder!.setCursor(MyPageCursor.precise);
      //     //   } else {
      //     //     cursorManagerHolder!.setCursor(MyPageCursor.basic);
      //     //   }
      //     // });
      //   },
      // ),
      ...colorList(
          value: value,
          list: [
            for (int i = 0; i < currentUser.maxBgColor; i++)
              currentUser.bgColorList1[i],
          ],
          onPressed: onPressed),
      IconButton(
        // 빠레뜨
        constraints: BoxConstraints(),
        iconSize: 30,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.palette_outlined),
        color: MyColors.mediumIcon,
        onPressed: () {
          showColorPicker(
            context: context,
            selectedColor: value,
            onColorSelected: (value) {
              for (int i = currentUser.maxBgColor - 2; i > 1; i--) {
                currentUser.bgColorList1[i] = currentUser.bgColorList1[i - 1];
              }
              currentUser.bgColorList1[1] = value;
              onPressed.call(value);
            },
          );
        },
      ),
    ],
  );
}

List<CircleAvatar> colorList(
    {required Color value,
    required List<Color> list,
    required void Function(Color) onPressed}) {
  return list.map((bg) {
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
          iconSize: value == bg ? 35 : 26,
          icon:
              bg == Color(0x00000000) ? Icon(Icons.clear) : Icon(Icons.circle),
          color: bg == Color(0x00000000) ? Color(0xFF101010) : bg,
          onPressed: () {
            onPressed.call(bg);
          },
        ));
  }).toList();
}
