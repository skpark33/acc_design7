import 'package:flutter/material.dart';
import 'package:acc_design7/model/contents.dart';
import 'package:acc_design7/common/util/logger.dart';
import 'package:acc_design7/common/util/my_utils.dart';
//import 'package:acc_design7/constants/styles.dart';
import 'package:acc_design7/common/buttons/hover_buttons.dart';
import 'package:acc_design7/player/play_manager.dart';
import 'acc_manager.dart';
import 'acc.dart';

class ACCMenu {
  ContentsType _type = ContentsType.free;
  void setType(ContentsType t) {
    _type = t;
  }

  Offset position = const Offset(0, 0);
  Size size = const Size(210, 40);
  bool _visible = false;
  bool get visible => _visible;
  OverlayEntry? entry;
  int accIndex = -1;

  double buttonWidth = 30.0;
  double buttonHeight = 30.0;

  void setState() {
    entry!.markNeedsBuild();
  }

  void unshow(BuildContext context) {
    if (_visible == true) {
      accIndex = -1;
      _visible = false;
      if (entry != null) {
        entry!.remove();
        entry = null;
        //setState();
      }
    }
  }

  Widget show(BuildContext context, ACC? acc) {
    logHolder.log('ACCMenu show');

    Widget? overlayWidget;
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
    _visible = true;
    entry = OverlayEntry(builder: (context) {
      if (acc != null) {
        accIndex = acc.index;
      }
      overlayWidget = showOverlay(context, acc);
      return overlayWidget!;
    });
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);

    if (overlayWidget != null) {
      return overlayWidget!;
    }
    return Container(color: Colors.red);
  }

  String getOrder() {
    ACC? acc = accManagerHolder!.getCurrentACC();
    if (acc != null) {
      return '[${acc.order.value}]';
    }
    return '[]';
  }

  Widget showOverlay(BuildContext context, ACC? acc) {
    // double radiusTopRight = 10; // menu 는 10 정도의 round 값으로 고정한다.
    // double radiusTopLeft = 10;
    // double radiusBottomRight = 10;
    // double radiusBottomLeft = 10;

    return Visibility(
      visible: _visible,
      child: Positioned(
        left: position.dx,
        top: position.dy,
        height: size.height,
        width: size.width,
        //child:
        child: glassMorphic(
          radius: 10,
          isGlass: true,
          child: Material(
            type: MaterialType.card,
            color: Colors.white.withOpacity(.5),
            //child: Container(
            //color: Colors.white.withOpacity(.5),
            //padding: const EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.5),
            // ),
            //decoBox(false, radiusTopLeft, radiusTopRight,radiusBottomLeft, radiusBottomRight),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      HoverButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          onEnter: onEnter,
                          onExit: onExit,
                          onPressed: () {
                            accManagerHolder!.up(context);
                          },
                          icon: const Icon(Icons.flip_to_front)),
                      HoverButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          onEnter: onEnter,
                          onExit: onExit,
                          onPressed: () {
                            accManagerHolder!.down(context);
                          },
                          icon: const Icon(Icons.flip_to_back)),
                      HoverButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          onEnter: () {},
                          onExit: () {},
                          onPressed: () {
                            accManagerHolder!.setPrimary();
                            accManagerHolder!.notify();
                            setState();
                            logHolder.log(
                                'primary=${accManagerHolder!.isPrimary()}');
                          },
                          icon: Icon(Icons.star,
                              color: accManagerHolder!.isPrimary()
                                  ? Colors.red
                                  : Colors.black)),
                      HoverButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          onEnter: () {},
                          onExit: () {},
                          onPressed: () {
                            accManagerHolder!.remove(context);
                          },
                          icon: const Icon(Icons.delete)),
                      HoverButton(
                        width: buttonWidth,
                        height: buttonHeight,
                        onEnter: () {},
                        onExit: () {},
                        onPressed: () {
                          accManagerHolder!.toggleFullscreen(context);
                        },
                        icon: Icon(accManagerHolder!.isFullscreen()
                            ? Icons.fullscreen_exit_outlined
                            : Icons.fullscreen), // fullscreen_exit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  menuByContentType(context, acc),
                ]),
          ),
          //),
        ),
      ),
    );
  }

  void onEnter() {
    accManagerHolder!.setACCOrderVisible(true);
  }

  void onExit() {
    accManagerHolder!.setACCOrderVisible(false);
  }

  Widget menuByContentType(BuildContext context, ACC? acc) {
    return FutureBuilder(
        future: acc!.accChild.playManager!.getCurrentData(),
        builder: (BuildContext context, AsyncSnapshot<CurrentData> snapshot) {
          if (snapshot.hasData == false) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            return emptyImage();
          }
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            return errMsgWidget(snapshot);
          }
          if (_type == ContentsType.video ||
              snapshot.data!.type == ContentsType.video) {
            return videoMenu(
                context, snapshot.data!.state, snapshot.data!.mute);
          } else if (_type == ContentsType.image ||
              snapshot.data!.type == ContentsType.image) {
            return imageMenu(
                context, snapshot.data!.state, snapshot.data!.mute);
          }
          return Container();
        });
  }

  Widget videoMenu(BuildContext context, PlayState state, bool mute) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.prev(context);
            },
            icon: const Icon(Icons.skip_previous)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.next(context);
            },
            icon: const Icon(Icons.skip_next)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              if (state != PlayState.pause) {
                accManagerHolder!.pause(context);
              } else {
                accManagerHolder!.play(context);
              }
              setState();
            },
            icon: Icon(
                state != PlayState.pause ? Icons.pause : Icons.play_arrow)),
        //icon: const Icon(Icons.pause)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.mute(context);
              setState();
            },
            icon: Icon(mute ? Icons.volume_off : Icons.volume_up)),
      ],
    );
  }

  Widget imageMenu(BuildContext context, PlayState state, bool mute) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.prev(context);
            },
            icon: const Icon(Icons.skip_previous)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.next(context);
            },
            icon: const Icon(Icons.skip_next)),
      ],
    );
  }
}
