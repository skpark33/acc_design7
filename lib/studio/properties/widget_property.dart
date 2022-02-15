// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable
//import 'dart:html';

import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/acc/acc_property.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/studio/properties/property_selector.dart';
//import 'package:flutter/rendering.dart';
//import 'package:acc_design7/common/buttons/toggle_switch.dart';
//import 'package:acc_design7/studio/pages/page_manager.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/constants/styles.dart';
//import 'package:acc_design7/constants/constants.dart';
import 'package:acc_design7/model/users.dart';
import 'package:acc_design7/common/util/textfileds.dart';
import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/common/undo/undo.dart';
//import 'package:acc_design7/common/libColor/tinyColor.dart';
//import 'package:acc_design7/common/colorPicker/widgets/color_picker.dart';
import 'package:acc_design7/common/colorPicker/color_row.dart';
import 'package:acc_design7/studio/properties/properties_frame.dart';
//import 'package:acc_design7/common/buttons/wave_slider.dart';
import 'package:acc_design7/common/buttons/dial_button.dart';

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
              SizedBox(
                width: titleSize,
                child: Text(
                  title,
                  style: MyTextStyles.subtitle2,
                ),
              ),
              if (titleLineWidget != null) titleLineWidget,
              IconButton(
                onPressed: setStateFunction,
                icon: Icon(isSelected
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
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
}

class WidgetPropertyState extends State<WidgetProperty>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);

  late AnimationController _aniIconController;

  TextEditingController descCon = TextEditingController();
  TextEditingController widthCon = TextEditingController();
  TextEditingController heightCon = TextEditingController();
  TextEditingController colorCon = TextEditingController();
  TextEditingController xCon = TextEditingController();
  TextEditingController yCon = TextEditingController();

  bool isSizeChangable = true;

  ExapandableModel animeModel = ExapandableModel(
    title: MyStrings.anime,
    height: 260,
    width: 240,
  );
  ExapandableModel bgColorModel = ExapandableModel(
    title: MyStrings.bgColor,
    height: 150,
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
    height: 260,
    width: 240,
  );
  ExapandableModel borderModel = ExapandableModel(
    title: MyStrings.border,
    height: 260,
    width: 240,
  );

  @override
  void initState() {
    _aniIconController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
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
            _titleRow(25, 25, 35, 15),
            _divider(),
            _primaryRow(acc, 25, 5, 12, 5),
            _divider(),
            sizePosModel.expandArea(
                child: _sizePosRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    sizePosModel.toggleSelected();
                  });
                },
                titleSize: 100,
                titleLineWidget: Text(
                  '${acc.containerOffset.value.dx},${acc.containerOffset.value.dy},${acc.containerSize.value.width} x ${acc.containerSize.value.height}',
                  style: MyTextStyles.subtitle1,
                )),
            _divider(),
            bgColorModel.expandArea(
                child: _bgColorRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    bgColorModel.toggleSelected();
                  });
                },
                titleSize: 100,
                titleLineWidget: acc.bgColor.value != Color(0x00000000)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            foregroundColor: acc.bgColor.value,
                            //foregroundColor: acc.bgColor.value == Color(0x00000000)
                            //    ? MyColors.primaryColor
                            //    : acc.bgColor.value,
                            backgroundColor: MyColors.secondaryColor,
                            child: Icon(Icons.circle, size: 32),
                            //acc.bgColor.value == Color(0x00000000)
                            //    ? Icon(Icons.clear, size: 32)
                            //    : Icon(Icons.circle, size: 32),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '#${acc.bgColor.value.toString().substring(8, 16)}',
                            style: MyTextStyles.subtitle1,
                          ),
                        ],
                      )
                    : null),
            _divider(),
            rotateModel.expandArea(
                child: _rotateRow(context, acc),
                titleLineWidget: Text(
                  '${acc.rotate.value} °',
                  style: MyTextStyles.subtitle1,
                ),
                setStateFunction: () {
                  setState(() {
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
                            icon: AnimatedIcon(
                              icon: _getAnimeIcon(acc.animeType.value),
                              progress: _aniIconController,
                              size: 30,
                              color: MyColors.primaryColor,
                            ),
                            //Icon(),
                            onPressed: () {
                              _aniIconController.forward().then(
                                (value) async {
                                  await Future.delayed(Duration(seconds: 1));
                                  _aniIconController.reverse();
                                },
                              );
                            }),
                      ])
                    : null,
                setStateFunction: () {
                  setState(() {
                    animeModel.toggleSelected();
                  });
                }),
            _divider(),
            borderModel.expandArea(
                child: _borderRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    borderModel.toggleSelected();
                  });
                }),
            _divider(),
            cornerModel.expandArea(
                child: _cornerRow(context, acc),
                setStateFunction: () {
                  setState(() {
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

  Widget _titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.widgetPropTitle,
        style: MyTextStyles.body2,
      ),
    );
  }

  Widget _primaryRow(
      ACC acc, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: [
          Text(
            MyStrings.primary,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 8, 8, 8),
            iconSize: 32.0,
            icon: Icon(
              acc.primary.value != true
                  ? Icons.star_outline_outlined
                  : Icons.star_outlined,
              color: acc.primary.value != true ? Colors.grey : Colors.red,
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
          defaultValue: acc.containerOffset.value.dx,
          controller: xCon,
          onEditingComplete: () {
            logHolder.log("textval = ${xCon.text}");
            acc.containerOffset.set(
                Offset(double.parse(xCon.text), acc.containerOffset.value.dy));

            acc.setState();
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
          defaultValue: acc.containerOffset.value.dy,
          controller: yCon,
          onEditingComplete: () {
            logHolder.log("textval = ${yCon.text}");
            acc.containerOffset.set(
                Offset(acc.containerOffset.value.dx, double.parse(yCon.text)));

            acc.setState();
          },
        ),
        writeButton(
          // x,y 좌표를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.containerOffset
                .set(Offset(double.parse(xCon.text), double.parse(yCon.text)));

            mychangeStack.endTrans();
            acc.setState();
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
          defaultValue: acc.containerSize.value.width,
          controller: widthCon,
          onEditingComplete: () {
            logHolder.log("textval = ${widthCon.text}");
            acc.containerSize.set(Size(
                double.parse(widthCon.text), acc.containerSize.value.height));
            acc.setState();
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
          defaultValue: acc.containerSize.value.height,
          controller: heightCon,
          onEditingComplete: () {
            logHolder.log("textval = ${heightCon.text}");
            acc.containerSize.set(Size(
                acc.containerSize.value.width, double.parse(heightCon.text)));
            acc.setState();
          },
        ),
        writeButton(
          // width,height를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.containerSize.set(Size(
                double.parse(widthCon.text), double.parse(heightCon.text)));
            mychangeStack.endTrans();
            acc.setState();
          },
        ),
      ],
    );
  }

  Widget _rotateRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.center,
        child: DialView(
          angle: acc.rotate.value,
          size: Size(200, 200),
          onValueChanged: (value) {
            //logHolder.log('onValueChanged: $value');
            acc.rotate.set(value);
            acc.setState();
            setState(() {});
          },
        ));
  }

  Widget _bgColorRow(BuildContext context, ACC acc) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
          // 배경 색상 수동입력
          children: [
            SizedBox(
              height: 10,
            ),
            colorRow(
              context: context,
              value: acc.bgColor.value,
              list: [
                for (int i = 0; i < currentUser.maxBgColor; i++)
                  currentUser.bgColorList1[i],
              ],
              onPressed: (bg) {
                acc.setBgColor(bg);
                //pageManagerHolder!.setState();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                ),
                SizedBox(
                  width: 100,
                  height: 30,
                  child: myTextField(
                    '#${acc.bgColor.value.toString().substring(8, 16)}',
                    limit: 9,
                    controller: colorCon,
                    style: MyTextStyles.body2,
                    enabled: true,
                    hasBorder: true,
                    hasDeleteButton: false,
                    onEditingComplete: () {
                      acc.setBgColor(hexToColor(colorCon.text));
                    },
                  ),
                ),
                writeButton(
                  // color를  Write 하는 icon
                  onPressed: () {
                    acc.setBgColor(hexToColor(colorCon.text));
                  },
                ),
              ],
            ),
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
    return Container(alignment: Alignment.topCenter, child: null);
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
}
