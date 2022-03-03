//import 'package:flutter/cupertino.dart';
//mport 'package:acc_design7/acc/acc_manager.dart';
// ignore_for_file: prefer_const_constructors

import 'package:provider/provider.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

//import 'package:acc_design7/model/contents.dart';
//import 'package:acc_design7/common/util/logger.dart';
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
  //final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  TextEditingController secCon = TextEditingController();
  TextEditingController minCon = TextEditingController();
  TextEditingController hourCon = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<ContentsModel> waitContents(SelectedModel selectedModel) async {
    ContentsModel? retval;
    while (retval == null) {
      retval = await selectedModel.getModel();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return retval;
  }

  @override
  Widget build(BuildContext context) {
    //return
    // Scrollbar(
    //     thickness: 8.0,
    //     scrollbarOrientation: ScrollbarOrientation.left,
    //     isAlwaysShown: true,
    //     controller: _scrollController,
    //     child:
    return Consumer<SelectedModel>(builder: (context, selectedModel, child) {
      return FutureBuilder(
          future: waitContents(selectedModel),
          builder: (BuildContext context, AsyncSnapshot<ContentsModel> snapshot) {
            if (snapshot.hasData == false) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              return emptyImage();
            }
            if (snapshot.hasError) {
              //error가 발생하게 될 경우 반환하게 되는 부분
              return errMsgWidget(snapshot);
            }

            ContentsModel model = snapshot.data!;

            double millisec = model.playTime.value;
            if (model.isVideo()) {
              millisec = model.videoPlayTime;
            }
            double sec = (millisec / 1000);
            return Column(children: [
              //  titleRow(25, 15, 12, 10),
              //  divider(),
              Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 5, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: MyTextStyles.h6,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      smallDivider(height: 8, indent: 0, endIndent: 20),
                      Text(
                        '${model.type}',
                        style: MyTextStyles.subtitle1,
                      ),
                      Text(
                        model.size,
                        style: MyTextStyles.subtitle1,
                      ),
                      Text(
                        'width/height.${(model.aspectRatio * 100).round() / 100}',
                        style: MyTextStyles.subtitle2,
                      ),
                      model.type == ContentsType.image
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                smallDivider(height: 8, indent: 0, endIndent: 20),
                                Row(
                                  children: [
                                    Text(
                                      MyStrings.playTime,
                                      style: MyTextStyles.subtitle1,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    myCheckBox(MyStrings.forever, (millisec == playTimeForever),
                                        () {
                                      if (millisec != playTimeForever) {
                                        model.reservPlayTime();
                                        model.playTime.set(playTimeForever);
                                      } else {
                                        model.resetPlayTime();
                                      }
                                      setState(() {});
                                    }, 8, 2, 0, 2),
                                  ],
                                ),
                                Visibility(
                                  visible: millisec != playTimeForever,
                                  child: Row(
                                    children: [
                                      myNumberTextField2(
                                          width: 50,
                                          height: 84,
                                          maxValue: 59,
                                          defaultValue: (sec % 60),
                                          controller: secCon,
                                          onEditingComplete: () {
                                            _updateTime(model);
                                          }),
                                      SizedBox(width: 4),
                                      Text(
                                        MyStrings.seconds,
                                        style: MyTextStyles.subtitle2,
                                      ),
                                      SizedBox(width: 10),
                                      myNumberTextField2(
                                          width: 50,
                                          height: 84,
                                          maxValue: 59,
                                          defaultValue: (sec % (60 * 60) / 60).floorToDouble(),
                                          controller: minCon,
                                          onEditingComplete: () {
                                            _updateTime(model);
                                          }),
                                      SizedBox(width: 4),
                                      Text(
                                        MyStrings.minutes,
                                        style: MyTextStyles.subtitle2,
                                      ),
                                      SizedBox(width: 10),
                                      myNumberTextField2(
                                          width: 50,
                                          height: 84,
                                          maxValue: 23,
                                          defaultValue: (sec / (60 * 60)).floorToDouble(),
                                          controller: hourCon,
                                          onEditingComplete: () {
                                            _updateTime(model);
                                          }),
                                      SizedBox(width: 4),
                                      Text(
                                        MyStrings.hours,
                                        style: MyTextStyles.subtitle2,
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
                      //   'sound.${model.volume}',
                      // ),
                    ],
                  )),
            ]);
          });

      //return ListView(controller: _scrollController, children: [
    });
    //);
  }

  void _updateTime(ContentsModel model) {
    setState(() {
      int sec = int.parse(secCon.text);
      int min = int.parse(minCon.text);
      int hour = int.parse(hourCon.text);
      model.playTime.set((hour * 60 * 60 + min * 60 + sec) * 1000);
    });
  }

  String _toTimeString(double sec) {
    return '${(sec / (60 * 60)).floor()} hour ${(sec % (60 * 60) / 60).floor()} min ${(sec % 60).floor()} sec';
  }

  Widget titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.contentsPropTitle,
        style: MyTextStyles.body1,
      ),
    );
  }
}
