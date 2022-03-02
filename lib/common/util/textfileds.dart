// ignore_for_file: prefer_const_constructors

import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/common/util/logger.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart';

Widget myTextField(String value,
    {required TextEditingController controller,
    String labelText = '',
    String hintText = '',
    int limit = 128,
    int maxValue = 360,
    int minValue = 0,
    TextInputType keyboardType = TextInputType.none,
    TextStyle? style,
    bool hasDeleteButton = true,
    bool hasCounterButton = false,
    TextAlign textAlign = TextAlign.end,
    bool enabled = true,
    bool hasBorder = false,
    TextAlignVertical textAlignVertical = TextAlignVertical.top,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
    void Function(String)? onSubmitted}) {
  controller.text = value;
  return TextField(
    enabled: enabled,
    keyboardType: keyboardType,
    controller: controller,
    cursorColor: MyColors.mainColor,
    textAlignVertical: textAlignVertical,
    textAlign: textAlign,
    decoration: InputDecoration(
      border: hasBorder ? OutlineInputBorder(gapPadding: 0) : InputBorder.none,
      enabledBorder: hasBorder
          ? OutlineInputBorder(
              borderSide: BorderSide(color: MyColors.primaryColor, width: 2.0),
            )
          : null,
      focusedBorder: hasBorder
          ? OutlineInputBorder(
              borderSide: BorderSide(color: MyColors.mainColor, width: 2.0),
            )
          : null,
      //hintText: labelText,
      labelText: labelText,
      prefixIconConstraints: BoxConstraints.tight(Size(24, 24)),
      prefixIcon: hasCounterButton
          ? IconButton(
              //constraints: BoxConstraints.tight(Size(16, 16)),
              padding: EdgeInsets.only(left: 5),
              color: MyColors.mainColor,
              iconSize: MySizes.smallIcon,
              icon: Icon(Icons.add),
              onPressed: () {
                int newVal = int.parse(controller.text);
                newVal++;
                if (newVal > maxValue) {
                  newVal = minValue;
                }
                controller.text = newVal.toString();
                if (onEditingComplete != null) {
                  onEditingComplete.call();
                }
              },
            )
          : null,

      suffixIconConstraints: BoxConstraints.tight(Size(24, 24)),
      suffixIcon: hasDeleteButton
          ? hasCounterButton
              ? IconButton(
                  //constraints: BoxConstraints.tight(Size(16, 16)),
                  padding: EdgeInsets.only(right: 5),
                  color: MyColors.mainColor,
                  iconSize: MySizes.smallIcon,
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    int newVal = int.parse(controller.text);
                    newVal--;
                    if (newVal < minValue) {
                      newVal = maxValue;
                    }
                    controller.text = newVal.toString();
                    if (onEditingComplete != null) {
                      onEditingComplete.call();
                    }
                  },
                )
              : IconButton(
                  color: MyColors.mainColor,
                  iconSize: MySizes.smallIcon,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                  },
                )
          : null,
    ),
    inputFormatters: [
      LengthLimitingTextInputFormatter(limit),
    ],
    onTap: () {
      logHolder.log('onTapped');
    },
    onChanged: onChanged,
    onEditingComplete: onEditingComplete,
    onSubmitted: onSubmitted,
    //style: style,
  );
}

Widget myNumberTextField({
  required double defaultValue,
  required TextEditingController controller,
  required void Function()? onEditingComplete,
  width = 75,
  hasDeleteButton = false,
  hasCounterButton = false,
  hasBorder = true,
  enabled = true,
  textAlign = TextAlign.end,
  maxValue = 359,
  minValue = 0,
  limit = 5,
  TextAlignVertical textAlignVertical = TextAlignVertical.top,
}) {
  //logHolder.log('_myNumberTextField($defaultValue)');
  int digit = defaultValue.floor();
  String val = digit.toString();
  return Container(
    padding: EdgeInsets.zero,
    width: width,
    height: 30,
    child: myTextField(val,
        maxValue: maxValue,
        minValue: minValue,
        enabled: enabled,
        hasBorder: hasBorder,
        keyboardType: TextInputType.number,
        textAlign: textAlign,
        limit: limit,
        controller: controller,
        style: MyTextStyles.body2,
        hasDeleteButton: hasDeleteButton,
        hasCounterButton: hasCounterButton,
        onEditingComplete: onEditingComplete),
  );
}

Widget myNumberTextField2({
  required double defaultValue,
  required TextEditingController controller,
  required void Function()? onEditingComplete,
  width = 75,
  height = 90,
  hasBorder = true,
  enabled = true,
  textAlign = TextAlign.center,
  maxValue = 359,
  minValue = 0,
  limit = 5,
  TextAlignVertical textAlignVertical = TextAlignVertical.top,
}) {
  int digit = defaultValue.floor();
  controller.text = digit.toString();
  return Container(
      padding: EdgeInsets.zero,
      width: width,
      height: height,
      //color: Colors.blue.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height / 3,
            child: IconButton(
              //constraints: BoxConstraints.tight(Size(width, 24)),
              padding: EdgeInsets.zero,
              color: MyColors.mainColor,
              iconSize: 24,
              icon: Icon(Icons.arrow_circle_up_outlined),
              onPressed: () {
                int newVal = int.parse(controller.text);
                newVal++;
                if (newVal > maxValue) {
                  newVal = minValue;
                }
                controller.text = newVal.toString();
                if (onEditingComplete != null) {
                  onEditingComplete.call();
                }
              },
            ),
          ),
          SizedBox(
            width: width,
            height: height / 3,
            child: TextField(
              enabled: enabled,
              keyboardType: TextInputType.number,
              controller: controller,
              cursorColor: MyColors.mainColor,
              textAlignVertical: textAlignVertical,
              textAlign: textAlign,
              decoration: InputDecoration(
                border: hasBorder ? OutlineInputBorder(gapPadding: 0) : InputBorder.none,
                enabledBorder: hasBorder
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: MyColors.primaryColor, width: 2.0),
                      )
                    : null,
                focusedBorder: hasBorder
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: MyColors.mainColor, width: 2.0),
                      )
                    : null,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(limit),
              ],
              onEditingComplete: onEditingComplete,
              //style: style,
            ),
          ),
          SizedBox(
            width: width,
            height: height / 3,
            child: IconButton(
              //constraints: BoxConstraints.tight(Size(width, 24)),
              padding: EdgeInsets.zero,
              color: MyColors.mainColor,
              iconSize: 24,
              icon: Icon(Icons.arrow_circle_down_outlined),
              onPressed: () {
                int newVal = int.parse(controller.text);
                newVal--;
                if (newVal < minValue) {
                  newVal = maxValue;
                }
                controller.text = newVal.toString();
                if (onEditingComplete != null) {
                  onEditingComplete.call();
                }
              },
            ),
          ),
        ],
      ));
}
