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
    if (baseWidgetKey.currentState != null) {
      logHolder.log('BaseWidget::invalidate');
      baseWidgetKey.currentState!.invalidate();
    }
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
              //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
              return emptyImage();
            }
            if (snapshot.hasError) {
              //error??? ???????????? ??? ?????? ???????????? ?????? ??????
              return errMsgWidget(snapshot);
            }
            logHolder.log(
                'playTime===${snapshot.data!.model!.playTime.value} sec, ${snapshot.data!.model!.name}');

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
                    maxInteger, // ?????? ??? ?????? ?????????.
                    widget.playManager!.currentIndex); // 0??? ????????? index(??? 0??????)??? ???????????? ??????????????? ?????????.

              case AnimeType.flip:
                logHolder.log('AnimeType.flip');
                return snapshot.data!;
              default:
                //logHolder.log('AnimeType.normal');
                return snapshot.data!;
            }
          }),

      //imagePlayer.play(widget._currentModel!),
      //),
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
