// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:acc_design7/studio/pages/page_manager.dart';
import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'package:acc_design7/studio/properties/property_selector.dart';
//import 'package:acc_design7/studio/properties/page_property.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/common/util/logger.dart';
//import 'package:acc_design7/constants/strings.dart';

class PropertiesFrame extends StatefulWidget {
  final bool isNarrow;

  PropertiesFrame({Key? key, required this.isNarrow}) : super(key: key);

  @override
  State<PropertiesFrame> createState() => PropertiesFrameState();
}

class PropertiesFrameState extends State<PropertiesFrame> {
  PageModel? selectedPage;

  bool isLandscape = true;
  bool isSizeChangable = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    selectedPage = pageManagerHolder!.getSelected();
    isLandscape = (selectedPage!.width.value >= selectedPage!.height.value);
  }

  void invalidate() {
    logHolder.log('setState of properties frame');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final TextStyle _segmentTextStyle =
    //     Theme.of(context).textTheme.caption ?? const TextStyle(fontSize: 12);

    // const Color _thumbColor = CupertinoDynamicColor.withBrightness(
    //   color: Color(0xFFFFFFFF),
    //   darkColor: Color(0xFF636366),
    // );

    // final Color? _thumbOnColor =
    //     ThemeData.estimateBrightnessForColor(_thumbColor) == Brightness.light
    //         ? Colors.black
    //         : Colors.white;

    return SafeArea(
        child: Container(
      color: MyColors.white,
      child: Stack(
        children: [
          Consumer<PageManager>(builder: (context, pageManager, child) {
            _init();
            PropertySelector selector = PropertySelector.fromManager(
              pageManager: pageManager,
              selectedPage: selectedPage,
              isNarrow: widget.isNarrow,
              isLandscape: isLandscape,
              parent: this,
            );
            return selector;
            // return Column(
            //   children: [
            //     CupertinoSlidingSegmentedControl<PropertyType>(
            //       children: <PropertyType, Widget>{
            //         PropertyType.page: Padding(
            //           padding: const EdgeInsets.all(5),
            //           child: Text(
            //             MyStrings.pagePropTitle,
            //             textAlign: TextAlign.center,
            //             style: pageManager.propertyType == PropertyType.page
            //                 ? _segmentTextStyle.copyWith(color: _thumbOnColor)
            //                 : _segmentTextStyle,
            //           ),
            //         ),
            //         PropertyType.acc: Padding(
            //           padding: const EdgeInsets.all(5),
            //           child: Text(
            //             MyStrings.widgetPropTitle,
            //             textAlign: TextAlign.center,
            //             style: pageManager.propertyType == PropertyType.acc
            //                 ? _segmentTextStyle.copyWith(color: _thumbOnColor)
            //                 : _segmentTextStyle,
            //           ),
            //         ),
            //         PropertyType.contents: Padding(
            //           padding: const EdgeInsets.all(5),
            //           child: Text(
            //             MyStrings.contentsPropTitle,
            //             textAlign: TextAlign.center,
            //             style: pageManager.propertyType == PropertyType.contents
            //                 ? _segmentTextStyle.copyWith(color: _thumbOnColor)
            //                 : _segmentTextStyle,
            //           ),
            //         ),
            //       },
            //       thumbColor: _thumbColor,
            //       onValueChanged: (PropertyType? value) {
            //         if (value != null) {
            //           setState(() {
            //             pageManager.setPropertyType(value);
            //           });
            //         }
            //       },
            //       groupValue: pageManager.propertyType,
            //     ),
            //     selector,
            //   ],
            // );
          }),
          Consumer<ACCManager>(builder: (context, pageManager, child) {
            // Dummy Consumer : 컨슈머가 late 하게 만들이지면 Provider 가 초기화가 안되기 때문에
            //  더미 Consumber 를 하나 만들어 둔다.
            //logHolder.log('Consumer of dummy accManager');
            return Container();
          }),
          Consumer<SelectedModel>(builder: (context, selectedModel, child) {
            // Dummy Consumer : 컨슈머가 late 하게 만들이지면 Provider 가 초기화가 안되기 때문에
            //  더미 Consumber 를 하나 만들어 둔다.
            //logHolder.log('Consumer of dummy accManager');
            return Container();
          }),
        ],
      ),
    ));
  }
}
