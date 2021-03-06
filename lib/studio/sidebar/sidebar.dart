// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

//import 'bloc.navigation_bloc/navigation_bloc.dart';
import 'menu_item.dart';
import '../../common/util/logger.dart';
import '../../constants/styles.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar> {
  AnimationController? _animationController;
  StreamController<bool>? isSidebarOpenedStreamController;
  Stream<bool>? isSidebarOpenedStream;
  StreamSink<bool>? isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController!.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController!.sink;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    isSidebarOpenedStreamController!.close();
    isSidebarOpenedSink!.close();
    super.dispose();
  }

  void onIconPressed() {
    logHolder.log('onIconPressed');
    final animationStatus = _animationController!.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink!.add(false);
      _animationController!.reverse();
    } else {
      isSidebarOpenedSink!.add(true);
      _animationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //const double screenWidth = 300;

    const double menuWidth = 320;
    const double clipWidth = 24;
    const double clipHeight = 90;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          //width: 400,
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSideBarOpenedAsync.data! ? 0 : -(menuWidth - clipWidth),
          right: isSideBarOpenedAsync.data! ? screenWidth - menuWidth : screenWidth - clipWidth,
          //left: isSideBarOpenedAsync.data! ? 0 : -screenWidth,
          //right: isSideBarOpenedAsync.data! ? 0 : 500,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: MyColors.primaryColor.withOpacity(0.5),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/pilot.PNG',
                        ),
                        radius: 60,
                      ),
                      Text(
                        "skpark",
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "skpark33333@gmail.com",
                        style: MyTextStyles.body1,
                      ),
                      // ListTile(
                      //   title: Text(
                      //     "skpark",
                      //     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      //   ),
                      //   subtitle: Text(
                      //     "skpark33333@gmail.com",
                      //     style: MyTextStyles.body1,
                      //   ),
                      //   leading: CircleAvatar(
                      //     backgroundImage: AssetImage(
                      //       'assets/pilot.png',
                      //     ),
                      //     radius: 50,
                      //   ),
                      // ),
                      Divider(
                        height: 32,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.create_new_folder,
                        title: "???????????????",
                        onTap: () {
                          onIconPressed();
                          //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.homePageClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.folder_open,
                        title: "??????",
                        onTap: () {
                          onIconPressed();
                          //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.myAccountClickedEvent);
                        },
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.last_page,
                        title: "?????? ?????? ??????",
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.paste,
                        title: "?????? ??????????????? ????????????",
                      ),
                      Divider(
                        height: 32,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.save,
                        title: "??????",
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.save_outlined,
                        title: "???????????? ??????",
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.send,
                        title: "????????????",
                      ),
                      Divider(
                        height: 32,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        onTap: () {},
                        icon: Icons.book,
                        title: "???????????? ?????? ??????",
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.999),
                child: GestureDetector(
                  onTap: () {
                    onIconPressed();
                  },
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: clipWidth,
                      height: clipHeight,
                      color: MyColors.primaryColor.withOpacity(0.5),
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        progress: _animationController!.view,
                        icon: AnimatedIcons.menu_close,
                        color: MyColors.secondaryColor,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);

    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width - 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
