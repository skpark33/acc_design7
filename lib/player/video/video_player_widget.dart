// ignore: implementation_imports
// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';

import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:acc_design7/player/video/video_player_controller.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:acc_design7/common/util/logger.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends AbsPlayWidget {
  VideoPlayerWidget({
    required GlobalObjectKey<VideoPlayerWidgetState> key,
    required void Function() onAfterEvent,
    required ContentsModel model,
    required ACC acc,
    bool autoStart = true,
  }) : super(
            key: key,
            onAfterEvent: onAfterEvent,
            acc: acc,
            model: model,
            autoStart: autoStart) {
    globalKey = key;
  }

  GlobalObjectKey<VideoPlayerWidgetState>? globalKey;
  VideoPlayerController? wcontroller;
  VideoEventType prevEvent = VideoEventType.unknown;

  @override
  Future<void> init() async {
    logHolder.log('initVideo(${model!.name})');
    wcontroller = VideoPlayerController.network(model!.url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        logHolder.log('initialize complete(${model!.name})');
        //setState(() {});
        logHolder.log(
            'initialize complete(${wcontroller!.value.duration.inMilliseconds})');

        model!.setState(PlayState.init);
        model!.playTime = wcontroller!.value.duration.inMilliseconds;
        wcontroller!.setLooping(false);
        wcontroller!.onAfterVideoEvent = (event) {
          logHolder.log(
              'video event ${event.eventType.toString()}, ${event.duration.toString()},(${model!.name})');
          if (event.eventType == VideoEventType.completed) {
            // bufferingEnd and completed 가 시간이 다 되서 종료한 것임.

            logHolder.log('video completed(${model!.name})');
            model!.setState(PlayState.end);
            onAfterEvent!.call();
          }
          prevEvent = event.eventType;
        };
        //wcontroller!.play();
      });
  }

  @override
  bool isInit() {
    return wcontroller!.value.isInitialized;
  }

  @override
  void invalidate() {
    if (globalKey != null && globalKey!.currentState != null) {
      globalKey!.currentState!.invalidate();
    }
  }

  @override
  Future<void> play() async {
    logHolder.log('play  ${model!.name}');
    model!.setState(PlayState.start);
    await wcontroller!.play();
  }

  @override
  Future<void> pause() async {
    logHolder.log('pause');
    model!.setState(PlayState.pause);
    await wcontroller!.pause();
  }

  @override
  Future<void> close() async {
    model!.setState(PlayState.none);
    logHolder.log("videoController close()");
    await wcontroller!.dispose();
  }

  @override
  Future<void> mute() async {
    if (model!.mute) {
      await wcontroller!.setVolume(1.0);
    } else {
      await wcontroller!.setVolume(0.0);
    }
    model!.mute = !model!.mute;
  }

  @override
  Future<void> setSound(double val) async {
    await wcontroller!.setVolume(1.0);
    model!.volume = val;
  }

  @override
  // ignore: no_logic_in_create_state
  VideoPlayerWidgetState createState() {
    logHolder.log('video createState (${model!.name}');
    return VideoPlayerWidgetState();
  }
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      logHolder.log('initState video');
      //   if (autoStart) {
      //     logHolder.log('initState play');
      //     widget.play();
    });
  }

  @override
  void dispose() {
    logHolder.log("video widget dispose,${widget.model!.name}");
    //widget.wcontroller!.dispose();
    widget.model!.setState(PlayState.disposed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('VideoPlayerWidgetState', level: 5);

    if (widget.autoStart) {
      logHolder.log('initState play', level: 5);
      widget.play();
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(widget.acc.radiusTopRight.value),
        topLeft: Radius.circular(widget.acc.radiusTopLeft.value),
        bottomRight: Radius.circular(widget.acc.radiusBottomRight.value),
        bottomLeft: Radius.circular(widget.acc.radiusBottomLeft.value),
      ),
      child: widget.wcontroller!.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: widget.acc.getRealWidth(),
                    height: widget.acc.getRealHeight(),
                    child: VideoPlayer(widget.wcontroller!,
                        key: ValueKey(widget.model!.url)),
                    //child: VideoPlayer(controller: widget.wcontroller!),
                  )),
            )
          : const Text('not init'),
    );
  }
}
