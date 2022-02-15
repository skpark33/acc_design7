// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:acc_design7/common/util/logger.dart';

CarouselSlider carouselWidget(
    BuildContext context,
    double height,
    List<AbsPlayWidget> widgetList,
    int playSec, // millisec
    //CarouselController carouselController,
    int indexNo) {
  return CarouselSlider(
    options: CarouselOptions(
        height: height * 0.9,
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
          //setState(() {});
        }),
    //carouselController: carouselController,
    items: widgetList,
  );
}
