// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:acc_design7/model/pages.dart';
import 'package:acc_design7/studio/pages/page_manager.dart';
import 'package:acc_design7/studio/properties/page_property.dart';
import 'package:acc_design7/studio/properties/widget_property.dart';
import 'package:acc_design7/studio/properties/contents_property.dart';
import 'package:acc_design7/studio/properties/properties_frame.dart';
import 'package:acc_design7/common/util/logger.dart';

class PropertySelector extends StatefulWidget {
  final bool isNarrow;
  final PageModel? selectedPage;
  bool isLandscape = true;
  PropertiesFrameState parent;

  PropertySelector({
    Key? key,
    required this.selectedPage,
    required this.isNarrow,
    required this.isLandscape,
    required this.parent,
  }) : super(key: key);

  factory PropertySelector.fromManager({
    Key? key,
    required PageManager pageManager,
    required selectedPage,
    required isNarrow,
    required isLandscape,
    required parent,
  }) {
    if (pageManager.isPage()) {
      logHolder.log("isPage", level: 2);
      return PageProperty(key, selectedPage, isNarrow, isLandscape, parent);
    }
    if (pageManager.isAcc()) {
      return WidgetProperty(key, selectedPage, isNarrow, isLandscape, parent);
    }
    if (pageManager.isContents()) {
      return ContentsProperty(key, selectedPage, isNarrow, isLandscape, parent);
    }
    return NullProperty(key, selectedPage, isNarrow, isLandscape, parent);
  }

  @override
  State<PropertySelector> createState() => PropertySelectorState();
}

class PropertySelectorState extends State<PropertySelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NullProperty extends PropertySelector {
  NullProperty(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );

  @override
  State<NullProperty> createState() => NullPropertyState();
}

class NullPropertyState extends State<NullProperty> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
