// ignore_for_file: prefer_const_constructors
import 'package:acc_design7/model/contents.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:acc_design7/common/buttons/basic_button.dart';
import 'package:acc_design7/common/buttons/hover_buttons.dart';
import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/constants/constants.dart';
import 'package:acc_design7/constants/strings.dart';
import 'package:acc_design7/common/util/my_text.dart';
import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/widgets/base_widget.dart';
import 'package:acc_design7/studio/pages/page_manager.dart';

class MenuModel {
  //complex drawer menu
  final IconData icon;
  final String title;
  final List<String> submenus;
  void Function()? onPressed;

  MenuModel(this.icon, this.title, this.submenus);
}

class MyMenuStick extends StatefulWidget {
  const MyMenuStick({required Key key}) : super(key: key);

  @override
  MyMenuStickState createState() => MyMenuStickState();
}

const double narrowWidth = 55;
const double wideWidth = 160;
const double subWidth = 125;

class MyMenuStickState extends State<MyMenuStick> {
  int selectedIndex = -1; //dont set it to 0
  bool isExpanded = false;
  bool isSubMenuOpen = false;

  static int _keyIdx = 0;

  static List<MenuModel> menuModelList = [
    // MenuModel(Icons.grid_view, "Control", []),
    MenuModel(Icons.dashboard_customize_outlined, MyStrings.frame, []),
    MenuModel(Icons.rtt_outlined, MyStrings.text, []),
    MenuModel(Icons.auto_fix_high_outlined, MyStrings.effect, []),
    MenuModel(Icons.military_tech_outlined, MyStrings.badge, []),
    MenuModel(Icons.videocam_outlined, MyStrings.camera, []),
    MenuModel(Icons.wb_sunny_outlined, MyStrings.weather, []),
    MenuModel(Icons.schedule_outlined, MyStrings.clock, []),
    MenuModel(Icons.music_note, MyStrings.music, []),
    MenuModel(Icons.feed_outlined, MyStrings.news, []),
    MenuModel(Icons.brush, MyStrings.brush, []),
  ];

  static void createACC(BuildContext context, ContentsModel model) {
    const uuid = Uuid();
    GlobalObjectKey<BaseWidgetState> baseWidgetKey = GlobalObjectKey<BaseWidgetState>(uuid.v1());
    ACC acc = accManagerHolder!.createACC(_keyIdx, context,
        BaseWidget(baseWidgetKey: baseWidgetKey), pageManagerHolder!.getSelected()!);
    _keyIdx++;
    if (acc.accChild.playManager != null) {
      acc.accChild.playManager!.push(acc, model);
    }
  }

