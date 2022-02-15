import 'dart:core';
import 'dart:collection';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
import '../util/logger.dart';

enum TransState {
  none,
  start,
  ing,
  end,
}

MyChangeStack mychangeStack = MyChangeStack();

class UndoAble<T> {
  late T _value;

  UndoAble(T val) {
    _value = val;
  }

  T get value => _value;

  void set(T val) {
    MyChange<T> c = MyChange<T>(_value, () {
      _value = val;
    }, (T old) {
      _value = old;
    });
    mychangeStack.add(c);
  }

  // this function doesn't support undo
  void init(T val) {
    _value = val;
  }
}

// class UndoMonitorAble<T> extends UndoAble<T> {
//   UndoMonitorAble(T val) : super(val);

//   @override
//   void set(T val) {
//     MyChange<T> c = MyChange<T>(_value, () {
//       _value = val;
//     }, (T old) {
//       _value = old;
//     });
//     c.monitored = true;
//     mychangeStack.add(c);
//   }
// }

class UndoAbleList<T> {
  late List<T> _value;

  UndoAbleList(List<T> val) {
    _value = val;
  }

  List<T> get value => _value;

  void set(List<T> val) {
    MyChange<List<T>> c = MyChange<List<T>>(_value, () {
      _value = val;
    }, (List<T> old) {
      _value = old;
    });
    mychangeStack.add(c);
  }

  void add(T val) {
    MyChange<List<T>> c = MyChange<List<T>>(_value, () {
      _value.add(val);
    }, (List<T> old) {
      _value.remove(val);
    });
    mychangeStack.add(c);
  }

  void remove(T val) {
    MyChange<List<T>> c = MyChange<List<T>>(_value, () {
      _value.remove(val);
    }, (List<T> old) {
      _value.add(val);
    });
    mychangeStack.add(c);
  }

  T removeAt(int index) {
    T? retval;
    MyChange<List<T>> c = MyChange<List<T>>(_value, () {
      retval = _value.removeAt(index);
    }, (List<T> old) {
      _value = List.from(old);
    });
    mychangeStack.add(c);
    return retval!;
  }

  void insert(int index, T val) {
    MyChange<List<T>> c = MyChange<List<T>>(_value, () {
      _value.insert(index, val);
    }, (List<T> old) {
      _value = List.from(old);
    });
    mychangeStack.add(c);
  }
}

class UndoAbleMap<String, T> {
  late Map<String, T> _value;

  UndoAbleMap(Map<String, T> val) {
    _value = Map.from(val);
  }

  Map<String, T> get value => _value;

  void set(Map<String, T> val) {
    MyChange<Map<String, T>> c = MyChange<Map<String, T>>(_value, () {
      _value = Map.from(val);
    }, (Map<String, T> old) {
      _value = Map.from(old);
    });
    mychangeStack.add(c);
  }

  void add(String key, T val) {
    MyChange<Map<String, T>> c = MyChange<Map<String, T>>(_value, () {
      _value[key] = val;
    }, (Map<String, T> old) {
      //_value = Map.from(old);
      if (old[key] != null) {
        _value[key] = old[key]!;
      } else {
        _value.remove(key);
      }
    });
    mychangeStack.add(c);
  }

  void remove(String key) {
    MyChange<Map<String, T>> c = MyChange<Map<String, T>>(_value, () {
      _value.remove(key);
    }, (Map<String, T> old) {
      if (old[key] != null) {
        _value[key] = old[key]!;
      }
    });
    mychangeStack.add(c);
  }
}

class MyChangeStack {
  /// Changes to keep track of
  MyChangeStack({this.limit});

  /// Limit changes to store in the history
  int? limit;

  final Queue<MyChange> _history = ListQueue();
  final Queue<MyChange> _redos = ListQueue();

  TransState transState = TransState.none;

  /// Can redo the previous change
  bool get canRedo => _redos.isNotEmpty;

  /// Can undo the previous change
  bool get canUndo => _history.isNotEmpty;

  /// Add New Change and Clear Redo Stack
  void add<T>(MyChange<T> change) {
    change.transState = transState;
    if (transState == TransState.start) {
      transState = TransState.ing;
    }
    change.execute();
    _history.addLast(change);
    _moveForward();
  }

  void _moveForward() {
    _redos.clear();

    if (limit != null && _history.length > limit! + 1) {
      _history.removeFirst();
    }
  }

  /// Add New Group of Changes and Clear Redo Stack
  // void addGroup<T>(List<Change<T>> changes) {
  //   _applyChanges(changes);
  //   _history.addLast(changes);
  //   _moveForward();
  // }

  void _applyChanges(MyChange change) {
    change.execute();
  }

  /// Clear Undo History
  void clear() => clearHistory();

  /// Clear Undo History
  void clearHistory() {
    _history.clear();
    _redos.clear();
  }

  /// Redo Previous Undo
  void redo() {
    while (true) {
      if (canRedo == false) {
        break;
      }
      final change = _redos.removeFirst();
      _applyChanges(change);
      _history.addLast(change);
      if (change.transState == TransState.none ||
          change.transState == TransState.end) {
        break;
      }
    }
  }

  /// Undo Last Change
  void undo() {
    while (true) {
      if (canUndo == false) {
        break;
      }
      final change = _history.removeLast();
      logHolder.log('TransState=${change.transState}');
      change.undo();
      _redos.addFirst(change);
      if (change.transState == TransState.none ||
          change.transState == TransState.start) {
        break;
      }
    }
  }

  void startTrans() {
    transState = TransState.start;
  }

  void endTrans() {
    if (canUndo) {
      if (_history.last.transState != TransState.start) {
        _history.last.transState = TransState.end;
      }
    }
    transState = TransState.none;
  }
}

class MyChange<T> {
  MyChange(
    this._oldValue,
    this._execute(),
    this._undo(T oldValue), {
    this.monitored = false,
    this.transState = TransState.none,
  });

  TransState transState = TransState.none;
  bool monitored = false;

  final void Function() _execute;
  final T _oldValue;

  final void Function(T oldValue) _undo;

  void execute() {
    _execute();
    if (monitored) {}
  }

  void undo() {
    _undo(_oldValue);
    if (monitored) {}
  }
}
