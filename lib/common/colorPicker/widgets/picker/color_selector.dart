// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:acc_design7/constants/strings.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import 'hex_textfield.dart';
import 'package:acc_design7/common/buttons/basic_button.dart';
import 'package:acc_design7/constants/styles.dart';
//import 'package:acc_design7/constants/styles.dart';

/// toolbar with :
/// - a color preview
/// - a hex color field
/// - an optional eyeDropper button
class ColorSelector extends StatefulWidget {
  Color? color;
  Color? oldColor;

  final bool withAlpha;

  final double thumbWidth;

  final FocusNode focus;

  final ValueChanged<Color> onColorChanged;

  final VoidCallback onClose;

  final VoidCallback? onEyePick;

  ColorSelector({
    required this.color,
    required this.onColorChanged,
    required this.onClose,
    required this.focus,
    this.onEyePick,
    this.withAlpha = false,
    this.thumbWidth = 80,
    Key? key,
  }) : super(key: key) {
    oldColor = color;
  }

  @override
  State<ColorSelector> createState() => ColorSelectorState();
}

class ColorSelectorState extends State<ColorSelector> {
  void repaint() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textKey = GlobalKey<HexColorFieldState>();

    return Column(children: [
      Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildColorThumb(),
            HexColorField(
              key: textKey,
              hexFocus: widget.focus,
              color: widget.color!,
              withAlpha: widget.withAlpha,
              onColorChanged: (value) {
                //widget.onColorChanged(value);
                setState(() {
                  widget.color = value;
                });
              },
            ),
          ],
        ),
      ),
      defaultDivider,
      Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            basicButton(
                name: MyStrings.apply,
                iconData: Icons.done,
                alignment: Alignment.center,
                onPressed: () {
                  setState(() {
                    widget.color = textKey.currentState!.getText();
                  });
                  widget.onColorChanged(widget.color!);
                  widget.onClose();
                }),
            SizedBox(
              width: 20,
            ),
            basicButton(
              name: MyStrings.cancel,
              iconData: Icons.close,
              alignment: Alignment.center,
              onPressed: widget.onClose,
            ),
            if (widget.onEyePick != null) // null if eyeDrop is disabled
              IconButton(
                  icon: const Icon(Icons.colorize),
                  onPressed: widget.onEyePick),
          ],
        ),
      ),
    ]);
  }

  Widget _buildColorThumb() => Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 10),
          height: 28,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.all(Radius.circular(180)),
            border: Border.all(
              width: 2,
              color: MyColors.border,
            ),
          ),
        ),
      );
}
