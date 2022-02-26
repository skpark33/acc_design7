// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_animated_button/flutter_animated_button.dart';

//import '../controllers/menu_controller.dart';
import '../acc/acc_manager.dart';
import '../common/util/logger.dart';
import '../common/buttons/basic_button.dart';
import '../model/users.dart';
//import '../widgets/base_widget.dart';
import '../constants/styles.dart';
import 'sidebar/sidebar.dart';
import '../studio/artboard/artboard_frame.dart';
import '../studio/pages/pages_frame.dart';
import '../studio/pages/page_manager.dart';
import '../studio/properties/properties_frame.dart';
import 'package:acc_design7/player/play_manager.dart';
import '../constants/constants.dart';
//import '../common/cursor/cursor_manager.dart';
//import 'side_menu.dart';

class StudioMainScreen extends StatefulWidget {
  const StudioMainScreen({Key? key, required this.contentsBoookName, required this.user})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String contentsBoookName;
  final UserModel user;

  @override
  State<StudioMainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<StudioMainScreen> {
  List<LogicalKeyboardKey> keys = [];

  bool isPlayed = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

//  MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => Data()),
//         ListenableProvider(create: (context) => Repo()),
//       ],

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<PageManager>(
    //     create: (context) {
    //       pageManagerHolder = PageManager();
    //       return pageManagerHolder!;
    //     },
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ACCManager>(
            create: (context) {
              accManagerHolder = ACCManager();
              logHolder.log("accManagerHolder initiate");
              return accManagerHolder!;
            },
          ),
          ChangeNotifierProvider<PageManager>(
            create: (context) {
              pageManagerHolder = PageManager();
              logHolder.log("pageManagerHolder initiate");
              return pageManagerHolder!;
            },
          ),
          ChangeNotifierProvider<SelectedModel>(
            create: (context) {
              logHolder.log('ChangeNotifierProvider<SelectedModel>', level: 5);
              selectedModelHolder = SelectedModel();
              return selectedModelHolder!;
            },
          ),
        ],
        child: RawKeyboardListener(
            autofocus: true,
            focusNode: FocusNode(),
            onKey: keyEventHandler,
            child: Scaffold(
              //key: context.read<MenuController>().scaffoldKey,
              appBar: buildAppBar(),
              //drawer: const SideMenu(),
              body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                bool isNarrow = (constraints.maxWidth <= minWindowWidth);
                bool isShort =
                    (constraints.maxHeight <= (isNarrow ? minWindowHeight : minWindowHeight / 2));

                return SafeArea(
                  child: Column(children: [
                    Expanded(
                      flex: 9,
                      child: Stack(children: [
                        isNarrow ? narrowLayout(isShort) : wideLayout(isShort),
                        SideBar(),
                      ]),
                    ),
                    logHolder.showLog ? DebugBar(key: logHolder.veiwerKey) : SizedBox(height: 1),
                  ]),
                );
              }),
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     GlobalKey<BaseWidgetState> baseWidgetKey =
              //         GlobalKey<BaseWidgetState>();
              //     accManagerHolder.createACC(
              //         context, BaseWidget(baseWidgetKey: baseWidgetKey));
              //   },
              //   tooltip: 'Create Contents Container',
              //   backgroundColor: MyColors.primaryColor,
              //   child: const Icon(Icons.add),
              // ),
            )));
  }

  Widget wideLayout(bool isShort) {
    if (isShort) {
      return Container();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // We want this side menu only for large screen
        SizedBox(
          width: layoutPageWidth,
          child: PagesFrame(isNarrow: false),
        ),
        Expanded(
          child: ArtBoardScreen(),
        ),
        SizedBox(
          width: layoutPropertiesWidth,
          child: PropertiesFrame(isNarrow: false),
        ),
      ],
    );
  }

  Widget narrowLayout(bool isShort) {
    if (isShort) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // We want this side menu only for large screen
        SizedBox(
          height: 200,
          child: PagesFrame(isNarrow: true),
        ),
        Expanded(
          child: ArtBoardScreen(),
        ),
        SizedBox(
          height: 240,
          child: PropertiesFrame(isNarrow: false),
        ),
      ],
    );
  }

  void keyEventHandler(RawKeyEvent event) {
    final key = event.logicalKey;
    if (event is RawKeyDownEvent) {
      if (keys.contains(key)) return;
      if (event.isKeyPressed(LogicalKeyboardKey.delete)) {
        logHolder.log('delete pressed');
        accManagerHolder!.remove(context);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
        logHolder.log('tab pressed');
        accManagerHolder!.nextACC(context);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.f9)) {
        setState(() {
          logHolder.showLog = !logHolder.showLog;
        });
      }
      keys.add(key);
      // Ctrl Key Area
      if ((keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight))) {
        if (keys.contains(LogicalKeyboardKey.keyZ)) {
          logHolder.log('Ctrl+Z pressed');
          // undo
          accManagerHolder!.undo(null, context);
        } else if (keys.contains(LogicalKeyboardKey.keyY)) {
          logHolder.log('Ctrl+Y pressed');
          // redo
          accManagerHolder!.redo(null, context);
        } else if (keys.contains(LogicalKeyboardKey.keyC)) {
          logHolder.log('Ctrl+C pressed');
          // Copy
        } else if (keys.contains(LogicalKeyboardKey.keyV)) {
          logHolder.log('Ctrl+V pressed');
          // Paste
        }
      }
    } else {
      keys.remove(key);
    }
  }

  PreferredSizeWidget buildAppBar() {
    bool isNarrow = MediaQuery.of(context).size.width <= minWindowWidth;
    return AppBar(
      backgroundColor: MyColors.appbar,
      title: Text(widget.contentsBoookName),
      leadingWidth: isNarrow ? 200 : 400,
      leading: isNarrow ? logoIconButton(onPressed: () {}) : appBarLeading(),
      actions: isNarrow ? [] : appBarAction(),
    );
  }

  Widget appBarLeading() {
    return Row(children: [
      logoIconButton(onPressed: () {}),
      IconButton(
        icon: const Icon(Icons.undo),
        onPressed: () {
          accManagerHolder!.undo(null, context);
          pageManagerHolder!.setState();
        },
      ),
      IconButton(
          onPressed: () {
            accManagerHolder!.redo(null, context);
            pageManagerHolder!.setState();
          },
          icon: const Icon(Icons.redo)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_out)),
      //IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
    ]);
  }

  List<Widget> appBarAction() {
    return [
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(MyColors.primaryColor),
          //foregroundColor: MaterialStateProperty.all(MyColors.critical),
        ),
        onPressed: () {
          setState(() {
            isPlayed = !isPlayed;
          });
        },
        child: Icon(isPlayed ? Icons.pause_presentation : Icons.slideshow),
      ),
      ElevatedButton(
          style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: MaterialStateProperty.all(MyColors.primaryColor)),
          onPressed: () {},
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            ImageIcon(
              AssetImage(
                "assets/Publish.png",
              ),
              size: 20, //MySizes.imageIcon,
              color: MyColors.secondaryColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text('publish'),
          ])),
      ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyColors.primaryColor)),
        onPressed: () {},
        child: const Icon(Icons.settings),
      ),
      // ElevatedButton(
      //     style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyColors.primaryColor)),
      //     onPressed: () {},
      //     child: Row(children: [
      //       const Icon(Icons.account_circle),
      //       const SizedBox(
      //         width: 20,
      //       ),
      //       Text(widget.user.id),
      //       IconButton(onPressed: () {}, icon: const Icon(Icons.expand_more))
      //     ])),
    ];
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return true;
  }
}
