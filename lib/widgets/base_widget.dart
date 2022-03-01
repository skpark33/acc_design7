//import 'dart:collection';
// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
//import 'package:carousel_slider/carousel_slider.dart';

import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/constants/constants.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/player/play_manager.dart';
//import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:acc_design7/widgets/carousel_widget.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/acc/acc_property.dart';

const int minCarouselCount = 3;

class BaseWidget extends StatefulWidget {
  PlayManager? playManager;
  ACC? _parentAcc;
  ACC? get acc => _parentAcc;
  void setParentAcc(ACC acc) {
    _parentAcc = acc;
  }

  // ignore: prefer_final_fields
  //List<AbsPlayWidget> _carouselList = [];

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
      if (!playManager!.isValidCarousel()) {
        return false;
      }
    }
    return true;
  }

  bool isCarousel() {
    if (getAnimeType() == AnimeType.carousel) {
      if (playManager!.isValidCarousel()) {
        return true;
      }
    }
    return false;
  }
}

class BaseWidgetState extends State<BaseWidget> {
  //AnimeCarousel? carousel;

  BaseWidgetState() : super() {
    logHolder.log("BaseWidgetState constructor", level: 5);
  }

  @override
  void initState() {
    super.initState();
    //carousel = AnimeCarousel.create();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('baseWidget build', level: 5);

    if (widget.isCarousel()) {
      widget.playManager!.resetCarousel();
    } else {
      widget.playManager!.setAutoStart();
    }
    return Container(
      color: Colors.transparent,
      child: FutureBuilder(
          future: widget.playManager!.waitBuild(),
          builder: (BuildContext context, AsyncSnapshot<AbsPlayWidget> snapshot) {
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

            // if (pageManagerHolder!.isContents() &&
            //     accManagerHolder!.isCurrentIndex(snapshot.data!.acc.index)) {
            //   selectedModelHolder!.setModel(snapshot.data!.model!);
            // }
            if (!widget.isAnime()) {
              return snapshot.data!;
            }

            switch (widget.getAnimeType()) {
              case AnimeType.carousel:
                logHolder.log('AnimeType.carousel start ${widget.playManager!.currentIndex}');
                //return carousel!.carouselWidget(
                return carouselWidget(
                    context,
                    widget.acc!.containerSize.value.height,
                    widget.playManager!.getPlayWidgetList(),
                    (index, reason) {}, // onPageChanged
                    widget.playManager!.animePageChanger,
                    maxInteger, // 가장 큰 수를 넣는다.
                    widget.playManager!.currentIndex); // 0은 첫번째 index(즉 0번째)가 가운데로 들어오라는 뜻이다.

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
