// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import '../../constants/styles.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MyColorPicker {
  Color pickerColor = MyColors.primaryColor;
  Color currentColor = MyColors.primaryColor;

  void Function()? onSelected;
  void Function(Color c)? onColorChanged;

  MyColorPicker(
      {required this.currentColor,
      required this.onColorChanged,
      required this.onSelected});

  dynamic runDialog(BuildContext context) {
// raise the [showDialog] widget
    return showDialog(
        context: context,
        builder: (con) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: onColorChanged!,
              ),
              // Use Material color picker:
              //
              // child: MaterialPicker(
              //   pickerColor: pickerColor,
              //   onColorChanged: changeColor,
              //   showLabel: true, // only on portrait mode
              // ),
              //
              // Use Block color picker:
              //
              // child: BlockPicker(
              //   pickerColor: currentColor,
              //   onColorChanged: changeColor,
              // ),
              //
              // child: MultipleChoiceBlockPicker(
              //   pickerColors: currentColors,
              //   onColorsChanged: changeColors,
              // ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Got it'),
                onPressed: () {
                  //setState(() => currentColor = pickerColor);
                  onSelected!();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
