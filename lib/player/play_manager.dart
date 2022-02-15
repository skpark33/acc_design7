import 'dart:async';

//import 'package:acc_design7/acc/acc_property.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';
//import 'package:uuid/uuid.dart';

import 'package:acc_design7/common/util/logger.dart';
//import 'package:acc_design7/common/util/my_utils.dart';
import 'package:acc_design7/player/abs_player.dart';
import 'package:acc_design7/acc/acc.dart';
import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/player/video/video_player_widget.dart';
import 'package:acc_design7/player/image/image_player_widget.dart';
import 'package:acc_design7/common/undo/undo.dart';
import 'package:acc_design7/model/contents.dart';
//import 'package:acc_design7/acc/acc_manager.dart';
import 'package:acc_design7/widgets/base_widget.dart';

class CurrentData {
  ContentsType type = ContentsType.free;
  PlayState state = PlayState.none;
  bool mute = false;
}

class PlayManager {
  PlayManager(this.baseWidget);

  BaseWidget baseWidget;
  UndoAbleList<AbsPlayWidget> playList = UndoAbleList([]);
  int _currentIndex = -1;
  final Lock _lock = Lock();
  double _currentPlaySec = 0.0;
  Timer? _timer;
  final int _timeGap = 100; // 0.

  int get currentIndex {
    return _currentIndex;
  }

  bool isValid() {
    return currentIndex >= 0 && playList.value.isNotEmpty;
  }