  @override
  void initState() {
    super.initState();
    menuModelList[0].onPressed = framePressed;
    menuModelList[1].onPressed = textPressed;
    menuModelList[2].onPressed = effectPressed;
    menuModelList[3].onPressed = badgePressed;
    menuModelList[4].onPressed = cameraPressed;
    menuModelList[5].onPressed = weatherPressed;
    menuModelList[6].onPressed = clockPressed;
    menuModelList[7].onPressed = musicPressed;
    menuModelList[8].onPressed = newsPressed;
    menuModelList[9].onPressed = brushPressed;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: layoutPageWidth + 12,
      top: 80,
      child: Material(
        type: MaterialType.card,
        color: Colors.transparent,
        child: frostedEdged(
          sigma: 10.0,
          radius: 8.0,
          //child: Padding(
          //padding: const EdgeInsets.only(left: 12, top: 10),
          child: Container(
              // decoration: simpleDeco(
              //     8.0, 0.5, Colors.white.withOpacity(0.2), MyColors.white),
              height: 560,
              width: isExpanded
                  ? wideWidth
                  : isSubMenuOpen
                      ? narrowWidth + subWidth
                      : narrowWidth,
              child: row(),
              color: Colors.white.withOpacity(0.5) //MyColors.compexDrawerCanvasColor,
              ),
          //),
        ),
      ),
    );
  }

  Widget row() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      isExpanded ? blackIconTiles() : blackIconMenu(),
      isSubMenuOpen ? invisibleSubMenus() : Container(),
    ]);
  }

  Widget blackIconTiles() {
    return Container(
      width: wideWidth,
      color: MyColors.complexDrawerBlack,
      child: Column(
        children: [
          controlTile(),
          Expanded(
            child: ListView.builder(
              itemCount: menuModelList.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                MenuModel menuModel = menuModelList[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: HoverButton.withIconData(
                      hoverSize: 32,
                      width: 45,
                      height: 45,
                      onPressed: () {
                        setState(() {
                          isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                          selectedIndex = index;
                        });
                        menuModel.onPressed!.call();
                      },
                      text: menuModel.title,
                      iconData: menuModel.icon,
                      iconColor: MyColors.mainColor,
                      iconHoverColor: MyColors.primaryText,
                      onEnter: () {},
                      onExit: () {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget controlTile() {
    // return Padding(
    //   padding: const EdgeInsets.only(top: 15, left: 15),
    //   child: HoverButton.withIconWidget(
    //       hoverSize: 32,
    //       width: 45,
    //       height: 45,
    //       onPressed: () {
    //         expandOrShrinkDrawer.call();
    //       },
    //       text: "Widgets",
    //       iconWidget: logoIcon2(size: 40),
    //       onEnter: () {},
    //       onExit: () {}),
    // );

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        children: [
          IconButton(
            icon: logoIcon2(size: 60),
            padding: const EdgeInsets.all(0),
            onPressed: expandOrShrinkDrawer,
          ),
          Text("Widgets", style: MyTextStyles.body1)
        ],
      ),
    );
  }

  Widget blackIconMenu() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: narrowWidth,
      color: MyColors.complexDrawerBlack,
      child: Column(
        children: [
          controlButton(), // 최상단 버튼,
          Expanded(
            child: ListView.builder(
                itemCount: menuModelList.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: HoverButton.withIconData(
                        hoverSize: 32,
                        width: 45,
                        height: 45,
                        onPressed: () {
                          setState(() {
                            isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                            selectedIndex = index;
                          });
                          menuModelList[index].onPressed!.call();
                        },
                        iconData: menuModelList[index].icon,
                        iconColor: MyColors.mainColor,
                        iconHoverColor: MyColors.primaryText,
                        onEnter: () {},
                        onExit: () {}),
                  );

                  // return InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                  //       selectedIndex = index;
                  //     });
                  //   },
                  //   child: Container(
                  //     height: 45,
                  //     alignment: Alignment.center,
                  //     child:
                  //         Icon(menuModelList[index].icon, color: MyColors.primaryText),
                  //   ),
                  // );
                }),
          ),
        ],
      ),
    );
  }

  Widget invisibleSubMenus() {
    // List<MenuModel> _cmds = menuModelList..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : subWidth,
      color: Colors.transparent, //MyColors.compexDrawerCanvasColor,
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: menuModelList.length,
                itemBuilder: (context, index) {
                  MenuModel cmd = menuModelList[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  bool selected = selectedIndex == index;
                  bool isValidSubMenu = selected && cmd.submenus.isNotEmpty;
                  return subMenuWidget([cmd.title, ...cmd.submenus], isValidSubMenu);
                }),
          ),
        ],
      ),
    );
  }

  Widget controlButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: logoIcon2(size: 60),
          //FlutterLogo(size: 40,),
        ),
      ),
    );
  }

  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 37.5 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isValidSubMenu ? MyColors.complexDrawerBlueGrey : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: isValidSubMenu ? submenus.length : 0,
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return sMenuButton(subMenu, index == 0);
          }),
    );
  }

  Widget sMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () {
        //handle the function
        //if index==0? donothing: doyourlogic here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Txt(
          text: subMenu,
          fontSize: isTitle ? 17 : 14,
          color: isTitle ? MyColors.primaryText : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void framePressed() {
    logHolder.log('frame Pressed');
    const uuid = Uuid();
    GlobalObjectKey<BaseWidgetState> baseWidgetKey = GlobalObjectKey<BaseWidgetState>(uuid.v1());
    accManagerHolder!.createACC(_keyIdx, context, BaseWidget(baseWidgetKey: baseWidgetKey),
        pageManagerHolder!.getSelected()!);
    _keyIdx++;
  }

  void textPressed() {
    //simpleDialog(context, "Notice", "Not Yet Implemented", MyColors.white);
    logHolder.log('text Pressed');
  }

  void effectPressed() {
    logHolder.log('effect Pressed');
  }

  void badgePressed() {
    logHolder.log('badge Pressed');
  }

  void cameraPressed() {
    logHolder.log('camera Pressed');
  }

  void weatherPressed() {
    logHolder.log('weather Pressed');
  }

  void clockPressed() {
    logHolder.log('clock Pressed');
  }

  void musicPressed() {
    logHolder.log('music Pressed');
  }

  void newsPressed() {
    logHolder.log('news Pressed');
  }

  void brushPressed() {
    logHolder.log('brush Pressed');
  }
}
