import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/common/colorPicker/my_color_indicator.dart';

const NeumorphicBoxShape defaultBoxShape = NeumorphicBoxShape.rect();

Widget myNeumorphicButton({
  required Widget child,
  void Function()? onPressed,
  double borderWidth = 0,
  Color borderColor = Colors.transparent,
  NeumorphicBoxShape boxShape = defaultBoxShape,
  NeumorphicShape shape = NeumorphicShape.flat,
  double intensity = 0,
  LightSource lightSource = LightSource.topLeft,
  double depth = 0,
  Color bgColor = Colors.transparent,
}) {
  return NeumorphicButton(
      padding: EdgeInsets.zero,
      duration: const Duration(milliseconds: 300),
      onPressed: onPressed,
      style: NeumorphicStyle(
        boxShape: boxShape,
        border: borderWidth == 0
            ? const NeumorphicBorder.none()
            : NeumorphicBorder(isEnabled: true, width: borderWidth, color: borderColor),
        shape: shape,
        intensity: intensity,
        color: bgColor,
        /*
        shadowLightColor: Colors.red,
        shadowDarkColor: Colors.blue,
        shadowLightColorEmboss: Colors.red,
        shadowDarkColorEmboss: Colors.blue,
         */
        //surfaceIntensity: surfaceIntensity,
        depth: depth,
        lightSource: lightSource,
      ),
      child: child);
}

Widget _doubleSlider(
    {required String title,
    required double value,
    required double min,
    required double max,
    String? valueString,
    required void Function(double) onChanged}) {
  return Row(
    children: <Widget>[
      Text(
        title,
        style: MyTextStyles.subtitle2,
      ),
      Expanded(
        child: Slider(
          min: min,
          max: max,
          value: value,
          onChanged: (val) {
            onChanged.call(val);
            // setState(() {
            //   borderWidth = value;
            // });
          },
          activeColor: MyColors.mainColor,
          thumbColor: MyColors.accBg,
          inactiveColor: MyColors.primaryColor,
        ),
      ),
      SizedBox(
        width: 60,
        child: Text(valueString ?? value.floor().toString()),
      ),
    ],
  );
}

Widget depthSelector({required double depth, required void Function(double) onChanged}) {
  return _doubleSlider(
    title: MyStrings.depth,
    value: depth,
    onChanged: onChanged,
    min: Neumorphic.MIN_DEPTH,
    max: Neumorphic.MAX_DEPTH,
  );
}

Widget intensitySelector({required double intensity, required void Function(double) onChanged}) {
  return _doubleSlider(
    title: MyStrings.intensity,
    value: intensity,
    onChanged: onChanged,
    min: Neumorphic.MIN_INTENSITY,
    max: Neumorphic.MAX_INTENSITY,
    valueString: ((intensity * 100).floor() / 100).toString(),
  );
}

Widget borderWidthSelector(
    {required double borderWidth, required void Function(double) onChanged}) {
  return _doubleSlider(
    title: MyStrings.thickness,
    value: borderWidth,
    onChanged: onChanged,
    min: 0,
    max: 10,
  );
}

Widget lightSourceDxWidgets(
    {required double lightSourceDx, required void Function(double) onChanged}) {
  return _doubleSlider(
    title: MyStrings.lightSourceDx,
    value: lightSourceDx,
    onChanged: onChanged,
    min: -1,
    max: 1,
    valueString: ((lightSourceDx * 100).floor() / 100).toString(),
  );
}

Widget lightSourceDyWidgets(
    {required double lightSourceDy, required void Function(double) onChanged}) {
  return _doubleSlider(
    title: MyStrings.lightSourceDy,
    value: lightSourceDy,
    onChanged: onChanged,
    min: -1,
    max: 1,
    valueString: ((lightSourceDy * 100).floor() / 100).toString(),
  );
}

Widget borderColorPicker(Color borderColor, void Function() onSelect) {
  return Row(
    children: <Widget>[
      Text(
        MyStrings.color,
        style: MyTextStyles.subtitle2,
      ),
      const SizedBox(
        width: 25,
      ),
      colorPickerIcon(borderColor, onSelect),
    ],
  );
}

MyColorIndicator colorPickerIcon(Color color, void Function() onSelect) {
  return MyColorIndicator(
    color: color == Colors.transparent ? const Color(0xFFFFFFFF) : color,
    onSelect: onSelect,
    isSelected: true,
    width: 30,
    height: 30,
    borderRadius: 0,
    hasBorder: true,
    borderColor: color == Colors.transparent ? Colors.black : MyColors.primaryColor,
    elevation: 5,
    selectedIcon: color == Colors.transparent ? Icons.cancel : Icons.blur_on_rounded,
  );
}
