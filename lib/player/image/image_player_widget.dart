// ignore: implementation_imports
// ignore_for_file: prefer_final_fields
import 'package:acc_design7/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/player/abs_player.dart';

// ignore: must_be_immutable
class ImagePlayerWidget extends AbsPlayWidget {
  ImagePlayerWidget({
    required GlobalObjectKey<ImagePlayerWidgetState> key,
    required ContentsModel model,
    required ACC acc,
    void Function()? onAfterEvent,
    bool autoStart = true,
  }) : super(
            key: key,
            onAfterEvent: onAfterEvent,
            acc: acc,
            model: model,
            autoStart: autoStart) {
    globalKey = key;
  }

  GlobalObjectKey<ImagePlayerWidgetState>? globalKey;

  @override
  Future<void> play() async {
    logHolder.log('image play');
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
  ImagePlayerWidgetState createState() => ImagePlayerWidgetState();
}

class ImagePlayerWidgetState extends State<ImagePlayerWidget> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double topLeft = widget.acc.radiusTopLeft.value;
    double topRight = widget.acc.radiusTopRight.value;
    double bottomLeft = widget.acc.radiusBottomLeft.value;
    double bottomRight = widget.acc.radiusBottomRight.value;
    return Container(
      decoration: BoxDecoration(
          //shape: BoxShape.circle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight),
          ),
          image: DecorationImage(
              fit: BoxFit.fill, image: NetworkImage(widget.model!.url))),
    );
  }
}
