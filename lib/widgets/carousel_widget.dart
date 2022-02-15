// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:acc_design7/common/util/logger.dart';

CarouselSlider carouselWidget(
    BuildContext context,
    double height,
    List<AbsPlayWidget> widgetList,
    dynamic Function(int, CarouselPageChangedReason)? onPageChanged,
    int playSec, // millisec
    //CarouselController carouselController,
    int indexNo) {
  return CarouselSlider(
    options: CarouselOptions(
        height: height * 0.8,
        initialPage: indexNo,
        enlargeCenterPage: true,
        autoPlay: false,
        reverse: true,
        enableInfiniteScroll: true,
        autoPlayInterval: Duration(milliseconds: playSec),
        autoPlayAnimationDuration: const Duration(milliseconds: 2000),
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {
          logHolder.log('Carousel onPageChanged(index=$index)');
          if (onPageChanged != null) {
            onPageChanged.call(index, reason);
          }
          //setState(() {});
        }),
    //carouselController: carouselController,
    items: widgetList,
  );
}
