// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/acc/acc_property.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/studio/properties/property_selector.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/model/users.dart';
import 'package:acc_design7/common/util/textfileds.dart';
import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/common/undo/undo.dart';
import 'package:acc_design7/common/colorPicker/color_row.dart';
import 'package:acc_design7/studio/properties/properties_frame.dart';
//import 'package:acc_design7/common/buttons/wave_slider.dart';
import 'package:acc_design7/common/buttons/dial_button.dart';
import 'package:acc_design7/common/slider/opacity/opacity_slider.dart';
import 'package:acc_design7/common/colorPicker/my_color_indicator.dart';
import 'package:acc_design7/common/neumorphic/neumorphic.dart';

class ExapandableModel {
  ExapandableModel({
    required this.title,
    required this.height,
    required this.width,
  });
  bool isSelected = false;
  String title;
  Widget? child;
  double height;
  double width;

  void toggleSelected() {
    isSelected = !isSelected;
  }

  Widget expandArea({
    double left = 25,
    double top = 6,
    double right = 0,
    double bottom = 0,
    required Widget child,
    required void Function() setStateFunction,
    double titleSize = 120,
    Widget? titleLineWidget,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTapDown: (details) {
                  setStateFunction.call();
                },
                child: SizedBox(
                  width: titleSize,
                  child: Text(
                    title,
                    style: MyTextStyles.subtitle2,
                  ),
                ),
              ),
              if (titleLineWidget != null) titleLineWidget,
              IconButton(
                onPressed: setStateFunction,
                icon: Icon(isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ),
            ],
          ),
          isSelected
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: height,
                  //alignment: Alignment.center,
                  child: child)
              : Container(),
        ],
      ),
    );
  }
}

class WidgetProperty extends PropertySelector {
  WidgetProperty(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );
  @override
  State<WidgetProperty> createState() => WidgetPropertyState();

  int _userColorIndex = 3;

  void setUserColorList(Color bg) {
    currentUser.bgColorList1[_userColorIndex] = bg;
    _userColorIndex++;
    if (_userColorIndex >= currentUser.maxBgColor) {
      _userColorIndex = 3;
    }
  }
}

