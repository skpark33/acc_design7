// ignore_for_file: prefer_final_fields
//import 'package:acc_design7/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/acc/acc.dart';

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
