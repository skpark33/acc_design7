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
import 'package:acc_design7/studio/pages/page_manager.dart';

class CurrentData {
  ContentsType type = ContentsType.free;
  PlayState state = PlayState.none;
  bool mute = false;
}

SelectedModel? selectedModelHolder;

class SelectedModel extends ChangeNotifier {
  ContentsModel? _model;

  ContentsModel? getModel() {
    return _model;
  }

  void setModel(ContentsModel m) {
    _model = m;
    notifyListeners();
  }
}

class PlayManager {
  PlayManager(this.baseWidget);

  BaseWidget baseWidget;
  final UndoAbleList<AbsPlayWidget> _playList = UndoAbleList([]);
  int _currentIndex = -1;
  final Lock _lock = Lock();
  double _currentPlaySec = 0.0;
  Timer? _timer;
  final int _timeGap = 100; // 0.

  int get currentIndex {
    return _currentIndex;
  }

  bool _shouldChaneAnimePage = false;
  final Lock _animelock = Lock();

  bool isValid() {
    return currentIndex >= 0 && _playList.value.isNotEmpty;
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
        if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
          if (_playList.value[_currentIndex].isInit()) {
            isReady = true;
            return;
          }
        }
        return;
      });
      if (isReady) {
        retval = _playList.value[_currentIndex];
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
    _playList.value.clear();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Future<void> resetCarousel() async {
    await _lock.synchronized(() async {
      if (currentIndex >= 0) {
        int len = _playList.value.length;
        for (int i = 0; i < len; i++) {
          _playList.value[i].autoStart = (i == currentIndex);
        }
      }
    });
  }

  Future<void> setAutoStart() async {
    await _lock.synchronized(() async {
      if (_currentIndex >= 0) {
        _playList.value[_currentIndex].autoStart = true;
      }
    });
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
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        type = _playList.value[_currentIndex].model!.type;
      }
    });
    return type;
  }

  Future<bool> getCurrentDynmicSize() async {
    bool state = false;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        state = _playList.value[_currentIndex].model!.dynamicSize.value;
      }
    });
    return state;
  }

  Future<double> getCurrentAspectRatio() async {
    double aspectRatio = -1;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        aspectRatio = _playList.value[_currentIndex].model!.aspectRatio;
      }
    });
    return aspectRatio;
  }

  Future<void> setCurrentDynmicSize(bool dynamicSize) async {
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        _playList.value[_currentIndex].model!.dynamicSize.set(dynamicSize);
      }
    });
  }

  Future<PlayState> getCurrentPlayState() async {
    PlayState state = PlayState.none;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        state = _playList.value[_currentIndex].model!.state;
      }
    });
    return state;
  }

  Future<bool> getCurrentMute() async {
    bool mute = false;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        mute = _playList.value[_currentIndex].model!.mute;
      }
    });
    return mute;
  }

  Future<bool> getCurrentAutoStart() async {
    bool autoStart = false;
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        autoStart = _playList.value[_currentIndex].autoStart;
      }
    });
    return autoStart;
  }

  Future<void> _timerExpired(Timer timer) async {
    ContentsModel? currentModel;
    await _lock.synchronized(() async {
      if (_playList.value.isEmpty) return;

      // 아무것도 돌고 있지 않다면,
      if (_currentIndex < 0) {
        _currentIndex = 0;
        return;
      }

      if (false == _playList.value[_currentIndex].isInit()) {
        logHolder.log('Not yet inited');
        return;
      }

      currentModel = _playList.value[_currentIndex].getModel();
      if (currentModel!.isImage()) {
        // playTime 이 영구히로 잡혀있다.
        if (0 > currentModel!.playTime.value) {
          return;
        }
        // 아직 교체시간이 되지 않았다.
        if (_currentPlaySec < currentModel!.playTime.value) {
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
        //if (currentModel!.prevState != PlayState.end &&
        //   currentModel!.state == PlayState.end) {
        if (currentModel!.state == PlayState.end) {
          currentModel!.setState(PlayState.none);
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
      _playList.value.add(aWidget);
      if (baseWidget.isAnime()) {
        // 애니타입인 경우, 새로운 데이터를 이해시키기 위해
        baseWidget.invalidate();
      }
      logHolder.log('push(${model.key})=${_playList.value.length}');
      accManagerHolder!.setState();
    });
  }

  void onVideoAfterEvent() {
    // 타이머에서 처리하므로 여기서는 아무것도 하지 않는다.
    // if (_playList.value.isEmpty) return;
    // // 아무것도 돌고 있지 않다면,
    // if (_currentIndex < 0) {
    //   _currentIndex = 0;
    //   return;
    // }
    // // if (false == _playList.value[_currentIndex].isInit()) {
    // //   logHolder.log('Not yet inited ($_currentIndex)');
    // //   return;
    // // }
    // next();
    return;
  }

  void onImageAfterEvent() {
    // if (_playList.value.isEmpty) return;
    // // 아무것도 돌고 있지 않다면,
    // if (_currentIndex < 0) {
    //   _currentIndex = 0;
    //   return;
    // }
    // // if (false == _playList.value[_currentIndex].isInit()) {
    // //   logHolder.log('Not yet inited');
    // //   return;
    // // }
    // next();
    // return;
  }

  Future<void> remove(int i) async {
    await _lock.synchronized(() async {
      if (_playList.value.isNotEmpty) {
        if (i < _playList.value.length && i >= 0) {
          _playList.value[i].close();
          _playList.value.removeAt(i);
        }
      }
    });
  }

  Future<void> removeCurrent() async {
    await _lock.synchronized(() async {
      if (_playList.value.isNotEmpty && _currentIndex >= 0) {
        remove(_currentIndex);
      }
    });
  }

  Future<void> removeByModel(ContentsModel model) async {
    await _lock.synchronized(() async {
      int len = _playList.value.length;
      for (int i = 0; i < len; i++) {
        ContentsModel ele = _playList.value[i].getModel();
        if (model.key == ele.key) {
          remove(i);
          return;
        }
      }
    });
  }

  Future<void> _changeAnimePage() async {
    await _animelock.synchronized(() async {
      _shouldChaneAnimePage = true;
    });
    if (currentIndex >= 0) {
      int len = _playList.value.length;
      for (int i = 0; i < len; i++) {
        if (i == _currentIndex) {
          _playList.value[i].autoStart = true;
          await _playList.value[i].play();
          logHolder.log('anime play ${_playList.value[i].model!.name}', level: 5);
        } else {
          _playList.value[i].autoStart = false;
          await _playList.value[i].pause();
        }
      }
    }
  }

  Future<int> animePageChanger() async {
    int retval = -1;
    await _animelock.synchronized(() async {
      if (_shouldChaneAnimePage) {
        retval = _currentIndex;
        _shouldChaneAnimePage = false;
      }
    });
    return retval;
  }

  Future<void> play() async {
    await _lock.synchronized(() async {
      if (_playList.value.isNotEmpty) {
        if (_currentIndex >= 0) {
          await _playList.value[_currentIndex].play();
        }
      }
    });
  }

  Future<void> next({bool pause = false}) async {
    await _lock.synchronized(() async {
      if (_playList.value.isNotEmpty) {
        int prevIndex = _currentIndex;
        if (_currentIndex >= 0) {
          if (pause) {
            logHolder.log('pause($_currentIndex)');
            await _playList.value[_currentIndex].pause();
          }
        }
        _currentIndex++;
        if (_currentIndex >= _playList.value.length) {
          _currentIndex = 0;
        }
        //logHolder.log('play($_currentIndex)--');
        _currentPlaySec = 0;

        if (!baseWidget.isAnime()) {
          //skpark carousel problem
          if (prevIndex != _currentIndex) {
            baseWidget.invalidate();
          } else {
            await _playList.value[_currentIndex].play();
          }
        } else {
          await _changeAnimePage();
        } // skpark carousel problem
        accManagerHolder!.resizeMenu(_playList.value[_currentIndex].model!.type);
        if (pageManagerHolder!.isContents() &&
            accManagerHolder!.isCurrentIndex(baseWidget.acc!.index)) {
          selectedModelHolder!.setModel(_playList.value[_currentIndex].model!);
        }
      }
    });
  }

  Future<void> prev({bool pause = false}) async {
    await _lock.synchronized(() async {
      if (_playList.value.isNotEmpty) {
        int prevIndex = _currentIndex;
        if (_currentIndex >= 0) {
          if (pause) {
            logHolder.log('pause($_currentIndex)');
            await _playList.value[_currentIndex].pause();
          }
        }
        _currentIndex--;
        if (_currentIndex < 0) {
          _currentIndex = _playList.value.length - 1;
        }
//        logHolder.log('play($_currentIndex)');
        _currentPlaySec = 0;

        if (!baseWidget.isAnime()) {
          //skpark carousel problem
          if (prevIndex != _currentIndex) {
            baseWidget.invalidate();
          } else {
            await _playList.value[_currentIndex].play();
          }
        } else {
          await _changeAnimePage();
        } // skpark carousel problem
        accManagerHolder!.resizeMenu(_playList.value[_currentIndex].model!.type);
      }
    });
  }

  Future<void> mute() async {
    await _lock.synchronized(() async {
      await _playList.value[_currentIndex].mute();
    });
  }

  Future<void> pause() async {
    await _lock.synchronized(() async {
      await _playList.value[_currentIndex].pause();
    });
  }

  Future<void> invalidate() async {
    await _lock.synchronized(() async {
      if (_currentIndex >= 0 && _currentIndex < _playList.value.length) {
        if (_playList.value[_currentIndex].isInit()) {
          _playList.value[_currentIndex].invalidate();
        }
      }
    });
  }

  Future<void> pauseAllExceptCurrent() async {
    await _lock.synchronized(() async {
      int len = _playList.value.length;
      for (int i = 0; i < len; i++) {
        if (i == currentIndex) {
          continue;
        }
        await _playList.value[i].pause();
      }
    });
  }

  bool isValidCarousel() {
    return _playList.value.length >= minCarouselCount;
  }

  bool isNotEmpty() {
    return _playList.value.isNotEmpty;
  }

  bool isEmpty() {
    return _playList.value.isEmpty;
  }

  Future<ContentsModel?> getCurrentModel() async {
    ContentsModel? retval;
    await _lock.synchronized(() async {
      if (currentIndex >= 0) {
        retval = _playList.value[currentIndex].model;
      }
    });
    return retval;
  }

  List<AbsPlayWidget> getPlayWidgetList() {
    return _playList.value;
  }
}