class WidgetPropertyState extends State<WidgetProperty> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  bool _borderColorVisible = false;

  late AnimationController _aniIconController;

  TextEditingController descCon = TextEditingController();
  TextEditingController widthCon = TextEditingController();
  TextEditingController heightCon = TextEditingController();
  TextEditingController colorCon = TextEditingController();
  TextEditingController xCon = TextEditingController();
  TextEditingController yCon = TextEditingController();

  bool isSizeChangable = true;
  final List<ExapandableModel> _modelList = [];

  ExapandableModel animeModel = ExapandableModel(
    title: MyStrings.anime,
    height: 260,
    width: 240,
  );

  ExapandableModel bgColorModel = ExapandableModel(
    title: '${MyStrings.bgColor}/${MyStrings.glass}',
    height: 410,
    width: 240,
  );
  ExapandableModel opacityModel = ExapandableModel(
    title: MyStrings.opacity,
    height: 64,
    width: 240,
  );
  ExapandableModel sizePosModel = ExapandableModel(
    title: MyStrings.widgetSize,
    height: 100,
    width: 240,
  );
  ExapandableModel cornerModel = ExapandableModel(
    title: MyStrings.radius,
    height: 260,
    width: 240,
  );
  ExapandableModel rotateModel = ExapandableModel(
    title: MyStrings.rotate,
    height: 270,
    width: 240,
  );
  ExapandableModel borderModel = ExapandableModel(
    title: MyStrings.border,
    height: 290,
    width: 240,
  );

  void unexpendAll(String expandModelName) {
    for (ExapandableModel model in _modelList) {
      if (expandModelName != model.title) {
        model.isSelected = false;
      }
    }
  }

  @override
  void initState() {
    _aniIconController = AnimationController(
        animationBehavior: AnimationBehavior.preserve,
        vsync: this,
        duration: Duration(milliseconds: 1000));

    _modelList.add(animeModel);
    _modelList.add(bgColorModel);
    _modelList.add(opacityModel);
    _modelList.add(sizePosModel);
    _modelList.add(cornerModel);
    _modelList.add(rotateModel);
    _modelList.add(borderModel);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: Consumer<ACCManager>(builder: (context, accManager, child) {
        //logHolder.log('Consumer of real accManager');

        ACC? acc = accManager.getCurrentACC();
        if (acc == null) {
          return Container();
        }

        return ListView(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          controller: _scrollController,
          children: [
            _titleRow(25, 15, 12, 10),
            _divider(),
            _primaryRow(acc, 25, 5, 12, 5),
            _divider(),
            _sourceRatioRow(acc, 25, 5, 12, 5),
            _divider(),
            sizePosModel.expandArea(
                child: _sizePosRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(sizePosModel.title);
                    sizePosModel.toggleSelected();
                  });
                },
                titleSize: 100,
                titleLineWidget: Text(
                  '${acc.containerOffset.value.dx.roundToDouble()},${acc.containerOffset.value.dy.roundToDouble()},${acc.containerSize.value.width.roundToDouble()} x ${acc.containerSize.value.height.roundToDouble()}',
                  style: MyTextStyles.subtitle1,
                )),
            _divider(),
            bgColorModel.expandArea(
                child: _bgColorRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(bgColorModel.title);
                    bgColorModel.toggleSelected();
                  });
                },
                titleSize: 132,
                titleLineWidget: acc.bgColor.value != Color(0x00000000)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          glassIcon(acc, acc.bgColor.value),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      )
                    : null),
            _divider(),
            opacityModel.expandArea(
                child: _opacityRow(context, acc),
                titleLineWidget: Row(children: [
                  Text(
                    '${((1 - acc.opacity.value) * 100).round()} %',
                    style: MyTextStyles.subtitle1,
                  ),
                ]),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(opacityModel.title);
                    opacityModel.toggleSelected();
                  });
                }),
            _divider(),
            rotateModel.expandArea(
                child: _rotateRow(context, acc),
                titleLineWidget: Text(
                  '${acc.rotate.value} °',
                  style: MyTextStyles.subtitle1,
                ),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(rotateModel.title);
                    rotateModel.toggleSelected();
                  });
                }),
            _divider(),
            animeModel.expandArea(
                child: _animeRow(context, acc),
                titleLineWidget: acc.animeType.value != AnimeType.none
                    ? Row(children: [
                        Text(_getAnimeName(acc.animeType.value)),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: AnimatedIcon(
                              icon: _getAnimeIcon(acc.animeType.value),
                              progress: _aniIconController,
                              size: 30,
                              color: MyColors.primaryColor,
                            ),
                            //Icon(),
                            onPressed: () {
                              if (_aniIconController.isAnimating) {
                                _aniIconController.stop();
                              } else {
                                _aniIconController.repeat();
                                // _aniIconController.forward().then(
                                //   (value) async {
                                //     await Future.delayed(Duration(seconds: 1));
                                //     _aniIconController.reverse();
                                //   },
                                // );
                              }
                            }),
                      ])
                    : null,
                setStateFunction: () {
                  setState(() {
                    unexpendAll(animeModel.title);
                    animeModel.toggleSelected();
                  });
                }),
            _divider(),
            borderModel.expandArea(
                child: _borderRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(borderModel.title);
                    borderModel.toggleSelected();
                  });
                }),
            _divider(),
            cornerModel.expandArea(
                child: _cornerRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(cornerModel.title);
                    cornerModel.toggleSelected();
                  });
                }),
          ],
        );
      }),
    );
  }

  Divider _divider() {
    return Divider(
      height: 5,
      thickness: 1,
      color: MyColors.divide,
      indent: 14,
      endIndent: 14,
    );
  }

  Divider _smallDivider() {
    return Divider(
      height: 4,
      thickness: 1,
      color: MyColors.divide,
      indent: 24,
      endIndent: 24,
    );
  }

  Widget _titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.widgetPropTitle,
        style: MyTextStyles.body1,
      ),
    );
  }

  Widget _primaryRow(ACC acc, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: [
          Text(
            MyStrings.primary,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 2, 8, 2),
            iconSize: 32.0,
            icon: Icon(
              acc.primary.value != true ? Icons.star_outline_outlined : Icons.star_outlined,
              color: acc.primary.value != true ? Colors.grey : MyColors.mainColor,
            ),
            onPressed: () {
              accManagerHolder!.setPrimary();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget _sourceRatioRow(ACC acc, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: [
          Text(
            acc.sourceRatio.value == true ? MyStrings.sourceRatio : MyStrings.sourceRatioToggle,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 2, 8, 2),
            iconSize: 32.0,
            icon: Icon(
              acc.sourceRatio.value == true
                  ? Icons.image_aspect_ratio_outlined
                  : Icons.aspect_ratio_outlined,
              color: acc.sourceRatio.value == true ? Colors.grey : MyColors.mainColor,
            ),
            onPressed: () {
              acc.sourceRatio.set(!acc.sourceRatio.value);
              //acc.setState();
              acc.invalidateContents();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget _locationRow(ACC acc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 30,
          child: Text(
            'X',
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // x 좌표
          defaultValue: acc.containerOffset.value.dx.roundToDouble(),
          controller: xCon,
          onEditingComplete: () {
            logHolder.log("textval = ${xCon.text}");
            setState(() {
              acc.containerOffset
                  .set(Offset(double.parse(xCon.text), acc.containerOffset.value.dy));
              acc.setState();
            });
          },
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 30,
          child: Text(
            'Y',
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // y 좌표
          defaultValue: acc.containerOffset.value.dy.roundToDouble(),
          controller: yCon,
          onEditingComplete: () {
            logHolder.log("textval = ${yCon.text}");
            setState(() {
              acc.containerOffset
                  .set(Offset(acc.containerOffset.value.dx, double.parse(yCon.text)));
              acc.setState();
            });
          },
        ),
        writeButton(
          // x,y 좌표를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.containerOffset.set(Offset(double.parse(xCon.text), double.parse(yCon.text)));
            mychangeStack.endTrans();
            acc.setState();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _sizeRow(ACC acc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 30,
          child: Text(
            MyStrings.width,
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // 너비
          defaultValue: acc.containerSize.value.width.roundToDouble(),
          controller: widthCon,
          onEditingComplete: () {
            logHolder.log("textval = ${widthCon.text}");
            setState(() {
              acc.containerSize
                  .set(Size(double.parse(widthCon.text), acc.containerSize.value.height));
              acc.setState();
            });
          },
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 30,
          child: Text(
            MyStrings.height,
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // 높이
          defaultValue: acc.containerSize.value.height.roundToDouble(),
          controller: heightCon,
          onEditingComplete: () {
            setState(() {
              acc.containerSize
                  .set(Size(acc.containerSize.value.width, double.parse(heightCon.text)));
              acc.setState();
            });
            logHolder.log("textval = ${heightCon.text}");
          },
        ),
        writeButton(
          // width,height를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.containerSize.set(Size(double.parse(widthCon.text), double.parse(heightCon.text)));
            mychangeStack.endTrans();
            acc.setState();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _opacityRow(BuildContext context, ACC acc) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          OpacitySlider(
            selectedColor: MyColors.secondaryColor,
            opacity: acc.opacity.value,
            onChange: (value) {
              //logHolder.log('onValueChanged: $value');
              acc.opacity.set(value);
              acc.setState();
              setState(() {});
            },
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget _rotateRow(BuildContext context, ACC acc) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          alignment: Alignment.center,
          child: DialView(
            angle: acc.rotate.value,
            size: Size(190, 190),
            onValueChanged: (value) {
              //logHolder.log('onValueChanged: $value');
              acc.rotate.set(value);
              acc.setState();
              setState(() {});
            },
          )),
      Row(
        children: [
          Text(
            MyStrings.contentsRotate,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 2, 8, 2),
            iconSize: 32.0,
            icon: Icon(
              acc.contentRotate.value == true
                  ? Icons.task_alt_outlined
                  : Icons.radio_button_unchecked_outlined,
              color: acc.contentRotate.value == true ? MyColors.mainColor : Colors.grey,
            ),
            onPressed: () {
              acc.contentRotate.set(!acc.contentRotate.value);
              acc.setState();
              //acc.invalidateContents();
              setState(() {});
            },
          )
        ],
      ),
    ]);
  }

  void _editComplete(ACC acc) {
    if (colorCon.text.isEmpty) {
      return;
    }
    if (colorCon.text[0] == '#') {
      if (colorCon.text.length == 9) {
        acc.setBgColor(hexToColor(colorCon.text));
      } else if (colorCon.text.length == 7) {
        String newVal = '#ff' + colorCon.text.substring(1);
        acc.setBgColor(hexToColor(newVal));
      }
    } else {
      if (colorCon.text.length == 8) {
        String newVal = '#' + colorCon.text;
        acc.setBgColor(hexToColor(newVal));
      } else if (colorCon.text.length == 6) {
        String newVal = '#ff' + colorCon.text;
        acc.setBgColor(hexToColor(newVal));
      }
    }
    widget.setUserColorList(acc.bgColor.value);
  }

  Widget _bgColorRow(BuildContext context, ACC acc) {
    return Container(
      padding: EdgeInsets.only(right: 20),
      alignment: Alignment.topCenter,
      child: Column(
          // 배경 색상
          children: [
            SizedBox(
              height: 10,
            ),
            colorRow(
              context: context,
              value: acc.bgColor.value,
              list: [
                for (int i = 0; i < currentUser.maxBgColor; i++) currentUser.bgColorList1[i],
              ],
              onPressed: (bg) {
                acc.setBgColor(bg);
                //pageManagerHolder!.setState();
              },
            ),
            SizedBox(
              height: 10,
            ),
            ColorPicker(
              subheading: _smallDivider(),
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: false,
                ColorPickerType.custom: false,
                ColorPickerType.wheel: true
              },
              pickerTypeLabels: <ColorPickerType, String>{
                ColorPickerType.primary: MyStrings.basicColor,
                ColorPickerType.accent: MyStrings.accentColor,
                ColorPickerType.wheel: MyStrings.customColor
              },
              color: acc.bgColor.value,
              onColorChanged: (bg) {},
              onColorChangeEnd: (bg) {
                acc.setBgColor(bg);
                widget.setUserColorList(bg);
              },
              width: 22,
              height: 22,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              showColorName: false,
              showRecentColors: false,
              //maxRecentColors: currentUser.maxBgColor,
              //recentColors: currentUser.bgColorList1,
              //onRecentColorsChanged: (list) {
              //  currentUser.bgColorList1 = list;
              //},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MyStrings.bgColorCodeInput,
                  style: MyTextStyles.subtitle2,
                ),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: myTextField(
                    '#${acc.bgColor.value.toString().substring(10, 16)}',
                    limit: 9,
                    controller: colorCon,
                    style: MyTextStyles.body2,
                    enabled: true,
                    hasBorder: true,
                    hasDeleteButton: false,
                    onEditingComplete: () {
                      _editComplete(acc);
                    },
                  ),
                ),
                writeButton(
                  // color를  Write 하는 icon
                  onPressed: () {
                    _editComplete(acc);
                  },
                ),
              ],
            ),
            Row(children: [
              Text(
                MyStrings.glass,
                style: MyTextStyles.subtitle2,
              ),
              SizedBox(width: 32),
              glassIcon(acc, acc.bgColor.value),
              // CircleAvatar(
              //   radius: 18,
              //   foregroundColor: acc.bgColor.value,
              //   backgroundColor: MyColors.secondaryColor,
              //   child: glassIcon(
              //       0, acc, acc.bgColor.value), //Icon(Icons.circle, size: 32),
              // ),
            ]),
          ]),
    );
  }

  Widget _sizePosRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(children: [
          _locationRow(acc),
          _sizeRow(acc),
        ]));
  }

  Widget _borderRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(children: [
          borderColorPicker(acc.borderColor.value, () {
            setState(() {
              _borderColorVisible = !_borderColorVisible;
            });
          }),
          _borderColorVisible
              ? ColorPicker(
                  subheading: _smallDivider(),
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: false
                  },
                  pickerTypeLabels: <ColorPickerType, String>{
                    ColorPickerType.primary: MyStrings.basicColor,
                    ColorPickerType.accent: MyStrings.accentColor,
                    //ColorPickerType.wheel: MyStrings.customColor
                  },
                  color: acc.borderColor.value,
                  onColorChanged: (bg) {},
                  onColorChangeEnd: (bg) {
                    acc.borderColor.set(bg);
                    acc.setState();
                    setState(() {
                      if (acc.borderWidth.value == 0) {
                        acc.borderWidth.set(1);
                      }
                      _borderColorVisible = false;
                    });
                  },
                  width: 22,
                  height: 22,
                  padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
                  showColorName: false,
                  showRecentColors: false,
                  //maxRecentColors: currentUser.maxBgColor,
                  //recentColors: currentUser.bgColorList1,
                  //onRecentColorsChanged: (list) {
                  //  currentUser.bgColorList1 = list;
                  //},
                )
              : Column(children: [
                  depthSelector(
                      depth: acc.depth.value,
                      onChanged: (value) {
                        setState(() {
                          autoChangeBgColor(acc);
                          acc.depth.set(value);
                          acc.setState();
                        });
                      }),
                  intensitySelector(
                      intensity: acc.intensity.value,
                      onChanged: (value) {
                        setState(() {
                          autoChangeBgColor(acc);
                          acc.intensity.set(value);
                          acc.setState();
                        });
                      }),
                  borderWidthSelector(
                      borderWidth: acc.borderWidth.value,
                      onChanged: (value) {
                        setState(() {
                          autoChangeBgColor(acc);
                          acc.borderWidth.set(value);
                          acc.setState();
                        });
                      }),
                  lightSourceDxWidgets(
                      lightSourceDx: acc.lightSource.value.dx,
                      onChanged: (value) {
                        setState(() {
                          autoChangeBgColor(acc);
                          acc.lightSource.set(acc.lightSource.value.copyWith(dx: value));
                          acc.setState();
                        });
                      }),
                  lightSourceDyWidgets(
                      lightSourceDy: acc.lightSource.value.dy,
                      onChanged: (value) {
                        setState(() {
                          autoChangeBgColor(acc);
                          acc.lightSource.set(acc.lightSource.value.copyWith(dy: value));
                          acc.setState();
                        });
                      }),
                ]),
          // ]),
        ]));
  }

  void autoChangeBgColor(ACC acc) {
    // 투명하거나,  유리질이거나, bg에 opacity 같은 것들이 잡혀있으면,
    // 보더 값이 먹지 않으므로, 자동으로 해제해 준다.
    if (acc.bgColor.value == Colors.transparent) {
      acc.bgColor.set(MyColors.bgColor);
    } else {
      // if (acc.bgColor.value.opacity > 0) {
      //   acc.bgColor.value.withOpacity(0);
      // }
    }
    acc.glass.set(false);
  }

  Widget _cornerRow(BuildContext context, ACC acc) {
    return Container(alignment: Alignment.topCenter, child: null);
  }

  Widget _animeRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    acc.animeType.set(AnimeType.none);
                    // acc.pauseAllExceptCurrent().then((_) {
                    acc.invalidateContents();
                    setState(() {});
                    //});
                  },
                  icon: Icon(Icons.not_interested),
                  iconSize: acc.animeType.value == AnimeType.none ? 36 : 24,
                  color: acc.animeType.value == AnimeType.none
                      ? MyColors.primaryColor
                      : MyColors.secondaryColor,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    //acc.pauseAllExceptCurrent().then((_) {
                    acc.animeType.set(AnimeType.carousel);
                    acc.invalidateContents();
                    setState(() {});
                    //});
                  },
                  iconSize: acc.animeType.value == AnimeType.carousel ? 36 : 24,
                  icon: Icon(Icons.view_carousel_outlined),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    //acc.pauseAllExceptCurrent().then((_) {
                    acc.animeType.set(AnimeType.flip);
                    acc.invalidateContents();
                    setState(() {});
                    //});
                  },
                  iconSize: acc.animeType.value == AnimeType.flip ? 36 : 24,
                  icon: Icon(Icons.flip_outlined),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
              ],
            )
          ],
        ));
  }

  AnimatedIconData _getAnimeIcon(AnimeType type) {
    switch (type) {
      case AnimeType.carousel:
        return AnimatedIcons.list_view;
      case AnimeType.flip:
        return AnimatedIcons.add_event;
      default:
        return AnimatedIcons.close_menu;
    }
  }

  String _getAnimeName(AnimeType type) {
    switch (type) {
      case AnimeType.carousel:
        return MyStrings.animeCarousel;
      case AnimeType.flip:
        return MyStrings.animeFlip;
      default:
        return "";
    }
  }

  MyColorIndicator glassIcon(ACC acc, Color bg) {
    return MyColorIndicator(
      color: bg == Color(0x00000000) ? Color(0xFFFFFFFF) : bg,
      onSelect: () {
        acc.glass.set(!acc.glass.value);
        if (acc.glass.value == true) {
          if (acc.bgColor.value == Colors.transparent) {
            // 바탕색이 투명일때, 유리질을 선택하면, 바탕색을 힌색으로 잡아준다.
            acc.bgColor.set(Colors.white);
          }
        }
        acc.setState();
        setState(() {});
      },
      isSelected: acc.glass.value,
      width: 30,
      height: 30,
      borderRadius: 0,
      hasBorder: true,
      borderColor: bg == Color(0x00000000) ? Colors.black : MyColors.primaryColor,
      elevation: 5,
      selectedIcon: Icons.blur_on_rounded,
    );
  }
  // IconButton _glassIcon(double left, ACC acc, Color bg) {
  //   return IconButton(
  //     padding: EdgeInsets.fromLTRB(left, 0, 0, 0),
  //     iconSize: 32.0,
  //     icon: Icon(
  //       acc.glass.value == false
  //           ? Icons.circle //Icons.blur_off_rounded
  //           : Icons.blur_on_rounded,
  //       color: bg,
  //       //color: acc.glass.value == false ? Colors.grey : Colors.red,
  //     ),
  //     onPressed: () {
  //       acc.glass.set(!acc.glass.value);
  //       if (acc.glass.value == true) {
  //         if (acc.bgColor.value == Colors.transparent) {
  //           // 바탕색이 투명일때, 유리질을 선택하면, 바탕색을 힌색으로 잡아준다.
  //           acc.bgColor.set(Colors.white);
  //         }
  //       }
  //       acc.setState();
  //       setState(() {});
  //     },
  //   );
  // }
}
