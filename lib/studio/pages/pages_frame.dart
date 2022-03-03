// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/styles.dart';
import '../../constants/strings.dart';
import '../../common/util/logger.dart';
import 'package:acc_design7/common/buttons/basic_button.dart';
import 'package:acc_design7/widgets/card_flip.dart';
import 'page_list.dart';
import 'page_manager.dart';

class PagesFrame extends StatefulWidget {
  final bool isNarrow;
  const PagesFrame({Key? key, required this.isNarrow}) : super(key: key);

  @override
  State<PagesFrame> createState() => _PageScreenState();
}

class _PageScreenState extends State<PagesFrame> {
  bool isListType = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    logHolder.log('width=$width, height=$height', level: 6);

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
                    icon: Icon(isListType ? Icons.list_alt : Icons.grid_view),
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
            // Expanded(
            //   child: Container(
            //     padding: EdgeInsets.all(5),
            //     //color: MyColors.artBoardBgColor,
            //     child: isListType
            //         ? PageSwipList(key: GlobalKey<PageSwipListState>())
            //         : Container(
            //             color: Colors.red,
            //             width: 310,
            //             height: 500,
            //             child: Text('second page'),
            //           ),
            //   ),
            // ),
            TwinCardFlip(
                firstPage: Container(
                  color: Colors.blue,
                  width: 310,
                  height: height - 140,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    //color: MyColors.artBoardBgColor,
                    child: PageSwipList(key: GlobalKey<PageSwipListState>()),
                  ),
                ),
                secondPage: Container(
                  color: Colors.red,
                  width: 310,
                  height: height - 140,
                  child: Text('second page'),
                ),
                flip: isListType)
          ]),
          Padding(
            padding: EdgeInsets.only(right: 17, bottom: 40),
            child: Consumer<PageManager>(builder: (context, pageManager, child) {
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
    //});
    // child: SingleChildScrollView(
    //   padding: const EdgeInsets.all(defaultPadding),
    //   child: Container(
    //     color: MyColors.white,
    //   ),
    // ),
  }
}
