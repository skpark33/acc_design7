// ignore_for_file: prefer_final_fields
//import 'package:acc_design7/common/util/logger.dart';
//import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'package:flutter/material.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/studio/pages/page_manager.dart';

// page (1) --> (n) acc (1) --> (1) baseWidget --> (1) PlayManager (n) absPlayWidget                                                                 (n) absPlayWidget

// ignore: must_be_immutable
abstract class AbsPlayWidget extends StatefulWidget {
  ContentsModel? model;
  ACC acc;
  bool autoStart = true;

  AbsPlayWidget(
      {Key? key, required this.onAfterEvent, required this.acc, this.model, this.autoStart = true})
      : super(key: key);

  void Function()? onAfterEvent;

  Future<void> init() async {}
  Future<void> play() async {}
  Future<void> pause() async {}
  Future<void> mute() async {}
  Future<void> setSound(double val) async {}
  Future<void> close() async {}

  void invalidate() async {}
  bool isInit() {
    return true;
  }

  PlayState getPlayState() {
    return model!.state;
  }

  ContentsModel getModel() {
    return model!;
  }

  Future<void> afterBuild() async {
    if (model == null) return;
    model!.setState(PlayState.init);
    if (model!.dynamicSize.value) {
      model!.dynamicSize.set(false);
      acc.resize(model!.aspectRatio);
    }
    if (await selectedModelHolder!.isSelectedModel(model!)) {
      pageManagerHolder!.setAsContents();
    }
  }

  Size getOuterSize(double srcRatio) {
    Size realSize = acc.getRealSize();
    // aspectorRatio 는 실제 비디오의  넓이/높이 이다.
    //double videoRatio = wcontroller!.value.aspectRatio;

    double outerWidth = realSize.width;
    double outerHeight = realSize.height;

    if (!acc.sourceRatio.value) {
      if (srcRatio >= 1.0) {
        outerWidth = srcRatio * outerWidth;
        outerHeight = outerWidth * (1.0 / srcRatio);
      } else {
        outerHeight = (1.0 / srcRatio) * outerHeight;
        outerWidth = srcRatio * outerHeight;
      }
    }
    return Size(outerWidth, outerHeight);
  }

  Widget getClipRect(Size outSize, Widget child) {
    return ClipRRect(
      //clipper: MyContentsClipper(),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(acc.radiusTopRight.value),
        topLeft: Radius.circular(acc.radiusTopLeft.value),
        bottomRight: Radius.circular(acc.radiusBottomRight.value),
        bottomLeft: Radius.circular(acc.radiusBottomLeft.value),
      ),
      child: SizedBox.expand(
          child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.cover,
        child: SizedBox(
          //width: realSize.width,
          //height: realSize.height,
          width: outSize.width,
          height: outSize.height,
          child: child,
        ),
      )),
    );
  }
}

// ignore: must_be_immutable
class EmptyPlayWidget extends AbsPlayWidget {
  EmptyPlayWidget(
      {required GlobalObjectKey<EmptyPlayWidgetState> key,
      required void Function() onAfterEvent,
      required ACC acc})
      : super(key: key, onAfterEvent: onAfterEvent, acc: acc) {
    globalKey = key;
  }

  GlobalObjectKey<EmptyPlayWidgetState>? globalKey;

  @override
  Future<void> play() async {
    model!.setState(PlayState.start);
  }

  @override
  Future<void> pause() async {
    model!.setState(PlayState.pause);
  }

  @override
  Future<void> mute() async {}

  @override
  Future<void> setSound(double val) async {}

  @override
  Future<void> close() async {
    model!.setState(PlayState.none);
  }

  @override
  void invalidate() {
    if (globalKey != null && globalKey!.currentState != null) {
      globalKey!.currentState!.invalidate();
    }
  }

  @override
  bool isInit() {
    return true;
  }

  @override
  PlayState getPlayState() {
    return PlayState.none;
  }

  @override
  ContentsModel getModel() {
    return model!;
  }

  @override
  EmptyPlayWidgetState createState() => EmptyPlayWidgetState();
}

class EmptyPlayWidgetState extends State<EmptyPlayWidget> {
  void invalidate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
