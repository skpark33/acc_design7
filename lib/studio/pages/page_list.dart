// ignore_for_file: prefer_const_constructors

import 'package:acc_design7/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../common/undo/undo.dart';
import '../../model/pages.dart';
import '../../common/util/logger.dart';
import '../../constants/styles.dart';
//import '../../constants/strings.dart';
//import '../../common/undo/undo.dart';
import 'page_manager.dart';

class PageSwipList extends StatefulWidget {
  const PageSwipList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageSwipListState();
  }
}

class PageSwipListState extends State<PageSwipList> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: Consumer<PageManager>(
          builder: (context, pageManager, child) {
            logHolder.log(
                'Consumer build PageSwipListState ${pageManager.pageIndex}');

            pageManager.reorderMap();
            List<PageModel> items = pageManager.orderMap.values.toList();

            if (items.isEmpty) {
              logHolder.log('item is empty');
              return Container();
            }
            return ReorderableListView(
              buildDefaultDragHandles: false,
              scrollController: _scrollController,
              children: [
                for (int i = 0; i < items.length; i++)
                  eachCard(i, items[i], pageManager),
              ],
              onReorder: (oldIndex, newIndex) => setState(() {
                final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                pageManager.changeOrder(index, oldIndex);
              }),
            );
          },
        ));
  }

  Widget eachCard(int index, PageModel model, PageManager pageManager) {
    double pageRatio = model.getRatio();
    double width = 0;
    double height = 0;
    double pageHeight = 0;
    double pageWidth = 0;

    logHolder.log('eachCard($index)');
    String pageNo = 'P ';
    pageNo += (index + 1).toString().padLeft(2, '0');
    return ReorderableDragStartListener(
      key: ValueKey(model.id.toString()),
      index: index,
      child: GestureDetector(
        key: ValueKey(model.id.toString()),
        onTapDown: (details) {
          //setState(() {
          logHolder.log('selected = $model.id');
          pageManager.setSelectedIndex(context, model.id);
          //});
        },
        onDoubleTapDown: (details) {
          logHolder.log('double clicked = $model.id');
          logHolder.log(
              'dx=${details.localPosition.dx}, dy=${details.localPosition.dx}');
        },
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
            child: Card(
              color: pageManager.isSelected(index)
                  ? MyColors.pageSmallBG
                  : MyColors.secondaryCompl,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1.0,
                    color: pageManager.isSelected(index)
                        ? MyColors.pageSmallBorder
                        : MyColors.pageSmallBorderCompl),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: SizedBox(
                height: 182.0,
                child: Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            iconSize: MySizes.smallIcon,
                            onPressed: () {
                              setState(() {
                                model.isCircle.set(!model.isCircle.value);
                              });
                            },
                            icon: Icon(model.isCircle.value
                                ? Icons.autorenew
                                : Icons.push_pin_outlined),
                            color: MyColors.icon,
                          ),
                          SizedBox(
                            height: 40,
                            width: 180,
                            //color: Colors.red,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  pageNo,
                                  style: MyTextStyles.buttonText,
                                ),
                                Text(
                                  ' | ',
                                  style: MyTextStyles.symbol,
                                ),
                                SizedBox(
                                  width: 118,
                                  child: Text(
                                    model.description.value.isEmpty
                                        ? '${MyStrings.title} ${model.id + 1}'
                                        : model.description.value,
                                    style: MyTextStyles.description,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            iconSize: MySizes.smallIcon,
                            onPressed: () {
                              setState(() {
                                pageManager.removePage(model.id);
                              });
                            },
                            icon: Icon(Icons.delete_outline),
                            color: MyColors.icon,
                          ),
                        ]),
                    //_drawPage(pageManager.isSelected(model.id)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
                      //padding: const EdgeInsets.only(left: 20, top: 0),
                      child: SizedBox(
                        // 실제 페이지를 그리는 부분
                        height: 126.0,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          width = constraints.maxWidth;
                          height = constraints.maxHeight;
                          if (pageRatio > 1) {
                            // 세로형
                            pageHeight = height;
                            pageWidth = pageHeight * (1 / pageRatio);
                          } else {
                            // 가로형
                            pageWidth = width;
                            pageHeight = pageWidth * pageRatio;
                            if (pageHeight > height) {
                              // 화면에서 page 를 표시하는 영역은 항상 가로형으로 항상 세로는
                              // 가로보다 작다.  이러다 보니, 세로 사이지그 화면의 영역을 오버하는
                              // 경우가 생기게 된다.  그러나 세로형의 경우는 이런 일이 발생하지 않는다.
                              pageHeight = height;
                              pageWidth = pageHeight * (1 / pageRatio);
                            }
                          }
                          logHolder.log(
                              "pl:width=$width, height=$height, ratio=$pageRatio");
                          logHolder.log(
                              "pl:pageWidth=$pageWidth, pageHeight=$pageHeight");

                          return SafeArea(
                            child: Container(
                              height: pageHeight,
                              width: pageWidth,
                              color: pageManager.isSelected(model.id)
                                  ? MyColors.pageSmallBG2
                                  : MyColors.primaryCompl,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 5,
            thickness: 1,
            color: MyColors.divide,
            indent: 20,
            endIndent: 10,
          ),
        ]),
      ),
    );
  }
}
