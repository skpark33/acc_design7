//import 'dart:collection';
// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:acc_design7/widgets/carousel_widget.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/acc/acc_property.dart';

class BaseWidget extends StatefulWidget {
  PlayManager? playManager;
  ACC? _parentAcc;
  ACC? get acc => _parentAcc;
  void setParentAcc(ACC acc) {
    _parentAcc = acc;
  }

  // ignore: prefer_final_fields
  List<AbsPlayWidget> _carouselList = [];

  BaseWidget({required this.baseWidgetKey}) : super(key: baseWidgetKey) {
    playManager = PlayManager(this);
    playManager!.initTimer();
  }
  final GlobalKey<BaseWidgetState> baseWidgetKey;

  @override
  BaseWidgetState createState() => BaseWidgetState();

  void invalidate() {
    //logHolder.log('BaseWidget::invalidate');
    baseWidgetKey.currentState!.invalidate();
    playManager!.invalidate();
  }

  Future<void> pauseAllExceptCurrent() async {
    int len = playManager!.playList.value.length;
    for (int i = 0; i < len; i++) {
      if (i == playManager!.currentIndex) {
        continue;
      }
      await playManager!.playList.value[i].pause();
    }
  }

  AnimeType getAnimeType() {
    if (acc != null) {
      return acc!.animeType.value;
    }
    return AnimeType.none;
  }

  bool isAnime() {
    if (getAnimeType() == AnimeType.none) {
      return false;
    }
    if (getAnimeType() == AnimeType.carousel) {
      if (playManager!.playList.value.length < 2) {
        return false;
      }
    }
    return true;
  }

  int resetCarousel() {
    _carouselList.clear();
    int limit = playManager!.playList.value.length - 1;
    int first = playManager!.currentIndex;

    if (first < 0 || first > limit) return 5000;

    int second = (first == limit ? 0 : first + 1);
    int third = (second == limit ? 0 : second + 1);

    // playManager!.playList.value[first].pause();
    // playManager!.playList.value[second].pause();
    // playManager!.playList.value[third].pause();
    logHolder.log('reset resetCarousel', level: 5);

    playManager!.playList.value[first].autoStart = true;
    playManager!.playList.value[second].autoStart = false;
    playManager!.playList.value[third].autoStart = false;

    _carouselList.add(playManager!.playList.value[first]);
    _carouselList.add(playManager!.playList.value[second]);
    _carouselList.add(playManager!.playList.value[third]);

    return playManager!.playList.value[first].model!.playTime;
  }
}

class BaseWidgetState extends State<BaseWidget> {
  CarouselController? carouselController;

  BaseWidgetState() : super() {
    logHolder.log("BaseWidgetState constructor", level: 5);
  }

  @override
  void initState() {
    super.initState();
    //carouselController = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('baseWidget build');
    int playTime = 5000;
    if (widget.getAnimeType() == AnimeType.carousel) {
      playTime = widget.resetCarousel();
    }
    return Container(
      color: Colors.transparent,
      child: FutureBuilder(
          future: widget.playManager!.waitBuild(),
          builder:
              (BuildContext context, AsyncSnapshot<AbsPlayWidget> snapshot) {
            if (snapshot.hasData == false) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              return emptyImage();
            }
            if (snapshot.hasError) {
              //error가 발생하게 될 경우 반환하게 되는 부분
              return errMsgWidget(snapshot);
            }
            logHolder.log(
                'playTime===${snapshot.data!.model!.playTime}sec, ${snapshot.data!.model!.name}');

            switch (widget.getAnimeType()) {
              case AnimeType.carousel:
                logHolder.log(
                    'AnimeType.carousel start ${widget.playManager!.currentIndex}');
                if (widget.playManager!.playList.value.length < 2) {
                  return snapshot.data!;
                }

                return carouselWidget(
                    context,
                    widget.acc!.containerSize.value.height,
                    widget._carouselList,
                    (index, reason) {}, // onPageChanged
                    playTime,
                    0); // 0은 첫번째 index(즉 0번째)가 가운데로 들어오라는 뜻이다.
              //carouselController!,
              //widget.playManager!.currentIndex);

              case AnimeType.flip:
                logHolder.log('AnimeType.flip');
                return snapshot.data!;
              default:
                //logHolder.log('AnimeType.normal');
                return snapshot.data!;
            }
          }),

      //imagePlayer.play(widget._currentModel!),
    );
  }

  @override
  void dispose() {
    logHolder.log("BaseWidgetState dispose");
    //widget.playManager!.clear();
    super.dispose();
  }

  void invalidate() {
    setState(() {});
  }
}
