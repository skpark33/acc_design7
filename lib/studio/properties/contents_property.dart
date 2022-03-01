//import 'package:flutter/cupertino.dart';
//mport 'package:acc_design7/acc/acc_manager.dart';
// ignore_for_file: prefer_const_constructors

import 'package:provider/provider.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

//import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/common/util/textfileds.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/studio/properties/property_selector.dart';
import 'package:acc_design7/studio/properties/properties_frame.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/constants/constants.dart';
//import 'package:acc_design7/common/util/my_utils.dart';

// ignore: must_be_immutable
class ContentsProperty extends PropertySelector {
  ContentsProperty(
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
  State<ContentsProperty> createState() => ContentsPropertyState();
}

class ContentsPropertyState extends State<ContentsProperty> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  TextEditingController secCon = TextEditingController();
  TextEditingController minCon = TextEditingController();
  TextEditingController hourCon = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thickness: 8.0,
        scrollbarOrientation: ScrollbarOrientation.left,
        isAlwaysShown: true,
        controller: _scrollController,
        child: Consumer<SelectedModel>(builder: (context, selectedModel, child) {
          double millisec = selectedModel.getModel()!.playTime.value;
          if (selectedModel.getModel()!.isVideo()) {
            millisec = selectedModel.getModel()!.videoPlayTime;
          }
          double sec = (millisec / 1000);
          return ListView(controller: _scrollController, children: [
            _titleRow(25, 15, 12, 10),
            divider(),
            Padding(
                padding: const EdgeInsets.fromLTRB(25, 5, 5, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedModel.getModel()!.name,
                      style: MyTextStyles.h5,
                    ),
                    smallDivider(height: 8, indent: 0, endIndent: 20),
                    Text(
                      '${selectedModel.getModel()!.type}',
                      style: MyTextStyles.subtitle1,
                    ),
                    Text(
                      selectedModel.getModel()!.size,
                      style: MyTextStyles.subtitle1,
                    ),
                    Text(
                      'width/height.${(selectedModel.getModel()!.aspectRatio * 100).round() / 100}',
                      style: MyTextStyles.subtitle2,
                    ),
                    selectedModel.getModel()!.type == ContentsType.image
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              smallDivider(height: 8, indent: 0, endIndent: 20),
                              Text(
                                MyStrings.playTime,
                                style: MyTextStyles.subtitle1,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              myCheckBox(MyStrings.forever, (millisec == playTimeForever), () {
                                if (millisec != playTimeForever) {
                                  selectedModel.getModel()!.reservPlayTime();
                                  selectedModel.getModel()!.playTime.set(playTimeForever);
                                } else {
                                  selectedModel.getModel()!.resetPlayTime();
                                }
                                setState(() {});
                              }, 18, 2, 8, 2),
                              Visibility(
                                visible: millisec != playTimeForever,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        myNumberTextField(
                                            maxValue: 59,
                                            width: 120,
                                            textAlign: TextAlign.end,
                                            hasDeleteButton: true,
                                            hasCounterButton: true,
                                            defaultValue: (sec % 60),
                                            controller: secCon,
                                            onEditingComplete: () {
                                              _updateTime(selectedModel);
                                            }),
                                        SizedBox(width: 10),
                                        Text(
                                          MyStrings.seconds,
                                          style: MyTextStyles.subtitle2,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        myNumberTextField(
                                            maxValue: 59,
                                            width: 120,
                                            textAlign: TextAlign.end,
                                            hasDeleteButton: true,
                                            hasCounterButton: true,
                                            defaultValue: (sec % (60 * 60) / 60).floorToDouble(),
                                            controller: minCon,
                                            onEditingComplete: () {
                                              _updateTime(selectedModel);
                                            }),
                                        SizedBox(width: 10),
                                        Text(
                                          MyStrings.minutes,
                                          style: MyTextStyles.subtitle2,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        myNumberTextField(
                                            maxValue: 23,
                                            width: 120,
                                            textAlign: TextAlign.end,
                                            hasDeleteButton: true,
                                            hasCounterButton: true,
                                            defaultValue: (sec / (60 * 60)).floorToDouble(),
                                            controller: hourCon,
                                            onEditingComplete: () {
                                              _updateTime(selectedModel);
                                            }),
                                        SizedBox(width: 10),
                                        Text(
                                          MyStrings.hours,
                                          style: MyTextStyles.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _toTimeString(sec),
                            style: MyTextStyles.subtitle1,
                          ),
                    // Text(
                    //   'sound.${selectedModel.getModel()!.volume}',
                    // ),
                  ],
                )),
          ]);
        }));
  }

  void _updateTime(SelectedModel selectedModel) {
    setState(() {
      int sec = int.parse(secCon.text);
      int min = int.parse(minCon.text);
      int hour = int.parse(hourCon.text);
      selectedModel.getModel()!.playTime.set((hour * 60 * 60 + min * 60 + sec) * 1000);
    });
    logHolder.log('setPlayTime called ${selectedModel.getModel()!.playTime.value / 1000}',
        level: 6);
  }

  String _toTimeString(double sec) {
    return '${(sec / (60 * 60)).floor()} hour ${(sec % (60 * 60) / 60).floor()} min ${(sec % 60).floor()} sec';
  }

  Widget _titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.contentsPropTitle,
        style: MyTextStyles.body1,
      ),
    );
  }
}
