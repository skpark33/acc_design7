// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/styles.dart';
import '../../constants/strings.dart';
import '../../common/util/logger.dart';
import 'package:acc_design7/common/buttons/basic_button.dart';
import 'page_list.dart';
import 'page_manager.dart';

class PagesFrame extends StatefulWidget {
  final bool isNarrow;
  const PagesFrame({Key? key, required this.isNarrow}) : super(key: key);

  @override
  State<PagesFrame> createState() => _PageScreenState();
}

class _PageScreenState extends State<PagesFrame> {
  bool isListType = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: MyColors.white,
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 6, 10, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(MyStrings.pages, style: MyTextStyles.body2),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isListType = !isListType;
                      });
                    },
                    icon: Icon(isListType ? Icons.grid_view : Icons.list_alt),
                    color: MyColors.icon,
                    iconSize: MySizes.smallIcon,
                  ),
                ],
              ),
            ),
            Divider(
              height: 5,
              thickness: 1,
              color: MyColors.divide,
              indent: 0,
              endIndent: 0,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                //color: MyColors.artBoardBgColor,
                child: PageSwipList(key: GlobalKey<PageSwipListState>()),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.only(right: 17, bottom: 40),
            child:
                Consumer<PageManager>(builder: (context, pageManager, child) {
              return basicButton(
                  name: MyStrings.pageAdd,
                  iconData: Icons.add,
                  onPressed: () {
                    logHolder.log('createPage()');
                    pageManager.createPage();
                    setState(() {});
                  });
            }),
          ),
        ]),
      ),
    );
    // child: SingleChildScrollView(
    //   padding: const EdgeInsets.all(defaultPadding),
    //   child: Container(
    //     color: MyColors.white,
    //   ),
    // ),
  }
}
