// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/opacity/opacity_slider.dart';
//import '../widgets/opacity/my_opacity_slider.dart';
import '../widgets/tabbar.dart';
import 'picker/color_selector.dart';
import 'picker/title_bar.dart';
//import 'picker_config.dart' if (dart.library.js) 'picker_config_web.dart';
import 'picker_config_web.dart';
import 'selectors/channels/hsl_selector.dart';
import 'selectors/grid_color_selector.dart';
import 'selectors/user_swatch_selector.dart';
import 'package:acc_design7/common/util/logger.dart';
//import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/constants/strings.dart';

void showColorPicker(
    {required BuildContext context,
    required Color selectedColor,
    required void Function(Color) onColorSelected}) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ColorPicker(
            selectedColor: selectedColor,
            onColorSelected: onColorSelected,
            config: const ColorPickerConfig(
              enableLibrary: false,
              enableEyePicker: false,
            ),
            onClose: Navigator.of(context).pop,
            onEyeDropper: () {},
          ),
        );
      });
}

const pickerWidth = 400.0;

const pickerHeight = 700.0;

const pickerSize = Size(pickerWidth, pickerHeight);

/// ColorPicker Widget
/// 2 or 3 tabs :
/// - material swatches
/// - HSL and RGB sliders
/// - custom swatches
///
/// Customisable with a [ColorPickerConfig]
class ColorPicker extends StatefulWidget {
  final Color selectedColor;

  /// custom swatches library
  final Set<Color> swatches;

  final bool darkMode;

  /// colorPicker configuration
  final ColorPickerConfig config;

  /// color selection callback
  final ValueChanged<Color> onColorSelected;

  /// open [EyeDrop] callback
  final VoidCallback? onEyeDropper;

  /// custom swatches update callabck
  final ValueChanged<Set<Color>>? onSwatchesUpdate;

  /// close colorPicker callback
  final VoidCallback onClose;

  final VoidCallback? onKeyboard;

  const ColorPicker({
    required this.onColorSelected,
    required this.selectedColor,
    required this.config,
    required this.onClose,
    this.onEyeDropper,
    this.onKeyboard,
    this.onSwatchesUpdate,
    this.swatches = const {},
    this.darkMode = false,
    Key? key,
  }) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late FocusNode hexFieldFocus;

  late Color selectedColor;
  double opacity = 1;

  final selectorKey = GlobalKey<ColorSelectorState>();

  @override
  void initState() {
    super.initState();
    hexFieldFocus = FocusNode();
    if (widget.onKeyboard != null) {
      hexFieldFocus.addListener(widget.onKeyboard!);
    }

    selectedColor = widget.selectedColor;
    opacity = selectedColor.opacity;
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onKeyboard != null) {
      hexFieldFocus.removeListener(widget.onKeyboard!);
    }
    hexFieldFocus.dispose();
  }

  @override
  void didUpdateWidget(covariant ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      selectedColor = widget.selectedColor;
      opacity = selectedColor.opacity;
    }
  }

  void onColorChanged(Color newColor) {
    //widget.onColorSelected(newColor);
    setState(() {
      newColor = newColor.withOpacity(opacity);
      selectedColor = newColor;
    });
  }

  void onOpacityChange(double value) {
    //widget.onColorSelected(widget.selectedColor.withOpacity(value));
    setState(() {
      logHolder.log("onOpacityChange($value)");
      opacity = value;
      selectedColor = selectedColor.withOpacity(value);
      logHolder.log("onOpacityChange($selectedColor)");
    });
    //selectorKey.currentState!.repaint();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('enableOpacity=${widget.config.enableOpacity}');
    return Theme(
      data: widget.darkMode ? darkTheme : lightTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Container(
            constraints: BoxConstraints.loose(pickerSize),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(defaultRadius),
              boxShadow: largeDarkShadowBox,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MainTitle(onClose: widget.onClose),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Tabs(
                      labels: [
                        MyStrings.sliderView,
                        MyStrings.matrixView,
                        if (widget.config.enableLibrary) 'Library'
                      ],
                      views: [
                        ChannelSliders(
                          selectedColor: selectedColor,
                          onChange: onColorChanged,
                        ),
                        GridColorSelector(
                          selectedColor: selectedColor,
                          onColorSelected: onColorChanged,
                          opacity: opacity,
                        ),
                        if (widget.config.enableLibrary)
                          SwatchLibrary(
                            colors: widget.swatches,
                            currentColor: selectedColor,
                            onSwatchesUpdate: widget.onSwatchesUpdate,
                            onColorSelected: onColorChanged,
                          ),
                      ],
                    ),
                  ),
                  //if (widget.config.enableOpacity)
                  RepaintBoundary(
                    child: OpacitySlider(
                      selectedColor: selectedColor,
                      opacity: opacity, // <-- should be member data
                      onChange: onOpacityChange,
                    ),
                  ),
                  defaultDivider,
                  ColorSelector(
                    key: selectorKey,
                    color: selectedColor,
                    //withAlpha: widget.config.enableOpacity,
                    withAlpha: true,
                    onColorChanged: widget.onColorSelected,
                    onClose: widget.onClose,
                    onEyePick: widget.config.enableEyePicker
                        ? widget.onEyeDropper
                        : null,
                    focus: hexFieldFocus,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