  Future<AbsPlayWidget> waitBuild() async {
    // const uuid = Uuid();
    // GlobalObjectKey<EmptyPlayWidgetState> key =
    //     GlobalObjectKey<EmptyPlayWidgetState>(uuid.v4());
    //AbsPlayWidget retval = EmptyPlayWidget(key: key, acc: baseWidget.acc!);
    AbsPlayWidget? retval;
    bool isReady = false;
    while (!isReady) {
      await _lock.synchronized(() async {
        if (_currentIndex >= 0 && _currentIndex < playList.value.length) {
          if (playList.value[_currentIndex].isInit()) {
            isReady = true;
            return;
          }
        }
        return;
      });
      if (isReady) {
        retval = playList.value[_currentIndex];
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return retval!;
  }

  Lock getLock() {
    return _lock;
  }

  void initTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _timeGap), _timerExpired);
  }

  void clear() {
    playList.value.clear();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Future<CurrentData> getCurrentData() async {
    CurrentData current = CurrentData();
    current.type = await getCurrentContentsType();
    current.state = await getCurrentPlayState();
    current.mute = await getCurrentMute();
    return current;
  }

  Future<ContentsType> getCurrentContentsType() async {
    ContentsType type = ContentsType.free;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < playList.value.length) {
        type = playList.value[_currentIndex].model!.type;
      }
    });
    return type;
  }

  Future<PlayState> getCurrentPlayState() async {
    PlayState state = PlayState.none;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < playList.value.length) {
        state = playList.value[_currentIndex].model!.state;
      }
    });
    return state;
  }

  Future<bool> getCurrentMute() async {
    bool mute = false;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < playList.value.length) {
        mute = playList.value[_currentIndex].model!.mute;
      }
    });
    return mute;
  }

  Future<void> _timerExpired(Timer timer) async {
    ContentsModel? currentModel;
    await _lock.synchronized(() async {
      if (playList.value.isEmpty) return;

      // 아무것도 돌고 있지 않다면,
      if (_currentIndex < 0) {
        _currentIndex = 0;
        return;
      }

      if (false == playList.value[_currentIndex].isInit()) {
        logHolder.log('Not yet inited');
        return;
      }

      currentModel = playList.value[_currentIndex].getModel();
      if (currentModel!.isImage()) {
        // 아직 교체시간이 되지 않았다.
        if (_currentPlaySec < currentModel!.playTime) {
          _currentPlaySec += _timeGap;
          return;
        }
        // 교체 시간이 되었다.
        next();
        //_currentPlaySec = 0;
        //baseWidget.invalidate();
        //accManagerHolder!.resizeMenu(currentModel!.type);
        return;
      }
      if (currentModel!.isVideo()) {
        if (currentModel!.state == PlayState.end) {
          next();
          // 비디오가 마무리 작업을 할 시간을 준다.
          Future.delayed(Duration(milliseconds: (_timeGap / 4).round()));
          //_currentPlaySec = 0;
          //baseWidget.invalidate();
          //accManagerHolder!.resizeMenu(currentModel!.type);
        }
        return;
      }
    });
  }

  Future<void> push(ACC acc, ContentsModel model) async {
    await _lock.synchronized(() async {
      AbsPlayWidget? aWidget;
      if (model.isVideo()) {
        logHolder.log('push video');
        GlobalObjectKey<VideoPlayerWidgetState> key =
            GlobalObjectKey<VideoPlayerWidgetState>(model.key);
        aWidget = VideoPlayerWidget(
          key: key,
          onAfterEvent: onVideoAfterEvent,
          model: model,
          acc: acc,
          autoStart: true, // (_currentIndex < 0) ? true : false,
        );
        await aWidget.init();
        if (_currentIndex < 0) _currentIndex = 0;
      } else if (model.isImage()) {
        GlobalObjectKey<ImagePlayerWidgetState> key =
            GlobalObjectKey<ImagePlayerWidgetState>(model.key);
        aWidget = ImagePlayerWidget(
          key: key,
          model: model,
          acc: acc,
          autoStart: true, // (_currentIndex < 0) ? true : false,
        );
        await aWidget.init();
        if (_currentIndex < 0) _currentIndex = 0;
      } else {
        logHolder.log('Invalid Contents Type error');
        return;
      }
      playList.value.add(aWidget);
      logHolder.log('push(${model.key})=${playList.value.length}');
    });
  }

  void onVideoAfterEvent() {
    // 타이머에서 처리하므로 여기서는 아무것도 하지 않는다.
    // if (playList.value.isEmpty) return;
    // // 아무것도 돌고 있지 않다면,
    // if (_currentIndex < 0) {
    //   _currentIndex = 0;
    //   return;
    // }
    // // if (false == playList.value[_currentIndex].isInit()) {
    // //   logHolder.log('Not yet inited ($_currentIndex)');
    // //   return;
    // // }
    // next();
    return;
  }

  void onImageAfterEvent() {
    if (playList.value.isEmpty) return;
    // 아무것도 돌고 있지 않다면,
    if (_currentIndex < 0) {
      _currentIndex = 0;
      return;
    }
    // if (false == playList.value[_currentIndex].isInit()) {
    //   logHolder.log('Not yet inited');
    //   return;
    // }
    next();
    return;
  }

  Future<void> remove(int i) async {
    await _lock.synchronized(() async {
      if (playList.value.isNotEmpty) {
        if (i < playList.value.length && i >= 0) {
          playList.value[i].close();
          playList.value.removeAt(i);
        }
      }
    });
  }

  Future<void> removeCurrent() async {
    await _lock.synchronized(() async {
      if (playList.value.isNotEmpty && _currentIndex >= 0) {
        remove(_currentIndex);
      }
    });
  }

  Future<void> removeByModel(ContentsModel model) async {
    await _lock.synchronized(() async {
      int len = playList.value.length;
      for (int i = 0; i < len; i++) {
        ContentsModel ele = playList.value[i].getModel();
        if (model.key == ele.key) {
          remove(i);
          return;
        }
      }
    });
  }

  Future<void> play() async {
    await _lock.synchronized(() async {
      if (playList.value.isNotEmpty) {
        if (_currentIndex >= 0) {
          await playList.value[_currentIndex].play();
        }
      }
    });
  }

  Future<void> next() async {
    await _lock.synchronized(() async {
      if (playList.value.isNotEmpty) {
        int prevIndex = _currentIndex;
        if (_currentIndex >= 0) {
          //logHolder.log('pause($_currentIndex)--');
          //await playList.value[_currentIndex].pause();
        }
        _currentIndex++;
        if (_currentIndex >= playList.value.length) {
          _currentIndex = 0;
        }
        //logHolder.log('play($_currentIndex)--');
        _currentPlaySec = 0;

        if (!baseWidget.isAnime()) {
          //await playList.value[_currentIndex].play();
        }
        if (/*doInvalidate || */ prevIndex != _currentIndex) {
          baseWidget.invalidate();
        } else {
          await playList.value[_currentIndex].play();
        }
        accManagerHolder!.resizeMenu(playList.value[_currentIndex].model!.type);
      }
    });
  }

  Future<void> prev() async {
    await _lock.synchronized(() async {
      if (playList.value.isNotEmpty) {
        int prevIndex = _currentIndex;
        if (_currentIndex >= 0) {
          // logHolder.log('pause($_currentIndex)');
          // await playList.value[_currentIndex].pause();
        }
        _currentIndex--;
        if (_currentIndex < 0) {
          _currentIndex = playList.value.length - 1;
        }
//        logHolder.log('play($_currentIndex)');
        _currentPlaySec = 0;

        if (!baseWidget.isAnime()) {
          //await playList.value[_currentIndex].play();
        }
        if (/*doInvalidate || */ prevIndex != _currentIndex) {
          baseWidget.invalidate();
        } else {
          await playList.value[_currentIndex].play();
        }
        accManagerHolder!.resizeMenu(playList.value[_currentIndex].model!.type);
      }
    });
  }

  Future<void> mute() async {
    await _lock.synchronized(() async {
      playList.value[_currentIndex].mute();
    });
  }

  Future<void> pause() async {
    await _lock.synchronized(() async {
      playList.value[_currentIndex].pause();
    });
  }

  Future<void> invalidate() async {
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < playList.value.length) {
        if (playList.value[_currentIndex].isInit()) {
          playList.value[_currentIndex].invalidate();
        }
      }
    });
  }
}
