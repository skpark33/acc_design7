import 'package:flutter/material.dart';

//import '../../../theme.dart';
import 'package:acc_design7/constants/strings.dart';
import '../../tabbar.dart';
import 'channel_slider.dart';
import 'hsl_sliders.dart';

typedef ChannelValueGetter = double Function(Color value);

typedef ValueLabelGetter = String Function(Color value);

class ChannelSliders extends StatefulWidget {
  final Color selectedColor;

  final ValueChanged<Color> onChange;

  const ChannelSliders(
      {required this.selectedColor, required this.onChange, Key? key})
      : super(key: key);

  @override
  _ChannelSlidersState createState() => _ChannelSlidersState();
}

class _ChannelSlidersState extends State<ChannelSliders> {
  bool hslMode = true;

  Color get color => widget.selectedColor;

  @override
  Widget build(BuildContext context) => Tabs(
        labels: const [
          'RGB',
          'HSL',
        ],
        views: [
          _buildRGBSliders(),
          HSLSliders(color: color, onColorChanged: widget.onChange),
        ],
      );

  Column _buildRGBSliders() => Column(
        children: [
          ChannelSlider(
              label: MyStrings.red,
              selectedColor: color,
              colors: [color.withRed(0), color.withRed(255)],
              channelValueGetter: (color) => color.red / 255,
              labelGetter: (color) => '${color.red}',
              labelHexGetter: (color) => color.red.toRadixString(16),
              onChange: (value) {
                widget.onChange(
                  color.withRed((value * 255).toInt()),
                );
              }),
          ChannelSlider(
              label: MyStrings.green,
              selectedColor: color,
              colors: [color.withGreen(0), color.withGreen(255)],
              channelValueGetter: (color) => color.green / 255,
              labelGetter: (color) => '${color.green}',
              labelHexGetter: (color) => color.green.toRadixString(16),
              onChange: (value) {
                widget.onChange(
                  color.withGreen((value * 255).toInt()),
                );
              }),
          ChannelSlider(
              label: MyStrings.blue,
              selectedColor: color,
              colors: [color.withBlue(0), color.withBlue(255)],
              channelValueGetter: (color) => color.blue / 255,
              labelGetter: (color) => '${color.blue}',
              labelHexGetter: (color) => color.blue.toRadixString(16),
              onChange: (value) {
                widget.onChange(
                  color.withBlue((value * 255).toInt()),
                );
              }),
        ],
      );
}
